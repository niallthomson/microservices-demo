package com.watchn.carts.controllers;

import com.watchn.carts.controllers.api.Cart;
import com.watchn.carts.controllers.api.Item;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;
import com.watchn.carts.services.CartService;

import java.util.List;
import java.util.stream.Collectors;


@RestController
@Api(tags = {"carts"})
@RequestMapping(path = "/carts")
@Slf4j
public class CartsController {
    @Autowired
    private CartService service;

    @ResponseStatus(HttpStatus.OK)
    @GetMapping(value = "/{customerId}", consumes = MediaType.APPLICATION_JSON_VALUE)
    @ApiOperation(value = "Retrieve a cart", nickname = "getCart")
    public Cart get(@PathVariable String customerId) {
        return Cart.from(this.service.get(customerId));
    }

    @ResponseStatus(HttpStatus.ACCEPTED)
    @DeleteMapping(value = "/{customerId}", consumes = MediaType.APPLICATION_JSON_VALUE)
    @ApiOperation(value = "Delete a cart", nickname = "deleteCart")
    public Cart delete(@PathVariable String customerId) {
        this.service.delete(customerId);

        return new Cart();
    }

    @ResponseStatus(HttpStatus.ACCEPTED)
    @GetMapping(value = "/{customerId}/merge", consumes = MediaType.APPLICATION_JSON_VALUE)
    @ApiOperation(value = "Merge two carts contents", nickname = "mergeCarts")
    public void mergeCarts(@PathVariable String customerId, @RequestParam(value = "sessionId") String sessionId) {
        this.service.merge(sessionId, customerId);
    }

    @ResponseStatus(HttpStatus.OK)
    @GetMapping(value = "/{customerId}/items/{itemId:.*}", consumes = MediaType.APPLICATION_JSON_VALUE)
    @ApiOperation(value = "Retrieve an item from a cart", nickname = "getItem")
    public Item get(@PathVariable String customerId, @PathVariable String itemId) {
        return this.service.item(customerId, itemId).map(Item::from).get();
    }

    @ResponseStatus(HttpStatus.OK)
    @GetMapping(value = "/{customerId}/items", consumes = MediaType.APPLICATION_JSON_VALUE)
    @ApiOperation(value = "Retrieve items from a cart", nickname = "getItems")
    public List<Item> getItems(@PathVariable String customerId) {
        return this.service.items(customerId).stream()
                .map(Item::from).collect(Collectors.toList());
    }

    @ResponseStatus(HttpStatus.CREATED)
    @PostMapping(value = "/{customerId}/items", consumes = MediaType.APPLICATION_JSON_VALUE)
    @ApiOperation(value = "Add an item to a cart", nickname = "addItem")
    public Item addToCart(@PathVariable String customerId, @RequestBody Item item) {
        return Item.from(this.service.add(customerId, item.getItemId(), item.getQuantity(), item.getUnitPrice()));
    }

    @ResponseStatus(HttpStatus.ACCEPTED)
    @DeleteMapping(value = "/{customerId}/items/{itemId:.*}", consumes = MediaType.APPLICATION_JSON_VALUE)
    @ApiOperation(value = "Delete an item from a cart", nickname = "deleteItem")
    public void removeItem(@PathVariable String customerId, @PathVariable String itemId) {
        this.service.deleteItem(customerId, itemId);
    }

    @ResponseStatus(HttpStatus.ACCEPTED)
    @PatchMapping(value = "/{customerId}/items", consumes = MediaType.APPLICATION_JSON_VALUE)
    @ApiOperation(value = "Update an item in a cart", nickname = "updateItem")
    public void updateItem(@PathVariable String customerId, @RequestBody Item item) {
        this.service.update(customerId, item.getItemId(), item.getQuantity(), item.getUnitPrice());
    }
}
