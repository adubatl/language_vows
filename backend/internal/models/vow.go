package models

type Vow struct {
	ID       string `json:"id" db:"id"`
	Text     string `json:"text" db:"text"`
	Language string `json:"language" db:"language"`
}
