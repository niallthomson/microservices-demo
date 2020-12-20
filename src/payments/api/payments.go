package api

import (
	"log"

	"github.com/niallthomson/microservices-demo/payments/config"
	"github.com/niallthomson/microservices-demo/payments/model"
	"github.com/niallthomson/microservices-demo/payments/repository"
)

// PaymentsAPI type
type PaymentsAPI struct {
	repository repository.Repository
}

func (a *PaymentsAPI) GetPaymentIntent(cartID string) (*model.PaymentIntent, error) {
	return a.repository.GetPaymentIntent(cartID)
}

// NewPaymentsAPI constructor
func NewPaymentsAPI(configuration config.DatabaseConfiguration) (*PaymentsAPI, error) {
	repository, err := repository.NewRepository(configuration)
	if err != nil {
		log.Println("Error creating payments API", err)
		return nil, err
	}

	return &PaymentsAPI{
		repository: repository,
	}, nil
}
