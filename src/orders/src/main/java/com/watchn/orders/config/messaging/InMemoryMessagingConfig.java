package com.watchn.orders.config.messaging;

import com.watchn.orders.messaging.MessagingProvider;
import com.watchn.orders.messaging.inmemory.InMemoryMessagingProvider;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;

@Configuration
@Profile("default")
public class InMemoryMessagingConfig {
    @Bean
    public MessagingProvider messagingProvider() {
        return new InMemoryMessagingProvider();
    }
}
