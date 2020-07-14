package com.watchn.orders.entities;

import lombok.Builder;
import lombok.Data;

import javax.persistence.*;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name="CUSTOMER_ORDER")
@Data
public class OrderEntity {

    @Id
    @GeneratedValue(strategy= GenerationType.AUTO)
    private Long id;
    private String firstName;
    private String lastName;
    private String email;

    @OneToMany(
            mappedBy = "order",
            orphanRemoval = true,
            fetch = FetchType.EAGER
    )
    private List<OrderItemEntity> items = new ArrayList<>();
}