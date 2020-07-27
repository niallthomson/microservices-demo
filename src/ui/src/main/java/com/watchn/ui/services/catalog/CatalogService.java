package com.watchn.ui.services.catalog;

import com.watchn.ui.services.catalog.model.Product;
import com.watchn.ui.services.catalog.model.ProductPage;
import com.watchn.ui.services.catalog.model.ProductTag;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

public interface CatalogService {
    Mono<ProductPage> getProducts(String tag, String order, int page, int size);

    Mono<Product> getProduct(String productId);

    Flux<ProductTag> getTags();
}
