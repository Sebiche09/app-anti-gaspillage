package integration_test

import (
	"testing"

	"github.com/Sebiche09/app-anti-gaspillage.git/api/handlers"
	"github.com/Sebiche09/app-anti-gaspillage.git/models"
	"github.com/Sebiche09/app-anti-gaspillage.git/routes"
	"github.com/gin-gonic/gin"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
)

func setupTestDB() *gorm.DB {
	db, err := gorm.Open(sqlite.Open(":memory:"), &gorm.Config{})
	if err != nil {
		panic("failed to connect database")
	}

	// Migration des modèles
	db.AutoMigrate(&models.User{})

	return db
}

func TestUserIntegration(t *testing.T) {
	db := setupTestDB()
	router := gin.Default()
	h := handlers.NewHandlers(db)

	routes.RegisterRoutes(router, db, h)

	// Testez le point de terminaison /api/auth/signup
	// Créez une requête, envoyez-la et vérifiez les réponses
}
