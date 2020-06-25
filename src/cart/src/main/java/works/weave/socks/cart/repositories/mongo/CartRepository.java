package works.weave.socks.cart.repositories.mongo;

import org.springframework.data.mongodb.repository.MongoRepository;
import works.weave.socks.cart.repositories.mongo.entities.MongoCartEntity;

public interface CartRepository extends MongoRepository<MongoCartEntity, String> {

}

