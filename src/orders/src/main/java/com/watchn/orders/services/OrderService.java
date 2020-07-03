package com.watchn.orders.services;

import com.google.common.collect.Lists;
import com.watchn.orders.entities.OrderEntity;
import com.watchn.orders.entities.OrderItemEntity;
import com.watchn.orders.repositories.OrderReadRepository;
import com.watchn.orders.repositories.OrderRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import javax.transaction.Transactional;
import java.util.List;

@Service
public class OrderService {

    @Autowired
    private OrderRepository repository;

    @Autowired
    private OrderReadRepository readRepository;

    @Transactional
    public OrderEntity create(OrderEntity order) {
        for(OrderItemEntity item : order.getItems()) {
            item.setOrder(order);
        }

        return repository.save(order);
    }

    public List<OrderEntity> list() {
        return Lists.newArrayList(this.readRepository.findAll());
    }
}
