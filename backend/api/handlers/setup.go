package handlers

import (
	"github.com/Sebiche09/app-anti-gaspillage.git/geocoding"
	"github.com/Sebiche09/app-anti-gaspillage.git/repositories"
	"github.com/Sebiche09/app-anti-gaspillage.git/services"
	"github.com/Sebiche09/app-anti-gaspillage.git/utils"
	"gorm.io/gorm"
)

type Handlers struct {
	User       *UserHandler
	Basket     *BasketHandler
	Merchant   *MerchantHandler
	Restaurant *RestaurantHandler
	Invitation *InvitationHandler
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

	geocodingConfig := geocoding.Config{
		APIKey: utils.GetEnv("GEOAPIFY_API_KEY"),
	}
	geocodingService := geocoding.NewService(geocodingConfig)

	restaurantRepo := repositories.NewRestaurantRepository(db)
	restaurantService := services.NewRestaurantService(restaurantRepo, merchantRepo, geocodingService)
	restaurantHandler := NewRestaurantHandler(restaurantService)

	invitationRepo := repositories.NewInvitationRepository(db)
	restaurantStaffRepo := repositories.NewRestaurantStaffRepository(db)

	emailService := services.NewNoopEmailService()

	invitationService := services.NewInvitationService(
		invitationRepo,
		restaurantRepo,
		merchantRepo,
		restaurantStaffRepo,
		emailService,
	)
	invitationHandler := NewInvitationHandler(invitationService)

	return &Handlers{
		User:       userHandler,
		Basket:     basketHandler,
		Merchant:   merchantHandler,
		Restaurant: restaurantHandler,
		Invitation: invitationHandler,
	}
}
