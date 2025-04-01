package repositories

import (
	"github.com/Sebiche09/app-anti-gaspillage.git/models"
	"gorm.io/gorm"
)

type RestaurantStaffRepository struct {
	db *gorm.DB
}

func NewRestaurantStaffRepository(db *gorm.DB) *RestaurantStaffRepository {
	return &RestaurantStaffRepository{db: db}
}

func (r *RestaurantStaffRepository) AddStaffMember(staff *models.RestaurantStaff) error {
	return r.db.Create(staff).Error
}

func (r *RestaurantStaffRepository) GetStaffByRestaurant(restaurantID uint) ([]models.RestaurantStaff, error) {
	var staffMembers []models.RestaurantStaff
	err := r.db.Preload("User").Where("restaurant_id = ?", restaurantID).Find(&staffMembers).Error
	return staffMembers, err
}

func (r *RestaurantStaffRepository) IsUserStaffMember(restaurantID, userID uint) (bool, error) {
	var count int64
	err := r.db.Model(&models.RestaurantStaff{}).
		Where("restaurant_id = ? AND user_id = ?", restaurantID, userID).
		Count(&count).Error
	return count > 0, err
}

func (r *RestaurantStaffRepository) RemoveStaffMember(restaurantID, userID uint) error {
	return r.db.Where("restaurant_id = ? AND user_id = ?", restaurantID, userID).
		Delete(&models.RestaurantStaff{}).Error
}
