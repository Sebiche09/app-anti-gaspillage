package routes

import (
	"github.com/Sebiche09/app-anti-gaspillage.git/api/handlers"
	"github.com/Sebiche09/app-anti-gaspillage.git/middlewares"
	"github.com/gin-gonic/gin"
	swaggerFiles "github.com/swaggo/files"
	ginSwagger "github.com/swaggo/gin-swagger"
	"gorm.io/gorm"
)

type Handler struct {
	DB *gorm.DB
}

func RegisterRoutes(r *gin.Engine, db *gorm.DB, h *handlers.Handlers) {
	// Documentation Swagger
	r.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))

	// Routes API
	api := r.Group("/api")

	// Routes publiques
	{
		auth := api.Group("/auth")
		{
			auth.POST("/signup", h.User.Signup)
			auth.POST("/login", h.User.Login)
		}
	}

	// Routes authentifiées
	authenticated := api.Group("")
	authenticated.Use(middlewares.Authenticate)
	{
		// Routes paniers
		baskets := authenticated.Group("/baskets")
		{
			// Routes accessibles à tous les utilisateurs authentifiés
			baskets.GET("", h.Basket.GetBaskets)
			baskets.GET("/:id", h.Basket.GetBasket)

			// Routes réservées aux marchands
			merchantBaskets := baskets.Group("")
			merchantBaskets.Use(middlewares.RequireMerchantWithSync(db))
			{
				merchantBaskets.POST("", h.Basket.CreateBasket)
				merchantBaskets.PUT("/:id", h.Basket.UpdateBasket)
				merchantBaskets.DELETE("/:id", h.Basket.DeleteBasket)
			}
		}

		// Routes marchands
		merchants := authenticated.Group("/merchants")
		{
			merchants.POST("/request", h.Merchant.CreateMerchantRequest)
		}

		// Routes administrateur
		admin := authenticated.Group("/admin")
		admin.Use(middlewares.RequireAdmin())
		{
			// Gestion des demandes marchands
			admin.GET("/merchant-requests", h.Merchant.GetPendingRequests)
			admin.PUT("/merchant-requests/:id", h.Merchant.ProcessRequest)

			// Espace pour futures routes admin
			// admin.GET("/users", h.Admin.GetUsers)
			// admin.GET("/statistics", h.Admin.GetStatistics)
		}
	}
}
