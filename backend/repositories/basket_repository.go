package repositories

import (
	"errors"

	"github.com/Sebiche09/app-anti-gaspillage.git/models"
	"gorm.io/gorm"
)

type BasketRepository struct {
	DB *gorm.DB
}

func NewBasketRepository(db *gorm.DB) *BasketRepository {
	return &BasketRepository{DB: db}
}

func (r *BasketRepository) GetAll() ([]models.Basket, error) {
	var baskets []models.Basket
	if err := r.DB.Find(&baskets).Error; err != nil {
		return nil, err
	}
	return baskets, nil
}

func (r *BasketRepository) GetByID(id int) (*models.Basket, error) {
	var basket models.Basket
	if err := r.DB.First(&basket, id).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errors.New("basket not found")
		}
		return nil, err
	}
	return &basket, nil
}

func (r *BasketRepository) Create(basket *models.Basket) error {
	return r.DB.Create(basket).Error
}

func (r *BasketRepository) Delete(basket *models.Basket) error {
	return r.DB.Delete(basket).Error
}

func (r *BasketRepository) Update(basket *models.Basket, updates models.Basket) error {
	return r.DB.Model(basket).Updates(updates).Error
}
