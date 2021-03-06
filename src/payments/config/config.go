package config

// Configuration exported
type AppConfiguration struct {
	Port      int    `env:"PORT,default=8080"`
	ImagePath string `env:"IMAGE_PATH,default=./images/"`
	Database  DatabaseConfiguration
}

// DatabaseConfiguration exported
type DatabaseConfiguration struct {
	Type         string `env:"DB_TYPE,default=mysql"`
	Endpoint     string `env:"DB_ENDPOINT,default=payments-db:3306"`
	ReadEndpoint string `env:"DB_READ_ENDPOINT"`
	Name         string `env:"DB_NAME,default=watchndb"`
	User         string `env:"DB_USER,default=payments_user"`
	Password     string `env:"DB_PASSWORD,default=default_password"`
	Migrate      bool   `env:"DB_MIGRATE,default=true"`
}
