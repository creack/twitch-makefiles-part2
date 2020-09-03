package main

import (
	"context"
	"fmt"
	"os"
	"time"

	"github.com/jmoiron/sqlx"
	_ "github.com/lib/pq" // Load the postgres driver.
)

func test(ctx context.Context) (time.Time, error) {
	db, err := sqlx.Open("postgres", "postgres://postgres:password@"+os.Getenv("DB_IP")+":5432?sslmode=disable")
	if err != nil {
		return time.Time{}, fmt.Errorf("sql.Open: %w", err)
	}
	defer func() { _ = db.Close() }() // Best effort.

	var now time.Time
	if err := db.GetContext(ctx, &now, "SELECT NOW();"); err != nil {
		return time.Time{}, fmt.Errorf("db.GetContext select time: %w", err)
	}

	return now, nil
}

func main() {
	if _, err := test(context.Background()); err != nil {
		println("Fail:", err.Error())
		return
	}
	println("success")
}
