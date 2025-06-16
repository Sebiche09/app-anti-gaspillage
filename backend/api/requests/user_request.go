package requests

type RegisterRequest struct {
	Email    string `json:"email" example:"user@example.com" binding:"required,email"`
	Password string `json:"password" example:"password123" binding:"required,min=8"`
}

type LoginRequest struct {
	Email    string `json:"email" example:"user@example.com" binding:"required,email"`
	Password string `json:"password" example:"password123" binding:"required"`
}
type ResendCodeRequest struct {
	Email string `json:"email" binding:"required,email"`
}
type CodeValidationRequest struct {
	Email string `json:"email"`
	Code  string `json:"code"`
}
