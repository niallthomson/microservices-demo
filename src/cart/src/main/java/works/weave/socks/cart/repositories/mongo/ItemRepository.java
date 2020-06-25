package works.weave.socks.cart.repositories.mongo;

import org.springframework.data.mongodb.repository.MongoRepository;
import works.weave.socks.cart.repositories.mongo.entities.MongoItemEntity;

public interface ItemRepository extends MongoRepository<MongoItemEntity, String> {
}

