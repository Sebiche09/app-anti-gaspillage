package services

import (
	"errors"

	"github.com/Sebiche09/app-anti-gaspillage.git/api/requests"
	"github.com/Sebiche09/app-anti-gaspillage.git/models"
	"github.com/Sebiche09/app-anti-gaspillage.git/repositories"
	"github.com/Sebiche09/app-anti-gaspillage.git/utils"
	"gorm.io/gorm"
)

type UserService struct {
	UserRepo *repositories.UserRepository
}

func NewUserService(userRepo *repositories.UserRepository) *UserService {
	return &UserService{UserRepo: userRepo}
}

func (s *UserService) Create(req requests.RegisterRequest) (*models.User, error) {
	_, err := s.UserRepo.FindByEmail(req.Email)

	if err == nil {
		return nil, errors.New("user already exists")
	}

	if !errors.Is(err, gorm.ErrRecordNotFound) {
		return nil, errors.New("failed to check existing user")
	}

	hashedPassword, err := utils.HashPassword(req.Password)
	if err != nil {
		return nil, errors.New("failed to hash password")
	}

	code := utils.GenerateValidationCode()

	user := &models.User{
		Email:            req.Email,
		PasswordHash:     hashedPassword,
		ValidationCode:   code,
		IsEmailConfirmed: false,
	}

	if err := s.UserRepo.Create(user); err != nil {
		return nil, errors.New("failed to create user")
	}

	return user, nil
}

func (s *UserService) GetByEmail(email string) (*models.User, error) {
	return s.UserRepo.FindByEmail(email)
}

func (s *UserService) Save(user *models.User) error {
	return s.UserRepo.Update(user)
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

	// Vérifier si l'email est confirmé
	if !user.IsEmailConfirmed {
		return "", errors.New("email not confirmed")
	}

	// Vérifier si l'utilisateur est marchand
	isMerchant, err := s.UserRepo.IsMerchant(user.ID)
	if err != nil {
		return "", errors.New("failed to check merchant status")
	}

	// Récupérer les restaurants où il est staff
	staffRestaurantIDs, err := s.UserRepo.GetStaffRestaurantIDs(user.ID)
	if err != nil {
		return "", errors.New("failed to get staff restaurant IDs")
	}

	// Générer un token JWT
	token, err := utils.GenerateToken(user.Email, user.ID, user.IsAdmin, isMerchant, staffRestaurantIDs)
	if err != nil {
		return "", errors.New("failed to generate token")
	}

	return token, nil
}

func (s *UserService) GetUsers() ([]models.User, error) {
	return s.UserRepo.GetUsers()
}
