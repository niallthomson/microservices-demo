package com.watchn.ui.web.util;

import com.watchn.ui.services.MetadataService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
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
public class RegionHeaderFilter implements WebFilter {

    @Autowired
    private MetadataService metadataService;

    @Override
    public Mono<Void> filter(ServerWebExchange serverWebExchange,
                             WebFilterChain webFilterChain) {
            serverWebExchange.getResponse()
                    .getHeaders().add("X-Watchn-Region", this.metadataService.getMetadata().getRegion());

        return webFilterChain.filter(serverWebExchange);
    }
}
