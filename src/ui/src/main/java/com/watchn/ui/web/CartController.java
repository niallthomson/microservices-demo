package com.watchn.ui.web;

import com.watchn.ui.clients.carts.api.CartsApi;
import com.watchn.ui.clients.carts.api.ItemsApi;
import com.watchn.ui.clients.carts.model.Item;
import com.watchn.ui.clients.catalog.api.CatalogApi;
import com.watchn.ui.web.payload.Cart;
import com.watchn.ui.web.payload.CartItem;
import com.watchn.ui.web.payload.CartChangeRequest;
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

@Controller
@RequestMapping("/cart")
public class CartController extends BaseController {

    private ItemsApi itemsApi;

    private CatalogApi catalogApi;

    public CartController(@Autowired ItemsApi itemsApi, @Autowired CartsApi cartsApi, @Autowired CatalogApi catalogApi) {
        super(cartsApi);

        this.itemsApi = itemsApi;
        this.catalogApi = catalogApi;
    }

    @GetMapping
    public String cart(ServerHttpRequest request, Model model) {
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

        this.populateCart(request, model);

        return "cart";
    }

    @PostMapping
    public Mono<String> add(@ModelAttribute CartChangeRequest addRequest, ServerHttpRequest request) {
        String sessionId = getSessionID(request);

        return this.catalogApi.catalogueProductIdGet(addRequest.getProductId())
                .map(p -> new Item().itemId(p.getId()).quantity(1).unitPrice(p.getPrice()))
                .flatMap(i -> this.itemsApi.addItem(sessionId, i))
                .thenReturn("redirect:/cart");
    }

    @PostMapping("/remove")
    public Mono<String> remove(@ModelAttribute CartChangeRequest addRequest, ServerHttpRequest request) {
        String sessionId = getSessionID(request);

        return this.itemsApi.deleteItem(sessionId, addRequest.getProductId())
                .thenReturn("redirect:/cart");
    }
}
