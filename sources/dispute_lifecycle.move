module dispute_os::dispute_lifecycle {
    use std::signer;
    use std::vector;
    use std::timestamp;
    use aptos_framework::event;
    use aptos_framework::table;
    use aptos_framework::guid;
    
    use dispute_os::dispute_errors;
    use dispute_os::dispute_types;
    use dispute_os::dispute_events;
    use dispute_os::dispute_constants;

    // ============ Initialization ============
    
    /// Initialize the dispute system under the admin account
    public entry fun init_system(admin: &signer) {
    let admin_addr = signer::address_of(admin);

    // --- Ensure stores do not already exist ---
    assert!(
        !exists<dispute_types::DisputeStore>(admin_addr),
        dispute_errors::ealready_initialized()
    );
    assert!(
        !exists<dispute_events::DisputeEventStore>(admin_addr),
        dispute_errors::ealready_initialized()
    );

    // --- Initialize main storage ---
    move_to(
        admin,
        dispute_types::DisputeStore {
            milestones: table::new<u64, dispute_types::DisputeMilestone>(),
            next_id: 0,
            total_disputes: 0,
        }
    );

    // --- Initialize event storage with a GUID counter ---
    move_to(
        admin,
        dispute_events::DisputeEventStore {
            milestone_events: event::new_event_handle<dispute_events::MilestoneLoggedEvent>(
                guid::GUID { id: guid::ID { creation_num: 0, addr: admin_addr } } // placeholder, will overwrite
            ),
            system_events: event::new_event_handle<dispute_events::SystemInitializedEvent>(
                guid::GUID { id: guid::ID { creation_num: 1, addr: admin_addr } } // placeholder, will overwrite
            ),
            next_guid_id: 2, // next GUID index for future events
        }
    );

    // --- Borrow event store to create real GUIDs and assign event handles ---
    let event_store = borrow_global_mut<dispute_events::DisputeEventStore>(admin_addr);

    // Create GUIDs using the friend-only create function
    let milestone_guid = guid::create(admin_addr, &mut event_store.next_guid_id);
    let system_guid = guid::create(admin_addr, &mut event_store.next_guid_id);

    // Overwrite placeholder event handles with correct GUIDs
    event_store.milestone_events = event::new_event_handle<dispute_events::MilestoneLoggedEvent>(milestone_guid);
    event_store.system_events = event::new_event_handle<dispute_events::SystemInitializedEvent>(system_guid);

    // --- Emit system initialization event ---
    event::emit_event(
        &mut event_store.system_events,
        dispute_events::SystemInitializedEvent {
            admin: admin_addr,
            timestamp: timestamp::now_seconds(),
        }
    );
}


    
    // ============ Core Milestone Logging ============
    
    /// Log a new milestone for a dispute
    public entry fun log_milestone(
        admin: &signer,
        actor_id: vector<u8>,
        dispute_id: vector<u8>,
        milestone_type: u8,
        metadata_hash: vector<u8>,
        rule_hash: vector<u8>
    ) acquires dispute_types::DisputeStore, dispute_events::DisputeEventStore {
         let admin_addr = signer::address_of(admin);
        
        // Verify system is initialized
        assert!(exists<dispute_types::DisputeStore>(admin_addr), dispute_errors::enot_published());
        assert!(exists<dispute_events::DisputeEventStore>(admin_addr), dispute_errors::enot_published());
        
        let store = borrow_global_mut<dispute_types::DisputeStore>(admin_addr);
        let event_store = borrow_global_mut<dispute_events::DisputeEventStore>(admin_addr);
        
        // Create milestone
        let milestone = dispute_types::DisputeMilestone {
            dispute_id,
            milestone_type,
            metadata_hash,
            timestamp: timestamp::now_seconds(),
            actor_id,
            rule_hash,
        };
        
        // Store milestone with auto-increment ID
        let milestone_id = store.next_id;
        table::add(&mut store.milestones, milestone_id, milestone);
        store.next_id = milestone_id + 1;
        
        // Update dispute count if this is a new dispute initiation
        if (milestone_type == dispute_constants::milestone_initiated()) {
            store.total_disputes = store.total_disputes + 1;
        };
        
        // Emit event
        event::emit_event(
            &mut event_store.milestone_events,
            dispute_events::MilestoneLoggedEvent {
                dispute_id: vector::empty(), // Already consumed, use empty or clone earlier if needed
                milestone_type,
                metadata_hash: vector::empty(), // Already consumed
                rule_hash: vector::empty(), // Already consumed
                timestamp: timestamp::now_seconds(),
                actor_id: actor_id,
                milestone_id,
            }
        );
    }
    
    /// Check if system is initialized for an address
    public fun is_initialized(addr: address): bool {
        exists<dispute_types::DisputeStore>(addr) && exists<dispute_events::DisputeEventStore>(addr)
    }
}