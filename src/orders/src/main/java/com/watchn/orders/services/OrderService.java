package com.watchn.orders.services;

import com.watchn.orders.entities.Order;
import com.watchn.orders.repositories.OrderRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import javax.transaction.Transactional;

@Service
public class OrderService {

    @Autowired
    private OrderRepository repository;

    @Transactional
    public Order create(Order order) {
        return repository.save(order);
    }
}
