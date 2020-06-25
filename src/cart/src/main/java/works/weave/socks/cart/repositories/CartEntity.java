package works.weave.socks.cart.repositories;

import java.util.List;

public interface CartEntity {
    String getCustomerId();

    List<? extends ItemEntity> getItems();
}
