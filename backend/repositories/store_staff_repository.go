package repositories

import (
	"github.com/Sebiche09/app-anti-gaspillage.git/models"
	"gorm.io/gorm"
)

type StoreStaffRepository struct {
	db *gorm.DB
}

func NewStoreStaffRepository(db *gorm.DB) *StoreStaffRepository {
	return &StoreStaffRepository{db: db}
}

func (r *StoreStaffRepository) AddStaffMember(staff *models.StoreStaff) error {
	return r.db.Create(staff).Error
}

func (r *StoreStaffRepository) GetStaffByStore(storeID uint) ([]models.StoreStaff, error) {
	var staffMembers []models.StoreStaff
	err := r.db.Preload("User").Where("store_id = ?", storeID).Find(&staffMembers).Error
	return staffMembers, err
}

func (r *StoreStaffRepository) IsUserStaffMember(storeID, userID uint) (bool, error) {
	var count int64
	err := r.db.Model(&models.StoreStaff{}).
		Where("store_id = ? AND user_id = ?", storeID, userID).
		Count(&count).Error
	return count > 0, err
}

func (r *StoreStaffRepository) RemoveStaffMember(storeID, userID uint) error {
	return r.db.Where("store_id = ? AND user_id = ?", storeID, userID).
		Delete(&models.StoreStaff{}).Error
}
