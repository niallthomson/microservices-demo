package com.watchn.ui.web;

import com.watchn.ui.clients.carts.api.CartsApi;
import com.watchn.ui.clients.carts.api.ItemsApi;
import com.watchn.ui.clients.carts.model.Item;
import com.watchn.ui.clients.catalog.api.CatalogApi;
import com.watchn.ui.services.MetadataService;
import com.watchn.ui.web.payload.Cart;
import com.watchn.ui.web.payload.CartChangeRequest;
import com.watchn.ui.web.payload.CartItem;
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

@Controller
@RequestMapping("/cart")
@Slf4j
public class CartController extends BaseController {

    private ItemsApi itemsApi;

    private CatalogApi catalogApi;

    public CartController(@Autowired ItemsApi itemsApi, @Autowired CartsApi cartsApi, @Autowired CatalogApi catalogApi, @Autowired MetadataService metadataService) {
        super(cartsApi, metadataService);

        this.itemsApi = itemsApi;
        this.catalogApi = catalogApi;
    }

    @GetMapping
    public String cart(ServerHttpRequest request, Model model) {
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

        return "cart";
    }

    @PostMapping
    public Mono<String> add(@ModelAttribute CartChangeRequest addRequest, ServerHttpRequest request) {
        String sessionId = getSessionID(request);

        return this.catalogApi.catalogueProductIdGet(addRequest.getProductId())
                .retryWhen(retrySpec("get catalog item"))
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
