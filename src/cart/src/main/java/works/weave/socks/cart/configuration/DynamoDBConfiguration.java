package works.weave.socks.cart.configuration;

import com.amazonaws.services.dynamodbv2.AmazonDynamoDB;
import com.amazonaws.services.dynamodbv2.AmazonDynamoDBClient;
import org.socialsignin.spring.data.dynamodb.repository.config.EnableDynamoDBRepositories;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;
import org.springframework.util.StringUtils;
import works.weave.socks.cart.repositories.dynamo.DynamoCartRepository;
import works.weave.socks.cart.services.CartService;
import works.weave.socks.cart.services.DynamoDBCartService;

@Configuration
@Profile("dynamodb")
@EnableDynamoDBRepositories
        (basePackages = "works.weave.socks.cart.repositories.dynamo")
public class DynamoDBConfiguration {

    @Value("${amazon.dynamodb.endpoint}")
    private String amazonDynamoDBEndpoint;

    @Bean
    public AmazonDynamoDB amazonDynamoDB() {
        AmazonDynamoDB amazonDynamoDB
                = new AmazonDynamoDBClient();

        if (!StringUtils.isEmpty(amazonDynamoDBEndpoint)) {
            amazonDynamoDB.setEndpoint(amazonDynamoDBEndpoint);
        }

        return amazonDynamoDB;
    }

    @Bean
    public CartService dynamoCartService(DynamoCartRepository repository) {
        return new DynamoDBCartService(repository, amazonDynamoDB());
    }
}
