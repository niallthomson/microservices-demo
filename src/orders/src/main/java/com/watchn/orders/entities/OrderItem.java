package com.watchn.orders.entities;

import lombok.Data;

import javax.persistence.*;

@Entity
@Data
public class OrderItem {
    @Id
    @GeneratedValue(strategy= GenerationType.AUTO)
    private Long id;

    private String productId;

    private int quantity;

    private int price;

    @ManyToOne(fetch = FetchType.LAZY)
    private Order order;
}
