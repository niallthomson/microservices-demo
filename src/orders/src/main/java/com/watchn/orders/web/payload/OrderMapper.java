package com.watchn.orders.web.payload;

import com.watchn.orders.entities.OrderEntity;
import com.watchn.orders.entities.OrderItemEntity;
import org.mapstruct.Mapper;

@Mapper(componentModel = "spring")
public interface OrderMapper {
    Order toOrder(OrderEntity entity);

    OrderItem toOrderItem(OrderItemEntity entity);

    ExistingOrder toExistingOrder(OrderEntity entity);

    OrderEntity toOrderEntity(Order order);

    OrderItemEntity toOrderItemEntity(OrderItem item);
}
