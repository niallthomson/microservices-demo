package works.weave.socks.cart.controllers;

import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import lombok.extern.slf4j.Slf4j;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;
import works.weave.socks.cart.controllers.api.Cart;
import works.weave.socks.cart.services.CartService;


@RestController
@Api(tags = {"carts"})
@RequestMapping(path = "/carts")
@Slf4j
public class CartsController {
    @Autowired
    private CartService service;

    @ResponseStatus(HttpStatus.OK)
    @GetMapping(value = "/{customerId}", produces = MediaType.APPLICATION_JSON_VALUE)
    @ApiOperation(value = "Retrieve a cart", nickname = "getCart")
    public Cart get(@PathVariable String customerId) {
        return Cart.from(this.service.get(customerId));
    }

    @ResponseStatus(HttpStatus.ACCEPTED)
    @DeleteMapping(value = "/{customerId}")
    @ApiOperation(value = "Delete a cart", nickname = "deleteCart")
    public Cart delete(@PathVariable String customerId) {
        this.service.delete(customerId);

        return new Cart();
    }

    @ResponseStatus(HttpStatus.ACCEPTED)
    @GetMapping(value = "/{customerId}/merge")
    @ApiOperation(value = "Merge two carts contents", nickname = "mergeCarts")
    public void mergeCarts(@PathVariable String customerId, @RequestParam(value = "sessionId") String sessionId) {
        this.service.merge(sessionId, customerId);
    }
}
