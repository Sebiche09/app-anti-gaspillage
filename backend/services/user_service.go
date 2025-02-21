package services

import (
	"errors"

	"github.com/Sebiche09/app-anti-gaspillage.git/api/requests"
	"github.com/Sebiche09/app-anti-gaspillage.git/models"
	"github.com/Sebiche09/app-anti-gaspillage.git/repositories"
	"github.com/Sebiche09/app-anti-gaspillage.git/utils"
)

type UserService struct {
	UserRepo *repositories.UserRepository
}

func NewUserService(userRepo *repositories.UserRepository) *UserService {
	return &UserService{UserRepo: userRepo}
}

func (s *UserService) Create(req requests.RegisterRequest) error {
	if _, err := s.UserRepo.FindByEmail(req.Email); err == nil {
		return errors.New("user already exists")
	}

	// Hashage du mot de passe de l'utilisateur
	hashedPassword, err := utils.HashPassword(req.Password)
	if err != nil {
		return errors.New("failed to hash password")
	}

	// Créer une instance utilisateur avec les données fournies
	user := &models.User{
		Email:        req.Email,
		PasswordHash: hashedPassword,
		FullName:     req.FullName,
		Phone:        req.Phone,
	}

	// Sauvegarder l'utilisateur dans la base de données
	return s.UserRepo.Create(user)
}

func (s *UserService) Login(email string, password string) (string, error) {
	// Vérifier si l'utilisateur existe
	user, err := s.UserRepo.FindByEmail(email)
	if err != nil {
		return "", errors.New("invalid credentials")
	}

	// Vérifier si le mot de passe est correct
	if !utils.CheckPasswordHash(password, user.PasswordHash) {
		return "", errors.New("invalid credentials")
	}

	// Vérifier si l'utilisateur est marchand
	isMerchant, err := s.UserRepo.IsMerchant(user.ID)
	if err != nil {
		return "", errors.New("failed to check merchant status")
	}

	// Générer un token pour l'utilisateur
	token, err := utils.GenerateToken(user.Email, user.ID, user.IsAdmin, isMerchant)
	if err != nil {
		return "", errors.New("failed to generate token")
	}

	return token, nil
}
