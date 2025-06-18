package services

import (
	"crypto/rand"
	"encoding/hex"
	"errors"
	"time"

	"github.com/Sebiche09/app-anti-gaspillage.git/models"
	"github.com/Sebiche09/app-anti-gaspillage.git/repositories"
)

type EmailService interface {
	SendInvitationEmail(email, invitationURL string) error
}

type InvitationService struct {
	invitationRepo *repositories.InvitationRepository
	storeRepo      *repositories.StoreRepository
	merchantRepo   *repositories.MerchantRepository
	staffRepo      *repositories.StoreStaffRepository
	emailService   EmailService
}

func NewInvitationService(
	invitationRepo *repositories.InvitationRepository,
	storeRepo *repositories.StoreRepository,
	merchantRepo *repositories.MerchantRepository,
	staffRepo *repositories.StoreStaffRepository,
	emailService EmailService,
) *InvitationService {
	return &InvitationService{
		invitationRepo: invitationRepo,
		storeRepo:      storeRepo,
		merchantRepo:   merchantRepo,
		staffRepo:      staffRepo,
		emailService:   emailService,
	}
}

// generateInviteCode génère un code unique pour l'invitation
func generateInviteCode() string {
	b := make([]byte, 6)
	rand.Read(b)
	return hex.EncodeToString(b)
}

func (s *InvitationService) CreateInvitation(senderID, storeID uint, email string) (*models.Invitation, error) {
	store, err := s.storeRepo.GetStoreByID(storeID)
	if err != nil {
		return nil, err
	}

	merchant, err := s.merchantRepo.FindMerchantByUserID(senderID)
	if err != nil || store.MerchantID != merchant.ID {
		return nil, errors.New("unauthorized: you don't own this store")
	}

	code := generateInviteCode()

	invitation := &models.Invitation{
		StoreID:   storeID,
		SenderID:  senderID,
		Email:     email,
		Code:      code,
		Status:    models.InvitationPending,
		ExpiresAt: time.Now().Add(7 * 24 * time.Hour),
	}

	if err := s.invitationRepo.CreateInvitation(invitation); err != nil {
		return nil, err
	}

	invitationURL := "http://localhost:3000//invitations/accept?code=" + code
	err = s.emailService.SendInvitationEmail(email, invitationURL)
	if err != nil {
	}

	return invitation, nil
}

func (s *InvitationService) AcceptInvitation(code string, userID uint) error {
	invitation, err := s.invitationRepo.GetInvitationByCode(code)
	if err != nil {
		return err
	}

	if invitation.Status != models.InvitationPending {
		return errors.New("invitation is no longer valid")
	}

	if invitation.ExpiresAt.Before(time.Now()) {
		invitation.Status = models.InvitationExpired
		s.invitationRepo.UpdateInvitation(invitation)
		return errors.New("invitation has expired")
	}
	isMember, _ := s.staffRepo.IsUserStaffMember(invitation.StoreID, userID)
	if isMember {
		return errors.New("you are already a staff member of this store")
	}

	staff := &models.StoreStaff{
		StoreID: invitation.StoreID,
		UserID:  userID,
	}

	if err := s.staffRepo.AddStaffMember(staff); err != nil {
		return err
	}

	invitation.Status = models.InvitationAccepted
	return s.invitationRepo.UpdateInvitation(invitation)
}

func (s *InvitationService) GetPendingInvitations(storeID uint, userID uint) ([]models.Invitation, error) {
	merchant, err := s.merchantRepo.FindMerchantByUserID(userID)
	if err != nil {
		return nil, err
	}

	store, err := s.storeRepo.GetStoreByID(storeID)
	if err != nil {
		return nil, err
	}

	if store.MerchantID != merchant.ID {
		return nil, errors.New("unauthorized: you don't have access to this store")
	}

	return s.invitationRepo.GetPendingInvitationsByStore(storeID)
}

func (s *InvitationService) CancelInvitation(invitationID, userID uint) error {
	invitation, err := s.invitationRepo.GetInvitationByID(invitationID)
	if err != nil {
		return err
	}

	if invitation.SenderID != userID {
		return errors.New("only the sender can cancel the invitation")
	}

	invitation.Status = models.InvitationRejected
	return s.invitationRepo.UpdateInvitation(invitation)
}
