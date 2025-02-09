package api

import (
	"encoding/json"
	"log"
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
	rows, err := vr.db.DB.Query("SELECT id, text, language FROM vows ORDER BY id")
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	var vows []models.Vow
	for rows.Next() {
		var vow models.Vow
		if err := rows.Scan(&vow.ID, &vow.Text, &vow.Language); err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
		vows = append(vows, vow)
	}

	log.Printf("Number of vows in database: %d", len(vows))

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(vows)
}

func (vr vowsResource) Create(w http.ResponseWriter, r *http.Request) {
	var vow models.Vow
	if err := json.NewDecoder(r.Body).Decode(&vow); err != nil {
		log.Printf("Error decoding request body: %v", err)
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	log.Printf("Creating vow: %+v", vow)

	result, err := vr.db.DB.Exec(
		"INSERT INTO vows (id, text, language) VALUES ($1, $2, $3)",
		vow.ID, vow.Text, vow.Language,
	)
	if err != nil {
		log.Printf("Error inserting vow: %v", err)
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	rowsAffected, _ := result.RowsAffected()
	log.Printf("Rows affected by insert: %d", rowsAffected)

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(vow)
}

func (vr vowsResource) Get(w http.ResponseWriter, r *http.Request) {
	vowID := chi.URLParam(r, "vowID")
	
	var vow models.Vow
	err := vr.db.DB.QueryRow(
		"SELECT id, text, language FROM vows WHERE id = $1",
		vowID,
	).Scan(&vow.ID, &vow.Text, &vow.Language)
	
	if err != nil {
		http.Error(w, "Vow not found", http.StatusNotFound)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(vow)
}

func (vr vowsResource) Update(w http.ResponseWriter, r *http.Request) {
	vowID := chi.URLParam(r, "vowID")
	
	var vow models.Vow
	if err := json.NewDecoder(r.Body).Decode(&vow); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	result, err := vr.db.DB.Exec(
		"UPDATE vows SET text = $1 WHERE id = $2",
		vow.Text, vowID,
	)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	rows, _ := result.RowsAffected()
	if rows == 0 {
		http.Error(w, "Vow not found", http.StatusNotFound)
		return
	}

	w.WriteHeader(http.StatusOK)
}

func (vr vowsResource) Delete(w http.ResponseWriter, r *http.Request) {
	vowID := chi.URLParam(r, "vowID")

	result, err := vr.db.DB.Exec("DELETE FROM vows WHERE id = $1", vowID)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	rows, _ := result.RowsAffected()
	if rows == 0 {
		http.Error(w, "Vow not found", http.StatusNotFound)
		return
	}

	w.WriteHeader(http.StatusNoContent)
} 