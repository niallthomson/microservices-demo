package com.watchn.ui;

import com.watchn.ui.clients.catalog.ApiClient;
import com.watchn.ui.clients.catalog.api.CatalogApi;

public class Test {
    public static void main(String[] args) {
        CatalogApi api = new CatalogApi(new ApiClient().setBasePath("http://localhost:8081"));

        System.out.println(api.catalogueGet("", "", 1, 5).blockLast());
    }
}
