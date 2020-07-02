package com.watchn.orders.repositories;

import com.watchn.orders.entities.Order;
import org.springframework.data.repository.CrudRepository;

public interface OrderRepository extends CrudRepository<Order, Long> {

}
