package middlewares

import (
	"bytes"
	"io"
	"net/http"
	"strconv"

	"github.com/Sebiche09/app-anti-gaspillage.git/repositories"
	"github.com/Sebiche09/app-anti-gaspillage.git/utils"
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

// Authenticate middleware validates the JWT token and extracts user information.
func Authenticate(c *gin.Context) {
	token := c.Request.Header.Get("Authorization")
	if token == "" {
		c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "Authorization token not provided"})
		return
	}

	userId, isAdmin, isMerchant, staffRestaurantIDs, err := utils.VerifyToken(token)
	if err != nil {
		c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "Invalid token"})
		return
	}
	c.Set("userId", userId)
	c.Set("isAdmin", isAdmin)
	c.Set("isMerchant", isMerchant)
	c.Set("staffRestaurantIDs", staffRestaurantIDs)
	c.Next()
}

// RequireAdmin middleware checks if the user has admin rights.
func RequireAdmin() gin.HandlerFunc {
	return func(c *gin.Context) {
		isAdmin, exists := c.Get("isAdmin")
		if !exists || !isAdmin.(bool) {
			c.AbortWithStatusJSON(http.StatusForbidden, gin.H{"error": "Admin access required"})
			return
		}
		c.Next()
	}
}

func RequireRestaurantStaff() gin.HandlerFunc {
	return func(c *gin.Context) {
		var restaurantID uint

		// Pour DELETE: vérifier le paramètre de requête
		if c.Request.Method == "DELETE" {
			restaurantIDStr := c.Query("restaurant_id")
			if restaurantIDStr != "" {
				parsedID, err := strconv.ParseUint(restaurantIDStr, 10, 32)
				if err == nil {
					restaurantID = uint(parsedID)
				}
			}
		} else {

			// Pour POST/PUT: vérifier le corps de la requête
			var requestBody struct {
				RestaurantID uint `json:"restaurant_id"`
			}

			if c.Request.ContentLength > 0 {
				bodyBytes, _ := io.ReadAll(c.Request.Body)
				c.Request.Body.Close()
				c.Request.Body = io.NopCloser(bytes.NewReader(bodyBytes))

				if err := c.ShouldBindJSON(&requestBody); err == nil {
					restaurantID = requestBody.RestaurantID
				}

				c.Request.Body = io.NopCloser(bytes.NewReader(bodyBytes))
			}
		}

		if restaurantID == 0 {
			c.AbortWithStatusJSON(http.StatusBadRequest, gin.H{
				"error": "Restaurant ID is required",
			})
			return
		}

		if !IsStaffOfRestaurant(c, restaurantID) {
			c.AbortWithStatusJSON(http.StatusForbidden, gin.H{
				"error": "You are not authorized to manage this restaurant",
			})
			return
		}

		c.Set("restaurantId", restaurantID)
		c.Next()
	}
}

func IsStaffOfRestaurant(c *gin.Context, restaurantID uint) bool {
	staffRestaurantIDsAny, exists := c.Get("staffRestaurantIDs")
	if !exists {
		return false
	}

	staffRestaurantIDs, ok := staffRestaurantIDsAny.([]uint)
	if !ok {
		return false
	}

	for _, id := range staffRestaurantIDs {
		if id == restaurantID {
			return true
		}
	}

	isAdmin, adminExists := c.Get("isAdmin")
	if adminExists && isAdmin.(bool) {
		return true
	}

	isMerchant, merchantExists := c.Get("isMerchant")
	if merchantExists && isMerchant.(bool) {
		return true
	}

	return false
}

// RequireMerchant middleware checks if the user is a merchant.
func RequireMerchant() gin.HandlerFunc {
	return func(c *gin.Context) {
		isMerchant, exists := c.Get("isMerchant")
		if !exists || !isMerchant.(bool) {
			c.AbortWithStatusJSON(http.StatusForbidden, gin.H{"error": "Access restricted to merchants only"})
			return
		}
		c.Next()
	}
}

// RequireMerchantWithSync checks if the user is a merchant and synchronizes merchant status with the database.
func RequireMerchantWithSync(db *gorm.DB) gin.HandlerFunc {
	userRepo := repositories.NewUserRepository(db)

	return func(c *gin.Context) {
		userIdValue, exists := c.Get("userId")
		if !exists {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
			return
		}

		userId, ok := userIdValue.(uint)
		if !ok {
			c.AbortWithStatusJSON(http.StatusBadRequest, gin.H{"error": "Invalid user ID format"})
			return
		}

		isMerchantValue, exists := c.Get("isMerchant")
		isMerchant := false
		if exists {
			isMerchant, _ = isMerchantValue.(bool)
		}

		if !isMerchant {
			merchantStatus, err := userRepo.IsMerchant(uint(userId))
			if err != nil {
				c.AbortWithStatusJSON(http.StatusInternalServerError, gin.H{"error": "Error checking merchant status"})
				return
			}
			if !merchantStatus {
				c.AbortWithStatusJSON(http.StatusForbidden, gin.H{"error": "Merchant access required"})
				return
			}

			c.Set("isMerchant", true)
		}

		c.Next()
	}
}
