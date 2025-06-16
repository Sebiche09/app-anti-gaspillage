package repositories

import (
	"github.com/Sebiche09/app-anti-gaspillage.git/models"
	"gorm.io/gorm"
)

type RestaurantRepository struct {
	db *gorm.DB
}

func NewRestaurantRepository(db *gorm.DB) *RestaurantRepository {
	return &RestaurantRepository{db: db}
}

func (r *RestaurantRepository) CreateRestaurant(restaurant *models.Restaurant) error {
	return r.db.Create(restaurant).Error
}

func (r *RestaurantRepository) GetCategories() ([]models.Category, error) {
	var categories []models.Category
	err := r.db.Find(&categories).Error
	if err != nil {
		return nil, err
	}
	return categories, nil
}

func (r *RestaurantRepository) GetRestaurantsMerchant(merchantID uint) ([]models.Restaurant, error) {
	var restaurants []models.Restaurant
	err := r.db.Preload("Merchant").Where("merchant_id = ?", merchantID).Find(&restaurants).Error
	if err != nil {
		return nil, err
	}
	return restaurants, nil
}

func (r *RestaurantRepository) GetRestaurants() ([]models.Restaurant, error) {
	var restaurants []models.Restaurant
	err := r.db.Preload("Merchant").Find(&restaurants).Error
	if err != nil {
		return nil, err
	}
	return restaurants, nil
}

func (r *RestaurantRepository) GetRestaurantByID(id uint) (*models.Restaurant, error) {
	var restaurant models.Restaurant
	err := r.db.Where("id = ?", id).First(&restaurant).Error
	if err != nil {
		return nil, err
	}
	return &restaurant, nil
}

func (r *RestaurantRepository) UpdateRestaurant(restaurant *models.Restaurant) error {
	return r.db.Save(restaurant).Error
}

func (r *RestaurantRepository) DeleteRestaurant(restaurant *models.Restaurant) error {
	return r.db.Delete(restaurant).Error
}
