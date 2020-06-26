package main

import (
	"context"
	"log"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	_ "github.com/go-sql-driver/mysql"
	"github.com/niallthomson/microservices-demo/user/config"
	"github.com/niallthomson/microservices-demo/user/controller"
	_ "github.com/niallthomson/microservices-demo/user/docs"
	"github.com/niallthomson/microservices-demo/user/repository"
	"github.com/sethvargo/go-envconfig/pkg/envconfig"
	ginprometheus "github.com/zsais/go-gin-prometheus"

	swaggerFiles "github.com/swaggo/files"
	ginSwagger "github.com/swaggo/gin-swagger"
)

// @title User API
// @version 1.0
// @description This API stores user data

// @license.name Apache 2.0
// @license.url http://www.apache.org/licenses/LICENSE-2.0.html

// @host localhost:8080
// @BasePath /customers

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

	catalog := r.Group("/customers")
	{
		catalog.GET("/:id/cards", c.GetCustomerCards)
		catalog.GET("/:id/addresses", c.GetCustomerAddresses)
		catalog.GET("/:id", c.GetCustomer)
	}

	r.GET("/login", c.Login)

	r.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))
	r.GET("/health", func(c *gin.Context) {
		c.String(http.StatusOK, "OK")
	})

	p := ginprometheus.NewPrometheus("gin")
	p.Use(r)

	r.Run(":" + strconv.Itoa(config.Port))
}
