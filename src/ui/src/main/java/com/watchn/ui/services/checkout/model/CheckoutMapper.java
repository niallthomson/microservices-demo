package com.watchn.ui.services.checkout.model;

import com.watchn.ui.services.carts.model.CartItem;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper
public interface CheckoutMapper {
    @Mapping(source = "request.items", target = "items")
    @Mapping(source = "request.subtotal", target = "subtotal")
    @Mapping(source = "shippingRates.rates", target = "shippingOptions")
    Checkout checkout(com.watchn.ui.clients.checkout.model.Checkout checkout);

    CheckoutSubmitted submitted(com.watchn.ui.clients.checkout.model.CheckoutSubmitted submitted);

    com.watchn.ui.clients.checkout.model.ShippingAddress clientShippingAddress(ShippingAddress address);

    CheckoutItem item(com.watchn.ui.clients.checkout.model.Item clientItem);

    @Mapping(source = "price", target = "unitCost")
    @Mapping(source = "totalPrice", target = "totalCost")
    com.watchn.ui.clients.checkout.model.Item fromCartItem(CartItem cartItem);
}
