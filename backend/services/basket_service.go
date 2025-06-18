package services

import (
	"errors"

	"github.com/Sebiche09/app-anti-gaspillage.git/api/requests"
	"github.com/Sebiche09/app-anti-gaspillage.git/models"
	"github.com/Sebiche09/app-anti-gaspillage.git/repositories"
)

type BasketService struct {
	BasketRepo *repositories.BasketRepository
}

func NewBasketService(basketRepo *repositories.BasketRepository) *BasketService {
	return &BasketService{BasketRepo: basketRepo}
}

func (s *BasketService) GetBaskets() ([]models.Basket, error) {
	return s.BasketRepo.GetAll()
}

func (s *BasketService) GetBasket(id int) (*models.Basket, error) {
	return s.BasketRepo.GetByID(id)
}

func (s *BasketService) CreateBasket(req requests.CreateBasketRequest, userId uint) error {
	basket := models.Basket{
		StoreID:            req.StoreID,
		ConfigurationID:    req.ConfigurationID,
		Name:               req.Name,
		Description:        req.Description,
		DiscountPercentage: req.DiscountPercentage,
		OriginalPrice:      req.OriginalPrice,
		Quantity:           req.Quantity,
		ExpirationDate:     req.ExpirationDate,
	}
	return s.BasketRepo.Create(&basket)
}

func (s *BasketService) UpdateBasket(id int, updates models.Basket, userId int) (*models.Basket, error) {
	basket, err := s.BasketRepo.GetByID(id)
	if err != nil {
		return nil, err
	}

	// Vérifie si le basket appartient au magasin de l'utilisateur
	if basket.StoreID != userId {
		return nil, errors.New("not authorized to update this basket")
	}

	err = s.BasketRepo.Update(basket, updates)
	return basket, err
}

func (s *BasketService) DeleteBasket(id int, userId int) error {
	basket, err := s.BasketRepo.GetByID(id)
	if err != nil {
		return err
	}

	// Vérifie si le basket appartient au magasin de l'utilisateur
	if basket.StoreID != userId {
		return errors.New("not authorized to delete this basket")
	}

	return s.BasketRepo.Delete(basket)
}
func (s *BasketService) GetBasketsByStore(storeId int) ([]models.Basket, error) {
	var baskets []models.Basket
	err := s.BasketRepo.DB.Where("store_id = ?", storeId).Find(&baskets).Error
	if err != nil {
		return nil, err
	}
	return baskets, nil
}
