package com.watchn.ui.config.metadata;

import com.watchn.ui.services.Metadata;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.cloud.aws.context.annotation.ConditionalOnAwsCloudEnvironment;
import org.springframework.cloud.aws.context.config.annotation.EnableContextInstanceData;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
@EnableContextInstanceData
@ConditionalOnAwsCloudEnvironment
public class AwsMetadataConfiguration {

    @Value("${placement/availability-zone}")
    private String availabilityZone;

    @Bean
    public Metadata metadata() {
        return new Metadata().add("az", this.availabilityZone);
    }
}
