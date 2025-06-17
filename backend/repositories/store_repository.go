package repositories

import (
	"github.com/Sebiche09/app-anti-gaspillage.git/models"
	"gorm.io/gorm"
)

type StoreRepository struct {
	db *gorm.DB
}

func NewStoreRepository(db *gorm.DB) *StoreRepository {
	return &StoreRepository{db: db}
}

func (r *StoreRepository) CreateStore(store *models.Store) error {
	return r.db.Create(store).Error
}

func (r *StoreRepository) GetCategories() ([]models.Category, error) {
	var categories []models.Category
	err := r.db.Find(&categories).Error
	if err != nil {
		return nil, err
	}
	return categories, nil
}

func (r *StoreRepository) GetStoresMerchant(merchantID uint) ([]models.Store, error) {
	var stores []models.Store
	err := r.db.Preload("Merchant").Where("merchant_id = ?", merchantID).Find(&stores).Error
	if err != nil {
		return nil, err
	}
	return stores, nil
}

func (r *StoreRepository) GetStores() ([]models.Store, error) {
	var stores []models.Store
	err := r.db.Preload("Merchant").Find(&stores).Error
	if err != nil {
		return nil, err
	}
	return stores, nil
}

func (r *StoreRepository) GetStoreByID(id uint) (*models.Store, error) {
	var store models.Store
	err := r.db.Where("id = ?", id).First(&store).Error
	if err != nil {
		return nil, err
	}
	return &store, nil
}

func (r *StoreRepository) UpdateStore(store *models.Store) error {
	return r.db.Save(store).Error
}

func (r *StoreRepository) DeleteStore(store *models.Store) error {
	return r.db.Delete(store).Error
}
func (r *StoreRepository) GetStoreStaff(storeID uint) ([]models.StoreStaff, error) {
	var storeStaff []models.StoreStaff
	err := r.db.Where("store_id = ?", storeID).Find(&storeStaff).Error
	if err != nil {
		return nil, err
	}
	return storeStaff, nil
}
func (r *StoreRepository) GetStoreBasketConfig(storeID uint) (*models.BasketConfiguration, error) {
	var config models.BasketConfiguration
	err := r.db.Where("store_id = ?", storeID).First(&config).Error
	if err != nil {
		return nil, err
	}
	return &config, nil
}

func (r *StoreRepository) CreateStoreBasketConfig(config *models.BasketConfiguration) error {
	return r.db.Create(config).Error
}

func (r *StoreRepository) UpdateStoreBasketConfig(config *models.BasketConfiguration) error {
	return r.db.Save(config).Error
}
func (r *StoreRepository) DeleteStoreBasketConfig(config *models.BasketConfiguration) error {
	return r.db.Delete(config).Error
}
