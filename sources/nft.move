module dispute_os::dispute_nft {

    use std::option;
    use aptos_framework::table;
    use dispute_os::dispute_errors;
    use std::signer;
    use std::timestamp;
    use std::vector;
    use dispute_os::dispute_utilities::copy_vector;
    use dispute_os::dispute_events;
    use dispute_os::dispute_constants as constants;
    use dispute_os::shared_types::DisputeNFTInstitutionOwner;

    struct DisputeNFT has store, drop {
        token_id: u64,
        dispute_id: vector<u8>,
        metadata_hash: vector<u8>,
        logical_owner_uuid: option::Option<vector<u8>>, // customer user’s off-chain UUID
        winner_domain_code: vector<u8>, //domain code of the winner
        winner_domain_type: vector<u8>, //domain type of the winner
		timestamp: u64
    }


    struct NFTStore has key, store {
		next_id: u64, 
		nfts: table::Table<u64, DisputeNFT>,//token_id ===> nft
        total_counts_nfts: u64,
        total_counts_burn_nfts: u64,
        total_counts_swapped_ownership_nfts: u64,
        nfts_by_user: table::Table<vector<u8>, vector<u64>>,     // user_uuid -> [token_ids]
        nfts_by_domain: table::Table<DisputeNFTInstitutionOwner, vector<u64>>,  // domain -> [token_ids]
    
	}

    public fun init(admin: &signer) {
	   //assert Store do not exsit in the first place
       let admin_addr = signer::address_of(admin);
        assert!(
            !exists<NFTStore>(admin_addr),
            dispute_errors::ealready_initialized()
        );

        move_to(admin, NFTStore {
            next_id: 0,
            nfts: table::new<u64, DisputeNFT>(),
            total_counts_nfts: 0, 
			total_counts_burn_nfts: 0, 
			total_counts_swapped_ownership_nfts: 0,
            nfts_by_user: table::new<vector<u8>, vector<u64>>(),
            nfts_by_domain: table::new<DisputeNFTInstitutionOwner, vector<u64>>(),
        });
    }

     public fun mint_nft(
        admin: &signer,
        dispute_id: vector<u8>,
        metadata_hash: vector<u8>,
        logical_owner_uuid: option::Option<vector<u8>>, // customer user’s off-chain UUID
        winner_domain_code: vector<u8>, //domain code of the winner
        winner_domain_type: vector<u8>
    ) acquires NFTStore {

        let admin_addr = signer::address_of(admin);
        let collection = borrow_global_mut<NFTStore>(admin_addr);

        let token_id = collection.next_id;
        collection.next_id = token_id + 1;
       
        let copied_dispute_id = copy_vector(&dispute_id);

        let nft = DisputeNFT {
            token_id,
            dispute_id:dispute_id,
            metadata_hash,
            logical_owner_uuid: logical_owner_uuid,
            winner_domain_code,
            winner_domain_type: winner_domain_type,
            timestamp: timestamp::now_seconds()
        };

        table::add(&mut collection.nfts, token_id, nft);
        collection.total_counts_nfts = collection.total_counts_nfts + 1;

         // CONDITIONAL LOGIC: Populate user table OR domain table
        let (populate_user, user_uuid) = check_logical_owner_condition(&logical_owner_uuid, &winner_domain_type, &winner_domain_code);
    
        if (populate_user) {
            // Populate nfts_by_user table
            add_to_user_nfts(collection, user_uuid, token_id);
        } else {
            // Populate nfts_by_domain table
            let domain_owner = DisputeNFTInstitutionOwner {
                winner_domain_code: copy_vector(&winner_domain_code),
                winner_domain_type: copy_vector(&winner_domain_type),
            };
            add_to_domain_nfts(collection, domain_owner, token_id);
        };




        dispute_events::emit_nft_mint_event(
            admin_addr,
            token_id,
            copied_dispute_id,
            logical_owner_uuid,
            DisputeNFTInstitutionOwner{
                winner_domain_code,
                winner_domain_type
            }
          
        );
    }



    public entry fun transfer_nft_ownership(
        admin: &signer,
        token_id: u64,
        new_owner_uuid: option::Option<vector<u8>>,
        new_owner_domain_code: vector<u8>,
        new_owner_domain_type: vector<u8>,
        timestamp: u64
    ) acquires NFTStore {
        let admin_addr = signer::address_of(admin);
        let store = borrow_global_mut<NFTStore>(admin_addr);
    
        // FIXED: Should check that token EXISTS (not that it doesn't exist!)
        assert!(
            table::contains(&store.nfts, token_id),
            dispute_errors::not_found()
        );

        // 1. Get the current NFT
        let nft = table::borrow(&store.nfts, token_id);
    
        // 2. REMOVE NFT FROM ALL OLD OWNER TABLES FIRST
        remove_from_all_owner_tables(store, nft, token_id);
    
        // 3. DROP the borrow so we can mutate
        let nft = table::remove(&mut store.nfts, token_id);
    
        // 4. Update NFT ownership fields
        let updated_nft = DisputeNFT {
            token_id: nft.token_id,
            dispute_id: nft.dispute_id,
            metadata_hash: nft.metadata_hash,
            logical_owner_uuid: new_owner_uuid,
            winner_domain_code: new_owner_domain_code,
            winner_domain_type: new_owner_domain_type,
            timestamp: timestamp
        };
    
        // 5. Add back to main table
        table::add(&mut store.nfts, token_id, updated_nft);
    
        // 6. ADD TO NEW OWNER'S TABLE BASED ON OWNER TYPE
        let (is_user_owner, user_uuid) = check_logical_owner_condition(&new_owner_uuid, &new_owner_domain_type, &new_owner_domain_code);
    
        if (is_user_owner) {
            // Add to user_nfts table
            add_to_user_nfts(store, user_uuid, token_id);
        } else {
            // Add to domain_nfts table
            let domain_owner = DisputeNFTInstitutionOwner {
                winner_domain_code: copy_vector(&new_owner_domain_code),
                winner_domain_type: copy_vector(&new_owner_domain_type),
            };
            add_to_domain_nfts(store, domain_owner, token_id);
        };
    
        // Update counter
        store.total_counts_swapped_ownership_nfts = store.total_counts_swapped_ownership_nfts + 1;



        dispute_events::emit_nft_owner_change_event(
            admin_addr,
            token_id,
            nft.dispute_id,
            nft.logical_owner_uuid, //updated_nft
            updated_nft.logical_owner_uuid,
            DisputeNFTInstitutionOwner {
                winner_domain_code: copy_vector(&updated_nft.winner_domain_code),
                winner_domain_type: copy_vector(&updated_nft.winner_domain_type)
            },
            DisputeNFTInstitutionOwner {
                winner_domain_code: copy_vector(&nft.winner_domain_code),
                winner_domain_type: copy_vector(&nft.winner_domain_type)
            }
        );
    }

    public fun burn(
        admin: &signer,
        store: &mut NFTStore,
        token_id: u64
    ) acquires NFTStore {
        // ----------------------------------------------
        // 1. Remove NFT object from main table
        // ----------------------------------------------
        // This returns the actual DisputeNFT struct instance,
        // removing it from global storage.
        let nft = table::remove(&mut store.nfts, token_id);

        // ----------------------------------------------
        // 2. Remove from indexing tables
        // ----------------------------------------------
        remove_from_all_owner_tables(store, &nft, token_id);

        // ----------------------------------------------
        // 3. Update burn counter
        // ----------------------------------------------
        store.total_counts_burn_nfts = store.total_counts_burn_nfts + 1;

        if(store.total_counts_nfts > 0){
            store.total_counts_nfts =  store.total_counts_nfts - 1;
        };

        let admin_addr = signer::address_of(admin);

        dispute_events::emit_nft_burn_event(
            admin_addr,
            token_id,
            nft.dispute_id,
            nft.logical_owner_uuid,
            DisputeNFTInstitutionOwner {
                winner_domain_code: copy_vector(&nft.winner_domain_code),
                winner_domain_type: copy_vector(&nft.winner_domain_type)
            }
        );

        // ----------------------------------------------
        // 4. NFT gets dropped *automatically* here
        // ----------------More like java GC ------------------------------
        // Because DisputeNFT has ability `drop`.
    }



    // Check if we should populate user table or domain table
    fun check_logical_owner_condition(
        logical_owner_uuid: &option::Option<vector<u8>>,
        winner_domain_type: &vector<u8>,
        winner_domain_code: &vector<u8>
    ): (bool, vector<u8>) {
        // Condition 1: logical_owner_uuid must be present (Some)
        let actual_domain_type = *winner_domain_type;
        if (option::is_some(logical_owner_uuid)) {
            if (actual_domain_type == constants::customer_domain_type()) {
                // Both conditions met: populate user table
                let user_uuid = option::borrow(logical_owner_uuid);
                return (true, copy_vector(user_uuid))
            };
        };
        let actual_domain_code = *winner_domain_code;
        if(actual_domain_type == constants::customer_domain_type() || actual_domain_code == constants::customer_user_domain_code()){
            abort dispute_errors::eillegalargument()
        };
        // Otherwise: populate domain table
        (false, vector::empty())
    }

    fun add_to_user_nfts(
        store: &mut NFTStore,
        user_uuid: vector<u8>,
        token_id: u64
    ) acquires NFTStore {
        if (!table::contains(&store.nfts_by_user, user_uuid)) {
            // Create new vector for this user
            let token_ids = vector::empty<u64>();
            table::add(&mut store.nfts_by_user, user_uuid, token_ids);
        };
    
        // Add token_id to user's collection
        let user_tokens = table::borrow_mut(&mut store.nfts_by_user, user_uuid);
        vector::push_back(user_tokens, token_id);
    }

    fun add_to_domain_nfts(
        store: &mut NFTStore,
        domain_owner: DisputeNFTInstitutionOwner,
        token_id: u64
    ) {
        if (!table::contains(&store.nfts_by_domain, domain_owner)) {
            // Create new vector for this domain
            let token_ids = vector::empty<u64>();
            table::add(&mut store.nfts_by_domain, domain_owner, token_ids);
        };
    
        // Add token_id to domain's collection
        let domain_tokens = table::borrow_mut(&mut store.nfts_by_domain, domain_owner);
        vector::push_back(domain_tokens, token_id);
    }


    fun remove_from_domain_table(
        store: &mut NFTStore,
        old_nft: &DisputeNFT,
        token_id: u64
    ) acquires NFTStore {
         // Remove from domain table
        let old_domain = DisputeNFTInstitutionOwner {
            winner_domain_code: copy_vector(&old_nft.winner_domain_code),
            winner_domain_type: copy_vector(&old_nft.winner_domain_type),
        };

    
    
        if (table::contains(&store.nfts_by_domain, old_domain)) {
            let domain_tokens = table::borrow_mut(&mut store.nfts_by_domain, old_domain);
        
            // Find and remove token_id from vector
            let i = 0;
            while (i < vector::length(domain_tokens)) {
                if (*vector::borrow(domain_tokens, i) == token_id) {
                    vector::remove(domain_tokens, i);
                    break
                };
                i = i + 1;
            };
        
            // If domain has no more tokens, remove entry entirely
            if (vector::length(domain_tokens) == 0) {
                table::remove(&mut store.nfts_by_domain, old_domain);
            };
        };
    }


    fun remove_from_all_owner_tables(
        store: &mut NFTStore,
        nft: &DisputeNFT,
        token_id: u64
    ) acquires NFTStore {
        // -------------------------------------------------
        // 1. REMOVE FROM USER TABLE (if old owner was a user)
        // -------------------------------------------------
        if (option::is_some(&nft.logical_owner_uuid)) {
            let old_user_uuid = option::borrow(&nft.logical_owner_uuid);
            let user_uuid_copy = copy_vector(old_user_uuid);
        
            if (table::contains(&store.nfts_by_user, user_uuid_copy)) {
                let user_tokens = table::borrow_mut(&mut store.nfts_by_user, user_uuid_copy);
            
                // Find and remove this token_id from user's token list
                remove_token_id_from_vector(user_tokens, token_id);
            
                // If user has no more tokens, remove the entire entry
                if (vector::length(user_tokens) == 0) {
                    table::remove(&mut store.nfts_by_user, user_uuid_copy);
                };
            };
        };
    
        // -------------------------------------------------
        // 2. REMOVE FROM DOMAIN TABLE (always check this)
        // -------------------------------------------------
        let old_domain_owner = DisputeNFTInstitutionOwner {
            winner_domain_code: copy_vector(&nft.winner_domain_code),
            winner_domain_type: copy_vector(&nft.winner_domain_type),
        };
    
        if (table::contains(&store.nfts_by_domain, old_domain_owner)) {
            let domain_tokens = table::borrow_mut(&mut store.nfts_by_domain, old_domain_owner);
        
            // Find and remove this token_id from domain's token list
            remove_token_id_from_vector(domain_tokens, token_id);
        
            // If domain has no more tokens, remove the entire entry
            if (vector::length(domain_tokens) == 0) {
                table::remove(&mut store.nfts_by_domain, old_domain_owner);
            };
        };
    }

    fun remove_token_id_from_vector(token_ids: &mut vector<u64>, target_id: u64) {
        let i = 0;
        while (i < vector::length(token_ids)) {
            if (*vector::borrow(token_ids, i) == target_id) {
                vector::remove(token_ids, i);
                return // Found and removed, exit early
            };
            i = i + 1;
        };
    }



}


 /*

    // Since nfts table is keyed by token_id, we need to search
    fun find_nft_by_dispute_id(
        store: &mut NFTStore,
        dispute_id: u64
    ): (vector<u8>, DisputeNFT) acquires NFTStore {
        let iter = table::iter(&store.nfts);
    
        while (!table::iter_done(&iter)) {
            let (dispute_id, nft) = table::iter_next(&mut iter);
            if (nft.dispute_id == dispute_id) {
                return (dispute_id, nft)
            };
        };
    
        abort dispute_errors::ENFT_NOT_FOUND()
    }
    */

    /* JUST DEMONSTRATE HOW TO BUILD OPTION<T>
    
        let old_domain_owner_opt = option::some(
            DisputeNFTInstitutionOwner {
                winner_domain_code: copy_vector(&nft.winner_domain_code),
                winner_domain_type: copy_vector(&nft.winner_domain_type)
            }
        );

        let new_domain_owner_opt = option::some(
            DisputeNFTInstitutionOwner {
                winner_domain_code: copy_vector(&updated_nft.winner_domain_code),
                winner_domain_type: copy_vector(&updated_nft.winner_domain_type)
            }
        );
 */