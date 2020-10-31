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
import reactor.netty.http.client.HttpClient;
import reactor.netty.tcp.TcpClient;

import java.text.DateFormat;
import java.util.TimeZone;

@Configuration
public class Clients {

    @Value("${endpoints.catalog}")
    private String catalogEndpoint;

    @Value("${endpoints.carts}")
    private String cartsEndpoint;

    @Value("${endpoints.orders}")
    private String ordersEndpoint;

    @Value("${endpoints.checkout}")
    private String checkoutEndpoint;


    private WebClient createWebClient(ObjectMapper mapper) {
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

        return WebClient.builder()
                .clientConnector(new ReactorClientHttpConnector(HttpClient.from(tcpClient)))
                .exchangeStrategies(strategies)
                .build();
    }

    private DateFormat createDefaultDateFormat() {
        DateFormat dateFormat = new RFC3339DateFormat();
        dateFormat.setTimeZone(TimeZone.getTimeZone("UTC"));
        return dateFormat;
    }

    @Bean
    public CatalogApi catalogApi() {
        ObjectMapper mapper = new ObjectMapper();

        return new CatalogApi(new com.watchn.ui.clients.catalog.ApiClient(this.createWebClient(mapper), mapper, createDefaultDateFormat())
                .setBasePath(this.catalogEndpoint));
    }

    @Bean
    public CartsApi cartsApi() {
        ObjectMapper mapper = new ObjectMapper();

        return new CartsApi(new com.watchn.ui.clients.carts.ApiClient(this.createWebClient(mapper), mapper, createDefaultDateFormat())
                .setBasePath(this.cartsEndpoint));
    }

    @Bean
    public ItemsApi itemsApi() {
        ObjectMapper mapper = new ObjectMapper();

        return new ItemsApi(new com.watchn.ui.clients.carts.ApiClient(this.createWebClient(mapper), mapper, createDefaultDateFormat())
                .setBasePath(this.cartsEndpoint));
    }

    @Bean
    public OrdersApi ordersApi() {
        ObjectMapper mapper = new ObjectMapper();

        return new OrdersApi(new com.watchn.ui.clients.orders.ApiClient(this.createWebClient(mapper), mapper, createDefaultDateFormat())
                .setBasePath(this.ordersEndpoint));
    }

    @Bean
    public CheckoutApi checkoutApi() {
        ObjectMapper mapper = new ObjectMapper();

        return new CheckoutApi(new com.watchn.ui.clients.checkout.ApiClient(this.createWebClient(mapper), mapper, createDefaultDateFormat())
                .setBasePath(this.checkoutEndpoint));
    }
}
