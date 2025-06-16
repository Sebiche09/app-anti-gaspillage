package services

import (
	"errors"

	"github.com/Sebiche09/app-anti-gaspillage.git/api/requests"
	"github.com/Sebiche09/app-anti-gaspillage.git/models"
	"github.com/Sebiche09/app-anti-gaspillage.git/repositories"
)

type MerchantService struct {
	repo *repositories.MerchantRepository
}

func NewMerchantService(repo *repositories.MerchantRepository) *MerchantService {
	return &MerchantService{repo: repo}
}

// Vérifier le statut de la demande de marchand
func (s *MerchantService) MerchantRequestStatus(userID uint) (*models.MerchantRequest, error) {
	request, err := s.repo.FindMerchantStatusByUserID(userID)
	if err != nil {
		return nil, err
	}
	if request == nil {
		return nil, nil
	}
	return request, nil
}

// Créer une demande de marchand
func (s *MerchantService) CreateMerchantRequest(req requests.CreateMerchantRequest, userID uint) error {
	existingRequest, err := s.repo.FindPendingRequestByUserID(userID)
	if err != nil {
		return err
	}
	if existingRequest != nil {
		return errors.New("une demande est déjà en cours de traitement")
	}

	request := &models.MerchantRequest{
		BusinessName: req.BusinessName,
		EmailPro:     req.EmailPro,
		SIREN:        req.SIREN,
		PhoneNumber:  req.PhoneNumber,
		UserID:       userID,
		Status:       "pending",
	}

	return s.repo.CreateMerchantRequest(request)
}

// Récupérer les demandes en attente
func (s *MerchantService) GetPendingRequests() ([]models.MerchantRequest, error) {
	return s.repo.GetPendingRequests()
}

// Traiter une demande
func (s *MerchantService) ProcessRequest(requestID uint, status string) error {
	request, err := s.repo.FindRequestByID(requestID)
	if err != nil {
		return err
	}

	request.Status = status

	if status == "approved" {
		merchant := &models.Merchant{
			BusinessName: request.BusinessName,
			EmailPro:     request.EmailPro,
			SIREN:        request.SIREN,
			PhoneNumber:  request.PhoneNumber,
			UserID:       request.UserID,
		}

		if err := s.repo.CreateMerchant(merchant); err != nil {
			return err
		}
	}

	return s.repo.UpdateRequest(request)
}

// Récupérer les informations du marchand
func (s *MerchantService) GetMerchants() ([]models.Merchant, error) {
	return s.repo.GetMerchants()
}

// Mettre à jour les informations du marchand
func (s *MerchantService) UpdateMerchant(req requests.UpdateMerchantRequest, userID uint) error {
	merchant, err := s.repo.FindMerchantByUserID(userID)
	if err != nil {
		return err
	}

	merchant.BusinessName = req.BusinessName
	merchant.EmailPro = req.EmailPro
	merchant.SIREN = req.SIREN
	merchant.PhoneNumber = req.PhoneNumber

	return s.repo.UpdateMerchant(merchant)
}

func (s *MerchantService) DeleteMerchant(userID uint) error {
	merchant, err := s.repo.FindMerchantByUserID(userID)
	if err != nil {
		return err
	}

	if merchant == nil {
		return errors.New("le marchand n'existe pas")
	}

	return s.repo.DeleteMerchant(merchant)
}

func (s *MerchantService) GetMerchant(userID uint) (*models.Merchant, error) {
	return s.repo.FindMerchantByUserID(userID)
}
