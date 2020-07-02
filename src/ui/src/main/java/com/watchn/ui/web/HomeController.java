package com.watchn.ui.web;

import com.watchn.ui.clients.carts.api.CartsApi;
import com.watchn.ui.clients.catalog.api.CatalogApi;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.server.reactive.ServerHttpRequest;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.thymeleaf.spring5.context.webflux.ReactiveDataDriverContextVariable;

@Controller
public class HomeController extends BaseController {

    private CatalogApi catalogApi;

    public HomeController(@Autowired CatalogApi catalogApi, @Autowired CartsApi cartsApi) {
        super(cartsApi);
        this.catalogApi = catalogApi;
    }

    @GetMapping("/")
    public String index() {
        return "redirect:/home";
    }

    @GetMapping("/home")
    public String home(final Model model, final ServerHttpRequest request) {
        model.addAttribute("catalog", new ReactiveDataDriverContextVariable(
                catalogApi.catalogueGet("", "", 1, 5)));

        populateCart(request, model);

        return "home";
    }
}
