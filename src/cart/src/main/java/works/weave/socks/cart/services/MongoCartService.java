package works.weave.socks.cart.services;

import lombok.extern.slf4j.Slf4j;
import works.weave.socks.cart.repositories.ItemEntity;
import works.weave.socks.cart.repositories.mongo.MongoCartRepository;
import works.weave.socks.cart.repositories.mongo.MongoItemRepository;
import works.weave.socks.cart.repositories.mongo.entities.MongoCartEntity;
import works.weave.socks.cart.repositories.mongo.entities.MongoItemEntity;

import java.util.List;
import java.util.Optional;

@Slf4j
public class MongoCartService implements CartService {

    private MongoCartRepository cartRepository;

    private MongoItemRepository itemRepository;

    public MongoCartService(MongoCartRepository cartRepository, MongoItemRepository itemRepository) {
        this.cartRepository = cartRepository;
        this.itemRepository = itemRepository;
    }

    private MongoCartEntity create(String customerId) {
        log.error("Creating new cart for {}", customerId);

        return cartRepository.save(new MongoCartEntity(customerId));
    }

    @Override
    public MongoCartEntity get(String customerId) {
        return cartRepository.findById(customerId)
                .orElseGet(() -> this.create(customerId));
    }

    @Override
    public void delete(String customerId) {
        log.error("Deleting cart for {}", customerId);

        this.cartRepository.deleteById(customerId);
    }

    @Override
    public MongoCartEntity merge(String sessionId, String customerId) {
        MongoCartEntity sessionCart = this.get(sessionId);
        MongoCartEntity customerCart = this.get(customerId);

        // TODO: Implement this

        this.cartRepository.deleteById(sessionId);

        return customerCart;
    }

    @Override
    public ItemEntity add(String customerId, String itemId, int quantity, int unitPrice) {
        MongoCartEntity cart = get(customerId);

        MongoItemEntity item = new MongoItemEntity(customerId+itemId, itemId, quantity, unitPrice);

        cart.add(item);

        item = itemRepository.save(item);
        cartRepository.save(cart);

        return item;
    }

    @Override
    public List<MongoItemEntity> items(String customerId) {
        return this.get(customerId).getItems();
    }

    @Override
    public Optional<MongoItemEntity> item(String customerId, String itemId) {
        return this.itemRepository.findById(customerId+itemId);
    }

    @Override
    public void deleteItem(String customerId, String itemId) {
        MongoCartEntity cart = this.get(customerId);

        cart.getItems().removeIf(
            item -> item.getItemId().equals(itemId)
        );

        this.cartRepository.save(cart);

        this.itemRepository.deleteById(customerId+itemId);
    }

    @Override
    public Optional<MongoItemEntity> update(String customerId, String itemId, int quantity, int unitPrice) {
        return item(customerId, itemId).map(
            item -> {
                item.setQuantity(quantity);
                item.setUnitPrice(unitPrice);

                return this.itemRepository.save(item);
            }
        );
    }
}
