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
