package com.watchn.ui.config;

import com.watchn.ui.clients.carts.api.CartsApi;
import com.watchn.ui.clients.carts.api.ItemsApi;
import com.watchn.ui.clients.catalog.api.CatalogApi;
import com.watchn.ui.clients.orders.api.OrdersApi;
import com.watchn.ui.services.carts.CartsService;
import com.watchn.ui.services.carts.WebClientCartsService;
import com.watchn.ui.services.catalog.CatalogService;
import com.watchn.ui.services.catalog.WebClientCatalogService;
import com.watchn.ui.services.orders.OrdersService;
import com.watchn.ui.services.orders.WebClientOrdersService;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
@ConditionalOnProperty(name = "watchn.ui.stubs", havingValue = "false")
public class WebClientServices {

    @Bean
    public CatalogService catalogService(CatalogApi catalogApi) {
        return new WebClientCatalogService(catalogApi);
    }

    @Bean
    public CartsService cartsService(CartsApi cartsApi, ItemsApi itemsApi, CatalogService catalogService) {
        return new WebClientCartsService(cartsApi, itemsApi, catalogService);
    }

    @Bean
    public OrdersService ordersService(OrdersApi ordersApi, CartsService cartsService) {
        return new WebClientOrdersService(ordersApi, cartsService);
    }
}
