package works.weave.socks.cart.configuration;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;
import works.weave.socks.cart.services.CartService;
import works.weave.socks.cart.services.InMemoryCartService;

@Configuration
@Profile("!mongo & !dynamodb")
public class InMemoryConfiguration {
    @Bean
    public CartService cartService() {
        return new InMemoryCartService();
    }
}
