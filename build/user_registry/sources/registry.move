module user_registry::registry {
    use sui::object::{Self, UID};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use std::vector;

    // ===== Storage =====
    struct Registry has key {
        id: UID,
        allowed_addresses: vector<vector<u8>>,  // List of Osmosis addresses
    }

    // ===== Constructor =====
    fun init(ctx: &mut TxContext) {
        let registry = Registry {
            id: object::new(ctx),
            allowed_addresses: vector::empty(),
        };
        transfer::share_object(registry)
    }

    // ===== Public Functions =====
    
    /// Add a new Osmosis address to the registry
    public entry fun add_osmosis_address(
        registry: &mut Registry,
        osmosis_address: vector<u8>
    ) {
        vector::push_back(&mut registry.allowed_addresses, osmosis_address);
    }

    /// Check if an Osmosis address is in the registry
    public fun is_address_allowed(
        registry: &Registry, 
        osmosis_address: vector<u8>
    ): bool {
        let i = 0;
        let len = vector::length(&registry.allowed_addresses);
        while (i < len) {
            let addr = vector::borrow(&registry.allowed_addresses, i);
            if (addr == &osmosis_address) {
                return true
            };
            i = i + 1;
        };
        false
    }
}