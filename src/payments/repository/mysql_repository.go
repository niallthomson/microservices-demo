package repository

import (
	"errors"
	"fmt"
	"log"

	"github.com/golang-migrate/migrate/v4"
	_ "github.com/golang-migrate/migrate/v4/database/mysql"
	_ "github.com/golang-migrate/migrate/v4/source/file"
	"github.com/jmoiron/sqlx"
	"github.com/niallthomson/microservices-demo/payments/config"
	"github.com/niallthomson/microservices-demo/payments/model"
)

// ErrNotFound is returned when there is no product for a given ID.
var ErrNotFound = errors.New("not found")

// ErrDBConnection is returned when connection with the database fails.
var ErrDBConnection = errors.New("database connection error")

var baseQuery = "SELECT product.product_id AS id, product.name, product.description, product.price, product.count, product.image_url, GROUP_CONCAT(tag.name) AS tag_name FROM product JOIN product_tag ON product.product_id=product_tag.product_id JOIN tag ON product_tag.tag_id=tag.tag_id"

type mySQLRepository struct {
	db       *sqlx.DB
	readerDb *sqlx.DB
	//logger log.Logger
}

func newMySQLRepository(config config.DatabaseConfiguration) (Repository, error) {
	connectionString := fmt.Sprintf("%s:%s@tcp(%s)/%s", config.User, config.Password, config.Endpoint, config.Name)

	if config.Migrate {
		err := migrateMySQL(connectionString)
		if err != nil {
			log.Println("Error: Failed to run migration", err)
			return nil, err
		}
	}

	var readerDb *sqlx.DB

	db, err := createConnection(connectionString)
	if err != nil {
		log.Println("Error: Unable to connect to database", err)
		return nil, err
	}

	if len(config.ReadEndpoint) > 0 {
		readerConnectionString := fmt.Sprintf("%s:%s@tcp(%s)/%s", config.User, config.Password, config.ReadEndpoint, config.Name)

		readerDb, err = createConnection(readerConnectionString)
		if err != nil {
			log.Println("Error: Unable to connect to reader database", err)
			return nil, err
		}
	} else {
		readerDb = db
	}

	return &mySQLRepository{
		db:       db,
		readerDb: readerDb,
	}, nil
}

func createConnection(connectionString string) (*sqlx.DB, error) {
	log.Printf("Connecting to %s\n", connectionString)

	db, err := sqlx.Open("mysql", connectionString)
	if err != nil {
		return nil, err
	}

	// Check if DB connection can be made, only for logging purposes, should not fail/exit
	err = db.Ping()
	if err != nil {
		return nil, err
	}

	return db, nil
}

func migrateMySQL(connectionString string) error {
	m, err := migrate.New(
		"file://db/migrations",
		"mysql://"+connectionString,
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

func (s *mySQLRepository) GetPaymentIntent(cartID string) (*model.PaymentIntent, error) {
	return &model.PaymentIntent{}, nil
}
