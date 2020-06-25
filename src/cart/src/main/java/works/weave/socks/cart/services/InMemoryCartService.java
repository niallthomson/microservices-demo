package works.weave.socks.cart.services;

import works.weave.socks.cart.repositories.CartEntity;
import works.weave.socks.cart.repositories.ItemEntity;

import java.util.List;
import java.util.Optional;

public class InMemoryCartService implements CartService {
    @Override
    public CartEntity get(String customerId) {
        return null;
    }

    @Override
    public void delete(String customerId) {

    }

    @Override
    public CartEntity merge(String sessionId, String customerId) {
        return null;
    }

    @Override
    public ItemEntity add(String customerId, String itemId, int quantity, float unitPrice) {
        return null;
    }

    @Override
    public List<? extends ItemEntity> items(String customerId) {
        return null;
    }

    @Override
    public Optional<? extends ItemEntity> item(String customerId, String itemId) {
        return Optional.empty();
    }

    @Override
    public void deleteItem(String customerId, String itemId) {

    }

    @Override
    public Optional<? extends ItemEntity> update(String customerId, String itemId, int quantity, float unitPrice) {
        return Optional.empty();
    }
}
