package works.weave.socks.cart.configuration;

import org.springframework.boot.autoconfigure.AutoConfigureBefore;
import org.springframework.boot.autoconfigure.mongo.MongoAutoConfiguration;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;
import works.weave.socks.cart.repositories.mongo.MongoCartRepository;
import works.weave.socks.cart.repositories.mongo.MongoItemRepository;
import works.weave.socks.cart.services.CartService;
import works.weave.socks.cart.services.MongoCartService;

@Configuration
@Profile("mongo")
@AutoConfigureBefore(MongoAutoConfiguration.class)
public class MongoConfiguration {

    @Bean
    public CartService mongoCartService(MongoCartRepository cartRepository, MongoItemRepository itemRepository) {
        return new MongoCartService(cartRepository, itemRepository);
    }
}
