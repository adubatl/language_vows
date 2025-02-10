package api

import (
	"bytes"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"

	"language_vows/internal/models"

	"github.com/go-chi/chi/v5"
)

type themesResource struct{}

func (tr themesResource) Routes() chi.Router {
	r := chi.NewRouter()
	r.Post("/generate", tr.GenerateTheme)
	return r
}

func (tr themesResource) GenerateTheme(w http.ResponseWriter, r *http.Request) {
	ollamaHost := os.Getenv("OLLAMA_HOST")
	if ollamaHost == "" {
		ollamaHost = "http://localhost:11434"
	}
	log.Printf("Using Ollama host: %s", ollamaHost)

	var themeRequest models.ThemeRequest
	if err := json.NewDecoder(r.Body).Decode(&themeRequest); err != nil {
		log.Printf("Error decoding request body: %v", err)
		themeRequest.Prompt = "Generate a unique theme"
	}
	log.Printf("Using prompt: %s", themeRequest.Prompt)

	prompt := fmt.Sprintf(`Generate a theme based on this prompt: "%s"
	Respond with a JSON object containing:
	1. "name": A short, catchy name for the theme (3-5 words)
	2. "description": A brief description of the theme (2-3 sentences)
	3. "background": A hex color code for the background that fits the theme
	4. "text": A contrasting hex color code for text that ensures readability
	5. "accent": A complementary hex color code that adds visual interest
	
	Ensure the colors have sufficient contrast for readability.
	Format the response as valid JSON only, no other text.
	If the prompt contains a color, use it or something similar as the background color.`, themeRequest.Prompt)

	reqBody := map[string]interface{}{
		"model":  "mistral",
		"prompt": prompt,
		"stream": false,
	}

	jsonBody, err := json.Marshal(reqBody)
	if err != nil {
		log.Printf("Error marshaling request: %v", err)
		http.Error(w, "Failed to create request", http.StatusInternalServerError)
		return
	}

	log.Printf("Making request to Ollama at %s/api/generate", ollamaHost)
	resp, err := http.Post(ollamaHost+"/api/generate", "application/json", bytes.NewBuffer(jsonBody))
	if err != nil {
		log.Printf("Error making request to Ollama: %v", err)
		http.Error(w, "Failed to generate theme", http.StatusInternalServerError)
		return
	}
	defer resp.Body.Close()

	var ollamaResp struct {
		Response string `json:"response"`
	}
	if err := json.NewDecoder(resp.Body).Decode(&ollamaResp); err != nil {
		log.Printf("Error decoding Ollama response: %v", err)
		http.Error(w, "Failed to parse response", http.StatusInternalServerError)
		return
	}

	log.Printf("Raw Ollama response: %s", ollamaResp.Response)

	var theme models.Theme
	if err := json.Unmarshal([]byte(ollamaResp.Response), &theme); err != nil {
		log.Printf("Error unmarshaling theme: %v", err)
		http.Error(w, "Failed to parse theme", http.StatusInternalServerError)
		return
	}

	log.Printf("Generated theme: %+v", theme)

	w.Header().Set("Content-Type", "application/json")
	if err := json.NewEncoder(w).Encode(theme); err != nil {
		log.Printf("Error encoding response: %v", err)
		http.Error(w, "Failed to encode response", http.StatusInternalServerError)
		return
	}
}
