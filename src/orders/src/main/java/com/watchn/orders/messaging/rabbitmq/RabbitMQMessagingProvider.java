package com.watchn.orders.messaging.rabbitmq;

import com.watchn.orders.config.messaging.RabbitMQMessagingConfig;
import com.watchn.orders.messaging.MessagingProvider;
import org.springframework.amqp.rabbit.core.RabbitTemplate;

public class RabbitMQMessagingProvider implements MessagingProvider {

    private RabbitTemplate rabbitTemplate;

    public RabbitMQMessagingProvider(RabbitTemplate rabbitTemplate) {
        this.rabbitTemplate = rabbitTemplate;
    }

    @Override
    public void publishEvent(Object event) {
        this.rabbitTemplate.convertAndSend(RabbitMQMessagingConfig.EXCHANGE_NAME, "", event);
    }
}
