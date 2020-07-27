package com.watchn.ui.services;

import lombok.AllArgsConstructor;
import lombok.Data;

import java.util.HashMap;
import java.util.Map;

@Data
public class Metadata {
    private Map<String, String> attributes = new HashMap<>();

    public Metadata add(String name, String value) {
        this.attributes.put(name, value);

        return this;
    }
}
