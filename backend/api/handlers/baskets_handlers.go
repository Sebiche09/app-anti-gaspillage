package handlers

import (
	"net/http"
	"strconv"

	"github.com/Sebiche09/app-anti-gaspillage.git/models"
	"github.com/Sebiche09/app-anti-gaspillage.git/services"
	"github.com/gin-gonic/gin"
)

type BasketHandler struct {
	BasketService *services.BasketService
}

func NewBasketHandler(basketService *services.BasketService) *BasketHandler {
	return &BasketHandler{BasketService: basketService}
}

// GetBaskets godoc
// @Summary Get all baskets
// @Description Retrieve a list of all baskets
// @Tags Baskets
// @Accept  json
// @Produce  json
// @Success 200 {array} models.Basket
// @Failure 500 {object} map[string]string "Internal server error"
// @Router /api/baskets [get]
func (h *BasketHandler) GetBaskets(c *gin.Context) {
	baskets, err := h.BasketService.GetBaskets()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, baskets)
}

// GetBasket godoc
// @Summary Get a single basket
// @Description Retrieve a basket by its ID
// @Tags Baskets
// @Accept  json
// @Produce  json
// @Param id path int true "Basket ID"
// @Success 200 {object} models.Basket
// @Failure 400 {object} map[string]string "Invalid basket ID"
// @Failure 404 {object} map[string]string "Basket not found"
// @Router /api/baskets/{id} [get]
func (h *BasketHandler) GetBasket(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid basket ID"})
		return
	}

	basket, err := h.BasketService.GetBasket(id)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, basket)
}

// CreateBasket godoc
// @Summary Create a new basket
// @Description Create a new basket with the provided details
// @Tags Baskets
// @Security BearerAuth
// @Accept  json
// @Produce  json
// @Param Authorization header string true "Bearer token"
// @Param basket body models.Basket true "Basket data"
// @Success 201 {object} models.Basket
// @Failure 400 {object} map[string]string "Bad request, invalid input"
// @Failure 500 {object} map[string]string "Internal server error"
// @Router /api/baskets [post]
func (h *BasketHandler) CreateBasket(c *gin.Context) {
	var basket models.Basket
	if err := c.ShouldBindJSON(&basket); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	userId := c.GetInt("userId") // Récupère l'ID de l'utilisateur connecté
	if err := h.BasketService.CreateBasket(basket, userId); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, basket)
}

// UpdateBasket godoc
// @Summary Update a basket
// @Description Update a basket by its ID
// @Tags Baskets
// @Accept  json
// @Produce  json
// @Param id path int true "Basket ID"
// @Param basket body models.Basket true "Basket data"
// @Success 200 {object} models.Basket
// @Failure 400 {object} map[string]string "Invalid basket ID or input"
// @Failure 403 {object} map[string]string "Not authorized to update this basket"
// @Failure 404 {object} map[string]string "Basket not found"
// @Failure 500 {object} map[string]string "Internal server error"
// @Router /api/baskets/{id} [put]
func (h *BasketHandler) UpdateBasket(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid basket ID"})
		return
	}

	userId := c.GetInt("userId")
	var updates models.Basket
	if err := c.ShouldBindJSON(&updates); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	updatedBasket, err := h.BasketService.UpdateBasket(id, updates, userId)
	if err != nil {
		statusCode := http.StatusInternalServerError
		if err.Error() == "not authorized to update this basket" {
			statusCode = http.StatusForbidden
		}
		c.JSON(statusCode, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, updatedBasket)
}

// DeleteBasket godoc
// @Summary Delete a basket
// @Description Delete a basket by its ID
// @Tags Baskets
// @Security BearerAuth
// @Accept  json
// @Produce  json
// @Param Authorization header string true "Bearer token"
// @Param id path int true "Basket ID"
// @Success 204 "No Content"
// @Failure 400 {object} map[string]string "Invalid basket ID"
// @Failure 403 {object} map[string]string "Not authorized to delete this basket"
// @Failure 404 {object} map[string]string "Basket not found"
// @Failure 500 {object} map[string]string "Internal server error"
// @Router /api/baskets/{id} [delete]
func (h *BasketHandler) DeleteBasket(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid basket ID"})
		return
	}

	userId := c.GetInt("userId")
	if err := h.BasketService.DeleteBasket(id, userId); err != nil {
		statusCode := http.StatusInternalServerError
		if err.Error() == "not authorized to delete this basket" {
			statusCode = http.StatusForbidden
		}
		c.JSON(statusCode, gin.H{"error": err.Error()})
		return
	}

	c.Status(http.StatusNoContent)
}
