package com.watchn.ui.config.metadata;

import com.watchn.ui.services.Metadata;
import com.watchn.ui.util.ecs.AwsECSEnvironmentCondition;
import com.watchn.ui.util.ecs.ECSMetadataUtils;
import com.watchn.ui.util.ecs.ECSTaskMetadata;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Conditional;
import org.springframework.context.annotation.Configuration;

@Configuration
@Conditional(AwsECSEnvironmentCondition.class)
public class AwsEcsMetadataConfiguration {
    @Bean
    public Metadata metadata() {
        ECSTaskMetadata task = new ECSMetadataUtils().getTaskMetadata().block();

        return new Metadata("ECS")
            .add("az", task.getAvailabilityZone())
            .add("launch-type", task.getLaunchType())
            .add("cluster", task.getCluster())
            .add("family", task.getFamily());
    }
}
