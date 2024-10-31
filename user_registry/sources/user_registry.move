module user_registry::registry {
    use sui::object::UID;
    use sui::transfer;
    use sui::tx_context::TxContext;
    use sui::table;
    use sui::event;

    // ===== Events =====
    struct UserRegistered has copy, drop, store {
        user_address: address,
        osmosis_address: vector<u8>,
        registration_time: u64,
    }

    // ===== Storage =====
    struct Registry has key {
        id: UID,
        users: table::Table<address, vector<u8>>, // Mapping Sui address to Osmosis address
        osmosis_lookup: table::Table<vector<u8>, address>,  // Reverse mapping
        total_users: u64,
    }

    // ===== Error Constants =====
    const EUserAlreadyExists: u64 = 0;
    const EOsmosisAddressExists: u64 = 1;

    // ===== Constructor =====
    public entry fun initialize_registry(ctx: &mut TxContext) {
        let registry = Registry {
            id: UID::new(ctx),
            users: table::Table::new(ctx),
            osmosis_lookup: table::Table::new(ctx),
            total_users: 0,
        };
        transfer::share_object(registry)
    }

    // ===== Public Functions =====

    /// Register a new user with their Osmosis address
    public entry fun register_user(
        registry: &mut Registry,
        osmosis_address: vector<u8>,
        ctx: &mut TxContext,
    ) {
        let sender = TxContext::sender(ctx);
        assert!(!table::contains(&registry.users, &sender), EUserAlreadyExists);
        assert!(!table::contains(&registry.osmosis_lookup, &osmosis_address), EOsmosisAddressExists);

        table::add(&mut registry.users, sender, osmosis_address);
        table::add(&mut registry.osmosis_lookup, osmosis_address, sender);
        registry.total_users = registry.total_users + 1;

        event::emit(UserRegistered {
            user_address: sender,
            osmosis_address,
            registration_time: TxContext::timestamp_ms(ctx),
        });
    }

    /// Check if an Osmosis address is registered
    public fun is_osmosis_address_registered(
        registry: &Registry,
        osmosis_address: &vector<u8>,
    ): bool {
        table::contains(&registry.osmosis_lookup, osmosis_address)
    }
}
