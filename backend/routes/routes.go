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
			auth.POST("/resend-code", h.User.ResendCode)
			auth.POST("/validate-code", h.User.ValidateCode)
			auth.POST("/signup", h.User.Signup)
			auth.POST("/login", h.User.Login)
		}
	}

	authenticated := api.Group("")
	authenticated.Use(middlewares.Authenticate)
	{
		authenticated.GET("/categories", h.Store.GetCategories)
		stores := authenticated.Group("/stores")
		{
			stores.GET("/", h.Store.GetStores)
			stores.GET("/:id", h.Store.GetStore)

			// Route pour obtenir les invitations en attente d'un magasin
			stores.GET("/:id/request-status-statustions", h.Invitation.GetPendingInvitations)
		}

		merchants := authenticated.Group("/merchants")
		{
			merchants.POST("/", h.Merchant.CreateMerchantRequest)
			merchants.GET("/request-status", h.Merchant.MerchantRequestStatus)
			merchants.GET("/stores", h.Store.GetStoresMerchant)
			merchants.PUT("/stores/:id", h.Store.UpdateStore)
			merchants.POST("/stores", h.Store.CreateStore)
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

			// Routes pour la gestion des paniers (staff du magasin uniquement)
			staffBaskets := baskets.Group("")
			staffBaskets.Use(middlewares.RequireStoreStaff())
			{
				staffBaskets.POST("/", h.Basket.CreateBasket)
				staffBaskets.PUT("/:id", h.Basket.UpdateBasket)
				staffBaskets.DELETE("/:id", h.Basket.DeleteBasket)
			}
		}
	}
}
