package db

import (
	"database/sql"
	"fmt"
	"os"

	// Import pq for Postgres driver side effects
	_ "github.com/lib/pq"
)

type Database struct {
	DB *sql.DB
}

func Initialize() (*Database, error) {
	db := &Database{}
	dsn := fmt.Sprintf(
		"host=%s port=%s user=%s password=%s dbname=%s sslmode=disable",
		os.Getenv("DB_HOST"),
		os.Getenv("DB_PORT"),
		os.Getenv("DB_USER"),
		os.Getenv("DB_PASSWORD"),
		os.Getenv("DB_NAME"),
	)

	conn, err := sql.Open("postgres", dsn)
	if err != nil {
		return nil, err
	}

	db.DB = conn
	err = db.DB.Ping()
	if err != nil {
		return nil, err
	}

	return db, nil
}

func (db *Database) Close() error {
	return db.DB.Close()
}
