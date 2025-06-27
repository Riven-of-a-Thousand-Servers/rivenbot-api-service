package main

import (
	"database/sql"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"

	"rivenbot-api-service/pkg/config"

	"github.com/deahtstroke/gsmt/pkg/dialect"
	"github.com/deahtstroke/gsmt/pkg/migrate"

	_ "github.com/lib/pq"
)

func main() {
	configPath := os.Getenv("CONFIG_PATH")
	if configPath == "" {
		configPath = "config/local.yaml"
	}
	appconfig, err := config.ParseConfig(configPath)
	if err != nil {
		log.Panicf("Error parsing app configuration: %v", err)
	}

	url := fmt.Sprintf("host=%s port=%s user=%s password=%s dbname=%s sslmode=disable",
		appconfig.Datasource.Host, appconfig.Datasource.Port, appconfig.Datasource.Username, appconfig.Datasource.Password, appconfig.Datasource.Database)
	db, err := sql.Open("postgres", url)
	if err != nil {
		log.Panicf("Error opening connection to database: %v", err)
	}

	migrator, err := migrate.New(db, migrate.WithDialect(dialect.NewPostgresDialect()))
	if err != nil {
		log.Panicf("Error creating migrator: %v", err)
	}

	err = migrator.ApplyMigrations()
	if err != nil {
		log.Panicf("Error applying migrations: %v", err)
	}

	mux := http.NewServeMux()

	mux.HandleFunc("/healthcheck", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		io.WriteString(w, "Ready")
	})

	log.Printf("Ready to receive requests on port: 8083")
	log.Fatal(http.ListenAndServe(":8083", mux))
}
