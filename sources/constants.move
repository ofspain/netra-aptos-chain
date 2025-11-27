module dispute_os::dispute_constants {
    // Milestone types
    const MILESTONE_INITIATED: u8 = 0;
    const MILESTONE_EVIDENCE_ADDED: u8 = 1;
    const MILESTONE_RESOLVED: u8 = 2;
    const MILESTONE_CLOSED: u8 = 3;
    const MILESTONE_APPEALED: u8 = 4;
    
    // Maximum sizes for vectors
    const MAX_DISPUTE_ID_LENGTH: u64 = 64;
    const MAX_HASH_LENGTH: u64 = 64;

    // --- Public interface functions ---

    public fun milestone_initiated(): u8 { MILESTONE_INITIATED }
    public fun milestone_evidence_added(): u8 { MILESTONE_EVIDENCE_ADDED }
    public fun milestone_resolved(): u8 { MILESTONE_RESOLVED }
    public fun milestone_closed(): u8 { MILESTONE_CLOSED }
    public fun milestone_appealed(): u8 { MILESTONE_APPEALED }

    public fun max_dispute_id_length(): u64 { MAX_DISPUTE_ID_LENGTH }
    public fun max_hash_length(): u64 { MAX_HASH_LENGTH }
}
