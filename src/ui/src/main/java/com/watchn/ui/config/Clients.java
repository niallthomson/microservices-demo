package com.watchn.ui.config;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.watchn.ui.clients.carts.api.CartsApi;
import com.watchn.ui.clients.carts.api.ItemsApi;
import com.watchn.ui.clients.catalog.RFC3339DateFormat;
import com.watchn.ui.clients.catalog.api.CatalogApi;
import com.watchn.ui.clients.checkout.api.CheckoutApi;
import com.watchn.ui.clients.orders.api.OrdersApi;
import io.netty.channel.ChannelOption;
import io.netty.handler.timeout.ReadTimeoutHandler;
import io.netty.handler.timeout.WriteTimeoutHandler;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.MediaType;
import org.springframework.http.client.reactive.ReactorClientHttpConnector;
import org.springframework.http.codec.json.Jackson2JsonDecoder;
import org.springframework.http.codec.json.Jackson2JsonEncoder;
import org.springframework.web.reactive.function.client.ExchangeFilterFunction;
import org.springframework.web.reactive.function.client.ExchangeStrategies;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;
import reactor.netty.http.client.HttpClient;
import reactor.netty.tcp.TcpClient;

import java.text.DateFormat;
import java.util.TimeZone;

@Configuration
@Slf4j
public class Clients {

    @Value("${endpoints.catalog}")
    private String catalogEndpoint;

    @Value("${endpoints.carts}")
    private String cartsEndpoint;

    @Value("${endpoints.orders}")
    private String ordersEndpoint;

    @Value("${endpoints.checkout}")
    private String checkoutEndpoint;

    @Value("${endpoints.logging}")
    private boolean logging;

    private WebClient createWebClient(ObjectMapper mapper, WebClient.Builder webClientBuilder) {
        TcpClient tcpClient = TcpClient.create()
                .option(ChannelOption.CONNECT_TIMEOUT_MILLIS, 1000) // Connection Timeout
                .doOnConnected(connection ->
                        connection.addHandlerLast(new ReadTimeoutHandler(10)) // Read Timeout
                                .addHandlerLast(new WriteTimeoutHandler(10))); // Write Timeout
        ExchangeStrategies strategies = ExchangeStrategies
                .builder()
                .codecs(clientDefaultCodecsConfigurer -> {
                    clientDefaultCodecsConfigurer.defaultCodecs().jackson2JsonEncoder(new Jackson2JsonEncoder(mapper, MediaType.APPLICATION_JSON));
                    clientDefaultCodecsConfigurer.defaultCodecs().jackson2JsonDecoder(new Jackson2JsonDecoder(mapper, MediaType.APPLICATION_JSON));
                }).build();

        return webClientBuilder
                .clientConnector(new ReactorClientHttpConnector(HttpClient.from(tcpClient)))
                .exchangeStrategies(strategies)
                .filters( exchangeFilterFunctions -> {
                    if(logging) {
                        exchangeFilterFunctions.add(logRequest());
                        exchangeFilterFunctions.add(logResponse());
                    }
                })
                .build();
    }

    private static ExchangeFilterFunction logRequest() {
        return ExchangeFilterFunction.ofRequestProcessor(clientRequest -> {
            log.info("Request: {} {}", clientRequest.method(), clientRequest.url());
            clientRequest.headers().forEach((name, values) -> values.forEach(value -> log.info("{}={}", name, value)));
            return Mono.just(clientRequest);
        });
    }

    private static ExchangeFilterFunction logResponse() {
        return ExchangeFilterFunction.ofResponseProcessor(clientResponse -> {
            log.info("Response: {} {}", clientResponse.rawStatusCode(), clientResponse.bodyToMono(String.class));
            return Mono.just(clientResponse);
        });
    }

    private DateFormat createDefaultDateFormat() {
        DateFormat dateFormat = new RFC3339DateFormat();
        dateFormat.setTimeZone(TimeZone.getTimeZone("UTC"));
        return dateFormat;
    }

    @Bean
    public ObjectMapper apiClientsObjectMapper() {
        return new ObjectMapper();
    }

    @Bean
    public CatalogApi catalogApi(WebClient.Builder webClientBuilder) {
        ObjectMapper mapper = apiClientsObjectMapper();

        return new CatalogApi(new com.watchn.ui.clients.catalog.ApiClient(this.createWebClient(mapper, webClientBuilder), mapper, createDefaultDateFormat())
                .setBasePath(this.catalogEndpoint));
    }

    @Bean
    public CartsApi cartsApi(WebClient.Builder webClientBuilder) {
        ObjectMapper mapper = apiClientsObjectMapper();

        return new CartsApi(new com.watchn.ui.clients.carts.ApiClient(this.createWebClient(mapper, webClientBuilder), mapper, createDefaultDateFormat())
                .setBasePath(this.cartsEndpoint));
    }

    @Bean
    public ItemsApi itemsApi(WebClient.Builder webClientBuilder) {
        ObjectMapper mapper = apiClientsObjectMapper();

        return new ItemsApi(new com.watchn.ui.clients.carts.ApiClient(this.createWebClient(mapper, webClientBuilder), mapper, createDefaultDateFormat())
                .setBasePath(this.cartsEndpoint));
    }

    @Bean
    public OrdersApi ordersApi(WebClient.Builder webClientBuilder) {
        ObjectMapper mapper = apiClientsObjectMapper();

        return new OrdersApi(new com.watchn.ui.clients.orders.ApiClient(this.createWebClient(mapper, webClientBuilder), mapper, createDefaultDateFormat())
                .setBasePath(this.ordersEndpoint));
    }

    @Bean
    public CheckoutApi checkoutApi(WebClient.Builder webClientBuilder) {
        ObjectMapper mapper = apiClientsObjectMapper();

        return new CheckoutApi(new com.watchn.ui.clients.checkout.ApiClient(this.createWebClient(mapper, webClientBuilder), mapper, createDefaultDateFormat())
                .setBasePath(this.checkoutEndpoint));
    }
}
