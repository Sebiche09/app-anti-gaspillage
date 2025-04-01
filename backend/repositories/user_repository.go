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

func (r *UserRepository) GetStaffRestaurantIDs(userID uint) ([]uint, error) {
	var restaurantIDs []uint

	err := r.DB.Model(&models.RestaurantStaff{}).
		Select("restaurant_id").
		Where("user_id = ?", userID).
		Pluck("restaurant_id", &restaurantIDs).
		Error

	return restaurantIDs, err
}

func (r *UserRepository) IsStaffOfRestaurant(userID, restaurantID uint) (bool, error) {
	var staffCount int64

	err := r.DB.Model(&models.RestaurantStaff{}).
		Where("user_id = ? AND restaurant_id = ?", userID, restaurantID).
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
