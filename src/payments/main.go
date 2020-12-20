package main

import (
	"context"
	"log"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	_ "github.com/go-sql-driver/mysql"
	"github.com/niallthomson/microservices-demo/payments/config"
	"github.com/niallthomson/microservices-demo/payments/controller"
	_ "github.com/niallthomson/microservices-demo/payments/docs"
	"github.com/niallthomson/microservices-demo/payments/repository"
	"github.com/sethvargo/go-envconfig/pkg/envconfig"
	ginprometheus "github.com/zsais/go-gin-prometheus"

	swaggerFiles "github.com/swaggo/files"
	ginSwagger "github.com/swaggo/gin-swagger"
)

// @title Payments API
// @version 1.0
// @description This API serves the product payments

// @license.name Apache 2.0
// @license.url http://www.apache.org/licenses/LICENSE-2.0.html

// @host localhost:8080

func main() {
	ctx := context.Background()

	var config config.AppConfiguration
	if err := envconfig.Process(ctx, &config); err != nil {
		log.Fatal(err)
	}

	_, err := repository.NewRepository(config.Database)
	if err != nil {
		log.Println("Error creating repository", err)
	}

	r := gin.Default()

	c, err := controller.NewController(config)
	if err != nil {
		log.Fatalln("Error creating controller", err)
	}

	payments := r.Group("/paymentsue")
	{
		payments.GET("", c.GetProducts)

		payments.GET("/size", c.PaymentsSize)
		payments.GET("/tags", c.ListTags)
		payments.GET("/product/:id", c.GetProduct)
	}

	r.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))
	r.GET("/health", func(c *gin.Context) {
		c.String(http.StatusOK, "OK")
	})

	p := ginprometheus.NewPrometheus("gin")
	p.Use(r)

	r.Run(":" + strconv.Itoa(config.Port))
}
