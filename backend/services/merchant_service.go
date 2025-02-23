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

func (s *MerchantService) CreateMerchantRequest(req requests.CreateMerchantRequestInput, userID uint) error {
	// Vérifier si une demande est déjà en cours
	existingRequest, err := s.repo.FindPendingRequestByUserID(userID)
	if err != nil {
		return err
	}
	if existingRequest != nil {
		return errors.New("une demande est déjà en cours de traitement")
	}

	// Créer la nouvelle demande
	request := &models.MerchantRequest{
		BusinessName: req.BusinessName,
		EmailPro:     req.EmailPro,
		SIRET:        req.SIRET,
		PhoneNumber:  req.PhoneNumber,
		UserID:       userID,
		Status:       "pending",
	}

	return s.repo.CreateMerchantRequest(request)
}

func (s *MerchantService) GetPendingRequests() ([]models.MerchantRequest, error) {
	return s.repo.GetPendingRequests()
}

func (s *MerchantService) ProcessRequest(requestID uint, status string) error {
	request, err := s.repo.FindRequestByID(requestID)
	if err != nil {
		return err
	}

	request.Status = status

	// Si la demande est approuvée, créer le compte marchand
	if status == "approved" {
		merchant := &models.Merchant{
			BusinessName: request.BusinessName,
			EmailPro:     request.EmailPro,
			SIRET:        request.SIRET,
			PhoneNumber:  request.PhoneNumber,
			UserID:       request.UserID,
		}

		if err := s.repo.CreateMerchant(merchant); err != nil {
			return err
		}
	}

	return s.repo.UpdateRequest(request)
}
