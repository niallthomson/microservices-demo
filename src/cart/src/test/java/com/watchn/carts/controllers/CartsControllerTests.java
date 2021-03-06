package com.watchn.carts.controllers;

import com.watchn.carts.controllers.api.Item;
import com.watchn.carts.repositories.CartEntity;
import com.watchn.carts.repositories.ItemEntity;
import com.watchn.carts.services.CartService;
import com.watchn.carts.util.TestUtil;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.ResultActions;

import java.util.ArrayList;
import java.util.List;

import static org.hamcrest.Matchers.hasSize;
import static org.mockito.BDDMockito.given;
import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(CartsController.class)
public class CartsControllerTests {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private CartService service;

    private final static String EMPTY_CART_ID = "123";
    private final static String POPULATED_CART_ID = "456";

    @BeforeEach
    void setup() {
        CartEntity emptyCart = mock(CartEntity.class);
        when(emptyCart.getCustomerId()).thenReturn(EMPTY_CART_ID);

        CartEntity populatedCart = mock(CartEntity.class);
        when(populatedCart.getCustomerId()).thenReturn(POPULATED_CART_ID);

        ItemEntity item = mock(ItemEntity.class);
        when(item.getItemId()).thenReturn("1");
        when(item.getQuantity()).thenReturn(1);
        when(item.getUnitPrice()).thenReturn(150);

        List<ItemEntity> items = new ArrayList<ItemEntity>();
        items.add(item);

        doReturn(items).when(populatedCart).getItems();

        given(this.service.get(EMPTY_CART_ID)).willReturn(emptyCart);
        given(this.service.get(POPULATED_CART_ID)).willReturn(populatedCart);

        doNothing().when(this.service).delete(EMPTY_CART_ID);

        given(this.service.add("123", "1", 1, 150)).willReturn(item);

        doNothing().when(this.service).deleteItem(POPULATED_CART_ID, "1");
    }

    @Test
    void testGetEmptyCart() throws Exception {
        ResultActions actions = mockMvc.perform(get("/carts/"+EMPTY_CART_ID)
                .contentType(MediaType.APPLICATION_JSON_VALUE)
                .accept(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk());

        actions.andExpect(content().contentType(MediaType.APPLICATION_JSON))
                .andExpect(jsonPath("$.customerId").value(EMPTY_CART_ID))
                .andExpect(jsonPath("$.items", hasSize(0)));
    }

    @Test
    void testGetPopulatedCart() throws Exception {
        ResultActions actions = mockMvc.perform(get("/carts/"+POPULATED_CART_ID)
                .contentType(MediaType.APPLICATION_JSON_VALUE)
                .accept(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk());

        actions.andExpect(content().contentType(MediaType.APPLICATION_JSON))
                .andExpect(jsonPath("$.customerId").value(POPULATED_CART_ID))
                .andExpect(jsonPath("$.items", hasSize(1)))
                .andExpect(jsonPath("$.items[0].itemId").value("1"))
                .andExpect(jsonPath("$.items[0].quantity").value(1))
                .andExpect(jsonPath("$.items[0].unitPrice").value(150));
    }

    @Test
    void testDeleteCart() throws Exception {
        ResultActions actions = mockMvc.perform(delete("/carts/"+EMPTY_CART_ID)
                .contentType(MediaType.APPLICATION_JSON_VALUE)
                .accept(MediaType.APPLICATION_JSON))
                .andExpect(status().isAccepted());

        actions.andExpect(content().contentType(MediaType.APPLICATION_JSON));
    }

    @Test
    void testAddItem() throws Exception {
        ResultActions actions = mockMvc.perform(post("/carts/"+EMPTY_CART_ID+"/items")
                .contentType(MediaType.APPLICATION_JSON_VALUE)
                .content(TestUtil.convertObjectToJsonBytes(new Item("1", 1, 150)))
                .accept(MediaType.APPLICATION_JSON))
                .andExpect(status().isCreated());

        actions.andExpect(content().contentType(MediaType.APPLICATION_JSON))
                .andExpect(jsonPath("$.itemId").value("1"))
                .andExpect(jsonPath("$.quantity").value(1))
                .andExpect(jsonPath("$.unitPrice").value(150));
    }

    @Test
    void testDeleteItem() throws Exception {
        ResultActions actions = mockMvc.perform(delete("/carts/"+POPULATED_CART_ID+"/items/1")
                .contentType(MediaType.APPLICATION_JSON_VALUE)
                .accept(MediaType.APPLICATION_JSON_VALUE))
                .andExpect(status().isAccepted());
    }
}
