package works.weave.socks.cart.repositories.mongo;

import org.springframework.data.mongodb.repository.MongoRepository;
import works.weave.socks.cart.repositories.mongo.entities.MongoItemEntity;

public interface MongoItemRepository extends MongoRepository<MongoItemEntity, String> {
}

