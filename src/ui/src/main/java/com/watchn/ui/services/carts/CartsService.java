package com.watchn.ui.services.carts;

import com.watchn.ui.services.carts.model.Cart;
import reactor.core.publisher.Mono;

public interface CartsService {
    Mono<Cart> getCart(String sessionId);

    Mono<Cart> deleteCart(String sessionId);

    Mono<Void> addItem(String sessionId, String productId);

    Mono<Void> removeItem(String sessionId, String productId);
}
