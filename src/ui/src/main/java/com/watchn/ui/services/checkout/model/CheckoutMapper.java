package com.watchn.ui.services.checkout.model;

import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper
public interface CheckoutMapper {
    @Mapping(source = "request.subtotal", target = "subtotal")
    @Mapping(source = "shippingRates.rates", target = "shippingOptions")
    Checkout checkout(com.watchn.ui.clients.checkout.model.Checkout checkout);

    CheckoutSubmitted submitted(com.watchn.ui.clients.checkout.model.CheckoutSubmitted submitted);

    com.watchn.ui.clients.checkout.model.ShippingAddress clientShippingAddress(ShippingAddress address);
}
