package com.watchn.ui.web;

import com.watchn.ui.clients.carts.api.CartsApi;
import com.watchn.ui.clients.carts.model.Item;
import com.watchn.ui.clients.catalog.api.CatalogApi;
import com.watchn.ui.clients.orders.api.OrdersApi;
import com.watchn.ui.clients.orders.model.Order;
import com.watchn.ui.clients.orders.model.OrderItem;
import com.watchn.ui.services.MetadataService;
import com.watchn.ui.web.payload.Cart;
import com.watchn.ui.web.payload.CartItem;
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
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;
import reactor.util.retry.Retry;

import java.time.Duration;

@Controller
@RequestMapping("/checkout")
@Slf4j
public class CheckoutController extends BaseController {

    private CatalogApi catalogApi;

    private OrdersApi ordersApi;

    public CheckoutController(@Autowired CartsApi cartsApi, @Autowired CatalogApi catalogApi, @Autowired OrdersApi ordersApi, @Autowired MetadataService metadataService) {
        super(cartsApi, metadataService);

        this.catalogApi = catalogApi;
        this.ordersApi = ordersApi;
    }

    @GetMapping
    public String checkout(ServerHttpRequest request, Model model) {
        String sessionId = getSessionID(request);

        model.addAttribute("fullCart", cartsApi.getCart(sessionId)
                .retryWhen(retrySpec("get cart"))
                .flatMapMany(c -> Flux.fromIterable(c.getItems()))
                .flatMap(i -> this.catalogApi.catalogueProductIdGet(i.getItemId())
                        .map(p -> CartItem.from(i, p)))
                .collectList()
                .map(Cart::from)
        );

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

        return cartsApi.getCart(sessionId)
                .retryWhen(retrySpec("get cart")).flatMap(
                cart -> {
                    for(Item item : cart.getItems()) {
                        OrderItem orderItem = new OrderItem()
                                .productId(item.getItemId())
                                .quantity(item.getQuantity())
                                .price(item.getUnitPrice());

                        createOrderRequest.addItemsItem(orderItem);
                    }

                    return this.ordersApi.createOrder(createOrderRequest);
                }
        )
                .doOnNext(o -> {
                    model.addAttribute("order", o);
                })
                .map(o -> this.cartsApi.deleteCart(sessionId))
                .doOnNext(c -> {
                    model.addAttribute("cart", c);
                })
                .thenReturn("order");
    }
}
