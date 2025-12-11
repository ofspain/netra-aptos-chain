 module dispute_os::shared_types {
    use std::signer;
    use std::vector;
 
 /// Represents a dispute state transition event
    public struct MilestoneLogged has copy, drop, store {
        /// e.g., "DIS_345" encoded as UTF-8 bytes
        dispute_id: vector<u8>,

        //these two are the trigger blockchain event, off the chain, we will use it to identify the
        //milestones

        new_trigger_event: u8,

        old_trigger_event: u8,

        /// SHA-256 hash of JSON metadata as raw bytes
        metadata_hash: vector<u8>,

        /// UUID of the actor as UTF-8 bytes
        actor_identity_uuid: vector<u8>,


        /// Epoch seconds
        timestamp: u64,

        /// UTF-8 bytes
        issuer_domain: vector<u8>,
        acquirer_domain: vector<u8>,
        beneficiary_domain: vector<u8>,
        actor_domain: vector<u8>
    }

    /**
    In Move, any type used as a table key must have:

        copy ability (to be duplicated when used as a key)

        drop ability (to be discarded)

        store ability (to be stored globally)
    **/

    public struct DisputeNFTInstitutionOwner has store, key, copy, drop{
        winner_domain_code: vector<u8>,
        winner_domain_type: vector<u8>

    }
}    