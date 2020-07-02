package com.watchn.orders.web;

import com.watchn.orders.entities.Order;
import com.watchn.orders.entities.OrderItem;
import com.watchn.orders.services.OrderService;
import com.watchn.orders.web.payload.CreateOrderRequest;
import com.watchn.orders.web.payload.CreateOrderRequestItem;
import com.watchn.orders.web.payload.CreateOrderResponse;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/orders")
@Api(tags = {"orders"})
public class OrderController {

    @Autowired
    private OrderService service;

    @PostMapping
    @ApiOperation(value = "Create an order", nickname = "createOrder")
    public CreateOrderResponse order(@RequestBody CreateOrderRequest createOrderRequest) {

        Order order = new Order();
        order.setFirstName(createOrderRequest.getFirstName());
        order.setLastName(createOrderRequest.getLastName());

        for(CreateOrderRequestItem itemRequest : createOrderRequest.getItems()) {
            OrderItem item = new OrderItem();
            item.setProductId(itemRequest.getProductId());
            item.setQuantity(itemRequest.getQuantity());
            item.setPrice(itemRequest.getPrice());

            order.getItems().add(item);
        }

        order = this.service.create(order);

        return new CreateOrderResponse(order.getId());
    }
}
