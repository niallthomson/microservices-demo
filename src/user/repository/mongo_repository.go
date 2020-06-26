package repository

import (
	"context"
	"errors"
	"log"
	"time"

	"github.com/golang-migrate/migrate/v4"
	_ "github.com/golang-migrate/migrate/v4/database/mongodb"
	_ "github.com/golang-migrate/migrate/v4/source/file"
	"github.com/niallthomson/microservices-demo/user/config"
	"github.com/niallthomson/microservices-demo/user/model"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
	"gopkg.in/mgo.v2/bson"
)

// ErrNotFound is returned when there is no product for a given ID.
var ErrNotFound = errors.New("not found")

// ErrDBConnection is returned when connection with the database fails.
var ErrDBConnection = errors.New("database connection error")

type mongoRepository struct {
	client *mongo.Client
}

func newMongoRepository(config config.DatabaseConfiguration) (Repository, error) {
	client, err := mongo.NewClient(options.Client().ApplyURI(config.Mongo.Endpoint))
	if err != nil {
		log.Println("Error: Failed to create mongo client", err)
		return nil, err
	}

	ctx, _ := context.WithTimeout(context.Background(), 10*time.Second)
	err = client.Connect(ctx)
	if err != nil {
		log.Println("Error: Failed to connect to mongo", err)
		return nil, err
	}

	if config.Mongo.Migrate {
		err = migrateMongo(config.Mongo.Endpoint)
		if err != nil {
			log.Println("Error: Failed to perform migration", err)
			return nil, err
		}
	}

	return &mongoRepository{
		client: client,
	}, nil
}

func migrateMongo(connectionString string) error {
	m, err := migrate.New(
		"file://db/migrations",
		connectionString,
	)
	if err != nil {
		log.Println("Error: Failed to prep migration", err)
		return err
	}

	if err := m.Up(); err != migrate.ErrNoChange {
		log.Println("Error: Failed to apply migration", err)
		return err
	}

	return nil
}

func (s *mongoRepository) GetCustomer(id string) (*model.User, error) {
	collection := s.client.Database("users").Collection("customers")

	var result model.User

	err := collection.FindOne(context.Background(), bson.M{"_id": id}).Decode(&result)
	if err != nil {
		if err == mongo.ErrNoDocuments {
			return nil, nil
		}

		log.Println("Error: Failed to load customer", err)
		return nil, err
	}

	return &result, nil
}

func (s *mongoRepository) GetCustomerByUsername(username string) *model.User {
	collection := s.client.Database("users").Collection("customers")

	var result model.User

	err := collection.FindOne(context.Background(), bson.M{"username": username}).Decode(&result)
	if err != nil {
		if err == mongo.ErrNoDocuments {
			return nil
		}

		log.Println("Error: Failed to load customer", err)
		return nil
	}

	return &result
}
