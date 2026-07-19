package main

import "testing"

func TestParseReadLimitUsesConservativeDefault(t *testing.T) {
	limit, err := parseReadLimit("")
	if err != nil {
		t.Fatalf("expected a default read limit: %v", err)
	}
	if limit != 50 {
		t.Fatalf("expected default read limit 50, got %d", limit)
	}
}

func TestParseReadLimitRejectsUnboundedReads(t *testing.T) {
	for _, raw := range []string{"0", "101", "not-a-number"} {
		if _, err := parseReadLimit(raw); err == nil {
			t.Fatalf("expected %q to be rejected", raw)
		}
	}
}

func TestParseReadLimitAcceptsBoundedRead(t *testing.T) {
	limit, err := parseReadLimit("12")
	if err != nil {
		t.Fatalf("expected bounded read to be valid: %v", err)
	}
	if limit != 12 {
		t.Fatalf("expected read limit 12, got %d", limit)
	}
}
