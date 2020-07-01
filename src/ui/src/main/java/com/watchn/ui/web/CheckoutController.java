package com.watchn.ui.web;

import com.watchn.ui.clients.carts.api.CartsApi;
import com.watchn.ui.clients.carts.api.ItemsApi;
import com.watchn.ui.clients.carts.model.Item;
import com.watchn.ui.clients.catalog.api.CatalogApi;
import com.watchn.ui.web.payload.Cart;
import com.watchn.ui.web.payload.CartChangeRequest;
import com.watchn.ui.web.payload.CartItem;
import com.watchn.ui.web.payload.OrderRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.annotation.Order;
import org.springframework.http.server.reactive.ServerHttpRequest;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

@Controller
@RequestMapping("/checkout")
public class CheckoutController extends BaseController {

    private CatalogApi catalogApi;

    public CheckoutController(@Autowired CartsApi cartsApi, @Autowired CatalogApi catalogApi) {
        super(cartsApi);

        this.catalogApi = catalogApi;
    }

    @GetMapping
    public String checkout(ServerHttpRequest request, Model model) {
        Cart cart = new Cart();

        String sessionId = getSessionID(request);

        model.addAttribute("fullCart", cartsApi.getCart(sessionId)
                .flatMapMany(c -> Flux.fromIterable(c.getItems()))
                .flatMap(i -> {
                    return this.catalogApi.catalogueProductIdGet(i.getItemId()).map(p -> {
                        return CartItem.from(i, p);
                    });
                }).collectList().map(Cart::from)
        );

        this.populateModel(request, model);

        return "checkout";
    }

    @PostMapping
    public String order(@ModelAttribute OrderRequest orderRequest, ServerHttpRequest request, Model model) {
        String sessionId = getSessionID(request);

        return checkout(request, model);
    }
}
