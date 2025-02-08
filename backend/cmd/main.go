package main

import (
	"log"
	"net/http"
	"os"

	"github.com/joho/godotenv"
	"language_vows/internal/api"
	"language_vows/internal/db"
)

func main() {
	// Load environment variables
	if err := godotenv.Load(); err != nil {
		log.Printf("Warning: .env file not found")
	}

	// Initialize database connection
	database, err := db.Initialize()
	if err != nil {
		log.Fatalf("Could not initialize database connection: %v", err)
	}
	defer database.Close()

	// Initialize router
	router := api.NewRouter(database)

	// Get port from environment variable or use default
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	log.Printf("Server starting on port %s", port)
	if err := http.ListenAndServe(":"+port, router); err != nil {
		log.Fatalf("Could not start server: %v", err)
	}
} 