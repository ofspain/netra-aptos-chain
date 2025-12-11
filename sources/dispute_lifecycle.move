module dispute_os::dispute_lifecycle {
    use std::signer;
    use std::vector;
    use std::timestamp;
    use aptos_framework::event;
    use aptos_framework::table;
    use dispute_os::shared_types as shared;
    use dispute_os::dispute_utilities::copy_vector;
    // use aptos_framework::guid;
    
    use dispute_os::dispute_errors;
    use dispute_os::dispute_events;
    use dispute_os::dispute_constants;

    // ============ Initialization ============
    
    struct DisputeStore has key, store {
        milestones: table::Table<u64, shared::MilestoneLogged>,
        milestones_by_dispute: table::Table<vector<u8>, vector<u64>>,//dispute_id ===> list[milestone_id]
        next_id: u64,
        total_disputes: u64,
    }

    public fun init_dispute_store(admin: &signer) {
        let addr = signer::address_of(admin);
        

        move_to(admin, DisputeStore {
            milestones: table::new<u64, shared::MilestoneLogged>(),
            milestones_by_dispute: table::new<vector<u8>, vector<u64>>(),
            next_id: 0,
            total_disputes: 0,
        });
    }


    
    // ============ Core Milestone Logging ============



    public entry fun log_milestone(
        admin: &signer,
        milestone: shared::MilestoneLogged
    ) acquires DisputeStore{
        let admin_addr = signer::address_of(admin);

    //
    // 0. SAFETY CHECKS — ensure system initialized
    //
    assert!(
        exists<DisputeStore>(admin_addr),
        dispute_errors::enot_published()
    );

    let store = borrow_global_mut<DisputeStore>(admin_addr);
    
    // 2. Assign unique milestone ID
    let milestone_id = store.next_id;
    store.next_id = milestone_id + 1;

    let dispute_id_clone = copy_vector(&milestone.dispute_id);
    let milestone_type = milestone.new_trigger_event;
        
    // 4. Insert into main milestone table
    table::add(&mut store.milestones, milestone_id, milestone);

    //5 Insert into the milestines by disputes 
    let list_ref = if (table::contains(&store.milestones_by_dispute, dispute_id_clone)) {
        table::borrow_mut(&mut store.milestones_by_dispute, dispute_id_clone)
    } else {
            let empty_vec = vector::empty<u64>();
            table::add(&mut store.milestones_by_dispute, dispute_id_clone, empty_vec);
            table::borrow_mut(&mut store.milestones_by_dispute, dispute_id_clone)
    };
    vector::push_back(list_ref, milestone_id);

    // 6. Update total disputes if milestone type indicates initiation
    if (milestone_type == dispute_constants::dispute_created()) {
        store.total_disputes = store.total_disputes + 1;
    };
    //
    // 7. EMIT EVENT
    //
    dispute_events::emit_milestone_event(admin_addr, milestone);   
}

}