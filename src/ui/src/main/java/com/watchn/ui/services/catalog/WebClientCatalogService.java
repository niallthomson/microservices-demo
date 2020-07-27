package com.watchn.ui.services.catalog;

import com.watchn.ui.clients.catalog.api.CatalogApi;
import com.watchn.ui.clients.catalog.model.ModelCatalogSizeResponse;
import com.watchn.ui.clients.catalog.model.ModelProduct;
import com.watchn.ui.services.catalog.CatalogService;
import com.watchn.ui.services.catalog.model.Product;
import com.watchn.ui.services.catalog.model.ProductPage;
import com.watchn.ui.services.catalog.model.ProductTag;
import com.watchn.ui.util.RetryUtils;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

public class WebClientCatalogService implements CatalogService {

    private CatalogApi catalogApi;

    public WebClientCatalogService(CatalogApi catalogApi) {
        this.catalogApi = catalogApi;
    }

    @Override
    public Mono<ProductPage> getProducts(String tag, String order, int page, int size) {
        Mono<ModelCatalogSizeResponse> response = catalogApi.catalogueSizeGet(tag)
                .retryWhen(RetryUtils.apiClientRetrySpec("get products size"));

        return catalogApi.catalogueGet(tag, order, page, size)
                .retryWhen(RetryUtils.apiClientRetrySpec("get products"))
                .map(this::toProduct)
                .collectList().zipWith(response, (p, r) -> new ProductPage(page, size, r.getSize(), p));
    }

    @Override
    public Mono<Product> getProduct(String productId) {
        return catalogApi.catalogueProductIdGet(productId)
                .retryWhen(RetryUtils.apiClientRetrySpec("get product"))
                .map(this::toProduct);
    }

    @Override
    public Flux<ProductTag> getTags() {
        return catalogApi.catalogueTagsGet()
                .retryWhen(RetryUtils.apiClientRetrySpec("get tags"))
                .map(t -> new ProductTag(t.getName(), t.getDisplayName()));
    }

    private Product toProduct(ModelProduct p) {
        return new Product(
                p.getId(),
                p.getName(),
                p.getDescription(),
                p.getCount(),
                p.getImageUrl(),
                p.getPrice(),
                p.getTag());
    }
}
