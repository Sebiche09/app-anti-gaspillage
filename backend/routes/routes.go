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

	// Routes publiques
	public := r.Group("/api")
	{
		auth := public.Group("/auth")
		{
			auth.POST("/signup", h.User.Signup)
			auth.POST("/login", h.User.Login)
		}
	}

	// Routes authentifiées
	api := r.Group("/api")
	api.Use(middlewares.Authenticate)
	{
		baskets := api.Group("/baskets")
		{
			baskets.GET("", h.Basket.GetBaskets)
			baskets.GET("/:id", h.Basket.GetBasket)

			merchantOnly := baskets.Group("")
			merchantOnly.Use(middlewares.RequireMerchantWithSync(db))
			{
				merchantOnly.POST("", h.Basket.CreateBasket)
				merchantOnly.PUT("/:id", h.Basket.UpdateBasket)
				merchantOnly.DELETE("/:id", h.Basket.DeleteBasket)
			}
		}
	}
}
