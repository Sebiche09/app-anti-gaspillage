package repositories

import (
	"errors"

	"github.com/Sebiche09/app-anti-gaspillage.git/models"
	"gorm.io/gorm"
)

type MerchantRepository struct {
	db *gorm.DB
}

func NewMerchantRepository(db *gorm.DB) *MerchantRepository {
	return &MerchantRepository{db: db}
}

func (r *MerchantRepository) FindMerchantStatusByUserID(userID uint) (*models.MerchantRequest, error) {
	var request models.MerchantRequest
	err := r.db.Where("user_id = ?", userID).First(&request).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, nil
		}
		return nil, err
	}
	return &request, nil
}

func (r *MerchantRepository) CreateMerchantRequest(request *models.MerchantRequest) error {
	return r.db.Create(request).Error
}

func (r *MerchantRepository) FindPendingRequestByUserID(userID uint) (*models.MerchantRequest, error) {
	var request models.MerchantRequest
	err := r.db.Where("user_id = ? AND status = ?", userID, "pending").First(&request).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, nil
		}
		return nil, err
	}
	return &request, nil
}

func (r *MerchantRepository) GetPendingRequests() ([]models.MerchantRequest, error) {
	var requests []models.MerchantRequest
	err := r.db.Where("status = ?", "pending").Find(&requests).Error
	return requests, err
}

func (r *MerchantRepository) FindRequestByID(id uint) (*models.MerchantRequest, error) {
	var request models.MerchantRequest
	err := r.db.First(&request, id).Error
	if err != nil {
		return nil, err
	}
	return &request, nil
}

func (r *MerchantRepository) UpdateRequest(request *models.MerchantRequest) error {
	return r.db.Save(request).Error
}

func (r *MerchantRepository) CreateMerchant(merchant *models.Merchant) error {
	return r.db.Create(merchant).Error
}

func (r *MerchantRepository) GetMerchants() ([]models.Merchant, error) {
	var merchants []models.Merchant
	err := r.db.Find(&merchants).Error
	return merchants, err
}

func (r *MerchantRepository) FindMerchantByUserID(userID uint) (*models.Merchant, error) {
	var merchant models.Merchant
	err := r.db.Where("user_id = ?", userID).First(&merchant).Error
	if err != nil {
		return nil, err
	}
	return &merchant, nil
}

func (r *MerchantRepository) UpdateMerchant(merchant *models.Merchant) error {
	return r.db.Save(merchant).Error
}

func (r *MerchantRepository) DeleteMerchant(merchant *models.Merchant) error {
	return r.db.Delete(merchant).Error
}
