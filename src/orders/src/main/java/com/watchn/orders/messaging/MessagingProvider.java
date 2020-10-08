package com.watchn.orders.messaging;

public interface MessagingProvider {
    void publishEvent(Object event);
}
