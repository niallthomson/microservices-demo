package com.watchn.ui.config;

import com.watchn.ui.clients.carts.api.CartsApi;
import com.watchn.ui.clients.carts.api.ItemsApi;
import com.watchn.ui.clients.catalog.api.CatalogApi;
import com.watchn.ui.clients.orders.api.OrdersApi;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class Clients {

    @Value("${endpoints.catalog}")
    private String catalogEndpoint;

    @Value("${endpoints.carts}")
    private String cartsEndpoint;

    @Value("${endpoints.orders}")
    private String ordersEndpoint;

    @Bean
    public CatalogApi catalogApi() {
        return new CatalogApi(new com.watchn.ui.clients.catalog.ApiClient()
                .setBasePath(this.catalogEndpoint));
    }

    @Bean
    public CartsApi cartsApi() {
        return new CartsApi(new com.watchn.ui.clients.carts.ApiClient()
                .setBasePath(this.cartsEndpoint));
    }

    @Bean
    public ItemsApi itemsApi() {
        return new ItemsApi(new com.watchn.ui.clients.carts.ApiClient()
                .setBasePath(this.cartsEndpoint));
    }

    @Bean
    public OrdersApi ordersApi() {
        return new OrdersApi(new com.watchn.ui.clients.orders.ApiClient()
                .setBasePath(this.ordersEndpoint));
    }
}
