package handlers

import (
	"fmt"
	"net/http"

	"github.com/Sebiche09/app-anti-gaspillage.git/services"
	"github.com/Sebiche09/app-anti-gaspillage.git/utils"
	"github.com/gin-gonic/gin"
)

type InvitationHandler struct {
	invitationService *services.InvitationService
}

func NewInvitationHandler(invitationService *services.InvitationService) *InvitationHandler {
	return &InvitationHandler{invitationService: invitationService}
}

// CreateInvitation envoie une invitation à rejoindre un restaurant
// @Summary Envoyer une invitation à rejoindre un restaurant
// @Description Permet à un marchand d'inviter une personne à rejoindre son restaurant en tant que staff
// @Tags invitations
// @Accept json
// @Produce json
// @Security Bearer
// @Param Authorization header string true "Bearer token"
// @Param request body object{restaurant_id=integer,email=string} true "Informations de l'invitation"
// @Success 201 {object} object{message=string,code=string} "Invitation envoyée avec succès"
// @Failure 400 {object} object{error=string} "Erreur dans la requête"
// @Failure 401 {object} object{error=string} "Non authentifié"
// @Failure 403 {object} object{error=string} "Accès non autorisé"
// @Router /api/invitations [post]
func (h *InvitationHandler) CreateInvitation(c *gin.Context) {
	tokenString := c.GetHeader("Authorization")
	if tokenString == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "authorization token required"})
		return
	}

	userID, _, isMerchant, _, err := utils.VerifyToken(tokenString)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "invalid token"})
		return
	}

	if !isMerchant {
		c.JSON(http.StatusForbidden, gin.H{"error": "only merchants can send invitations"})
		return
	}

	var req struct {
		RestaurantID uint   `json:"restaurant_id" binding:"required"`
		Email        string `json:"email" binding:"required,email"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	invitation, err := h.invitationService.CreateInvitation(userID, req.RestaurantID, req.Email)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"message": "Invitation sent successfully",
		"code":    invitation.Code,
	})
}

// AcceptInvitation accepte une invitation à rejoindre un restaurant
// @Summary Accepter une invitation à rejoindre un restaurant
// @Description Permet à un utilisateur d'accepter une invitation à rejoindre un restaurant en tant que staff
// @Tags invitations
// @Accept json
// @Produce json
// @Security Bearer
// @Param Authorization header string true "Bearer token"
// @Param code query string true "Code d'invitation"
// @Success 200 {object} object{message=string} "Invitation acceptée avec succès"
// @Failure 400 {object} object{error=string} "Erreur dans la requête"
// @Failure 401 {object} object{error=string} "Non authentifié"
// @Router /api/invitations/accept [get]
func (h *InvitationHandler) AcceptInvitation(ctx *gin.Context) {
	// Extraire userID du token
	tokenString := ctx.GetHeader("Authorization")
	if tokenString == "" {
		ctx.JSON(http.StatusUnauthorized, gin.H{"error": "authorization token required"})
		return
	}

	userID, _, _, _, err := utils.VerifyToken(tokenString)
	if err != nil {
		ctx.JSON(http.StatusUnauthorized, gin.H{"error": "invalid token"})
		return
	}

	// Get invitation code from query
	code := ctx.Query("code")
	if code == "" {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": "invitation code is required"})
		return
	}

	if err := h.invitationService.AcceptInvitation(code, userID); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	ctx.JSON(http.StatusOK, gin.H{"message": "You have successfully joined the restaurant team"})
}

// GetPendingInvitations récupère les invitations en attente pour un restaurant
// @Summary Récupérer les invitations en attente pour un restaurant
// @Description Permet à un marchand de voir toutes les invitations en attente pour son restaurant
// @Tags invitations
// @Produce json
// @Security Bearer
// @Param Authorization header string true "Bearer token"
// @Param restaurantId path integer true "ID du restaurant"
// @Success 200 {array} models.Invitation "Liste des invitations en attente"
// @Failure 400 {object} object{error=string} "Erreur dans la requête"
// @Failure 401 {object} object{error=string} "Non authentifié"
// @Failure 403 {object} object{error=string} "Accès non autorisé"
// @Router /api/restaurants/{restaurantId}/invitations [get]
func (h *InvitationHandler) GetPendingInvitations(c *gin.Context) {
	// Extraire userID du token
	tokenString := c.GetHeader("Authorization")
	if tokenString == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "authorization token required"})
		return
	}

	userID, _, isMerchant, _, err := utils.VerifyToken(tokenString)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "invalid token"})
		return
	}

	if !isMerchant {
		c.JSON(http.StatusForbidden, gin.H{"error": "only merchants can view invitations"})
		return
	}

	restaurantID := c.Param("id")
	if restaurantID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "restaurant ID is required"})
		return
	}

	var restIDUint uint
	if _, err := fmt.Sscanf(restaurantID, "%d", &restIDUint); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid restaurant ID format"})
		return
	}

	invitations, err := h.invitationService.GetPendingInvitations(restIDUint, userID)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, invitations)
}

// CancelInvitation annule une invitation
// @Summary Annuler une invitation
// @Description Permet à un marchand d'annuler une invitation envoyée
// @Tags invitations
// @Produce json
// @Security Bearer
// @Param Authorization header string true "Bearer token"
// @Param invitationId path integer true "ID de l'invitation"
// @Success 200 {object} object{message=string} "Invitation annulée avec succès"
// @Failure 400 {object} object{error=string} "Erreur dans la requête"
// @Failure 401 {object} object{error=string} "Non authentifié"
// @Router /api/invitations/{invitationId} [delete]
func (h *InvitationHandler) CancelInvitation(c *gin.Context) {
	// Extraire userID du token
	tokenString := c.GetHeader("Authorization")
	if tokenString == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "authorization token required"})
		return
	}

	userID, _, _, _, err := utils.VerifyToken(tokenString)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "invalid token"})
		return
	}

	invitationID := c.Param("invitationId")
	if invitationID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invitation ID is required"})
		return
	}

	var invIDUint uint
	if _, err := fmt.Sscanf(invitationID, "%d", &invIDUint); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid invitation ID format"})
		return
	}

	if err := h.invitationService.CancelInvitation(invIDUint, userID); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Invitation cancelled successfully"})
}
