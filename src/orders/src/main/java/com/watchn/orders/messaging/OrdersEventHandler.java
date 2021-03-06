package com.watchn.orders.messaging;

import com.watchn.events.orders.Order;
import com.watchn.events.orders.OrderCreatedEvent;
import com.watchn.orders.entities.OrderEntity;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Component;
import org.springframework.transaction.event.TransactionalEventListener;

@Component
public class OrdersEventHandler {

    @Autowired
    private ApplicationEventPublisher publisher;

    @Autowired
    private MessagingProvider messagingProvider;

    @TransactionalEventListener
    public void onOrderCreated(OrderCreatedEvent event) {
        this.messagingProvider.publishEvent(event);
    }

    public void postCreatedEvent(OrderEntity entity) {
        Order order = new Order();
        order.setId(entity.getId());
        order.setFirstName(entity.getFirstName());
        order.setLastName(entity.getLastName());
        order.setEmail(entity.getEmail());

        OrderCreatedEvent event = new OrderCreatedEvent();
        event.setOrder(order);

        publisher.publishEvent(event);
    }
}
