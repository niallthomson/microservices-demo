package com.watchn.ui.web;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.reactive.function.client.ExchangeStrategies;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

@RestController
public class CatalogImageController {

    @Value("${endpoints.catalog}")
    private String catalogEndpoint;

    @GetMapping(value = "/catalogue/images/{image}", produces = MediaType.IMAGE_JPEG_VALUE)
    public Mono<byte[]> catalogueImage(@PathVariable String image) {
        return WebClient.builder()
            .exchangeStrategies(ExchangeStrategies.builder()
            .codecs(configurer -> configurer
                    .defaultCodecs()
                    .maxInMemorySize(16 * 1024 * 1024))
            .build())
                .baseUrl(this.catalogEndpoint+"/catalogue/images/"+image)
            .build().get()
                .accept(MediaType.IMAGE_JPEG)
                .retrieve()
                .bodyToMono(byte[].class);

        /*return WebClient.create("https://greatatmosphere.files.wordpress.com/2013/02/great-atmosphere-149-tenaya-lake-yosemite-national-park-2.jpg")
                .get()
                .accept(MediaType.IMAGE_JPEG)
                .retrieve()
                .bodyToMono(byte[].class);*/
    }
}
