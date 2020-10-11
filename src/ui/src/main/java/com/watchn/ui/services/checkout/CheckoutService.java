package com.watchn.ui.services.checkout;

import com.watchn.ui.services.checkout.model.Checkout;
import com.watchn.ui.services.checkout.model.CheckoutSubmitted;
import com.watchn.ui.services.checkout.model.CheckoutSubmittedResponse;
import reactor.core.publisher.Mono;

public interface CheckoutService {
    Mono<Checkout> get(String sessionId);

    Mono<Checkout> create(String sessionId, String customerEmail);

    Mono<CheckoutSubmittedResponse> submit(String sessionId);
}
