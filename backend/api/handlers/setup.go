package handlers

import (
	"github.com/Sebiche09/app-anti-gaspillage.git/repositories"
	"github.com/Sebiche09/app-anti-gaspillage.git/services"
	"gorm.io/gorm"
)

type Handlers struct {
	User     *UserHandler
	Basket   *BasketHandler
	Merchant *MerchantHandler
}

func NewHandlers(db *gorm.DB) *Handlers {
	userRepo := repositories.NewUserRepository(db)
	userService := services.NewUserService(userRepo)
	userHandler := NewUserHandler(userService)

	basketRepo := repositories.NewBasketRepository(db)
	basketService := services.NewBasketService(basketRepo)
	basketHandler := NewBasketHandler(basketService)

	merchantRepo := repositories.NewMerchantRepository(db)
	merchantService := services.NewMerchantService(merchantRepo)
	merchantHandler := NewMerchantHandler(merchantService)

	return &Handlers{
		User:     userHandler,
		Basket:   basketHandler,
		Merchant: merchantHandler,
	}
}
