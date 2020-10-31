package com.watchn.ui.web;

import com.watchn.ui.clients.orders.model.Order;
import com.watchn.ui.services.Metadata;
import com.watchn.ui.services.carts.CartsService;
import com.watchn.ui.services.checkout.CheckoutService;
import com.watchn.ui.services.checkout.model.ShippingAddress;
import com.watchn.ui.web.payload.CheckoutDeliveryMethodRequest;
import com.watchn.ui.web.payload.OrderRequest;
import com.watchn.ui.web.payload.ShippingAddressRequest;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.server.reactive.ServerHttpRequest;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import reactor.core.publisher.Mono;

@Controller
@RequestMapping("/checkout")
@Slf4j
public class CheckoutController extends BaseController {

    private CheckoutService checkoutService;

    public CheckoutController(@Autowired CartsService cartsService,
                              @Autowired CheckoutService checkoutService,
                              @Autowired Metadata metadata) {
        super(cartsService, metadata);

        this.cartsService = cartsService;
        this.checkoutService = checkoutService;
    }

    @GetMapping
    public Mono<String> checkout(ServerHttpRequest request, Model model) {
        String sessionId = getSessionID(request);

        this.populateCommon(request, model);

        model.addAttribute("shipping", new ShippingAddressRequest());

        return this.checkoutService.create(sessionId)
            .doOnNext(o -> {
                model.addAttribute("checkout", o);
            })
            .thenReturn("checkout-shipping");
    }

    @PostMapping
    public Mono<String> handleShipping(@ModelAttribute("shipping") ShippingAddressRequest shipping, ServerHttpRequest request, Model model) {
        String sessionId = getSessionID(request);

        ShippingAddress address = new ShippingAddress();
        address.setFirstName(shipping.getFirstName());
        address.setLastName(shipping.getLastName());
        address.setAddress1(shipping.getAddress1());
        address.setAddress2(shipping.getAddress2());
        address.setCity(shipping.getCity());
        address.setState(shipping.getState());
        address.setZip(shipping.getZip());
        address.setCountry(shipping.getCountry());

        model.addAttribute("delivery", new CheckoutDeliveryMethodRequest());

        this.populateCommon(request, model);

        return this.checkoutService.shipping(sessionId, address)
            .doOnNext(o -> {
                log.error("{}", o);
                model.addAttribute("checkout", o);
            })
            .thenReturn("checkout-delivery");
    }

    @PostMapping("/delivery")
    public Mono<String> handleDelivery(@ModelAttribute("delivery") CheckoutDeliveryMethodRequest delivery, ServerHttpRequest request, Model model) {
        String sessionId = getSessionID(request);

        this.populateCommon(request, model);

        return this.checkoutService.delivery(sessionId, delivery.getToken())
            .doOnNext(o -> {
                model.addAttribute("checkout", o);
            })
            .thenReturn("checkout-payment");
    }

    @PostMapping("/payment")
    public String handlePayment(ServerHttpRequest request, Model model) {
        String sessionId = getSessionID(request);

        this.populateCommon(request, model);

        model.addAttribute("checkout", this.checkoutService.get(sessionId));

        return "checkout-confirm";
    }

    @PostMapping("/confirm")
    public Mono<String> confirm(ServerHttpRequest request, Model model) {
        String sessionId = getSessionID(request);

        populateMetadata(model);

        return this.checkoutService.submit(sessionId)
            .doOnNext(o -> {
                model.addAttribute("order", o.getSubmitted());
                model.addAttribute("cart", o.getCart());
            })
            .thenReturn("order");
    }
}
