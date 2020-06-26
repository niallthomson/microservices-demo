package controller

import (
	"encoding/base64"
	"errors"
	"net/http"
	"strings"

	"github.com/gin-gonic/gin"
	"github.com/niallthomson/microservices-demo/user/api"
	"github.com/niallthomson/microservices-demo/user/config"
	"github.com/niallthomson/microservices-demo/user/httputil"
	"github.com/niallthomson/microservices-demo/user/model"
)

var ErrNotFound = errors.New("not found")
var ErrUnAuthorized = errors.New("unauthorized")

// Controller example
type Controller struct {
	api *api.UsersAPI
}

// NewController example
func NewController(config config.AppConfiguration) (*Controller, error) {
	api, err := api.NewUsersAPI(config.Database)
	if err != nil {
		return nil, err
	}

	return &Controller{
		api: api,
	}, nil
}

// GetCustomer godoc
// @Summary Get customer
// @Description Get customer
// @Tags customers
// @Accept  json
// @Produce  json
// @Param id path string true "Customer ID"
// @Success 200 {object} model.User
// @Failure 400 {object} httputil.HTTPError
// @Failure 404 {object} httputil.HTTPError
// @Failure 500 {object} httputil.HTTPError
// @Router /customers/{id} [get]
func (c *Controller) GetCustomer(ctx *gin.Context) {
	id := ctx.Param("id")

	customer, err := c.api.GetCustomer(id)
	if err != nil || customer == nil {
		httputil.NewError(ctx, http.StatusNotFound, ErrNotFound)
		return
	}

	customer.MaskCCs()

	ctx.JSON(http.StatusOK, customer)
}

// GetCustomerCards godoc
// @Summary Get customer cards
// @Description Get customer cards
// @Tags customers
// @Accept  json
// @Produce  json
// @Param id path string true "Customer ID"
// @Success 200 {array} model.Card
// @Failure 400 {object} httputil.HTTPError
// @Failure 404 {object} httputil.HTTPError
// @Failure 500 {object} httputil.HTTPError
// @Router /customers/{id}/cards [get]
func (c *Controller) GetCustomerCards(ctx *gin.Context) {
	id := ctx.Param("id")

	customer, err := c.api.GetCustomer(id)
	if err != nil || customer == nil {
		httputil.NewError(ctx, http.StatusNotFound, ErrNotFound)
		return
	}

	customer.MaskCCs()

	ctx.JSON(http.StatusOK, customer.Cards)
}

// GetCustomerAddresses godoc
// @Summary Get customer addresses
// @Description Get customer addresses
// @Tags customers
// @Accept  json
// @Produce  json
// @Param id path string true "Customer ID"
// @Success 200 {array} model.Address
// @Failure 400 {object} httputil.HTTPError
// @Failure 404 {object} httputil.HTTPError
// @Failure 500 {object} httputil.HTTPError
// @Router /customers/{id} [get]
func (c *Controller) GetCustomerAddresses(ctx *gin.Context) {
	id := ctx.Param("id")

	customer, err := c.api.GetCustomer(id)
	if err != nil || customer == nil {
		httputil.NewError(ctx, http.StatusNotFound, ErrNotFound)
		return
	}

	ctx.JSON(http.StatusOK, customer.Addresses)
}

// Login exported
func (c *Controller) Login(ctx *gin.Context) {
	auth := strings.SplitN(ctx.Request.Header.Get("Authorization"), " ", 2)

	if len(auth) != 2 || auth[0] != "Basic" {
		httputil.NewError(ctx, http.StatusUnauthorized, ErrUnAuthorized)
		return
	}
	payload, _ := base64.StdEncoding.DecodeString(auth[1])
	pair := strings.SplitN(string(payload), ":", 2)

	if len(pair) != 2 {
		httputil.NewError(ctx, http.StatusUnauthorized, ErrUnAuthorized)
		return
	}

	user := c.api.Login(pair[0], pair[1])
	if user == nil {
		httputil.NewError(ctx, http.StatusUnauthorized, ErrUnAuthorized)
		return
	}

	user.MaskCCs()

	ctx.JSON(http.StatusOK, &userResponse{User: user})
}

type userResponse struct {
	User *model.User `json:"user"`
}
