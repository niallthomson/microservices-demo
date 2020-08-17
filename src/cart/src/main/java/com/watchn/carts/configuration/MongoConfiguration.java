package com.watchn.carts.configuration;

import com.watchn.carts.services.CartService;
import com.watchn.carts.services.MongoCartService;
import org.springframework.boot.autoconfigure.AutoConfigureBefore;
import org.springframework.boot.autoconfigure.mongo.MongoAutoConfiguration;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;
import com.watchn.carts.repositories.mongo.MongoCartRepository;
import com.watchn.carts.repositories.mongo.MongoItemRepository;

@Configuration
@Profile("mongo")
@AutoConfigureBefore(MongoAutoConfiguration.class)
public class MongoConfiguration {

    @Bean
    public CartService mongoCartService(MongoCartRepository cartRepository, MongoItemRepository itemRepository) {
        return new MongoCartService(cartRepository, itemRepository);
    }
}
