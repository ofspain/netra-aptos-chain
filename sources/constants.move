module dispute_os::dispute_constants {
    // Milestone types
const DISPUTE_CREATED: u8 = 0; 
const EVIDENCE_SUBMITTED: u8 = 1;
const EVIDENCE_ACCEPTED: u8 = 2;
const EVIDENCE_REJECTED: u8 = 3;
const PLAINTIFF_VERIFIED: u8 = 4;
const PLAINTIFF_DECLINED: u8 = 5;
const RESPONDER_VERIFIED: u8 = 6;
const RESPONDER_DECLINED: u8 = 7;
const ARBITRATION_INITIATED: u8 = 8;
const ARBITRATION_RULED_PLAINTIFF: u8 = 9;
const ARBITRATION_RULED_RESPONDER: u8 = 10;
const ARBITRATION_AMBIGUOUS: u8 = 11;
const MANUAL_ARBITRATION_RULED_PLAINTIFF: u8 = 12;
const MANUAL_ARBITRATION_RULED_RESPONDER: u8 = 13;
const MANUAL_ARBITRATION_AMBIGUOUS: u8 = 14;
const AUTHORITY_ESCALATED_PLAINTIFF: u8 = 15;
const AUTHORITY_ESCALATED_RESPONDER: u8 = 16;
const AUTHORITY_ESCALATED_SYSTEM: u8 = 17;
const WITHDRAWN_BY_CUSTOMER: u8 = 18;
const WITHDRAWN_BY_PLAINTIFF: u8 = 19;
const WITHDRAWN_BY_RESPONDER: u8 = 20;
const WITHDRAWN_DURING_ARBITRATION: u8 = 21;
const WITHDRAWN_BY_SUB_INSTITUTION: u8 = 22;
const DISPUTE_EXPIRED: u8 = 23;
const DISPUTE_CLOSED: u8 = 24;

//todo: define all system events here
const SYSTEMT_EVENT_MILESTONE_STORE: u8 = 99;

const NFT_MINT_EVENT: vector<u8> = b"mint_event";
const NFT_OWNER_CHANGE_EVENT: vector<u8> = b"owner_change_events";
const NFT_BURN_EVENT: vector<u8> = b"burn_events";
const MILESTONE_LOGGED_EVENT: vector<u8> = b"milestone_logged_events";

//application domains constant
const CUSTOMER_USER_DOMAIN_CODE: vector<u8> = b"THSCUDC";

const FIN_INST_DOMAIN_TYPE: vector<u8> = b"FINANCIAL_INSTITUTION";
const SWITCH_DOMAIN_TYPE: vector<u8> = b"SWITCH";
const REGULATOR_DOMAIN_TYPE: vector<u8> = b"REGULATOR";
const INTERNAL_DOMAIN_TYPE: vector<u8> = b"INTERNAL";
const SYSTEM_DOMAIN_TYPE: vector<u8> = b"SYSTEM";
const CUSTOMER_DOMAIN_TYPE: vector<u8> = b"CUSTOMER";





    
    // Maximum sizes for vectors
    const MAX_DISPUTE_ID_LENGTH: u64 = 64;
    const MAX_HASH_LENGTH: u64 = 64;

    // --- Public interface functions ---

        // --- Public getters for dispute status constants ---

    public fun dispute_created(): u8 { DISPUTE_CREATED }
    public fun evidence_submitted(): u8 { EVIDENCE_SUBMITTED }
    public fun evidence_accepted(): u8 { EVIDENCE_ACCEPTED }
    public fun evidence_rejected(): u8 { EVIDENCE_REJECTED }

    public fun plaintiff_verified(): u8 { PLAINTIFF_VERIFIED }
    public fun plaintiff_declined(): u8 { PLAINTIFF_DECLINED }

    public fun responder_verified(): u8 { RESPONDER_VERIFIED }
    public fun responder_declined(): u8 { RESPONDER_DECLINED }

    public fun arbitration_initiated(): u8 { ARBITRATION_INITIATED }
    public fun arbitration_ruled_plaintiff(): u8 { ARBITRATION_RULED_PLAINTIFF }
    public fun arbitration_ruled_responder(): u8 { ARBITRATION_RULED_RESPONDER }
    public fun arbitration_ambiguous(): u8 { ARBITRATION_AMBIGUOUS }

    public fun manual_arbitration_ruled_plaintiff(): u8 { MANUAL_ARBITRATION_RULED_PLAINTIFF }
    public fun manual_arbitration_ruled_responder(): u8 { MANUAL_ARBITRATION_RULED_RESPONDER }
    public fun manual_arbitration_ambiguous(): u8 { MANUAL_ARBITRATION_AMBIGUOUS }

    public fun authority_escalated_plaintiff(): u8 { AUTHORITY_ESCALATED_PLAINTIFF }
    public fun authority_escalated_responder(): u8 { AUTHORITY_ESCALATED_RESPONDER }
    public fun authority_escalated_system(): u8 { AUTHORITY_ESCALATED_SYSTEM }

    public fun withdrawn_by_customer(): u8 { WITHDRAWN_BY_CUSTOMER }
    public fun withdrawn_by_plaintiff(): u8 { WITHDRAWN_BY_PLAINTIFF }
    public fun withdrawn_by_responder(): u8 { WITHDRAWN_BY_RESPONDER }
    public fun withdrawn_during_arbitration(): u8 { WITHDRAWN_DURING_ARBITRATION }
    public fun withdrawn_by_sub_institution(): u8 { WITHDRAWN_BY_SUB_INSTITUTION }

    public fun dispute_expired(): u8 { DISPUTE_EXPIRED }
    public fun dispute_closed(): u8 { DISPUTE_CLOSED }

    public fun nft_mint_event(): vector<u8> {
        NFT_MINT_EVENT
    }   

    public fun nft_owner_change_event(): vector<u8> {
        NFT_OWNER_CHANGE_EVENT
    }

    public fun nft_burn_event(): vector<u8> {
        NFT_BURN_EVENT
    }

    public fun milestone_logged_event(): vector<u8> {
        MILESTONE_LOGGED_EVENT
    }

    // --- Public getters for max sizes ---
    public fun max_dispute_id_length(): u64 { MAX_DISPUTE_ID_LENGTH }
    public fun max_hash_length(): u64 { MAX_HASH_LENGTH }

    //public getter for dmain constants
    public fun switch_domain_type(): vector<u8> { SWITCH_DOMAIN_TYPE }
    public fun regulator_domain_type(): vector<u8> { REGULATOR_DOMAIN_TYPE }
    public fun internal_domain_type(): vector<u8> { INTERNAL_DOMAIN_TYPE }
    public fun system_domain_type(): vector<u8> { SYSTEM_DOMAIN_TYPE }
    public fun customer_domain_type(): vector<u8> { CUSTOMER_DOMAIN_TYPE }
    public fun customer_user_domain_code(): vector<u8> { CUSTOMER_USER_DOMAIN_CODE }

}