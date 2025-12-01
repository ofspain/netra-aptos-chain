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
            milestones_by_dispute: table::new<vector<u8>, vector<u64>>(),
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



public entry fun log_milestone(
    admin: &signer,
    actor_id: vector<u8>,
    dispute_id: vector<u8>,
    milestone_type: u8,
    metadata_hash: vector<u8>,
    rule_hash: vector<u8>
) acquires dispute_types::DisputeStore, dispute_events::DisputeEventStore {
    let admin_addr = signer::address_of(admin);

    //
    // 0. SAFETY CHECKS — ensure system initialized
    //
    assert!(
        exists<dispute_types::DisputeStore>(admin_addr),
        dispute_errors::enot_published()
    );
    assert!(
        exists<dispute_events::DisputeEventStore>(admin_addr),
        dispute_errors::enot_published()
    );

    let store = borrow_global_mut<dispute_types::DisputeStore>(admin_addr);
    let event_store = borrow_global_mut<dispute_events::DisputeEventStore>(admin_addr);

    //
    // 1. PREPARE CLONES BEFORE VALUE CONSUMPTION
    //
    //    - One clone for indexing table
    //    - One clone for event emission
    //
    let dispute_id_for_index = copy_vector(&dispute_id);
    let dispute_id_for_event = copy_vector(&dispute_id);

    let metadata_hash_for_event = copy_vector(&metadata_hash);
    let rule_hash_for_event = copy_vector(&rule_hash);
    let actor_id_for_event = copy_vector(&actor_id);

    //
    // 2. BUILD THE MILESTONE STRUCT (consumes the original vectors)
    //
    let milestone = dispute_types::DisputeMilestone {
        dispute_id,          // consumed
        milestone_type,
        metadata_hash,       // consumed
        timestamp: timestamp::now_seconds(),
        actor_id,            // consumed
        rule_hash,           // consumed
    };

    //
    // 3. ASSIGN UNIQUE AUTO-INCREMENT ID
    //
    let milestone_id = store.next_id;
    store.next_id = milestone_id + 1;
   // store.milestones_by_dispute

    //
    // 4. INSERT MILESTONE INTO MAIN TABLE
    //
    table::add(&mut store.milestones, milestone_id, milestone);

    //
    // 5. UPDATE SECONDARY INDEX: milestones_by_dispute
    //
    let list_ref = if (
        table::contains(&store.milestones_by_dispute, dispute_id_for_index)
    ) {
        // dispute already has milestones → borrow existing vector
        table::borrow_mut(&mut store.milestones_by_dispute, dispute_id_for_index)
    } else {
        // first milestone for this dispute → create new vector
        let empty_vec = vector::empty<u64>();
        table::add(&mut store.milestones_by_dispute, dispute_id_for_index, empty_vec);
        table::borrow_mut(&mut store.milestones_by_dispute, dispute_id_for_index)
    };

    // Add milestone ID to index
    vector::push_back(list_ref, milestone_id);

    //
    // 6. UPDATE NEW DISPUTE COUNT IF INITIALIZED
    //
    if (milestone_type == dispute_constants::milestone_initiated()) {
        store.total_disputes = store.total_disputes + 1;
    };

    //
    // 7. EMIT EVENT
    //
    event::emit_event(
        &mut event_store.milestone_events,
        dispute_events::MilestoneLoggedEvent {
            dispute_id: dispute_id_for_event,
            milestone_type,
            metadata_hash: metadata_hash_for_event,
            rule_hash: rule_hash_for_event,
            timestamp: timestamp::now_seconds(),
            actor_id: actor_id_for_event,
            milestone_id,
        }
    );
}



    
    // /// Log a new milestone for a dispute
    // public entry fun log_milestone(
    //     admin: &signer,
    //     actor_id: vector<u8>,
    //     dispute_id: vector<u8>,
    //     milestone_type: u8,
    //     metadata_hash: vector<u8>,
    //     rule_hash: vector<u8>
    // ) acquires dispute_types::DisputeStore, dispute_events::DisputeEventStore {
    //      let admin_addr = signer::address_of(admin);
        
    //     // Verify system is initialized
    //     assert!(exists<dispute_types::DisputeStore>(admin_addr), dispute_errors::enot_published());
    //     assert!(exists<dispute_events::DisputeEventStore>(admin_addr), dispute_errors::enot_published());
        
    //     let store = borrow_global_mut<dispute_types::DisputeStore>(admin_addr);
    //     let event_store = borrow_global_mut<dispute_events::DisputeEventStore>(admin_addr);
        
    //     // Create milestone
    //     let milestone = dispute_types::DisputeMilestone {
    //         dispute_id,
    //         milestone_type,
    //         metadata_hash,
    //         timestamp: timestamp::now_seconds(),
    //         actor_id,
    //         rule_hash,
    //     };
        
    //     // Store milestone with auto-increment ID
    //     let milestone_id = store.next_id;
    //     table::add(&mut store.milestones, milestone_id, milestone);
    //     store.next_id = milestone_id + 1;
        
    //     // Update dispute count if this is a new dispute initiation
    //     if (milestone_type == dispute_constants::milestone_initiated()) {
    //         store.total_disputes = store.total_disputes + 1;
    //     };
        
    //     // Emit event
    //     event::emit_event(
    //         &mut event_store.milestone_events,
    //         dispute_events::MilestoneLoggedEvent {
    //             dispute_id: vector::empty(), // Already consumed, use empty or clone earlier if needed
    //             milestone_type,
    //             metadata_hash: vector::empty(), // Already consumed
    //             rule_hash: vector::empty(), // Already consumed
    //             timestamp: timestamp::now_seconds(),
    //             actor_id: actor_id,
    //             milestone_id,
    //         }
    //     );
    // }
    
    /// Check if system is initialized for an address
    public fun is_initialized(addr: address): bool {
        exists<dispute_types::DisputeStore>(addr) && exists<dispute_events::DisputeEventStore>(addr)
    }

    /// Utility function to create an independent copy of a vector<u8>.
    public fun copy_vector(source: &vector<u8>): vector<u8> {
        let len = vector::length(source);
        let i = 0;
        let copied = vector::empty<u8>();
    
        // Manually copy each byte
        while (i < len) {
            let byte = *vector::borrow(source, i);
            vector::push_back(&mut copied, byte);
            i = i + 1;
        };
        copied
    }
}