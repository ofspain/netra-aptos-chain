script {
    use dispute_os::dispute_lifecycle;
    
    fun main(
        admin: signer,
        actor_id: vector<u8>,
        dispute_id: vector<u8>,
        milestone_type: u8,
        metadata_hash: vector<u8>,
        rule_hash: vector<u8>
    ) {
        dispute_lifecycle::log_milestone(
            &admin,
            actor_id,
            dispute_id,
            milestone_type,
            metadata_hash,
            rule_hash
        );
    }
}