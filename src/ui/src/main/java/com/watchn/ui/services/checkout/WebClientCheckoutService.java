package com.watchn.ui.services.checkout;

import com.watchn.ui.clients.checkout.api.CheckoutApi;
import com.watchn.ui.clients.checkout.model.CheckoutRequest;
import com.watchn.ui.clients.checkout.model.ShippingAddress;
import com.watchn.ui.services.carts.CartsService;
import com.watchn.ui.services.carts.model.Cart;
import com.watchn.ui.services.checkout.model.Checkout;
import com.watchn.ui.services.checkout.model.CheckoutMapper;
import com.watchn.ui.services.checkout.model.CheckoutSubmittedResponse;
import com.watchn.ui.util.RetryUtils;
import reactor.core.publisher.Mono;

import java.util.ArrayList;

public class WebClientCheckoutService implements CheckoutService {

    private final CheckoutApi api;
    private final CheckoutMapper mapper;
    private final CartsService cartsService;

    public WebClientCheckoutService(CheckoutApi api, CheckoutMapper mapper, CartsService cartsService) {
        this.api = api;
        this.mapper = mapper;

        this.cartsService = cartsService;
    }

    @Override
    public Mono<Checkout> get(String sessionId) {
        return api.checkoutControllerGetCheckout(sessionId)
            .retryWhen(RetryUtils.apiClientRetrySpec("get checkout"))
            .map(mapper::checkout);
    }

    @Override
    public Mono<Checkout> create(String sessionId, String customerEmail) {
        Mono<Cart> cart = cartsService.getCart(sessionId);

        return cart.flatMap(c -> {
            ShippingAddress address = new ShippingAddress();
            address.address1("123123");
            address.city("bla");
            address.state("AS");
            address.zip("12345");

            CheckoutRequest request = new CheckoutRequest();
            request.customerEmail(customerEmail);
            request.subtotal(c.getSubtotal());
            request.setShippingAddress(address);
            request.setItems(new ArrayList<>());

            return api.checkoutControllerUpdateCheckout(sessionId, request)
                .map(mapper::checkout);
        });
    }

    @Override
    public Mono<CheckoutSubmittedResponse> submit(String sessionId) {
        return api.checkoutControllerSubmitCheckout(sessionId)
            .zipWith(this.cartsService.deleteCart(sessionId), (e, f) -> new CheckoutSubmittedResponse(mapper.submitted(e), f));
    }
}
