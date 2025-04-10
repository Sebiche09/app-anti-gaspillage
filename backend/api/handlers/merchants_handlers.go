// @Security Bearer
package handlers

import (
	"net/http"
	"strconv"
	"strings"

	"github.com/Sebiche09/app-anti-gaspillage.git/api/requests"
	"github.com/Sebiche09/app-anti-gaspillage.git/services"
	"github.com/gin-gonic/gin"
)

type MerchantHandler struct {
	service *services.MerchantService
}

func NewMerchantHandler(service *services.MerchantService) *MerchantHandler {
	return &MerchantHandler{service: service}
}

// @Summary Créer une demande de marchand
// @Description Permet à un utilisateur de soumettre une demande pour devenir marchand
// @Tags Users
// @Accept json
// @Produce json
// @Security Bearer
// @Param Authorization header string true "Bearer token"
// @Param input body requests.CreateMerchantRequest true "Données de la demande"
// @Success 201 {object} models.Response
// @Failure 400 {object} models.ErrorResponse
// @Failure 401 {object} models.ErrorResponse
// @Failure 409 {object} models.ErrorResponse
// @Failure 500 {object} models.ErrorResponse
// @Router /api/merchants [post]
func (h *MerchantHandler) CreateMerchantRequest(c *gin.Context) {
	var req requests.CreateMerchantRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	req.SIREN = strings.ReplaceAll(req.SIREN, " ", "")
	req.SIREN = strings.ReplaceAll(req.SIREN, "-", "")

	if len(req.SIREN) != 9 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Le SIRET doit contenir exactement 14 chiffres"})
		return
	}

	if _, err := strconv.ParseUint(req.SIREN, 10, 64); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Le SIRET doit contenir uniquement des chiffres"})
		return
	}

	userID := c.MustGet("userId").(uint)

	if err := h.service.CreateMerchantRequest(req, userID); err != nil {
		if err.Error() == "une demande est déjà en cours de traitement" {
			c.JSON(http.StatusConflict, gin.H{"error": err.Error()})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Erreur lors de la création de la demande"})
		return
	}

	c.JSON(http.StatusCreated, gin.H{"message": "Demande créée avec succès"})
}

// @Summary Update un marchand
// @Description Permet à un marchand de mettre à jour ses informations
// @Tags Merchants
// @Accept json
// @Produce json
// @Security Bearer
// @Param Authorization header string true "Bearer token"
// @Param input body requests.UpdateMerchantRequest true "Données du marchand"
// @Success 200 {object} models.Response
// @Failure 400 {object} models.ErrorResponse
// @Failure 401 {object} models.ErrorResponse
// @Failure 403 {object} models.ErrorResponse
// @Failure 404 {object} models.ErrorResponse
// @Failure 500 {object} models.ErrorResponse
// @Router /api/merchants [put]
func (h *MerchantHandler) UpdateMerchant(c *gin.Context) {
	var req requests.UpdateMerchantRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	userID := c.MustGet("userId").(uint)

	if err := h.service.UpdateMerchant(req, userID); err != nil {
		if err.Error() == "le marchand n'existe pas" {
			c.JSON(http.StatusNotFound, gin.H{"error": err.Error()})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Erreur lors de la mise à jour du marchand"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Marchand mis à jour avec succès"})
}

// @Summary Suppression d'un marchand
// @Description Permet à un marchand de supprimer son compte
// @Tags Merchants
// @Accept json
// @Produce json
// @Security Bearer
// @Param Authorization header string true "Bearer token"
// @Success 200 {object} models.Response
// @Failure 401 {object} models.ErrorResponse
// @Failure 403 {object} models.ErrorResponse
// @Failure 404 {object} models.ErrorResponse
// @Failure 500 {object} models.ErrorResponse
// @Router /api/merchants [delete]
func (h *MerchantHandler) DeleteMerchant(c *gin.Context) {
	userID := c.MustGet("userId").(uint)

	if err := h.service.DeleteMerchant(userID); err != nil {
		if err.Error() == "le marchand n'existe pas" {
			c.JSON(http.StatusNotFound, gin.H{"error": err.Error()})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Erreur lors de la suppression du marchand"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Marchand supprimé avec succès"})
}

// @Summary Récupérer information d'un marchand
// @Description Récupère les informations du marchand actuel
// @Tags Merchants
// @Produce json
// @Security Bearer
// @Param Authorization header string true "Bearer token"
// @Success 200 {object} models.Merchant "Informations du marchand"
// @Failure 401 {object} models.ErrorResponse "Non authentifié"
// @Failure 403 {object} models.ErrorResponse "Non autorisé"
// @Failure 404 {object} models.ErrorResponse "Marchand non trouvé"
// @Failure 500 {object} models.ErrorResponse "Erreur serveur"
// @Router /api/merchants [get]
func (h *MerchantHandler) GetMerchant(c *gin.Context) {
	userID := c.MustGet("userId").(uint)

	merchant, err := h.service.GetMerchant(userID)
	if err != nil {
		if err.Error() == "le marchand n'existe pas" {
			c.JSON(http.StatusNotFound, gin.H{"error": err.Error()})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Erreur lors de la récupération du marchand"})
		return
	}

	c.JSON(http.StatusOK, merchant)
}

// @Summary Récupérer les demandes en attente
// @Description Récupère toutes les demandes de marchand en attente (admin only)
// @Tags Admin
// @Produce json
// @Security Bearer
// @Param Authorization header string true "Bearer token"
// @Success 200 {array} models.MerchantRequest "Liste des demandes en attente"
// @Failure 401 {object} models.ErrorResponse "Non authentifié"
// @Failure 403 {object} models.ErrorResponse "Non autorisé"
// @Failure 500 {object} models.ErrorResponse "Erreur serveur"
// @Router /api/admin/merchant-requests [get]
func (h *MerchantHandler) GetPendingRequests(c *gin.Context) {
	requests, err := h.service.GetPendingRequests()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Erreur lors de la récupération des demandes"})
		return
	}
	c.JSON(http.StatusOK, requests)
}

// @Summary Récupérer les marchands
// @Description Récupère tout les marchands (admin only)
// @Tags Admin
// @Produce json
// @Security Bearer
// @Param Authorization header string true "Bearer token"
// @Success 200 {array} models.Merchant "Liste des marchands"
// @Failure 401 {object} models.ErrorResponse "Non authentifié"
// @Failure 403 {object} models.ErrorResponse "Non autorisé"
// @Failure 500 {object} models.ErrorResponse "Erreur serveur"
// @Router /api/admin/merchants [get]
func (h *MerchantHandler) GetMerchants(c *gin.Context) {
	merchants, err := h.service.GetMerchants()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Erreur lors de la récupération des marchands"})
		return
	}
	c.JSON(http.StatusOK, merchants)
}

// @Summary Traiter une demande de marchand
// @Description Permet à un administrateur d'approuver ou rejeter une demande de marchand
// @Tags Admin
// @Accept json
// @Produce json
// @Security Bearer
// @Param Authorization header string true "Bearer token"
// @Param id path int true "ID de la demande"
// @Param status body ProcessRequestInput true "Statut de la demande (approved/rejected)"
// @Success 200 {object} models.Response "Demande traitée avec succès"
// @Failure 400 {object} models.ErrorResponse "ID invalide ou statut invalide"
// @Failure 401 {object} models.ErrorResponse "Non authentifié"
// @Failure 403 {object} models.ErrorResponse "Non autorisé"
// @Failure 500 {object} models.ErrorResponse "Erreur serveur"
// @Router /api/admin/merchant-requests/{id} [put]
func (h *MerchantHandler) ProcessRequest(c *gin.Context) {
	requestID, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "ID invalide"})
		return
	}

	var input struct {
		Status string `json:"status" binding:"required,oneof=approved rejected"`
	}
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if err := h.service.ProcessRequest(uint(requestID), input.Status); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Erreur lors du traitement de la demande"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Demande traitée avec succès", "status": input.Status})
}

type ProcessRequestInput struct {
	Status string `json:"status" binding:"required,oneof=approved rejected" example:"approved"` // Status de la demande (approved/rejected)
}
