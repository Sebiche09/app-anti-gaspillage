package services

import (
	"github.com/Sebiche09/app-anti-gaspillage.git/api/requests"
	"github.com/Sebiche09/app-anti-gaspillage.git/models"
	"github.com/Sebiche09/app-anti-gaspillage.git/repositories"
)

type RestaurantService struct {
	restaurantRepo *repositories.RestaurantRepository
	merchantRepo   *repositories.MerchantRepository
}

func NewRestaurantService(restaurantRepo *repositories.RestaurantRepository, merchantRepo *repositories.MerchantRepository) *RestaurantService {
	return &RestaurantService{restaurantRepo: restaurantRepo, merchantRepo: merchantRepo}
}

func (s *RestaurantService) CreateRestaurant(req requests.CreateRestaurantRequest, userID uint) error {
	merchand, err := s.merchantRepo.FindMerchantByUserID(userID)
	if err != nil {
		return err
	}

	restaurant := &models.Restaurant{
		Name:        req.Name,
		SIREN:       req.SIREN,
		Address:     req.Address,
		City:        req.City,
		PostalCode:  req.PostalCode,
		PhoneNumber: req.PhoneNumber,
		MerchantID:  merchand.ID,
		CategoryID:  req.CategoryID,
	}

	return s.restaurantRepo.CreateRestaurant(restaurant)
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
	restaurant.SIREN = req.SIREN
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
