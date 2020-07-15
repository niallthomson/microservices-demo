package com.watchn.ui.web;

import com.watchn.ui.clients.carts.api.CartsApi;
import com.watchn.ui.clients.catalog.api.CatalogApi;
import com.watchn.ui.services.MetadataService;
import com.watchn.ui.web.util.PageInfo;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.server.reactive.ServerHttpRequest;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.reactive.function.client.WebClientResponseException;
import org.springframework.web.server.ResponseStatusException;
import reactor.core.publisher.Flux;
import reactor.util.retry.Retry;
import reactor.util.retry.RetryBackoffSpec;
import reactor.util.retry.RetrySpec;

import java.net.ConnectException;
import java.time.Duration;
import java.util.Collections;

@Controller
@RequestMapping("/catalog")
@Slf4j
public class CatalogController extends BaseController {

    private CatalogApi catalogApi;

    public CatalogController(@Autowired CatalogApi catalogApi, @Autowired CartsApi cartsApi, @Autowired MetadataService metadataService) {
        super(cartsApi, metadataService);

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

        model.addAttribute("page", catalogApi
                .catalogueSizeGet(tag)
                .retryWhen(retrySpec("get catalog"))
                .map(r -> new PageInfo(page, size, r.getSize()))
        );

        populateCommon(request, model);

        return "catalog";
    }

    @GetMapping("/{id}")
    public String item(@PathVariable String id,
                       ServerHttpRequest request, Model model) {
        model.addAttribute("item", catalogApi.catalogueProductIdGet(id)
                .retryWhen(retrySpec("get catalog item"))
        );
        model.addAttribute("recommendations", catalogApi.catalogueGet("", "", 1, 3).collectList().map(l -> {
            Collections.shuffle(l);
            return l;
        }).flatMapMany(Flux::fromIterable));

        populateCommon(request, model);

        return "detail";
    }
}
