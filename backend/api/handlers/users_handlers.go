package handlers

import (
	"net/http"

	"github.com/Sebiche09/app-anti-gaspillage.git/api/requests"
	"github.com/Sebiche09/app-anti-gaspillage.git/services"
	"github.com/gin-gonic/gin"
)

type UserHandler struct {
	UserService *services.UserService
}

func NewUserHandler(userService *services.UserService) *UserHandler {
	return &UserHandler{UserService: userService}
}

// signup godoc
// @Summary Create a new user
// @Description Create a user with the provided details
// @Tags Users
// @Accept json
// @Produce json
// @Param user body requests.RegisterRequest true "User data"
// @Success 201 {object} models.User
// @Router /api/auth/signup [post]
func (h *UserHandler) Signup(c *gin.Context) {
	var registerReq requests.RegisterRequest
	if err := c.ShouldBindJSON(&registerReq); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	err := h.UserService.Create(registerReq)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.Status(http.StatusCreated)
}

// login godoc
// @Summary Authenticate user
// @Description Authenticate a user using email and password
// @Tags Users
// @Accept json
// @Produce json
// @Param credentials body requests.LoginRequest true "User credentials"
// @Success 200 {object} map[string]string{token=string}
// @Failure 400 {object} map[string]string
// @Failure 401 {object} map[string]string
// @Router /api/auth/login [post]
func (h *UserHandler) Login(c *gin.Context) {
	var req requests.LoginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Appeler le service UserService.Login
	token, err := h.UserService.Login(req.Email, req.Password)
	if err != nil {
		if err.Error() == "invalid credentials" {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid credentials"})
		} else {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		}
		return
	}

	c.JSON(http.StatusOK, gin.H{"token": token})
}
