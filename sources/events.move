module dispute_os::dispute_events {
    use std::vector;
    use aptos_framework::event;
    
    // Event emitted when a milestone is logged
    struct MilestoneLoggedEvent has drop, store {
        dispute_id: vector<u8>,
        milestone_type: u8,
        metadata_hash: vector<u8>,
        rule_hash: vector<u8>,
        timestamp: u64,
        actor: address,
        milestone_id: u64,
    }
    // Event emitted when system is initialized
    struct SystemInitializedEvent has drop, store {
        admin: address,
        timestamp: u64,
    }
    
    // Event handle container
    struct DisputeEventStore has key {
        milestone_events: event::EventHandle<MilestoneLoggedEvent>,
        system_events: event::EventHandle<SystemInitializedEvent>,
        next_guid_id: u64, // counter for generating new GUIDs
    }
}