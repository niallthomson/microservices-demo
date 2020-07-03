package com.watchn.orders.web;

import com.watchn.orders.entities.OrderEntity;
import com.watchn.orders.entities.OrderItemEntity;
import com.watchn.orders.services.OrderService;
import com.watchn.orders.web.payload.*;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/orders")
@Api(tags = {"orders"})
public class OrderController {

    @Autowired
    private OrderService service;

    @Autowired
    private OrderMapper orderMapper;

    @PostMapping
    @ApiOperation(value = "Create an order", nickname = "createOrder")
    public ExistingOrder order(@RequestBody Order orderRequest) {
        return this.orderMapper.toExistingOrder(this.service.create(this.orderMapper.toOrderEntity(orderRequest)));
    }

    @GetMapping
    @ApiOperation(value = "List orders", nickname = "listOrders")
    public List<ExistingOrder> order() {
        return this.service.list().stream().map(this.orderMapper::toExistingOrder).collect(Collectors.toList());
    }
}
