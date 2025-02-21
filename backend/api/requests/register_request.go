package requests

type RegisterRequest struct {
	Email    string `json:"email" example:"user@example.com" binding:"required,email"`
	Password string `json:"password" example:"password123" binding:"required,min=8"`
	FullName string `json:"full_name" example:"patrick" binding:"required"`
	Phone    string `json:"phone" example:"+32460232425" binding:"required,e164"`
}
