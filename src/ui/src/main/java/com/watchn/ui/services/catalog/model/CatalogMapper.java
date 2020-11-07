package com.watchn.ui.services.catalog.model;

import com.watchn.ui.clients.catalog.model.ModelProduct;
import com.watchn.ui.clients.catalog.model.ModelTag;
import org.mapstruct.Mapper;

@Mapper
public interface CatalogMapper {
    Product product(ModelProduct product);

    ProductTag tag(ModelTag tag);
}