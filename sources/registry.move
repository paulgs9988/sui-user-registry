module user_registry::registry {
    use sui::object::{Self, UID};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use sui::table::{Self, Table};
    use sui::event;

    // ===== Events =====
    struct UserRegistered has copy, drop {
        user_address: address,
        registration_time: u64
    }

    // ===== Storage =====
    struct Registry has key {
        id: UID,
        users: Table<address, User>,
        total_users: u64
    }

    struct User has store {
        address: address,
        is_registered: bool,
        registration_time: u64,
        external_chain_address: vector<u8>
    }

    // ===== Error Constants =====
    const EUserAlreadyExists: u64 = 0;
    //const EUserNotFound: u64 = 1;

    // ===== Constructor =====
    fun init(ctx: &mut TxContext) {
        let registry = Registry {
            id: object::new(ctx),
            users: table::new(ctx),
            total_users: 0
        };
        transfer::share_object(registry)
    }

    // ===== Public Functions =====
    public entry fun register_user(
        registry: &mut Registry,
        ctx: &mut TxContext
    ) {
        let sender = tx_context::sender(ctx);
        assert!(!table::contains(&registry.users, sender), EUserAlreadyExists);

        let user = User {
            address: sender,
            is_registered: true,
            registration_time: tx_context::epoch(ctx),
            external_chain_address: vector[]
        };

        table::add(&mut registry.users, sender, user);
        registry.total_users = registry.total_users + 1;

        event::emit(UserRegistered {
            user_address: sender,
            registration_time: tx_context::epoch(ctx)
        });
    }

    // ===== View Functions =====
    public fun is_registered(registry: &Registry, user_address: address): bool {
        table::contains(&registry.users, user_address)
    }

    public fun get_total_users(registry: &Registry): u64 {
        registry.total_users
    }
}