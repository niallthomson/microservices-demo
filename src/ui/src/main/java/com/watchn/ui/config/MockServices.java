package com.watchn.ui.config;

import com.watchn.ui.clients.orders.api.OrdersApi;
import com.watchn.ui.services.carts.CartsService;
import com.watchn.ui.services.carts.MockCartsService;
import com.watchn.ui.services.catalog.CatalogService;
import com.watchn.ui.services.catalog.MockCatalogService;
import com.watchn.ui.services.checkout.CheckoutService;
import com.watchn.ui.services.checkout.MockCheckoutService;
import com.watchn.ui.services.checkout.model.CheckoutMapper;
import com.watchn.ui.services.orders.OrdersService;
import com.watchn.ui.services.orders.WebClientOrdersService;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;

@Configuration
@Profile("stubs")
public class MockServices {

    @Bean
    public CatalogService catalogService() {
        return new MockCatalogService();
    }

    @Bean
    public CartsService cartsService(CatalogService catalogService) {
        return new MockCartsService(catalogService);
    }

    @Bean
    public CheckoutService checkoutService(CartsService cartsService, CheckoutMapper mapper) {
        return new MockCheckoutService(mapper, cartsService);
    }

    @Bean
    public OrdersService ordersService(OrdersApi ordersApi, CartsService cartsService) {
        return new WebClientOrdersService(ordersApi, cartsService);
    }
}
