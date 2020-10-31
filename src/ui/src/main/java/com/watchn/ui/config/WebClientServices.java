package com.watchn.ui.config;

import com.watchn.ui.clients.carts.api.CartsApi;
import com.watchn.ui.clients.carts.api.ItemsApi;
import com.watchn.ui.clients.catalog.api.CatalogApi;
import com.watchn.ui.clients.checkout.api.CheckoutApi;
import com.watchn.ui.clients.orders.api.OrdersApi;
import com.watchn.ui.services.carts.CartsService;
import com.watchn.ui.services.carts.WebClientCartsService;
import com.watchn.ui.services.catalog.CatalogService;
import com.watchn.ui.services.catalog.WebClientCatalogService;
import com.watchn.ui.services.catalog.model.CatalogMapper;
import com.watchn.ui.services.checkout.CheckoutService;
import com.watchn.ui.services.checkout.WebClientCheckoutService;
import com.watchn.ui.services.checkout.model.CheckoutMapper;
import com.watchn.ui.services.orders.OrdersService;
import com.watchn.ui.services.orders.WebClientOrdersService;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;

@Configuration
@Profile("!stubs")
public class WebClientServices {

    @Bean
    public CatalogService catalogService(CatalogApi catalogApi, CatalogMapper mapper) {
        return new WebClientCatalogService(catalogApi, mapper);
    }

    @Bean
    public CartsService cartsService(CartsApi cartsApi, ItemsApi itemsApi, CatalogService catalogService) {
        return new WebClientCartsService(cartsApi, itemsApi, catalogService);
    }

    @Bean
    public CheckoutService checkoutService(CheckoutApi api, CheckoutMapper mapper, CartsService cartsService) {
        return new WebClientCheckoutService(api, mapper, cartsService);
    }

    @Bean
    public OrdersService ordersService(OrdersApi ordersApi, CartsService cartsService) {
        return new WebClientOrdersService(ordersApi, cartsService);
    }
}
