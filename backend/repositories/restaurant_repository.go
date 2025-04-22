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

func (r *RestaurantRepository) CreateBasketConfiguration(config *models.BasketConfiguration) error {
	return r.db.Create(config).Error
}

func (r *RestaurantRepository) GetBasketConfiguration(restaurantID uint) (*models.BasketConfiguration, error) {
	var config models.BasketConfiguration
	err := r.db.Where("restaurant_id = ?", restaurantID).Preload("DailyAvailabilities").First(&config).Error
	if err != nil {
		return nil, err
	}
	return &config, nil
}

func (r *RestaurantRepository) UpdateBasketConfiguration(config *models.BasketConfiguration) error {
	if err := r.db.Save(config).Error; err != nil {
		return err
	}

	if len(config.DailyAvailabilities) > 0 {
		if err := r.db.Create(&config.DailyAvailabilities).Error; err != nil {
			return err
		}
	}

	return nil
}
func (r *RestaurantRepository) DeleteBasketConfiguration(configID uint) error {
	// Supprimer la configuration (les disponibilités seront supprimées en cascade)
	return r.db.Delete(&models.BasketConfiguration{ID: configID}).Error
}

// DeleteDailyAvailabilities supprime toutes les disponibilités journalières d'une configuration
func (r *RestaurantRepository) DeleteDailyAvailabilities(configID uint) error {
	return r.db.Where("configuration_id = ?", configID).Delete(&models.DailyBasketAvailability{}).Error
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
