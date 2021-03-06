package com.watchn.ui.services.carts;

import com.watchn.ui.clients.carts.api.CartsApi;
import com.watchn.ui.clients.carts.api.ItemsApi;
import com.watchn.ui.clients.carts.model.Item;
import com.watchn.ui.services.carts.model.Cart;
import com.watchn.ui.services.carts.model.CartItem;
import com.watchn.ui.services.catalog.CatalogService;
import com.watchn.ui.services.catalog.model.Product;
import com.watchn.ui.util.RetryUtils;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.util.List;

public class WebClientCartsService implements CartsService {

    private CartsApi cartsApi;

    private ItemsApi itemsApi;

    private CatalogService catalogService;

    public WebClientCartsService(CartsApi cartsApi, ItemsApi itemsApi, CatalogService catalogService) {
        this.cartsApi = cartsApi;
        this.itemsApi = itemsApi;
        this.catalogService = catalogService;
    }

    @Override
    public Mono<Cart> getCart(String sessionId) {
        return this.createCart(cartsApi.getCart(sessionId)
                .retryWhen(RetryUtils.apiClientRetrySpec("get cart")));
    }

    @Override
    public Mono<Cart> deleteCart(String sessionId) {
        return this.createCart(this.cartsApi.deleteCart(sessionId));
    }

    @Override
    public Mono<Void> addItem(String sessionId, String productId) {
        return this.catalogService.getProduct(productId)
                .map(p -> new Item().itemId(p.getId()).quantity(1).unitPrice(p.getPrice()))
                .flatMap(i -> this.itemsApi.addItem(sessionId, i)).then();
    }

    @Override
    public Mono<Void> removeItem(String sessionId, String productId) {
        return this.itemsApi.deleteItem(sessionId, productId);
    }

    private Mono<Cart> createCart(Mono<com.watchn.ui.clients.carts.model.Cart> cart) {
        return cart.flatMapMany(c -> Flux.fromIterable(c.getItems()))
                .flatMap(i -> this.catalogService.getProduct(i.getItemId())
                        .map(p -> { return this.toCartItem(i, p); }))
                .collectList()
                .map(this::toCart);
    }

    private Cart toCart(List<CartItem> items) {
        return new Cart(items);
    }

    private CartItem toCartItem(Item item, Product product) {
        return new CartItem(product.getId(),
                item.getQuantity(), product.getPrice(),
                product.getName(), product.getImageUrl());
    }
}
