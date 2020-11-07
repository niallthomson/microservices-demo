package com.watchn.orders.repositories;

import com.watchn.orders.entities.OrderEntity;
import org.springframework.data.repository.CrudRepository;

public interface OrderRepository extends CrudRepository<OrderEntity, String> {

}
