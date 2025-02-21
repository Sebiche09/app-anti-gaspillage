package repositories

import (
	"github.com/Sebiche09/app-anti-gaspillage.git/models"
	"gorm.io/gorm"
)

type UserRepository struct {
	DB *gorm.DB
}

func NewUserRepository(db *gorm.DB) *UserRepository {
	return &UserRepository{DB: db}
}

func (r *UserRepository) Create(user *models.User) error {
	return r.DB.Create(user).Error
}

func (r *UserRepository) FindByEmail(email string) (*models.User, error) {
	var user models.User
	if err := r.DB.Where("email = ?", email).First(&user).Error; err != nil {
		return nil, err
	}
	return &user, nil
}

func (r *UserRepository) IsMerchant(userID uint) (bool, error) {
	var merchantCount int64

	err := r.DB.Model(&models.Merchant{}).Where("user_id = ?", userID).Count(&merchantCount).Error
	if err != nil {
		return false, err
	}

	return merchantCount > 0, nil
}
