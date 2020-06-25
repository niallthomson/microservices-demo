package works.weave.socks.cart.repositories.dynamo;

import org.springframework.data.repository.CrudRepository;
import works.weave.socks.cart.repositories.dynamo.entities.DynamoItemEntity;

import java.util.List;

public interface DynamoCartRepository extends CrudRepository<DynamoItemEntity, String> {
    List<DynamoItemEntity> findByCustomerId(String customerId);
}
