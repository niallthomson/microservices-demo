package works.weave.socks.cart.controllers.api;

import lombok.Data;
import works.weave.socks.cart.repositories.CartEntity;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Data
public class Cart {
    private String customerId;

    private List<Item> items = new ArrayList<>();

    public static Cart from(CartEntity cartEntity) {
        Cart cart = new Cart();
        cart.setCustomerId(cartEntity.getCustomerId());

        cart.items = cartEntity.getItems().stream()
                .map(Item::from).collect(Collectors.toList());

        return cart;
    }
}
