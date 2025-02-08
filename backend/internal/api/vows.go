package api

import (
	"encoding/json"
	"net/http"

	"language_vows/internal/db"
	"language_vows/internal/models"

	"github.com/go-chi/chi/v5"
)

type vowsResource struct {
	db *db.Database
}

func (vr vowsResource) Routes() chi.Router {
	r := chi.NewRouter()

	r.Get("/", vr.List)    // GET /api/vows
	r.Post("/", vr.Create) // POST /api/vows
	r.Route("/{vowID}", func(r chi.Router) {
		r.Get("/", vr.Get)       // GET /api/vows/{vowID}
		r.Put("/", vr.Update)    // PUT /api/vows/{vowID}
		r.Delete("/", vr.Delete) // DELETE /api/vows/{vowID}
	})

	return r
}

func (vr vowsResource) List(w http.ResponseWriter, r *http.Request) {
	// Temporary implementation - replace with actual database query
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode([]models.Vow{})
}

func (vr vowsResource) Create(w http.ResponseWriter, r *http.Request) {
	// Temporary implementation
	w.WriteHeader(http.StatusCreated)
}

func (vr vowsResource) Get(w http.ResponseWriter, r *http.Request) {
	// Temporary implementation
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(models.Vow{})
}

func (vr vowsResource) Update(w http.ResponseWriter, r *http.Request) {
	// Temporary implementation
	w.WriteHeader(http.StatusOK)
}

func (vr vowsResource) Delete(w http.ResponseWriter, r *http.Request) {
	// Temporary implementation
	w.WriteHeader(http.StatusNoContent)
} 