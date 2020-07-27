package com.watchn.ui.web;

import com.watchn.ui.clients.orders.model.Order;
import com.watchn.ui.services.Metadata;
import com.watchn.ui.services.carts.CartsService;
import com.watchn.ui.services.orders.OrdersService;
import com.watchn.ui.web.payload.OrderRequest;
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

    private CartsService cartsService;

    private OrdersService ordersService;

    public CheckoutController(@Autowired CartsService cartsService, @Autowired OrdersService ordersService, @Autowired Metadata metadata) {
        super(cartsService, metadata);

        this.cartsService = cartsService;
        this.ordersService = ordersService;
    }

    @GetMapping
    public String checkout(ServerHttpRequest request, Model model) {
        String sessionId = getSessionID(request);

        model.addAttribute("fullCart", this.cartsService.getCart(sessionId));

        this.populateCommon(request, model);

        return "checkout";
    }

    @PostMapping
    public Mono<String> order(@ModelAttribute OrderRequest orderRequest, ServerHttpRequest request, Model model) {
        String sessionId = getSessionID(request);

        Order createOrderRequest = new Order();
        createOrderRequest.setFirstName(orderRequest.getFirstName());
        createOrderRequest.setLastName(orderRequest.getLastName());
        createOrderRequest.setEmail(orderRequest.getEmail());

        populateMetadata(model);

        return this.ordersService.order(sessionId, orderRequest.getFirstName(), orderRequest.getLastName(), orderRequest.getEmail())
                .doOnNext(o -> {
                    model.addAttribute("order", o);
                })
                .map(o -> this.cartsService.deleteCart(sessionId))
                .doOnNext(c -> {
                    model.addAttribute("cart", c);
                })
                .thenReturn("order");
    }
}
