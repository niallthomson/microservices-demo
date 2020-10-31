package controller

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"github.com/niallthomson/microservices-demo/payments/api"
	"github.com/niallthomson/microservices-demo/payments/config"
	"github.com/niallthomson/microservices-demo/payments/httputil"
)

// Controller example
type Controller struct {
	api *api.PaymentsAPI
}

// NewController example
func NewController(config config.AppConfiguration) (*Controller, error) {
	api, err := api.NewPaymentsAPI(config.Database)
	if err != nil {
		return nil, err
	}

	return &Controller{
		api: api,
	}, nil
}

// GetPaymentIntentByCartID godoc
// @Summary Get payment intent by cart ID
// @Description Get payment intent by cart ID
// @Tags payments
// @Accept  json
// @Produce  json
// @Param id path string true "Cart ID"
// @Success 200 {array} model.PaymentIntent
// @Failure 400 {object} httputil.HTTPError
// @Failure 404 {object} httputil.HTTPError
// @Failure 500 {object} httputil.HTTPError
// @Router /client-secret/{id} [get]
func (c *Controller) GetPaymentIntentByCartID(ctx *gin.Context) {
	id := ctx.Param("id")

	products, err := c.api.GetPaymentIntent(id)
	if err != nil {
		httputil.NewError(ctx, http.StatusNotFound, err)
		return
	}
	ctx.JSON(http.StatusOK, products)
}

func getQueryInt(name string, defaultValue int, ctx *gin.Context) (int, error) {
	str := ctx.Query(name)

	if len(str) > 0 {
		return strconv.Atoi(str)
	}

	return defaultValue, nil
}
