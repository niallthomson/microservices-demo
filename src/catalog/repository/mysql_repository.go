package repository

import (
	"errors"
	"fmt"
	"log"
	"strings"
	"time"

	"github.com/golang-migrate/migrate/v4"
	_ "github.com/golang-migrate/migrate/v4/database/mysql"
	_ "github.com/golang-migrate/migrate/v4/source/file"
	"github.com/jmoiron/sqlx"
	"github.com/niallthomson/microservices-demo/catalog/config"
	"github.com/niallthomson/microservices-demo/catalog/model"
)

// ErrNotFound is returned when there is no product for a given ID.
var ErrNotFound = errors.New("not found")

// ErrDBConnection is returned when connection with the database fails.
var ErrDBConnection = errors.New("database connection error")

var baseQuery = "SELECT product.product_id AS id, product.name, product.description, product.price, product.count, product.image_url_1, product.image_url_2, GROUP_CONCAT(tag.name) AS tag_name FROM product JOIN product_tag ON product.product_id=product_tag.product_id JOIN tag ON product_tag.tag_id=tag.tag_id"

type mySQLRepository struct {
	db *sqlx.DB
	//logger log.Logger
}

func newMySQLRepository(config config.DatabaseConfiguration) (Repository, error) {
	connectionString := fmt.Sprintf("%s:%s@tcp(%s)/%s", config.User, config.Password, config.Endpoint, config.Name)

	log.Printf("Connecting to %s\n", connectionString)

	if config.Migrate {
		err := migrateMySQL(connectionString)
		if err != nil {
			log.Println("Error: Failed to run migration", err)
			return nil, err
		}
	}

	db, err := sqlx.Open("mysql", connectionString)
	if err != nil {
		log.Println("Error: Unable to create connection to database", err)
		return nil, err
	}

	// Check if DB connection can be made, only for logging purposes, should not fail/exit
	err = db.Ping()
	if err != nil {
		log.Println("Error: Unable to connect to database")
		return nil, err
	}

	return &mySQLRepository{
		db: db,
	}, nil
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

func (s *mySQLRepository) List(tags []string, order string, pageNum, pageSize int) ([]model.Product, error) {
	var products []model.Product
	query := baseQuery

	var args []interface{}

	for i, t := range tags {
		if i == 0 {
			query += " WHERE tag.name=?"
			args = append(args, t)
		} else {
			query += " OR tag.name=?"
			args = append(args, t)
		}
	}

	query += " GROUP BY id"

	if order != "" {
		query += " ORDER BY ?"
		args = append(args, order)
	}

	query += ";"

	err := s.db.Select(&products, query, args...)
	if err != nil {
		log.Println("database error", err)
		return []model.Product{}, ErrDBConnection
	}
	for i, s := range products {
		products[i].ImageURL = []string{s.ImageURL_1, s.ImageURL_2}
		products[i].Tags = strings.Split(s.TagString, ",")
	}

	// DEMO: Change 0 to 850
	time.Sleep(0 * time.Millisecond)

	products = cut(products, pageNum, pageSize)

	return products, nil
}

func (s *mySQLRepository) Count(tags []string) (int, error) {
	query := "SELECT COUNT(DISTINCT product.product_id) FROM product JOIN product_tag ON product.product_id=product_tag.product_id JOIN tag ON product_tag.tag_id=tag.tag_id"

	var args []interface{}

	for i, t := range tags {
		if i == 0 {
			query += " WHERE tag.name=?"
			args = append(args, t)
		} else {
			query += " OR tag.name=?"
			args = append(args, t)
		}
	}

	query += ";"

	sel, err := s.db.Prepare(query)

	if err != nil {
		log.Println("database error", err)
		return 0, ErrDBConnection
	}
	defer sel.Close()

	var count int
	err = sel.QueryRow(args...).Scan(&count)

	if err != nil {
		log.Println("database error", err)
		return 0, ErrDBConnection
	}

	return count, nil
}

func (s *mySQLRepository) Get(id string) (*model.Product, error) {
	query := baseQuery + " WHERE product.product_id =? GROUP BY product.product_id;"

	var product model.Product
	err := s.db.Get(&product, query, id)
	if err != nil {
		log.Println("database error", err)
		return nil, ErrNotFound
	}

	product.ImageURL = []string{product.ImageURL_1, product.ImageURL_2}
	product.Tags = strings.Split(product.TagString, ",")

	return &product, nil
}

func (s *mySQLRepository) Tags() ([]model.Tag, error) {
	var tags []model.Tag
	query := "SELECT name, display_name FROM tag;"
	rows, err := s.db.Query(query)
	if err != nil {
		log.Println("database error", err)
		return []model.Tag{}, ErrDBConnection
	}

	for rows.Next() {
		var tag model.Tag

		err = rows.Scan(&tag.Name, &tag.DisplayName)
		if err != nil {
			log.Println("Error reading tag row", err)
			continue
		}
		tags = append(tags, tag)
	}

	return tags, nil
}

func cut(products []model.Product, pageNum, pageSize int) []model.Product {
	if pageNum == 0 || pageSize == 0 {
		return []model.Product{} // pageNum is 1-indexed
	}
	start := (pageNum * pageSize) - pageSize
	if start > len(products) {
		return []model.Product{}
	}
	end := (pageNum * pageSize)
	if end > len(products) {
		end = len(products)
	}
	return products[start:end]
}

func contains(s []string, e string) bool {
	for _, a := range s {
		if a == e {
			return true
		}
	}
	return false
}
