package com.watchn.ui.config.metadata;

import com.watchn.ui.services.Metadata;
import org.springframework.boot.autoconfigure.condition.ConditionalOnMissingBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
@ConditionalOnMissingBean(Metadata.class)
public class DefaultMetadataConfiguration {

    @Bean
    public Metadata metadata() {
        return new Metadata().add("environment", "local");
    }
}
