module dispute_os::dispute_queries {
    use std::vector;
    use aptos_framework::table;
    
    use dispute_os::dispute_types;
    use dispute_os::dispute_errors;
    
    // ============ Query Functions ============



  public fun get_milestones_for_dispute(owner: address, dispute_id: vector<u8>): vector<dispute_types::DisputeMilestone> {
     let milestones_id = dispute_types::get_dispute_milestones_id(owner, dispute_id);
     let result = vector::empty<dispute_types::DisputeMilestone>();
     let len = vector::length(&milestones_id);
     let i = 0;
     while (i < len) {
         let id = *vector::borrow(&milestones_id, i);
         let m = dispute_types::get_milestone_by_id(owner, id);
         vector::push_back(&mut result, m);
         i = i + 1;
     };
     result
 }

    

}