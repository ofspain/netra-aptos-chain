module dispute_os::dispute_types {
    friend dispute_os::dispute_queries;

    use std::vector;
    use aptos_framework::table;
    use std::signer;
    use dispute_os::dispute_errors;
    use dispute_os::dispute_events::DisputeEventStore;
    use dispute_os::dispute_utilities::copy_vector;
    use dispute_os::dispute_constants;
    use dispute_os::dispute_events;
    
    // Main milestone storage structure
    public struct DisputeMilestone has store, drop, copy {
        dispute_id: vector<u8>,
        milestone_type: u8,
        metadata_hash: vector<u8>,
        timestamp: u64,
        actor_id: vector<u8>,
        rule_hash: vector<u8>,
    }
    
    // Global storage for the entire dispute system
    struct DisputeStore has key, store {
        milestones: table::Table<u64, DisputeMilestone>,
        milestones_by_dispute: table::Table<vector<u8>, vector<u64>>,
        next_id: u64,
        total_disputes: u64,
    }

    public fun init_dispute_store(admin: &signer) {
        let addr = signer::address_of(admin);
        
        assert!(
            !exists<DisputeStore>(addr), 
            dispute_errors::ealready_initialized()
        );

        move_to(admin, DisputeStore {
            milestones: table::new<u64, DisputeMilestone>(),
            milestones_by_dispute: table::new<vector<u8>, vector<u64>>(),
            next_id: 0,
            total_disputes: 0,
        });
    }

    // SAFE HELPERS (public friend or public)
    public fun create_and_log_milestone(
        admin_addr: address,
        milestone: DisputeMilestone
    ) acquires DisputeStore { //, DisputeEventStore



        // 1. Borrow global resources
        let store = borrow_global_mut<DisputeStore>(admin_addr);
       
        // 2. Assign unique milestone ID
        let milestone_id = store.next_id;
        store.next_id = milestone_id + 1;

        let dispute_id_clone = copy_vector(&milestone.dispute_id);
        let milestone_type = milestone.milestone_type;
        
        // 4. Insert into main milestone table
        table::add(&mut store.milestones, milestone_id, milestone);

        let list_ref = if (table::contains(&store.milestones_by_dispute, dispute_id_clone)) {
            table::borrow_mut(&mut store.milestones_by_dispute, dispute_id_clone)
        } else {
            let empty_vec = vector::empty<u64>();
            table::add(&mut store.milestones_by_dispute, dispute_id_clone, empty_vec);
            table::borrow_mut(&mut store.milestones_by_dispute, dispute_id_clone)
        };
        vector::push_back(list_ref, milestone_id);

        // 6. Update total disputes if milestone type indicates initiation
        if (milestone_type == dispute_constants::milestone_initiated()) {
            store.total_disputes = store.total_disputes + 1;
        };

        // 7. Emit milestone event
     //   dispute_events::emit_milestone_event(admin_addr, dispute_id_clone, milestone.milestone_type);
    }

    /// Check if system is initialized for an address
    public fun is_dispute_store_initialized(addr: address): bool {
        exists<DisputeStore>(addr)
    }



         /// Get total number of milestones logged
    public fun get_total_milestones(addr: address): u64 acquires DisputeStore {
        assert!(exists<DisputeStore>(addr), dispute_errors::enot_published());
        borrow_global<DisputeStore>(addr).next_id
    }
    
    /// Get total number of unique disputes
    public fun get_total_disputes(addr: address): u64 acquires DisputeStore {
        assert!(exists<DisputeStore>(addr), dispute_errors::enot_published());
        borrow_global<DisputeStore>(addr).total_disputes
    }
    
    /// Check if a specific milestone exists
    public fun milestone_exists(addr: address, id: u64): bool acquires DisputeStore {
        assert!(exists<DisputeStore>(addr), dispute_errors::enot_published());
        table::contains(&borrow_global<DisputeStore>(addr).milestones, id)
    }
    
    /// Get milestone type
    public fun get_milestone_type(addr: address, id: u64): u8 acquires DisputeStore {
        assert!(exists<DisputeStore>(addr), dispute_errors::enot_published());
        let store = borrow_global<DisputeStore>(addr);
        assert!(table::contains(&store.milestones, id), dispute_errors::emilestone_not_found());
        table::borrow(&store.milestones, id).milestone_type
    }
    
    /// Get milestone timestamp
    public fun get_milestone_timestamp(addr: address, id: u64): u64 acquires DisputeStore {
        assert!(exists<DisputeStore>(addr), dispute_errors::enot_published());
        let store = borrow_global<DisputeStore>(addr);
        assert!(table::contains(&store.milestones, id), dispute_errors::emilestone_not_found());
        table::borrow(&store.milestones, id).timestamp
    }
    
    /// Get milestone actor
    public fun get_milestone_actor(addr: address, id: u64): vector<u8> acquires DisputeStore {
        assert!(exists<DisputeStore>(addr), dispute_errors::enot_published());
        let store = borrow_global<DisputeStore>(addr);
        assert!(table::contains(&store.milestones, id), dispute_errors::emilestone_not_found());
        table::borrow(&store.milestones, id).actor_id
    }

    public fun get_milestones_for_dispute(
        owner: address,
        dispute_id: vector<u8>,
    ): vector<DisputeMilestone> acquires DisputeStore {

        let store = borrow_global<DisputeStore>(owner);

        if (!table::contains(&store.milestones_by_dispute, dispute_id)) {
            return vector::empty<DisputeMilestone>()
        };

        let ids = table::borrow(&store.milestones_by_dispute, dispute_id);

        let result = vector::empty<DisputeMilestone>();
        let len = vector::length(ids);
        let  i = 0;

        while (i < len) {
            let id = *vector::borrow(ids, i);
            let m = table::borrow(&store.milestones, id);
            vector::push_back(&mut result, *m);
            i = i + 1;
        };

        result
    }


}