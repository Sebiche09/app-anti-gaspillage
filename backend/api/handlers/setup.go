package handlers

import (
	"os"

	"github.com/Sebiche09/app-anti-gaspillage.git/geocoding"
	"github.com/Sebiche09/app-anti-gaspillage.git/repositories"
	"github.com/Sebiche09/app-anti-gaspillage.git/services"
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
	// Initialisation des repositories existants
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
		APIKey: getEnv("GEOAPIFY_API_KEY", "2115077bfd0b48daa4204a0e9466c4cc"),
	}
	geocodingService := geocoding.NewService(geocodingConfig)

	restaurantRepo := repositories.NewRestaurantRepository(db)
	restaurantService := services.NewRestaurantService(restaurantRepo, merchantRepo, geocodingService)
	restaurantHandler := NewRestaurantHandler(restaurantService)

	// Initialisation des nouveaux repositories et services pour les invitations
	invitationRepo := repositories.NewInvitationRepository(db)
	restaurantStaffRepo := repositories.NewRestaurantStaffRepository(db)

	// Si vous avez un service d'email, vous pouvez l'initialiser ici
	// emailService := services.NewEmailService(...)

	// Pour l'exemple, créons un service d'email simple qui ne fait rien
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

func getEnv(key, defaultValue string) string {
	value := os.Getenv(key)
	if value == "" {
		return defaultValue
	}
	return value
}
