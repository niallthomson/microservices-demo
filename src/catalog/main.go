package main

import (
	"context"
	"log"
	"net/http"
	"strconv"

	"github.com/gin-contrib/static"
	"github.com/gin-gonic/gin"
	_ "github.com/go-sql-driver/mysql"
	"github.com/niallthomson/microservices-demo/catalog/config"
	"github.com/niallthomson/microservices-demo/catalog/controller"
	_ "github.com/niallthomson/microservices-demo/catalog/docs"
	"github.com/niallthomson/microservices-demo/catalog/repository"
	"github.com/sethvargo/go-envconfig/pkg/envconfig"
	"github.com/zsais/go-gin-prometheus"

	swaggerFiles "github.com/swaggo/files"
	ginSwagger "github.com/swaggo/gin-swagger"
)

// @title Catalog API
// @version 1.0
// @description This API serves the product catalog

// @license.name Apache 2.0
// @license.url http://www.apache.org/licenses/LICENSE-2.0.html

// @host localhost:8080
// @BasePath /catalogue

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

	catalog := r.Group("/catalogue")
	{
		catalog.GET("", c.GetProducts)

		catalog.GET("/size", c.CatalogSize)
		catalog.GET("/tags", c.ListTags)
		catalog.GET("/product/:id", c.GetProduct)
	}

	r.Use(static.Serve("/catalogue/images", static.LocalFile("./images/", false)))

	r.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))
	r.GET("/health", func(c *gin.Context) {
		c.String(http.StatusOK, "OK")
	})

	p := ginprometheus.NewPrometheus("gin")
	p.Use(r)

	r.Run(":" + strconv.Itoa(config.Port))
}
