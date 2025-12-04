module dispute_os::dispute_events {
    use std::vector;
    use aptos_framework::event;
    use std::signer;
    use aptos_framework::account;
        use std::timestamp;
    
    use dispute_os::dispute_errors;
    use dispute_os::dispute_constants;

    // Event emitted when system is initialized
    struct SystemInitializedEvent has drop, store {
        admin: address,
        timestamp: u64,
    }

    // Event emitted when system is initialized
    struct DisputeMilestoneLoggedEvent has drop, store {
        dispute_id: vector<u8>,
        milestone_type: u8,
        timestamp: u64,
    }
    
    // Event handle container
    struct DisputeEventStore has key {
        milestone_events: event::EventHandle<DisputeMilestoneLoggedEvent>,
        system_events: event::EventHandle<SystemInitializedEvent>,
        milestone_events_counter: u64
    }

    public fun init_disputeEvent_store(admin: &signer) {
        let admin_addr = signer::address_of(admin);
        assert!(
            !exists<DisputeEventStore>(admin_addr),
            dispute_errors::ealready_initialized()
        );

      //  let milestone_event_guid = account::create_guid(admin);
      //  let system_event_guid = account::create_guid(admin);

        // --- Initialize event storage with a GUID counter ---
        move_to(
            admin,
            DisputeEventStore {
                milestone_events: account::new_event_handle<DisputeMilestoneLoggedEvent>(
                    admin
                ),
                system_events: account::new_event_handle<SystemInitializedEvent>(
                    admin
                ),
                milestone_events_counter: 0
            }
        );
    }

    
    /// Check if system is initialized for an address
    public fun is_event_store_initialized(addr: address): bool {
       exists<DisputeEventStore>(addr)
    }

    /// Emits a `MilestoneLoggedEvent` to the milestone_events stream
    public fun emit_milestone_event(
        admin_addr: address,
        dispute_id: vector<u8>,
        milestone_type: u8 
    ) acquires DisputeEventStore {
        // Borrow the resource mutably
        let store = borrow_global_mut<DisputeEventStore>(admin_addr);
        let milestone_logged_event = DisputeMilestoneLoggedEvent{
            dispute_id: dispute_id,
            milestone_type: milestone_type,
            timestamp: timestamp::now_seconds(),
        };


        // Emit the event using the event handle
        event::emit_event(
            &mut store.milestone_events,
            milestone_logged_event 
        );

        store.milestone_events_counter = store.milestone_events_counter + 1;
    }
    
    // Emits a `SystemInitializedEvent` to the system_events stream
    public fun emit_system_event(
        admin_addr: address
    )   acquires DisputeEventStore {
        let store = borrow_global_mut<DisputeEventStore>(admin_addr);
        let systemEvent = SystemInitializedEvent {
            admin: admin_addr,
            timestamp: timestamp::now_seconds()
        };

        event::emit_event(
            &mut store.system_events,
            systemEvent 
        );
    }

}