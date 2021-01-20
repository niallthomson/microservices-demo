package com.watchn.orders.services;

import com.google.common.collect.Lists;
import com.watchn.orders.entities.OrderEntity;
import com.watchn.orders.entities.OrderItemEntity;
import com.watchn.orders.messaging.OrdersEventHandler;
import com.watchn.orders.repositories.OrderReadRepository;
import com.watchn.orders.repositories.OrderRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import javax.transaction.Transactional;
import java.util.List;

@Service
@Slf4j
public class OrderService {

    @Autowired
    private OrderRepository repository;

    @Autowired
    private OrderReadRepository readRepository;

    @Autowired
    private OrdersEventHandler eventHandler;

    @Transactional
    public OrderEntity create(OrderEntity order) {
        for(OrderItemEntity item : order.getItems()) {
            item.setOrder(order);

            OrderItemEntity.Key key = new OrderItemEntity.Key();
            //key.setProductId(item.getProductId());

            item.setId(key);
        }

        OrderEntity entity = repository.save(order);

        eventHandler.postCreatedEvent(entity);

        return entity;
    }

    public List<OrderEntity> list() {
        return Lists.newArrayList(this.readRepository.findAll());
    }
}
