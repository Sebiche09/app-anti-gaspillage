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
	r.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))

	api := r.Group("/api")

	{
		auth := api.Group("/auth")
		{
			auth.POST("/signup", h.User.Signup)
			auth.POST("/login", h.User.Login)
		}
	}

	authenticated := api.Group("")
	authenticated.Use(middlewares.Authenticate)
	{
		restaurants := authenticated.Group("/restaurants")
		{
			restaurants.GET("/", h.Restaurant.GetRestaurants)
			restaurants.GET("/:id", h.Restaurant.GetRestaurant)

			// Route pour obtenir les invitations en attente d'un restaurant
			restaurants.GET("/:id/invitations", h.Invitation.GetPendingInvitations)
		}

		merchants := authenticated.Group("/merchants")
		{
			merchants.POST("/", h.Merchant.CreateMerchantRequest)
			merchants.GET("/restaurants", h.Restaurant.GetRestaurantsMerchant)
			merchants.PUT("/restaurants/:id", h.Restaurant.UpdateRestaurant)
			merchants.POST("/restaurants", h.Restaurant.CreateRestaurant)
		}

		merchants.Use(middlewares.RequireMerchantWithSync(db))
		{
			merchants.PUT("/", h.Merchant.UpdateMerchant)
			merchants.DELETE("/", h.Merchant.DeleteMerchant)
			merchants.GET("/", h.Merchant.GetMerchant)
		}

		admin := authenticated.Group("/admin")
		admin.Use(middlewares.RequireAdmin())
		{
			admin.GET("/merchants", h.Merchant.GetMerchants)
			admin.GET("/merchant-requests", h.Merchant.GetPendingRequests)
			admin.PUT("/merchant-requests/:id", h.Merchant.ProcessRequest)
			admin.GET("/users", h.User.GetUsers)
		}

		// Routes pour les invitations
		invitations := authenticated.Group("/invitations")
		{
			invitations.POST("/", h.Invitation.CreateInvitation)
			invitations.GET("/accept", h.Invitation.AcceptInvitation)
			invitations.DELETE("/:id", h.Invitation.CancelInvitation)
		}

		// Routes pour les paniers (baskets)
		baskets := authenticated.Group("/baskets")
		{
			// Routes publiques pour les paniers
			baskets.GET("/", h.Basket.GetBaskets)
			baskets.GET("/:id", h.Basket.GetBasket)

			// Routes pour la gestion des paniers (staff du restaurant uniquement)
			staffBaskets := baskets.Group("")
			staffBaskets.Use(middlewares.RequireRestaurantStaff())
			{
				staffBaskets.POST("/", h.Basket.CreateBasket)
				staffBaskets.PUT("/:id", h.Basket.UpdateBasket)
				staffBaskets.DELETE("/:id", h.Basket.DeleteBasket)
			}
		}
	}
}
