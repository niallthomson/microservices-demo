package com.watchn.ui.web;

import com.watchn.ui.clients.carts.api.CartsApi;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpCookie;
import org.springframework.http.server.reactive.ServerHttpRequest;
import org.springframework.ui.Model;
import org.springframework.util.MultiValueMap;
import org.springframework.web.server.WebSession;

@Slf4j
public class BaseController {

    protected CartsApi cartsApi;

    public BaseController(CartsApi cartsApi) {
        this.cartsApi = cartsApi;
    }

    protected void populateCart(ServerHttpRequest request, Model model) {
        String sessionId = getSessionID(request);

        model.addAttribute("cart", cartsApi.getCart(sessionId));
    }

    protected String getSessionID(ServerHttpRequest request) {
        return request.getHeaders().getFirst("X-Session-ID");
    }
}
