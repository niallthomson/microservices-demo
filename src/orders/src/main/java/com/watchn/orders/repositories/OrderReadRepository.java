package com.watchn.orders.repositories;

import com.watchn.orders.entities.OrderEntity;
import org.springframework.data.repository.CrudRepository;

@ReadOnlyRepository
public interface OrderReadRepository extends CrudRepository<OrderEntity, Long> {

}
