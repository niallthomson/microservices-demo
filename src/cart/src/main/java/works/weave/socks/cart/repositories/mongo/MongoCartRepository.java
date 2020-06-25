package works.weave.socks.cart.repositories.mongo;

import org.springframework.data.mongodb.repository.MongoRepository;
import works.weave.socks.cart.repositories.mongo.entities.MongoCartEntity;

public interface MongoCartRepository extends MongoRepository<MongoCartEntity, String> {

}

