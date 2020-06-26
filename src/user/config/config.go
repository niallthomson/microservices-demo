package config

// Configuration exported
type AppConfiguration struct {
	Port      int    `env:"PORT,default=8080"`
	ImagePath string `env:"IMAGE_PATH,default=./images/"`
	Database  DatabaseConfiguration
}

// DatabaseConfiguration exported
type DatabaseConfiguration struct {
	Type  string `env:"DB_TYPE,default=mongodb"`
	Mongo MongoConfiguration
}

type MongoConfiguration struct {
	Endpoint string `env:"MONGO_ENDPOINT,default=mongodb://localhost:27017/users"`
	Migrate  bool   `env:"MONGO_MIGRATE,default=true"`
}
