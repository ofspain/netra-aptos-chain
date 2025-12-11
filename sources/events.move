module dispute_os::dispute_events {
    use std::vector;
    use aptos_framework::event;
    use std::signer;
    use aptos_framework::account;
    use aptos_framework::table;
    use std::timestamp;
    use std::option;
    use dispute_os::dispute_errors;
    use dispute_os::dispute_lifecycle;
    use dispute_os::dispute_constants as constants;
    use dispute_os::shared_types;
    use dispute_os::shared_types::DisputeNFTInstitutionOwner;

    // Event emitted when system is initialized
    struct SystemEvent has drop, store {
        type: u8,
        timestamp: u64,
    }

    // Event emitted when milestone is logged
    struct MilestoneLoggedEvent has drop, store{
        dispute_id: vector<u8>,
        current_trigger_event: u8,
        last_trigger_event: u8,
        actor_id: vector<u8>,
        actor_domain: vector<u8>,
        issue_domain: vector<u8>,
        acquirer_domain: vector<u8>,
        beneficiary_domain: vector<u8>,
        timestamp: u64,
    }
    struct NftMintEvent  has drop, store {
         token_id: u64,
         dispute_id: vector<u8>,
         owner_logical_id: option::Option<vector<u8>>,
         domain_owner: DisputeNFTInstitutionOwner,
         timestamp: u64
    }
    struct NftOwnershipChangedEvent  has drop, store {
        token_id: u64,
        dispute_id: vector<u8>,
        old_owner_uuid: option::Option<vector<u8>>, // customer user’s off-chain UUID
        new_owner_uuid: option::Option<vector<u8>>,
		old_domain_owner: DisputeNFTInstitutionOwner, //this is the old owner of the nft
        new_domain_owner: DisputeNFTInstitutionOwner, //this is the old owner of the nft
        timestamp: u64,
    }

    struct NftBurnEvent  has drop, store {
        token_id: u64,
        dispute_id: vector<u8>,
        logical_owner_uuid: option::Option<vector<u8>>, // customer user’s off-chain UUID
		domain_owner: DisputeNFTInstitutionOwner, //this is the old owner of the nft
        timestamp: u64,
    }
    
    // Event store on global
    struct EventCounterStore has key, store {
        mint_events_counter: u64,            // fixed primitive counter
        owner_change_events_counter: u64,    // fixed primitive counter
        burn_events_counter: u64,            // fixed primitive counter
        milestone_logged_events_counts: u64, // fixed primitive counter
        dynamic_events_counter: table::Table<u8, u64>, // dynamic milestone logged type -> counter

         //event handler hook
         milestone_logged_events: event::EventHandle<MilestoneLoggedEvent>,
         nft_mint_events: event::EventHandle<NftMintEvent>,
         nft_owner_change_events: event::EventHandle<NftOwnershipChangedEvent>,
         nft_burn_events: event::EventHandle<NftBurnEvent>
    }

    public fun init_disputeEvent_store(admin: &signer) {
        let admin_addr = signer::address_of(admin);
        assert!(
            !exists<EventCounterStore>(admin_addr),
            dispute_errors::ealready_initialized()
        );

      //  let milestone_event_guid = account::create_guid(admin);
      //  let system_event_guid = account::create_guid(admin);

        
        
        
        // Create a new event handle
        let milestone_event_handle = account::new_event_handle<MilestoneLoggedEvent>(admin);
        let nft_mint_event_handle = account::new_event_handle<NftMintEvent>(admin);
        let nft_owner_change_event_handle = account::new_event_handle<NftOwnershipChangedEvent>(admin);
        let nft_burn_event_handle = account::new_event_handle<NftBurnEvent>(admin);



        // Store the counters in the admin account
        move_to(admin, EventCounterStore {
            mint_events_counter: 0,
            owner_change_events_counter: 0,
            burn_events_counter: 0,
            milestone_logged_events_counts: 0,
            // Create a new empty table for dynamic event and use lazy initialization pattern
            dynamic_events_counter: table::new<u8, u64>(),
            milestone_logged_events: milestone_event_handle,
            nft_mint_events: nft_mint_event_handle,
            nft_owner_change_events: nft_owner_change_event_handle,
            nft_burn_events: nft_burn_event_handle,

        });
    }


    /// Emits a `MilestoneLoggedEvent` to the milestone_events stream
    public fun emit_milestone_event(
        admin_addr: address,
        logged_milestone: shared_types::MilestoneLogged
    ) acquires EventCounterStore {
        // Borrow the resource mutably
        let store = borrow_global_mut<EventCounterStore>(admin_addr);
        //
        // Construct the event by *copying fields* from milestone_logged
        //
        let event_logged = MilestoneLoggedEvent {
            dispute_id: logged_milestone.dispute_id,
            current_trigger_event: logged_milestone.new_trigger_event,
            last_trigger_event: logged_milestone.old_trigger_event,
            actor_id: logged_milestone.actor_identity_uuid,
            actor_domain: logged_milestone.actor_domain,
            issue_domain: logged_milestone.issuer_domain,
            acquirer_domain: logged_milestone.acquirer_domain,
            beneficiary_domain: logged_milestone.beneficiary_domain,
            timestamp: timestamp::now_seconds(),
        };


        // Emit the event using the event handle
        event::emit_event(
            &mut store.milestone_logged_events,
            event_logged 
        );

        store.milestone_logged_events_counts = store.milestone_logged_events_counts + 1;

        store.milestone_logged_events_counts = store.milestone_logged_events_counts + 1;

        let key = event_logged.current_trigger_event;

        // Lazy initialize if the key does not exist
        if (!table::contains(&store.dynamic_events_counter, key)) {
            table::add(&mut store.dynamic_events_counter, key, 0);
        };

        // Increment
        let counter_ref = table::borrow_mut(&mut store.dynamic_events_counter, key);
        *counter_ref = *counter_ref + 1;
    }

    ///Emit nft mint event
    public fun emit_nft_mint_event(
        admin_addr: address,
        token_id: u64,
        dispute_id: vector<u8>,
        owner_logical_id: option::Option<vector<u8>>,
        domain_owner: DisputeNFTInstitutionOwner
        
    ) acquires EventCounterStore {
        let store = borrow_global_mut<EventCounterStore>(admin_addr);

        let event_logged = NftMintEvent {
            token_id,
            dispute_id,
            owner_logical_id,
            domain_owner,
            timestamp: timestamp::now_seconds(),
        };

        event::emit_event(
            &mut store.nft_mint_events,
            event_logged
        );

        store.mint_events_counter = store.mint_events_counter + 1;
    }

    //emit nft burn event
    public fun emit_nft_burn_event(
        admin_addr: address,
        token_id: u64,
        dispute_id: vector<u8>,
        logical_owner_uuid: option::Option<vector<u8>>,
        domain_owner: DisputeNFTInstitutionOwner
    ) acquires EventCounterStore {
        let store = borrow_global_mut<EventCounterStore>(admin_addr);

        let event_logged = NftBurnEvent {
            token_id,
            dispute_id,
            logical_owner_uuid,
            domain_owner,
            timestamp: timestamp::now_seconds(),
        };
        event::emit_event(
            &mut store.nft_burn_events,
            event_logged
        );

        store.burn_events_counter = store.burn_events_counter + 1;
    }

    /// Emits a NftOwnershipChangedEvent and increments the owner_change_events_counter
    public fun emit_nft_owner_change_event(
        admin_addr: address,
        token_id: u64,
        dispute_id: vector<u8>,
        old_owner_uuid: option::Option<vector<u8>>,
        new_owner_uuid: option::Option<vector<u8>>,
        old_domain_owner: DisputeNFTInstitutionOwner, //this is the old owner of the nft
        new_domain_owner: DisputeNFTInstitutionOwner
    ) acquires EventCounterStore {
        let store = borrow_global_mut<EventCounterStore>(admin_addr);

        let event_logged = NftOwnershipChangedEvent {
            token_id,
            dispute_id,
            old_owner_uuid,
            new_owner_uuid,
            old_domain_owner,
            new_domain_owner,
            timestamp: timestamp::now_seconds(),
        };

        event::emit_event(
            &mut store.nft_owner_change_events,
            event_logged
        );

        store.owner_change_events_counter = store.owner_change_events_counter + 1;
    }
//consider listenning to all mint-events on backend



}