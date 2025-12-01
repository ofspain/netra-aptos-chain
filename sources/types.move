module dispute_os::dispute_types {
    use std::vector;
    use aptos_framework::table;

    
    // Main milestone storage structure
    struct DisputeMilestone has store, drop {
        dispute_id: vector<u8>,
        milestone_type: u8,
        metadata_hash: vector<u8>,
        timestamp: u64,
        actor_id: vector<u8>,
        rule_hash: vector<u8>,
    }
    
    // Global storage for the entire dispute system
    struct DisputeStore has key {
        milestones: table::Table<u64, DisputeMilestone>,
        next_id: u64,
        total_disputes: u64,
    }
}