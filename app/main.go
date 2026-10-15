// Command app is the sample workload deployed onto the k3s cluster this
// repo provisions. It exists to make the Terraform + Kubernetes manifests
// in this repo demonstrable end to end: build it, containerize it, deploy
// it, and watch `hostname` rotate across replicas as the Service load
// balances and the Deployment rolls.
package main

import (
	"context"
	"errors"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"
)

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	srv := newServer()

	mux := http.NewServeMux()
	mux.HandleFunc("/healthz", srv.healthzHandler)
	mux.HandleFunc("/", srv.rootHandler)

	httpServer := &http.Server{
		Addr:              ":" + port,
		Handler:           mux,
		ReadHeaderTimeout: 5 * time.Second,
	}

	go func() {
		log.Printf("listening on :%s", port)
		if err := httpServer.ListenAndServe(); err != nil && !errors.Is(err, http.ErrServerClosed) {
			log.Fatalf("server error: %v", err)
		}
	}()

	// Graceful shutdown matters here specifically because this runs under
	// Kubernetes: on a rolling update the kubelet sends SIGTERM and then
	// waits terminationGracePeriodSeconds before SIGKILL. Exiting cleanly
	// avoids dropping in-flight requests during every deploy.
	stop := make(chan os.Signal, 1)
	signal.Notify(stop, syscall.SIGINT, syscall.SIGTERM)
	<-stop

	log.Println("shutting down")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	if err := httpServer.Shutdown(ctx); err != nil {
		log.Fatalf("graceful shutdown failed: %v", err)
	}
}
