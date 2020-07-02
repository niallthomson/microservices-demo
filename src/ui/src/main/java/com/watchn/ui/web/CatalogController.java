package com.watchn.ui.web;

import com.watchn.ui.clients.carts.api.CartsApi;
import com.watchn.ui.clients.catalog.api.CatalogApi;
import com.watchn.ui.web.util.PageInfo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.server.reactive.ServerHttpRequest;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import reactor.core.publisher.Flux;

import java.util.Collections;

@Controller
@RequestMapping("/catalog")
public class CatalogController extends BaseController {

    private CatalogApi catalogApi;

    public CatalogController(@Autowired CatalogApi catalogApi, @Autowired CartsApi cartsApi) {
        super(cartsApi);
        //this.catalogApi = new CatalogApi(new ApiClient().setBasePath("http://localhost:8081"));
        this.catalogApi = catalogApi;
    }

    @GetMapping("")
    public String catalog(@RequestParam(required = false, defaultValue = "") String tag,
                          @RequestParam(required = false, defaultValue = "1") int page,
                          @RequestParam(required = false, defaultValue = "3") int size,
                          ServerHttpRequest request, Model model) {
        model.addAttribute("tags", catalogApi.catalogueTagsGet());
        model.addAttribute("selectedTag", tag);

        model.addAttribute("catalog", catalogApi.catalogueGet(tag, "", page, size));

        model.addAttribute("page", catalogApi.catalogueSizeGet(tag).map(r -> new PageInfo(page, size, r.getSize())));

        populateCart(request, model);

        return "catalog";
    }

    @GetMapping("/{id}")
    public String item(@PathVariable String id,
                       ServerHttpRequest request, Model model) {
        model.addAttribute("item", catalogApi.catalogueProductIdGet(id));
        model.addAttribute("recommendations", catalogApi.catalogueGet("", "", 1, 3).collectList().map(l -> {
            Collections.shuffle(l);
            return l;
        }).flatMapMany(Flux::fromIterable));

        populateCart(request, model);

        return "detail";
    }
}
