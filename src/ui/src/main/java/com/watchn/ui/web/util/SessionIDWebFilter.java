package com.watchn.ui.web.util;

import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpCookie;
import org.springframework.http.ResponseCookie;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ServerWebExchange;
import org.springframework.web.server.WebFilter;
import org.springframework.web.server.WebFilterChain;
import reactor.core.publisher.Mono;

import java.util.UUID;

@Component
@Slf4j
public class SessionIDWebFilter implements WebFilter {
    @Override
    public Mono<Void> filter(ServerWebExchange serverWebExchange,
                             WebFilterChain webFilterChain) {
        String sessionId;

        HttpCookie cookie = serverWebExchange.getRequest().getCookies().getFirst("SESSIONID");

        if(cookie == null) {
            sessionId = UUID.randomUUID().toString();

            ResponseCookie newCookie = ResponseCookie.from("SESSIONID", sessionId).build();

            serverWebExchange.getResponse()
                    .getCookies().add("SESSIONID", newCookie);
        }
        else {
            sessionId = cookie.getValue();
        }

        serverWebExchange = serverWebExchange.mutate().request(serverWebExchange.getRequest().mutate().header("X-Session-ID", sessionId).build()).build();

        return webFilterChain.filter(serverWebExchange);
    }
}
