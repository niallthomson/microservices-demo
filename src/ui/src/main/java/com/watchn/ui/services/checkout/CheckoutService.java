package com.watchn.ui.services.checkout;

import com.watchn.ui.services.checkout.model.Checkout;
import com.watchn.ui.services.checkout.model.CheckoutSubmitted;
import com.watchn.ui.services.checkout.model.CheckoutSubmittedResponse;
import com.watchn.ui.services.checkout.model.ShippingAddress;
import reactor.core.publisher.Mono;

public interface CheckoutService {
    Mono<Checkout> get(String sessionId);

    Mono<Checkout> create(String sessionId);

    Mono<Checkout> shipping(String sessionId, String customerEmail, ShippingAddress shippingAddress);

    Mono<Checkout> delivery(String sessionId, String token);

    Mono<CheckoutSubmittedResponse> submit(String sessionId);
}
