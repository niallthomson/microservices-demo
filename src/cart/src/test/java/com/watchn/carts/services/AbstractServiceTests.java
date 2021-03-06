package com.watchn.carts.services;

import com.watchn.carts.repositories.CartEntity;
import com.watchn.carts.repositories.ItemEntity;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;

public abstract class AbstractServiceTests {

    public abstract CartService getService();

    @Test
    public void testGetNewCart() {
        CartEntity cartEntity = this.getService().get("empty");

        assertEquals(0, cartEntity.getItems().size());
    }

    @Test
    public void testAddItem() {
        this.getService().add("123", "1", 1, 150);

        CartEntity cartEntity = this.getService().get("123");

        assertEquals("123", cartEntity.getCustomerId());
        assertEquals(1, cartEntity.getItems().size());

        ItemEntity itemEntity = cartEntity.getItems().get(0);

        assertEquals("1", itemEntity.getItemId());
        assertEquals(1, itemEntity.getQuantity());
        assertEquals(150, itemEntity.getUnitPrice());
    }

    @Test
    public void testRemoveItem() {
        this.getService().add("234", "1", 1, 150);

        this.getService().deleteItem("234", "1");

        CartEntity cartEntity = this.getService().get("234");

        assertEquals("234", cartEntity.getCustomerId());
        assertEquals(0, cartEntity.getItems().size());
    }

    @Test
    public void testDeleteCart() {
        this.getService().get("deleteme");

        this.getService().delete("deleteme");

        assertEquals(false, this.getService().exists("deleteme"));
    }
}
