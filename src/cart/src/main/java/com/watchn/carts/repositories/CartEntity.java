package com.watchn.carts.repositories;

import java.util.List;

public interface CartEntity {
    String getCustomerId();

    List<? extends ItemEntity> getItems();
}
