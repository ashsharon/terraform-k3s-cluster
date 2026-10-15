package main

import (
	"encoding/json"
	"net/http"
	"os"
	"sync/atomic"
	"time"
)

// server holds the small bit of state the handlers need. Keeping it as a
// struct (instead of package-level globals) is what makes it trivial to
// unit test — handlers_test.go constructs its own instance per test.
type server struct {
	hostname  string
	startedAt time.Time
	requests  atomic.Int64
}

func newServer() *server {
	hostname, err := os.Hostname()
	if err != nil {
		hostname = "unknown"
	}
	return &server{hostname: hostname, startedAt: time.Now()}
}

// healthzResponse is intentionally tiny: Kubernetes liveness/readiness
// probes just need a 200 and a body is optional, but a status field makes
// `curl`-ing it by hand nicer.
type healthzResponse struct {
	Status string `json:"status"`
}

func (s *server) healthzHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	_ = json.NewEncoder(w).Encode(healthzResponse{Status: "ok"})
}

type rootResponse struct {
	Hostname       string `json:"hostname"`
	UptimeSeconds  int64  `json:"uptimeSeconds"`
	RequestsServed int64  `json:"requestsServed"`
}

// rootHandler is deliberately boring: in a multi-replica Deployment behind
// a Service, hitting this repeatedly and watching the hostname change is
// the easiest way to prove load balancing and rolling updates are actually
// working — which is the whole point of this sample app.
func (s *server) rootHandler(w http.ResponseWriter, r *http.Request) {
	count := s.requests.Add(1)

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	_ = json.NewEncoder(w).Encode(rootResponse{
		Hostname:       s.hostname,
		UptimeSeconds:  int64(time.Since(s.startedAt).Seconds()),
		RequestsServed: count,
	})
}
