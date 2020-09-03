package main

import (
	"context"
	"testing"
	"time"
)

func TestTest(t *testing.T) {
	ctx := context.Background()

	now, err := test(ctx)
	if err != nil {
		t.Fatalf("Unexpected error running test(): %s", err)
	}
	if time.Since(now) > 1*time.Second {
		t.Fatalf("Result of test() too far in the past.")
	}
}
