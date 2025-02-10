package main

import (
	"log"
	"net/http"
	"os"

	"language_vows/internal/api"
	"language_vows/internal/db"

	"github.com/joho/godotenv"
)

func main() {
	if err := godotenv.Load(); err != nil {
		log.Printf("Warning: .env file not found")
	}

	database, err := db.Initialize()
	if err != nil {
		log.Fatalf("Could not initialize database connection: %v", err)
	}
	defer database.Close()

	router := api.NewRouter(database)

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	log.Printf("Server starting on port %s", port)
	if err := http.ListenAndServe(":"+port, router); err != nil {
		log.Fatalf("Could not start server: %v", err)
	}
}
