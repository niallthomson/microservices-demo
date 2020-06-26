package api

import (
	"crypto/sha1"
	"fmt"
	"io"
	"log"

	"github.com/niallthomson/microservices-demo/user/config"
	"github.com/niallthomson/microservices-demo/user/model"
	"github.com/niallthomson/microservices-demo/user/repository"
)

// UsersAPI type
type UsersAPI struct {
	repository repository.Repository
}

func (a *UsersAPI) GetCustomer(id string) (*model.User, error) {
	return a.repository.GetCustomer(id)
}

func (a *UsersAPI) Login(username, password string) *model.User {
	user := a.repository.GetCustomerByUsername(username)

	if user != nil {
		if user.Password != calculatePassHash(password, user.Salt) {
			return nil
		}

		return user
	}

	return nil
}

// NewUsersAPI constructor
func NewUsersAPI(configuration config.DatabaseConfiguration) (*UsersAPI, error) {
	repository, err := repository.NewRepository(configuration)
	if err != nil {
		log.Println("Error creating catalog API", err)
		return nil, err
	}

	return &UsersAPI{
		repository: repository,
	}, nil
}

func calculatePassHash(pass, salt string) string {
	h := sha1.New()
	io.WriteString(h, salt)
	io.WriteString(h, pass)
	return fmt.Sprintf("%x", h.Sum(nil))
}
