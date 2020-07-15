package com.watchn.ui.web;

import com.watchn.ui.clients.carts.api.CartsApi;
import com.watchn.ui.services.MetadataService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.server.reactive.ServerHttpRequest;
import org.springframework.ui.Model;
import reactor.util.retry.Retry;
import reactor.util.retry.RetryBackoffSpec;

import java.net.ConnectException;
import java.time.Duration;

@Slf4j
public class BaseController {

    protected CartsApi cartsApi;

    protected MetadataService metadataService;

    public BaseController(CartsApi cartsApi, MetadataService metadataService) {
        this.cartsApi = cartsApi;
        this.metadataService = metadataService;
    }

    protected static RetryBackoffSpec retrySpec(String path) {
        return Retry
                .backoff(3, Duration.ofSeconds(1))
                .doBeforeRetry(context -> log.warn("Retrying {}", path));
    }

    protected void populateCommon(ServerHttpRequest request, Model model) {
        this.populateCart(request, model);
        this.populateMetadata(model);
    }

    protected void populateCart(ServerHttpRequest request, Model model) {
        String sessionId = getSessionID(request);

        model.addAttribute("cart", cartsApi.getCart(sessionId)
                .retryWhen(retrySpec("get cart"))
        );
    }

    protected void populateMetadata(Model model) {
        model.addAttribute("metadata", metadataService.getMetadata());
    }

    protected String getSessionID(ServerHttpRequest request) {
        return request.getHeaders().getFirst("X-Session-ID");
    }
}
