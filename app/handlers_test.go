package main

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"
)

func TestHealthzHandler(t *testing.T) {
	s := newServer()
	req := httptest.NewRequest(http.MethodGet, "/healthz", nil)
	rec := httptest.NewRecorder()

	s.healthzHandler(rec, req)

	if rec.Code != http.StatusOK {
		t.Fatalf("want status 200, got %d", rec.Code)
	}

	var body healthzResponse
	if err := json.Unmarshal(rec.Body.Bytes(), &body); err != nil {
		t.Fatalf("response isn't valid JSON: %v", err)
	}
	if body.Status != "ok" {
		t.Errorf("want status %q, got %q", "ok", body.Status)
	}
}

func TestRootHandler_CountsRequests(t *testing.T) {
	s := newServer()

	for i, want := range []int64{1, 2, 3} {
		req := httptest.NewRequest(http.MethodGet, "/", nil)
		rec := httptest.NewRecorder()

		s.rootHandler(rec, req)

		if rec.Code != http.StatusOK {
			t.Fatalf("request %d: want status 200, got %d", i, rec.Code)
		}

		var body rootResponse
		if err := json.Unmarshal(rec.Body.Bytes(), &body); err != nil {
			t.Fatalf("request %d: response isn't valid JSON: %v", i, err)
		}
		if body.RequestsServed != want {
			t.Errorf("request %d: want RequestsServed=%d, got %d", i, want, body.RequestsServed)
		}
		if body.Hostname == "" {
			t.Errorf("request %d: expected a non-empty hostname", i)
		}
	}
}
