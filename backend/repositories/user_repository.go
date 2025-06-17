package repositories

import (
	"time"

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

func (r *UserRepository) FindByID(userID uint) (*models.User, error) {
	var user models.User
	if err := r.DB.First(&user, userID).Error; err != nil {
		return nil, err
	}
	return &user, nil
}

func (r *UserRepository) Update(user *models.User) error {
	return r.DB.Save(user).Error
}
func (r *UserRepository) IsMerchant(userID uint) (bool, error) {
	var merchantCount int64

	err := r.DB.Model(&models.Merchant{}).Where("user_id = ?", userID).Count(&merchantCount).Error
	if err != nil {
		return false, err
	}

	return merchantCount > 0, nil
}

func (r *UserRepository) GetStaffStoreIDs(userID uint) ([]uint, error) {
	var storeIDs []uint

	err := r.DB.Model(&models.StoreStaff{}).
		Select("store_id").
		Where("user_id = ?", userID).
		Pluck("store_id", &storeIDs).
		Error

	return storeIDs, err
}

func (r *UserRepository) IsStaffOfStore(userID, storeID uint) (bool, error) {
	var staffCount int64

	err := r.DB.Model(&models.StoreStaff{}).
		Where("user_id = ? AND store_id = ?", userID, storeID).
		Count(&staffCount).Error

	if err != nil {
		return false, err
	}

	return staffCount > 0, nil
}

func (r *UserRepository) GetUsers() ([]models.User, error) {
	var users []models.User
	err := r.DB.Find(&users).Error
	return users, err
}

func (r *UserRepository) StoreRefreshToken(userID uint, refreshToken string, expiredTime time.Time) error {
	return r.DB.Model(&models.User{}).Where("id = ?", userID).Updates(map[string]interface{}{
		"refresh_token": refreshToken,
		"expiry_time":   expiredTime,
	}).Error
}
func (r *UserRepository) FindByRefreshToken(refreshToken string) (*models.User, error) {
	var user models.User
	if err := r.DB.Where("refresh_token = ?", refreshToken).First(&user).Error; err != nil {
		return nil, err
	}
	return &user, nil
}
