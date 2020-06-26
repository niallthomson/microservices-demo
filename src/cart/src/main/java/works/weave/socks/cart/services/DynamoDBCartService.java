package works.weave.socks.cart.services;

import com.amazonaws.services.dynamodbv2.AmazonDynamoDB;
import com.amazonaws.services.dynamodbv2.datamodeling.DynamoDBMapper;
import com.amazonaws.services.dynamodbv2.model.*;
import lombok.extern.slf4j.Slf4j;
import works.weave.socks.cart.repositories.CartEntity;
import works.weave.socks.cart.repositories.ItemEntity;
import works.weave.socks.cart.repositories.dynamo.DynamoCartRepository;
import works.weave.socks.cart.repositories.dynamo.entities.DynamoItemEntity;

import javax.annotation.PostConstruct;
import java.util.List;
import java.util.Optional;

@Slf4j
public class DynamoDBCartService implements CartService {

    private DynamoCartRepository repository;
    private AmazonDynamoDB dynamoDB;
    private boolean createTable;

    public DynamoDBCartService(DynamoCartRepository repository, AmazonDynamoDB dynamoDB, boolean createTable) {
        this.repository = repository;
        this.dynamoDB = dynamoDB;
        this.createTable = createTable;
    }

    @PostConstruct
    public void init() {
        if(createTable) {
            DynamoDBMapper dynamoDBMapper = new DynamoDBMapper(dynamoDB);

            DeleteTableRequest deleteTableRequest = dynamoDBMapper.generateDeleteTableRequest(DynamoItemEntity.class);

            try {
                DescribeTableResult result = dynamoDB.describeTable(deleteTableRequest.getTableName());

                log.warn("Dynamo table found, deleting to recreate....");
                dynamoDB.deleteTable(deleteTableRequest);
            }
            catch (com.amazonaws.services.dynamodbv2.model.ResourceNotFoundException rnfe) {
                log.warn("Dynamo table not found");
            }

            ProvisionedThroughput pt = new ProvisionedThroughput(1L, 1L);

            CreateTableRequest tableRequest = dynamoDBMapper
                    .generateCreateTableRequest(DynamoItemEntity.class);
            tableRequest.setProvisionedThroughput(pt);
            tableRequest.getGlobalSecondaryIndexes().get(0).setProvisionedThroughput(pt);
            tableRequest.getGlobalSecondaryIndexes().get(0).setProjection(new Projection().withProjectionType("ALL"));
            dynamoDB.createTable(tableRequest);
        }
    }

    @Override
    public CartEntity get(String customerId) {
        List<DynamoItemEntity> items = items(customerId);

        return new CartEntity() {
            @Override
            public String getCustomerId() {
                return customerId;
            }

            @Override
            public List<? extends ItemEntity> getItems() {
                return items;
            }
        };
    }

    @Override
    public void delete(String customerId) {
        List<DynamoItemEntity> items = items(customerId);

        this.repository.deleteAll(items);
    }

    @Override
    public CartEntity merge(String sessionId, String customerId) {
        return null;
    }

    @Override
    public ItemEntity add(String customerId, String itemId, int quantity, float unitPrice) {
        DynamoItemEntity item = new DynamoItemEntity(hashKey(customerId, itemId), customerId, itemId, 1, unitPrice);

        return this.repository.save(item);
    }

    @Override
    public List<DynamoItemEntity> items(String customerId) {
        return this.repository.findByCustomerId(customerId);
    }

    @Override
    public Optional<DynamoItemEntity> item(String customerId, String itemId) {
        return this.repository.findById(hashKey(customerId, itemId));
    }

    @Override
    public void deleteItem(String customerId, String itemId) {
        this.repository.deleteById(hashKey(customerId, itemId));
    }

    @Override
    public Optional<DynamoItemEntity> update(String customerId, String itemId, int quantity, float unitPrice) {
        return item(customerId, itemId).map(
            item -> {
                item.setQuantity(quantity);
                item.setUnitPrice(unitPrice);

                return this.repository.save(item);
            }
        );
    }

    private String hashKey(String customerId, String itemId) {
        return customerId+":"+itemId;
    }
}
