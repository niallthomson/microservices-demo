package com.watchn.orders.entities;

import lombok.Data;

import javax.persistence.*;

@Entity
@Table(name="CUSTOMER_ORDER_ITEM")
@Data
public class OrderItemEntity {
    @Id
    @GeneratedValue(strategy= GenerationType.AUTO)
    private Long id;

    private String productId;

    private int quantity;

    private int price;

    @ManyToOne(fetch = FetchType.LAZY)
    private OrderEntity order;
}
