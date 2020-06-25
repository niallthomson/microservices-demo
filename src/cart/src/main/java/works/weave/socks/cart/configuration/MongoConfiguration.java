package works.weave.socks.cart.configuration;

import org.springframework.boot.autoconfigure.AutoConfigureBefore;
import org.springframework.boot.autoconfigure.mongo.MongoAutoConfiguration;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import com.mongodb.MongoClientOptions;
import org.springframework.context.annotation.Profile;
import org.springframework.data.mongodb.core.mapping.event.ValidatingMongoEventListener;
import org.springframework.validation.beanvalidation.LocalValidatorFactoryBean;
import works.weave.socks.cart.repositories.mongo.MongoCartRepository;
import works.weave.socks.cart.repositories.mongo.MongoItemRepository;
import works.weave.socks.cart.services.CartService;
import works.weave.socks.cart.services.MongoCartService;

@Configuration
@Profile("mongo")
@AutoConfigureBefore(MongoAutoConfiguration.class)
public class MongoConfiguration {

    @Bean
    public MongoClientOptions optionsProvider() {
        MongoClientOptions.Builder optionsBuilder = new MongoClientOptions.Builder();
        optionsBuilder.serverSelectionTimeout(10000);
        MongoClientOptions options = optionsBuilder.build();
        return options;
    }

    @Bean
    public ValidatingMongoEventListener validatingMongoEventListener(LocalValidatorFactoryBean validator) {
        return new ValidatingMongoEventListener(validator);
    }

    @Bean
    public CartService mongoCartService(MongoCartRepository cartRepository, MongoItemRepository itemRepository) {
        return new MongoCartService(cartRepository, itemRepository);
    }
}
