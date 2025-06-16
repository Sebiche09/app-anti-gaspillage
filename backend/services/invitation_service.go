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
	restaurantRepo *repositories.RestaurantRepository
	merchantRepo   *repositories.MerchantRepository
	staffRepo      *repositories.RestaurantStaffRepository
	emailService   EmailService
}

func NewInvitationService(
	invitationRepo *repositories.InvitationRepository,
	restaurantRepo *repositories.RestaurantRepository,
	merchantRepo *repositories.MerchantRepository,
	staffRepo *repositories.RestaurantStaffRepository,
	emailService EmailService,
) *InvitationService {
	return &InvitationService{
		invitationRepo: invitationRepo,
		restaurantRepo: restaurantRepo,
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

func (s *InvitationService) CreateInvitation(senderID, restaurantID uint, email string) (*models.Invitation, error) {
	// Vérifier si le sender est autorisé pour ce restaurant
	restaurant, err := s.restaurantRepo.GetRestaurantByID(restaurantID)
	if err != nil {
		return nil, err
	}

	merchant, err := s.merchantRepo.FindMerchantByUserID(senderID)
	if err != nil || restaurant.MerchantID != merchant.ID {
		return nil, errors.New("unauthorized: you don't own this restaurant")
	}

	// Générer le code unique
	code := generateInviteCode()

	// Créer l'invitation
	invitation := &models.Invitation{
		RestaurantID: restaurantID,
		SenderID:     senderID,
		Email:        email,
		Code:         code,
		Status:       models.InvitationPending,
		ExpiresAt:    time.Now().Add(7 * 24 * time.Hour), // 7 jours
	}

	if err := s.invitationRepo.CreateInvitation(invitation); err != nil {
		return nil, err
	}

	// Envoyer un email avec le code d'invitation
	invitationURL := "http://localhost:3000//invitations/accept?code=" + code
	err = s.emailService.SendInvitationEmail(email, invitationURL)
	if err != nil {
		// Loggez l'erreur mais ne faites pas échouer l'opération
		// si l'envoi d'email échoue
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

	// Vérifier que l'utilisateur n'est pas déjà membre du staff
	isMember, _ := s.staffRepo.IsUserStaffMember(invitation.RestaurantID, userID)
	if isMember {
		return errors.New("you are already a staff member of this restaurant")
	}

	// Ajouter l'utilisateur au staff
	staff := &models.RestaurantStaff{
		RestaurantID: invitation.RestaurantID,
		UserID:       userID,
	}

	if err := s.staffRepo.AddStaffMember(staff); err != nil {
		return err
	}

	// Mettre à jour le statut de l'invitation
	invitation.Status = models.InvitationAccepted
	return s.invitationRepo.UpdateInvitation(invitation)
}

func (s *InvitationService) GetPendingInvitations(restaurantID uint, userID uint) ([]models.Invitation, error) {
	// Vérifier que l'utilisateur est autorisé à voir les invitations de ce restaurant
	merchant, err := s.merchantRepo.FindMerchantByUserID(userID)
	if err != nil {
		return nil, err
	}

	restaurant, err := s.restaurantRepo.GetRestaurantByID(restaurantID)
	if err != nil {
		return nil, err
	}

	if restaurant.MerchantID != merchant.ID {
		return nil, errors.New("unauthorized: you don't have access to this restaurant")
	}

	return s.invitationRepo.GetPendingInvitationsByRestaurant(restaurantID)
}

func (s *InvitationService) CancelInvitation(invitationID, userID uint) error {
	invitation, err := s.invitationRepo.GetInvitationByID(invitationID)
	if err != nil {
		return err
	}

	// Vérifier que c'est bien le sender qui annule
	if invitation.SenderID != userID {
		return errors.New("only the sender can cancel the invitation")
	}

	invitation.Status = models.InvitationRejected
	return s.invitationRepo.UpdateInvitation(invitation)
}
