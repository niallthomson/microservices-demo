package repository

import (
	"fmt"

	"github.com/niallthomson/microservices-demo/payments/config"
	"github.com/niallthomson/microservices-demo/payments/model"
)

type Repository interface {
	GetPaymentIntent(cartID string) (*model.PaymentIntent, error)
}

func NewRepository(config config.DatabaseConfiguration) (Repository, error) {
	if config.Type == "mysql" {
		return newMySQLRepository(config)
	}

	return nil, fmt.Errorf("Unknown database type: %s", config.Type)
}
