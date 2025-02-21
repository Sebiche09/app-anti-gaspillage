package middlewares

import (
	"net/http"

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

	userId, isAdmin, isMerchant, err := utils.VerifyToken(token)
	if err != nil {
		c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "Invalid token"})
		return
	}
	c.Set("userId", userId)
	c.Set("isAdmin", isAdmin)
	c.Set("isMerchant", isMerchant)
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

		userId, ok := userIdValue.(int)
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
