package handlers

import (
	"github.com/Sebiche09/app-anti-gaspillage.git/repositories"
	"github.com/Sebiche09/app-anti-gaspillage.git/services"
	"gorm.io/gorm"
)

type Handlers struct {
	User   *UserHandler
	Basket *BasketHandler
}

func NewHandlers(db *gorm.DB) *Handlers {
	userRepo := repositories.NewUserRepository(db)
	userService := services.NewUserService(userRepo)
	userHandler := NewUserHandler(userService)

	basketRepo := repositories.NewBasketRepository(db)
	basketService := services.NewBasketService(basketRepo)
	basketHandler := NewBasketHandler(basketService)

	return &Handlers{
		User:   userHandler,
		Basket: basketHandler,
	}
}
