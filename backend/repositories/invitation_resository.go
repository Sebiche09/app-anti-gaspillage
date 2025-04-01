// repositories/invitation_repository.go
package repositories

import (
	"github.com/Sebiche09/app-anti-gaspillage.git/models"
	"gorm.io/gorm"
)

type InvitationRepository struct {
	db *gorm.DB
}

func NewInvitationRepository(db *gorm.DB) *InvitationRepository {
	return &InvitationRepository{db: db}
}

func (r *InvitationRepository) CreateInvitation(invitation *models.Invitation) error {
	return r.db.Create(invitation).Error
}

func (r *InvitationRepository) GetInvitationByCode(code string) (*models.Invitation, error) {
	var invitation models.Invitation
	err := r.db.Where("code = ?", code).First(&invitation).Error
	if err != nil {
		return nil, err
	}
	return &invitation, nil
}

func (r *InvitationRepository) GetInvitationByID(id uint) (*models.Invitation, error) {
	var invitation models.Invitation
	err := r.db.Where("id = ?", id).First(&invitation).Error
	if err != nil {
		return nil, err
	}
	return &invitation, nil
}

func (r *InvitationRepository) GetPendingInvitationsByRestaurant(restaurantID uint) ([]models.Invitation, error) {
	var invitations []models.Invitation
	err := r.db.Where("restaurant_id = ? AND status = ?", restaurantID, models.InvitationPending).Find(&invitations).Error
	return invitations, err
}

func (r *InvitationRepository) UpdateInvitation(invitation *models.Invitation) error {
	return r.db.Save(invitation).Error
}

func (r *InvitationRepository) DeleteInvitation(id uint) error {
	return r.db.Delete(&models.Invitation{}, id).Error
}
