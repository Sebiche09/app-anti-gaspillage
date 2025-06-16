package models

// Response représente une réponse générique de succès
type Response struct {
	Message string      `json:"message" example:"Opération réussie"`
	Data    interface{} `json:"data,omitempty"`
}

// ErrorResponse représente une réponse d'erreur
type ErrorResponse struct {
	Error string `json:"error" example:"Message d'erreur"`
}
