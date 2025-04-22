package services

import (
	"fmt"

	"github.com/Sebiche09/app-anti-gaspillage.git/api/requests"
	"github.com/Sebiche09/app-anti-gaspillage.git/geocoding"
	"github.com/Sebiche09/app-anti-gaspillage.git/models"
	"github.com/Sebiche09/app-anti-gaspillage.git/repositories"
)

type RestaurantService struct {
	restaurantRepo   *repositories.RestaurantRepository
	merchantRepo     *repositories.MerchantRepository
	geocodingService *geocoding.Service
}

func NewRestaurantService(restaurantRepo *repositories.RestaurantRepository, merchantRepo *repositories.MerchantRepository, geocodingService *geocoding.Service) *RestaurantService {
	return &RestaurantService{restaurantRepo: restaurantRepo, merchantRepo: merchantRepo, geocodingService: geocodingService}
}

func (s *RestaurantService) CreateOrUpdateBasketConfiguration(restaurantID uint, req requests.BasketConfigurationRequest, userID uint) (*models.BasketConfiguration, error) {
	// Récupérer le restaurant
	restaurant, err := s.restaurantRepo.GetRestaurantByID(restaurantID)
	if err != nil {
		return nil, fmt.Errorf("restaurant non trouvé: %w", err)
	}

	// Récupérer le merchant associé à l'utilisateur
	merchant, err := s.merchantRepo.FindMerchantByUserID(userID)
	if err != nil {
		return nil, fmt.Errorf("merchant non trouvé: %w", err)
	}

	// Vérifier si ce merchant est bien propriétaire du restaurant
	if restaurant.MerchantID != merchant.ID {
		return nil, fmt.Errorf("vous n'êtes pas autorisé à modifier ce restaurant")
	}

	existingConfig, err := s.restaurantRepo.GetBasketConfiguration(restaurantID)

	if err == nil {
		return s.updateBasketConfiguration(existingConfig, req)
	}

	return s.createBasketConfiguration(restaurant.ID, req)
}

func (s *RestaurantService) createBasketConfiguration(restaurantID uint, req requests.BasketConfigurationRequest) (*models.BasketConfiguration, error) {
	config := &models.BasketConfiguration{
		RestaurantID: restaurantID,
		Price:        req.Price,
	}

	for _, availability := range req.DailyAvailabilities {
		config.DailyAvailabilities = append(config.DailyAvailabilities, models.DailyBasketAvailability{
			DayOfWeek:       availability.DayOfWeek,
			NumberOfBaskets: availability.NumberOfBaskets,
		})
	}

	if err := s.restaurantRepo.CreateBasketConfiguration(config); err != nil {
		return nil, fmt.Errorf("erreur lors de la création de la configuration: %w", err)
	}

	return config, nil
}

func (s *RestaurantService) updateBasketConfiguration(config *models.BasketConfiguration, req requests.BasketConfigurationRequest) (*models.BasketConfiguration, error) {
	config.Price = req.Price

	if err := s.restaurantRepo.DeleteDailyAvailabilities(config.ID); err != nil {
		return nil, fmt.Errorf("erreur lors de la suppression des disponibilités existantes: %w", err)
	}

	for _, availability := range req.DailyAvailabilities {
		config.DailyAvailabilities = append(config.DailyAvailabilities, models.DailyBasketAvailability{
			ConfigurationID: config.ID,
			DayOfWeek:       availability.DayOfWeek,
			NumberOfBaskets: availability.NumberOfBaskets,
		})
	}

	if err := s.restaurantRepo.UpdateBasketConfiguration(config); err != nil {
		return nil, fmt.Errorf("erreur lors de la mise à jour de la configuration: %w", err)
	}

	return config, nil
}

func (s *RestaurantService) GetBasketConfiguration(restaurantID uint, userID uint) (*models.BasketConfiguration, error) {
	// Récupérer le restaurant
	restaurant, err := s.restaurantRepo.GetRestaurantByID(restaurantID)
	if err != nil {
		return nil, fmt.Errorf("restaurant non trouvé: %w", err)
	}

	// Récupérer le merchant associé à l'utilisateur
	merchant, err := s.merchantRepo.FindMerchantByUserID(userID)
	if err != nil {
		return nil, fmt.Errorf("merchant non trouvé: %w", err)
	}

	// Vérifier si ce merchant est bien propriétaire du restaurant
	if restaurant.MerchantID != merchant.ID {
		return nil, fmt.Errorf("vous n'êtes pas autorisé à accéder à ce restaurant")
	}

	return s.restaurantRepo.GetBasketConfiguration(restaurantID)
}

func (s *RestaurantService) DeleteBasketConfiguration(restaurantID uint, userID uint) error {
	// Récupérer le restaurant
	restaurant, err := s.restaurantRepo.GetRestaurantByID(restaurantID)
	if err != nil {
		return fmt.Errorf("restaurant non trouvé: %w", err)
	}

	// Récupérer le merchant associé à l'utilisateur
	merchant, err := s.merchantRepo.FindMerchantByUserID(userID)
	if err != nil {
		return fmt.Errorf("merchant non trouvé: %w", err)
	}

	// Vérifier si ce merchant est bien propriétaire du restaurant
	if restaurant.MerchantID != merchant.ID {
		return fmt.Errorf("vous n'êtes pas autorisé à modifier ce restaurant")
	}

	config, err := s.restaurantRepo.GetBasketConfiguration(restaurantID)
	if err != nil {
		return fmt.Errorf("configuration de panier non trouvée: %w", err)
	}

	return s.restaurantRepo.DeleteBasketConfiguration(config.ID)
}

func (s *RestaurantService) GetCategories() ([]models.Category, error) {
	categories, err := s.restaurantRepo.GetCategories()
	if err != nil {
		return nil, err
	}
	if len(categories) == 0 {
		return nil, fmt.Errorf("aucune catégorie trouvée")
	}
	return categories, nil
}

func (s *RestaurantService) CreateRestaurant(req requests.CreateRestaurantRequest, userID uint) (*models.Restaurant, error) {
	merchand, err := s.merchantRepo.FindMerchantByUserID(userID)
	if err != nil {
		return nil, err
	}

	coordinates, err := s.geocodingService.GetCoordinatesFromAddress(req.Address, req.City, req.PostalCode)
	if err != nil {
		return nil, fmt.Errorf("erreur lors de la récupération des coordonnées géographiques: %w", err)
	}

	restaurant := &models.Restaurant{
		Name:        req.Name,
		Address:     req.Address,
		City:        req.City,
		PostalCode:  req.PostalCode,
		PhoneNumber: req.PhoneNumber,
		MerchantID:  merchand.ID,
		CategoryID:  req.CategoryID,
		Latitude:    coordinates.Latitude,
		Longitude:   coordinates.Longitude,
	}

	if err := s.restaurantRepo.CreateRestaurant(restaurant); err != nil {
		return nil, err
	}

	return restaurant, nil
}

func (s *RestaurantService) GetRestaurantsMerchant(userID uint) ([]models.Restaurant, error) {
	merchant, err := s.merchantRepo.FindMerchantByUserID(userID)
	if err != nil {
		return nil, err
	}

	return s.restaurantRepo.GetRestaurantsMerchant(merchant.ID)
}

func (s *RestaurantService) GetRestaurants() ([]models.Restaurant, error) {
	return s.restaurantRepo.GetRestaurants()
}

func (s *RestaurantService) GetRestaurantByID(id uint) (*models.Restaurant, error) {
	return s.restaurantRepo.GetRestaurantByID(id)
}

func (s *RestaurantService) UpdateRestaurant(req requests.UpdateRestaurantRequest, id uint) error {
	restaurant, err := s.restaurantRepo.GetRestaurantByID(id)
	if err != nil {
		return err
	}

	restaurant.Name = req.Name
	restaurant.Address = req.Address
	restaurant.City = req.City
	restaurant.PostalCode = req.PostalCode
	restaurant.PhoneNumber = req.PhoneNumber

	return s.restaurantRepo.UpdateRestaurant(restaurant)
}

func (s *RestaurantService) DeleteRestaurant(id uint) error {
	restaurant, err := s.restaurantRepo.GetRestaurantByID(id)
	if err != nil {
		return err
	}

	return s.restaurantRepo.DeleteRestaurant(restaurant)
}
