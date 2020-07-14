package com.watchn.ui.services;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

@Service
public class MetadataService {

    @Value("${watchn.ui.metadata.region}")
    private String region;

    public Metadata getMetadata() {
        return new Metadata(this.region);
    }
}
