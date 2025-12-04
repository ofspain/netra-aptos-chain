module dispute_os::dispute_lifecycle {
    use std::signer;
   // use std::vector;
    // use std::timestamp;
    use aptos_framework::event;
    // use aptos_framework::table;
    // use aptos_framework::guid;
    
    // use dispute_os::dispute_errors;
    use dispute_os::dispute_types;
    use dispute_os::dispute_events;
    // use dispute_os::dispute_constants;

    // ============ Initialization ============
    
    /// Initialize the dispute system under the admin account
    public entry fun init_system(admin: &signer){// acquires dispute_events::DisputeEventStore 
        // let admin_addr = signer::address_of(admin);

    
        // //initialize dispute store
        // dispute_types::init_dispute_store(admin);

        // //initialize event store
        // dispute_events::init_disputeEvent_store(admin);

        // //emit system event for creation of stores
        // dispute_events::emit_system_event(admin_addr);
    
    }


    
    // ============ Core Milestone Logging ============


/*
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
    dispute_events::emit_milestone_event(admin_addr, milestone);   
}*/

}