package handlers

import (
	"fmt"
	"net/http"

	"github.com/Sebiche09/app-anti-gaspillage.git/api/requests"
	"github.com/Sebiche09/app-anti-gaspillage.git/api/responses"
	"github.com/Sebiche09/app-anti-gaspillage.git/services"
	"github.com/Sebiche09/app-anti-gaspillage.git/utils"
	"github.com/gin-gonic/gin"
)

type UserHandler struct {
	UserService *services.UserService
}

func NewUserHandler(userService *services.UserService) *UserHandler {
	return &UserHandler{UserService: userService}
}

// login godoc
// @Summary Authenticate user
// @Description Authenticate a user using email and password
// @Tags Users
// @Accept json
// @Produce json
// @Param credentials body requests.LoginRequest true "User credentials"
// @Success 200 {object} responses.LoginResponse
// @Failure 400 {object} map[string]string
// @Failure 401 {object} map[string]string
// @Router /api/auth/login [post]
func (h *UserHandler) Login(c *gin.Context) {
	var req requests.LoginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	token, refreshToken, err := h.UserService.Login(req.Email, req.Password)
	if err != nil {
		if err.Error() == "invalid credentials" {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid credentials"})
		} else if err.Error() == "email not confirmed" {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Please confirm your email before logging in."})
		} else {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		}
		return
	}

	c.JSON(http.StatusOK, responses.LoginResponse{Token: token, RefreshToken: refreshToken})
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

	createdUser, err := h.UserService.Create(registerReq)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	emailService := services.NewEmailService(
		utils.GetEnv("SMTP_HOST"),
		utils.GetEnv("SMTP_PORT"),
		utils.GetEnv("SMTP_USER"),
		utils.GetEnv("SMTP_PASS"),
		utils.GetEnv("EMAIL_FROM"),
	)

	emailBody := fmt.Sprintf("Bonjour,\n\nVoici votre code de validation : %s\n\nIl est valable pendant 10 minutes.\n\nMerci !", createdUser.ValidationCode)

	err = emailService.SendEmail(createdUser.Email, "Votre code de validation", emailBody)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Échec de l'envoi de l'email", "details": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"message": "Utilisateur créé. Un code de validation a été envoyé par email.",
	})
}

// validate-code godoc
// @Summary Valider le code de confirmation
// @Description Valide le code envoyé par email et active le compte
// @Tags Users
// @Accept json
// @Produce json
// @Param validation body requests.CodeValidationRequest true "Email et code"
// @Success 200 {object} map[string]string
// @Failure 400 {object} map[string]string
// @Router /api/auth/validate-code [post]
func (h *UserHandler) ValidateCode(c *gin.Context) {
	var req requests.CodeValidationRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Requête invalide"})
		return
	}

	user, err := h.UserService.GetByEmail(req.Email)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Utilisateur introuvable"})
		return
	}

	if user.IsEmailConfirmed {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Email déjà confirmé"})
		return
	}

	if user.ValidationCode != req.Code {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Code invalide"})
		return
	}

	user.IsEmailConfirmed = true
	user.ValidationCode = ""
	if err := h.UserService.Save(user); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Erreur lors de la confirmation"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Email confirmé avec succès"})
}

// resend-code godoc
// @Summary Resend validation code
// @Description Resend the validation code to the user's email
// @Tags Users
// @Accept json
// @Produce json
// @Param email body requests.ResendCodeRequest true "Email address"
// @Success 200 {object} map[string]string
// @Failure 400 {object} map[string]string
// @Router /api/auth/resend-code [post]
func (h *UserHandler) ResendCode(c *gin.Context) {
	var req requests.ResendCodeRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Requête invalide"})
		return
	}
	user, err := h.UserService.GetByEmail(req.Email)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Utilisateur introuvable"})
		return
	}
	if user.IsEmailConfirmed {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Email déjà confirmé"})
		return
	}
	emailService := services.NewEmailService(
		utils.GetEnv("SMTP_HOST"),
		utils.GetEnv("SMTP_PORT"),
		utils.GetEnv("SMTP_USER"),
		utils.GetEnv("SMTP_PASS"),
		utils.GetEnv("EMAIL_FROM"),
	)
	emailBody := fmt.Sprintf("Bonjour,\n\nVoici votre code de validation : %s\n\nIl est valable pendant 10 minutes.\n\nMerci !", user.ValidationCode)
	err = emailService.SendEmail(user.Email, "Votre code de validation", emailBody)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Échec de l'envoi de l'email", "details": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "Code de validation renvoyé par email."})
}

// getUsers godoc
// @Summary Get all users
// @Description Get all users
// @Tags Admin
// @Accept json
// @Produce json
// @Security Bearer
// @Param Authorization header string true "Bearer token"
// @Success 200 {array} models.User
// @Failure 500 {object} map[string]string
// @Router /api/admin/users [get]
func (h *UserHandler) GetUsers(c *gin.Context) {
	users, err := h.UserService.GetUsers()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, users)
}

// refresh-token godoc
// @Summary Refresh user token
// @Description Refresh the user's authentication token
// @Tags Users
// @Accept json
// @Produce json
// @Security Bearer
// @Param refresh_token body requests.RefreshTokenRequest true "Refresh token"
// @Success 200 {object} responses.LoginResponse
// @Failure 401 {object} map[string]string
// @Failure 500 {object} map[string]string
// @Router /api/auth/refresh-token [post]
func (h *UserHandler) RefreshToken(c *gin.Context) {
	var req requests.RefreshTokenRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request"})
		return
	}

	newToken, newRefreshToken, err := h.UserService.RefreshToken(req.RefreshToken)
	if err != nil {
		if err.Error() == "invalid refresh token" {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid refresh token"})
		} else {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		}
		return
	}

	c.JSON(http.StatusOK, responses.LoginResponse{Token: newToken, RefreshToken: newRefreshToken})
}
