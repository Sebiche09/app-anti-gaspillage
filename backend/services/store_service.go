package services

import (
	"fmt"

	"github.com/Sebiche09/app-anti-gaspillage.git/api/requests"
	"github.com/Sebiche09/app-anti-gaspillage.git/geocoding"
	"github.com/Sebiche09/app-anti-gaspillage.git/models"
	"github.com/Sebiche09/app-anti-gaspillage.git/repositories"
)

type StoreService struct {
	storeRepo        *repositories.StoreRepository
	merchantRepo     *repositories.MerchantRepository
	geocodingService *geocoding.Service
}

func NewStoreService(storeRepo *repositories.StoreRepository, merchantRepo *repositories.MerchantRepository, geocodingService *geocoding.Service) *StoreService {
	return &StoreService{storeRepo: storeRepo, merchantRepo: merchantRepo, geocodingService: geocodingService}
}

func (s *StoreService) GetCategories() ([]models.Category, error) {
	categories, err := s.storeRepo.GetCategories()
	if err != nil {
		return nil, err
	}
	if len(categories) == 0 {
		return nil, fmt.Errorf("aucune catégorie trouvée")
	}
	return categories, nil
}

func (s *StoreService) CreateStore(req requests.CreateStoreRequest, userID uint) error {
	merchand, err := s.merchantRepo.FindMerchantByUserID(userID)
	if err != nil {
		return err
	}

	coordinates, err := s.geocodingService.GetCoordinatesFromAddress(req.Address, req.City, req.PostalCode)
	if err != nil {
		return fmt.Errorf("erreur lors de la récupération des coordonnées géographiques: %w", err)
	}

	store := &models.Store{
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

	return s.storeRepo.CreateStore(store)
}

func (s *StoreService) GetStoresMerchant(userID uint) ([]models.Store, error) {
	merchant, err := s.merchantRepo.FindMerchantByUserID(userID)
	if err != nil {
		return nil, err
	}

	return s.storeRepo.GetStoresMerchant(merchant.ID)
}

func (s *StoreService) GetStores() ([]models.Store, error) {
	return s.storeRepo.GetStores()
}

func (s *StoreService) GetStoreByID(id uint) (*models.Store, error) {
	return s.storeRepo.GetStoreByID(id)
}

func (s *StoreService) UpdateStore(req requests.UpdateStoreRequest, id uint) error {
	store, err := s.storeRepo.GetStoreByID(id)
	if err != nil {
		return err
	}

	store.Name = req.Name
	store.Address = req.Address
	store.City = req.City
	store.PostalCode = req.PostalCode
	store.PhoneNumber = req.PhoneNumber

	return s.storeRepo.UpdateStore(store)
}

func (s *StoreService) DeleteStore(id uint) error {
	store, err := s.storeRepo.GetStoreByID(id)
	if err != nil {
		return err
	}

	return s.storeRepo.DeleteStore(store)
}
func (s *StoreService) GetStoreStaff(id uint) ([]models.StoreStaff, error) {
	store, err := s.storeRepo.GetStoreByID(id)
	if err != nil {
		return nil, err
	}

	staff, err := s.storeRepo.GetStoreStaff(store.ID)
	if err != nil {
		return nil, fmt.Errorf("erreur lors de la récupération du personnel du magasin: %w", err)
	}

	return staff, nil
}
func (s *StoreService) GetStoreBasketConfig(id uint) (*models.BasketConfiguration, error) {
	store, err := s.storeRepo.GetStoreByID(id)
	if err != nil {
		return nil, err
	}

	config, err := s.storeRepo.GetStoreBasketConfig(store.ID)
	if err != nil {
		return nil, fmt.Errorf("erreur lors de la récupération de la configuration du panier du magasin: %w", err)
	}

	return config, nil
}
func (s *StoreService) CreateStoreBasketConfig(req requests.CreateBasketConfigurationRequest, id uint) error {
	store, err := s.storeRepo.GetStoreByID(id)
	if err != nil {
		return err
	}

	config := &models.BasketConfiguration{
		Name:               req.Name,
		Description:        req.Description,
		DiscountPercentage: req.DiscountPercentage,
		Quantity:           req.Quantity,
		StoreID:            store.ID,
	}

	return s.storeRepo.CreateStoreBasketConfig(config)
}
func (s *StoreService) UpdateStoreBasketConfig(req requests.UpdateBasketConfigurationRequest, id uint) error {
	store, err := s.storeRepo.GetStoreByID(id)
	if err != nil {
		return err
	}

	config, err := s.storeRepo.GetStoreBasketConfig(store.ID)
	if err != nil {
		return fmt.Errorf("erreur lors de la récupération de la configuration du panier du magasin: %w", err)
	}

	config.Name = req.Name
	config.Description = req.Description
	config.DiscountPercentage = req.DiscountPercentage
	config.Quantity = req.Quantity

	return s.storeRepo.UpdateStoreBasketConfig(config)
}
func (s *StoreService) DeleteStoreBasketConfig(id uint) error {
	store, err := s.storeRepo.GetStoreByID(id)
	if err != nil {
		return err
	}

	config, err := s.storeRepo.GetStoreBasketConfig(store.ID)
	if err != nil {
		return fmt.Errorf("erreur lors de la récupération de la configuration du panier du magasin: %w", err)
	}

	return s.storeRepo.DeleteStoreBasketConfig(config)
}
