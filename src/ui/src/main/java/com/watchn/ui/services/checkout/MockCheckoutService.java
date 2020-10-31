package com.watchn.ui.services.checkout;

import com.watchn.ui.services.carts.CartsService;
import com.watchn.ui.services.carts.model.Cart;
import com.watchn.ui.services.checkout.model.Checkout;
import com.watchn.ui.services.checkout.model.CheckoutMapper;
import com.watchn.ui.services.checkout.model.CheckoutSubmittedResponse;
import com.watchn.ui.services.checkout.model.ShippingAddress;
import reactor.core.publisher.Mono;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

public class MockCheckoutService implements CheckoutService {

    private final CartsService cartsService;
    private final CheckoutMapper mapper;

    private Map<String, Checkout> checkouts = new HashMap<>();

    public MockCheckoutService(CheckoutMapper mapper, CartsService cartsService) {
        this.mapper = mapper;
        this.cartsService = cartsService;
    }

    @Override
    public Mono<Checkout> get(String sessionId) {
        return Mono.just(checkouts.get(sessionId));
    }

    @Override
    public Mono<Checkout> create(String sessionId) {
        Mono<Cart> cart = cartsService.getCart(sessionId);

        return cart.map(c -> {
            Checkout checkout = new Checkout(null,
                "asd",
                c.getSubtotal(),
                10,
                10,
                1234,
                new ArrayList<>());

            this.checkouts.put(sessionId, checkout);

            return checkout;
        });
    }

    @Override
    public Mono<Checkout> shipping(String sessionId, ShippingAddress shippingAddress) {
        return get(sessionId);
    }

    @Override
    public Mono<Checkout> delivery(String sessionId, String token) {
        return get(sessionId);
    }

    @Override
    public Mono<CheckoutSubmittedResponse> submit(String sessionId) {
        return null;
    }
}
