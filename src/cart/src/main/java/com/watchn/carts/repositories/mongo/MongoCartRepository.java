package com.watchn.carts.repositories.mongo;

import com.watchn.carts.repositories.mongo.entities.MongoCartEntity;
import org.springframework.data.mongodb.repository.MongoRepository;

public interface MongoCartRepository extends MongoRepository<MongoCartEntity, String> {

}

