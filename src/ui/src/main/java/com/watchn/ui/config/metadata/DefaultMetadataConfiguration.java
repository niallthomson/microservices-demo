package com.watchn.ui.config.metadata;

import com.watchn.ui.services.Metadata;
import org.springframework.cloud.aws.context.annotation.ConditionalOnMissingAwsCloudEnvironment;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
@ConditionalOnMissingAwsCloudEnvironment
public class DefaultMetadataConfiguration {

    @Bean
    public Metadata metadata() {
        return new Metadata().add("environment", "local");
    }
}
