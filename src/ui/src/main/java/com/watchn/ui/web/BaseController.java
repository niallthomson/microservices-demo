package com.watchn.ui.web;

import com.watchn.ui.clients.carts.api.CartsApi;
import com.watchn.ui.services.MetadataService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.server.reactive.ServerHttpRequest;
import org.springframework.ui.Model;
import reactor.util.retry.Retry;

import java.time.Duration;

@Slf4j
public class BaseController {

    protected CartsApi cartsApi;

    protected MetadataService metadataService;

    public BaseController(CartsApi cartsApi, MetadataService metadataService) {
        this.cartsApi = cartsApi;
        this.metadataService = metadataService;
    }

    protected void populateCommon(ServerHttpRequest request, Model model) {
        this.populateCart1(request, model);
        this.populateMetadata(model);
    }

    protected void populateCart1(ServerHttpRequest request, Model model) {
        String sessionId = getSessionID(request);

        model.addAttribute("cart", cartsApi.getCart(sessionId)
                .retryWhen(Retry.backoff(3, Duration.ofSeconds(1))
                .doBeforeRetry(context -> log.warn("Retrying cart get")))
        );
    }

    protected void populateMetadata(Model model) {
        model.addAttribute("metadata", metadataService.getMetadata());
    }

    protected String getSessionID(ServerHttpRequest request) {
        return request.getHeaders().getFirst("X-Session-ID");
    }
}
