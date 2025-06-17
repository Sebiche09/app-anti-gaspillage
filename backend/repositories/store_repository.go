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
