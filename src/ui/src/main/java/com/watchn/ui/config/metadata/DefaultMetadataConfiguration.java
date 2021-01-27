package com.watchn.ui.config.metadata;

import com.watchn.ui.services.Metadata;
import com.watchn.ui.util.ecs.AwsECSEnvironmentCondition;
import com.watchn.ui.util.ecs.MissingAwsECSEnvironmentCondition;
import org.springframework.cloud.aws.context.annotation.ConditionalOnMissingAwsCloudEnvironment;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Conditional;
import org.springframework.context.annotation.Configuration;

@Configuration
@ConditionalOnMissingAwsCloudEnvironment
@Conditional(MissingAwsECSEnvironmentCondition.class)
public class DefaultMetadataConfiguration {

    @Bean
    public Metadata metadata() {
        return new Metadata("Local").add("environment", "local");
    }
}
