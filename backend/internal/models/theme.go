package models

type Theme struct {
	Name        string `json:"name"`
	Description string `json:"description"`
	Background  string `json:"background"`
	Text        string `json:"text"`
	Accent      string `json:"accent"`
}

type ThemeRequest struct {
	Prompt string `json:"prompt"`
}