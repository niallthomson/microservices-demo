package repository

import (
	"fmt"

	"github.com/niallthomson/microservices-demo/user/config"
	"github.com/niallthomson/microservices-demo/user/model"
)

type Repository interface {
	GetCustomer(id string) (*model.User, error)
	GetCustomerByUsername(username string) *model.User
}

func NewRepository(config config.DatabaseConfiguration) (Repository, error) {
	if config.Type == "mongodb" {
		return newMongoRepository(config)
	}

	return nil, fmt.Errorf("Unknown database type: %s", config.Type)
}
