package handlers

import (
	"net/http"
	"strconv"

	"github.com/Sebiche09/app-anti-gaspillage.git/api/requests"
	"github.com/Sebiche09/app-anti-gaspillage.git/services"
	"github.com/gin-gonic/gin"
)

type RestaurantHandler struct {
	service *services.RestaurantService
}

func NewRestaurantHandler(service *services.RestaurantService) *RestaurantHandler {
	return &RestaurantHandler{service: service}
}

// summary: Récupérer toutes les catégories
// description: Permet de récupérer la liste de toutes les catégories de restaurants
// tags: Restaurants
// @Accept json
// @Produce json
// @Security Bearer
// @Param Authorization header string true "Bearer token"
// @Success 200 {object} models.Response
// @Failure 401 {object} models.ErrorResponse
// @Failure 500 {object} models.ErrorResponse
// @Router /api/categories [get]
func (h *RestaurantHandler) GetCategories(c *gin.Context) {
	categories, err := h.service.GetCategories()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": categories})
}

// summary: Créer un restaurant
// description: Permet à un marchand de créer un restaurant
// tags: Restaurants
// @Accept json
// @Produce json
// @Security Bearer
// @Param Authorization header string true "Bearer token"
// @Param input body requests.CreateRestaurantRequest true "Données de la demande"
// @Success 201 {object} models.Response
// @Failure 400 {object} models.ErrorResponse
// @Failure 401 {object} models.ErrorResponse
// @Failure 409 {object} models.ErrorResponse
// @Failure 500 {object} models.ErrorResponse
// @Router /api/merchants/restaurants [post]
func (h *RestaurantHandler) CreateRestaurant(c *gin.Context) {
	var req requests.CreateRestaurantRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	userID := c.MustGet("userId").(uint)

	if err := h.service.CreateRestaurant(req, userID); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, gin.H{"message": "Votre demande a été soumise avec succès"})
}

// summary: Mise à jour d'un restaurant
// description: Permet à un marchand de mettre à jour un restaurant
// tags: Restaurants
// @Accept json
// @Produce json
// @Security Bearer
// @Param Authorization header string true "Bearer token"
// @Param id path int true "Restaurant ID"
// @Param input body requests.UpdateRestaurantRequest true "Données de la demande"
// @Success 200 {object} models.Response
// @Failure 401 {object} models.ErrorResponse
// @Failure 500 {object} models.ErrorResponse
// @Router /api/merchants/restaurants/{id} [put]
func (h *RestaurantHandler) UpdateRestaurant(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid ID format"})
		return
	}

	var req requests.UpdateRestaurantRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if err := h.service.UpdateRestaurant(req, uint(id)); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Votre demande a été soumise avec succès"})
}

// summary: supprimer le restaurant d'un marchand
// description: Permet à un marchand de supprimer un restaurant
// tags: Restaurants
// @Accept json
// @Produce json
// @Security Bearer
// @Param Authorization header string true "Bearer token"
// @Param id path int true "Restaurant ID"
// @Success 200 {object} models.Response
// @Failure 401 {object} models.ErrorResponse
// @Failure 500 {object} models.ErrorResponse
// @Router /api/merchants/restaurants/{id} [delete]
func (h *RestaurantHandler) DeleteRestaurant(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid ID format"})
		return
	}

	if err := h.service.DeleteRestaurant(uint(id)); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Votre demande a été soumise avec succès"})
}

// summary: Obtenir les restaurants d'un marchand
// description: Permet à un marchand de récupérer la liste de ses restaurants
// tags: Restaurants
// @Accept json
// @Produce json
// @Security Bearer
// @Param Authorization header string true "Bearer token"
// @Success 200 {object} models.Response
// @Failure 401 {object} models.ErrorResponse
// @Failure 500 {object} models.ErrorResponse
// @Router /api/merchants/restaurants [get]
func (h *RestaurantHandler) GetRestaurantsMerchant(c *gin.Context) {
	userID := c.MustGet("userId").(uint)

	restaurants, err := h.service.GetRestaurantsMerchant(userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": restaurants})
}

// summary: Obtenir les restaurants
// description: Permet de récupérer la liste de tous les restaurants
// tags: Restaurants
// @Accept json
// @Produce json
// @Security Bearer
// @Param Authorization header string true "Bearer token"
// @Success 200 {object} models.Response
// @Failure 401 {object} models.ErrorResponse
// @Failure 500 {object} models.ErrorResponse
// @Router /api/restaurants [get]
func (h *RestaurantHandler) GetRestaurants(c *gin.Context) {
	restaurants, err := h.service.GetRestaurants()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": restaurants})
}

// summary: Obtenir un restaurant
// description: Permet de récupérer un restaurant
// tags: Restaurants
// @Accept json
// @Produce json
// @Security Bearer
// @Param Authorization header string true "Bearer token"
// @Param id path int true "ID du restaurant"
// @Success 200 {object} models.Response
// @Failure 401 {object} models.ErrorResponse
// @Failure 404 {object} models.ErrorResponse
// @Failure 500 {object} models.ErrorResponse
// @Router /api/restaurants/{id} [get]
func (h *RestaurantHandler) GetRestaurant(c *gin.Context) {
	id := c.Param("id")

	parsedID, err := strconv.ParseUint(id, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid ID format"})
		return
	}
	restaurantID := uint(parsedID)

	restaurant, err := h.service.GetRestaurantByID(restaurantID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": restaurant})
}
