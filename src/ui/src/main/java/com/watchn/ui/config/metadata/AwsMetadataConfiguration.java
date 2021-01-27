package com.watchn.ui.config.metadata;

import com.watchn.ui.services.Metadata;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.cloud.aws.context.annotation.ConditionalOnAwsCloudEnvironment;
import org.springframework.cloud.aws.context.config.annotation.EnableContextInstanceData;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
@ConditionalOnAwsCloudEnvironment
@EnableContextInstanceData
public class AwsMetadataConfiguration {

    @Value("${placement/availability-zone:N/A}")
    private String availabilityZone;

    @Value("${instance-id:N/A}")
    private String instanceId;

    @Value("${instance-type:N/A}")
    private String instanceType;

    @Bean
    public Metadata metadata() {
        return new Metadata("EC2")
            .add("az", this.availabilityZone)
            .add("instance-id", this.instanceId)
            .add("instance-type", this.instanceType);
    }
}
