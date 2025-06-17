package handlers

import (
	"net/http"
	"strconv"

	"github.com/Sebiche09/app-anti-gaspillage.git/api/requests"
	"github.com/Sebiche09/app-anti-gaspillage.git/services"
	"github.com/gin-gonic/gin"
)

type StoreHandler struct {
	service *services.StoreService
}

func NewStoreHandler(service *services.StoreService) *StoreHandler {
	return &StoreHandler{service: service}
}

// summary: Récupérer toutes les catégories
// description: Permet de récupérer la liste de toutes les catégories de stores
// tags: Stores
// @Accept json
// @Produce json
// @Security Bearer
// @Param Authorization header string true "Bearer token"
// @Success 200 {object} models.Response
// @Failure 401 {object} models.ErrorResponse
// @Failure 500 {object} models.ErrorResponse
// @Router /api/categories [get]
func (h *StoreHandler) GetCategories(c *gin.Context) {
	categories, err := h.service.GetCategories()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": categories})
}

// summary: Créer un magasin
// description: Permet à un marchand de créer un magasin
// tags: Stores
// @Accept json
// @Produce json
// @Security Bearer
// @Param Authorization header string true "Bearer token"
// @Param input body requests.CreateStoreRequest true "Données de la demande"
// @Success 201 {object} models.Response
// @Failure 400 {object} models.ErrorResponse
// @Failure 401 {object} models.ErrorResponse
// @Failure 409 {object} models.ErrorResponse
// @Failure 500 {object} models.ErrorResponse
// @Router /api/merchants/stores [post]
func (h *StoreHandler) CreateStore(c *gin.Context) {
	var req requests.CreateStoreRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	userID := c.MustGet("userId").(uint)

	if err := h.service.CreateStore(req, userID); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, gin.H{"message": "Votre demande a été soumise avec succès"})
}

// summary: Mise à jour d'un magasin
// description: Permet à un marchand de mettre à jour un magasin
// tags: Stores
// @Accept json
// @Produce json
// @Security Bearer
// @Param Authorization header string true "Bearer token"
// @Param id path int true "Magasin ID"
// @Param input body requests.UpdateStoreRequest true "Données de la demande"
// @Success 200 {object} models.Response
// @Failure 401 {object} models.ErrorResponse
// @Failure 500 {object} models.ErrorResponse
// @Router /api/merchants/stores/{id} [put]
func (h *StoreHandler) UpdateStore(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid ID format"})
		return
	}

	var req requests.UpdateStoreRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if err := h.service.UpdateStore(req, uint(id)); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Votre demande a été soumise avec succès"})
}

// summary: supprimer le magasin d'un marchand
// description: Permet à un marchand de supprimer un magasin
// tags: Magasins
// @Accept json
// @Produce json
// @Security Bearer
// @Param Authorization header string true "Bearer token"
// @Param id path int true "Magasin ID"
// @Success 200 {object} models.Response
// @Failure 401 {object} models.ErrorResponse
// @Failure 500 {object} models.ErrorResponse
// @Router /api/merchants/magasins/{id} [delete]
func (h *StoreHandler) DeleteStore(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid ID format"})
		return
	}

	if err := h.service.DeleteStore(uint(id)); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Votre demande a été soumise avec succès"})
}

// summary: Obtenir les magasins d'un marchand
// description: Permet à un marchand de récupérer la liste de ses magasins
// tags: Stores
// @Accept json
// @Produce json
// @Security Bearer
// @Param Authorization header string true "Bearer token"
// @Success 200 {object} models.Response
// @Failure 401 {object} models.ErrorResponse
// @Failure 500 {object} models.ErrorResponse
// @Router /api/merchants/stores [get]
func (h *StoreHandler) GetStoresMerchant(c *gin.Context) {
	userID := c.MustGet("userId").(uint)

	stores, err := h.service.GetStoresMerchant(userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": stores})
}

// summary: Obtenir les magasins
// description: Permet de récupérer la liste de tous les magasins
// tags: Stores
// @Accept json
// @Produce json
// @Security Bearer
// @Param Authorization header string true "Bearer token"
// @Success 200 {object} models.Response
// @Failure 401 {object} models.ErrorResponse
// @Failure 500 {object} models.ErrorResponse
// @Router /api/stores [get]
func (h *StoreHandler) GetStores(c *gin.Context) {
	stores, err := h.service.GetStores()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": stores})
}

// summary: Obtenir un magasin
// description: Permet de récupérer un magasin
// tags: Stores
// @Accept json
// @Produce json
// @Security Bearer
// @Param Authorization header string true "Bearer token"
// @Param id path int true "ID du magasin"
// @Success 200 {object} models.Response
// @Failure 401 {object} models.ErrorResponse
// @Failure 404 {object} models.ErrorResponse
// @Failure 500 {object} models.ErrorResponse
// @Router /api/stores/{id} [get]
func (h *StoreHandler) GetStore(c *gin.Context) {
	id := c.Param("id")

	parsedID, err := strconv.ParseUint(id, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid ID format"})
		return
	}
	storeID := uint(parsedID)

	store, err := h.service.GetStoreByID(storeID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": store})
}
