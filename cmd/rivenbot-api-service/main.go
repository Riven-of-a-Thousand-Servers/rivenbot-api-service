package main

import (
	"context"
	"database/sql"
	"embed"
	"fmt"
	"io"
	"log"
	"net/http"
	"net/url"
	"os"

	"rivenbot-api-service/pkg/config"

	"github.com/deahtstroke/gsmt/pkg/dialect"
	"github.com/deahtstroke/gsmt/pkg/migrator"
	"github.com/deahtstroke/gsmt/pkg/store"

	_ "github.com/lib/pq"
)

//go:embed migrations/schema
var schema embed.FS

//go:embed migrations/data
var data embed.FS

func main() {
	configPath := os.Getenv("CONFIG_PATH")
	if configPath == "" {
		configPath = "config/local.yaml"
	}
	appconfig, err := config.ParseConfig(configPath)
	if err != nil {
		log.Panicf("Error parsing app configuration: %v", err)
	}

	connString := fmt.Sprintf("postgres://%s:%s@%s:%s/%s?sslmode=disable",
		url.QueryEscape(appconfig.Datasource.Username),
		url.QueryEscape(appconfig.Datasource.Password),
		appconfig.Datasource.Host,
		appconfig.Datasource.Port,
		appconfig.Datasource.Database)
	db, err := sql.Open("postgres", connString)
	fmt.Printf(connString)
	if err != nil {
		log.Panicf("Error opening connection to database: %v", err)
	}

	migrator, err := migrator.NewMigrator(migrator.MigratorOpts{
		Schema: schema,
		Data:   data,
		Store:  store.NewSQLStore(db, dialect.Postgres()),
	})

	err = migrator.ApplyMigrations(context.Background())
	if err != nil {
		log.Panicf("Error applying migrations: %v", err)
	}

	mux := http.NewServeMux()

	mux.HandleFunc("/healthcheck", func(w http.ResponseWriter, r *http.Request) {
		log.Printf("Received healthcheck probe. Status: OK")
		w.WriteHeader(http.StatusOK)
		io.WriteString(w, "Ready")
	})

	log.Printf("Ready to receive requests on port: 8080")
	log.Fatal(http.ListenAndServe(":8080", mux))
}
