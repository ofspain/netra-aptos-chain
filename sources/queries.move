module dispute_os::dispute_queries {
    use std::vector;
    use aptos_framework::table;
    
    use dispute_os::dispute_types;
    use dispute_os::dispute_errors;
    
    // ============ Query Functions ============
    
    /// Get total number of milestones logged
    public fun get_total_milestones(addr: address): u64 acquires dispute_types::DisputeStore {
        assert!(exists<dispute_types::DisputeStore>(addr), dispute_errors::enot_published());
        borrow_global<dispute_types::DisputeStore>(addr).next_id
    }
    
    /// Get total number of unique disputes
    public fun get_total_disputes(addr: address): u64 acquires dispute_types::DisputeStore {
        assert!(exists<dispute_types::DisputeStore>(addr), dispute_errors::enot_published());
        borrow_global<dispute_types::DisputeStore>(addr).total_disputes
    }
    
    /// Check if a specific milestone exists
    public fun milestone_exists(addr: address, id: u64): bool acquires dispute_types::DisputeStore {
        assert!(exists<dispute_types::DisputeStore>(addr), dispute_errors::enot_published());
        table::contains(&borrow_global<dispute_types::DisputeStore>(addr).milestones, id)
    }
    
    /// Get milestone type
    public fun get_milestone_type(addr: address, id: u64): u8 acquires dispute_types::DisputeStore {
        assert!(exists<dispute_types::DisputeStore>(addr), dispute_errors::enot_published());
        let store = borrow_global<dispute_types::DisputeStore>(addr);
        assert!(table::contains(&store.milestones, id), dispute_errors::emilestone_not_found());
        table::borrow(&store.milestones, id).milestone_type
    }
    
    /// Get milestone timestamp
    public fun get_milestone_timestamp(addr: address, id: u64): u64 acquires dispute_types::DisputeStore {
        assert!(exists<dispute_types::DisputeStore>(addr), dispute_errors::enot_published());
        let store = borrow_global<dispute_types::DisputeStore>(addr);
        assert!(table::contains(&store.milestones, id), dispute_errors::emilestone_not_found());
        table::borrow(&store.milestones, id).timestamp
    }
    
    /// Get milestone actor
    public fun get_milestone_actor(addr: address, id: u64): vector<u8> acquires dispute_types::DisputeStore {
        assert!(exists<dispute_types::DisputeStore>(addr), dispute_errors::enot_published());
        let store = borrow_global<dispute_types::DisputeStore>(addr);
        assert!(table::contains(&store.milestones, id), dispute_errors::emilestone_not_found());
        table::borrow(&store.milestones, id).actor_id
    }
}