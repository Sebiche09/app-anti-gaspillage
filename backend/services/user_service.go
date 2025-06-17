package services

import (
	"errors"
	"time"

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

func (s *UserService) Login(email string, password string) (string, string, error) {
	user, err := s.UserRepo.FindByEmail(email)
	if err != nil {
		return "", "", errors.New("invalid credentials")
	}

	if !utils.CheckPasswordHash(password, user.PasswordHash) {
		return "", "", errors.New("invalid credentials")
	}

	if !user.IsEmailConfirmed {
		return "", "", errors.New("email not confirmed")
	}

	isMerchant, err := s.UserRepo.IsMerchant(user.ID)
	if err != nil {
		return "", "", errors.New("failed to check merchant status")
	}

	staffStoreIDs, err := s.UserRepo.GetStaffStoreIDs(user.ID)
	if err != nil {
		return "", "", errors.New("failed to get staff store IDs")
	}

	token, err := utils.GenerateToken(user.Email, user.ID, user.IsAdmin, isMerchant, staffStoreIDs)
	if err != nil {
		return "", "", errors.New("failed to generate token")
	}

	refreshToken, expiredTime, err := utils.GenerateRefreshToken()
	if err != nil {
		return "", "", errors.New("failed to generate refresh token")
	}

	err = s.UserRepo.StoreRefreshToken(user.ID, refreshToken, expiredTime)
	if err != nil {
		return "", "", errors.New("failed to store refresh token")
	}

	return token, refreshToken, nil
}

func (s *UserService) GetUsers() ([]models.User, error) {
	return s.UserRepo.GetUsers()
}

func (s *UserService) RefreshToken(refreshToken string) (string, string, error) {
	user, err := s.UserRepo.FindByRefreshToken(refreshToken)
	if err != nil {
		return "", "", errors.New("invalid refresh token")
	}

	if time.Now().After(user.ExpiryTime) {
		return "", "", errors.New("refresh token expired")
	}

	isMerchant, err := s.UserRepo.IsMerchant(user.ID)
	if err != nil {
		return "", "", errors.New("failed to check merchant status")
	}

	staffStoreIDs, err := s.UserRepo.GetStaffStoreIDs(user.ID)
	if err != nil {
		return "", "", errors.New("failed to get staff store IDs")
	}

	newAccessToken, err := utils.GenerateToken(user.Email, user.ID, user.IsAdmin, isMerchant, staffStoreIDs)
	if err != nil {
		return "", "", errors.New("failed to generate new access token")
	}

	newRefreshToken, newExpiryTime, err := utils.GenerateRefreshToken()
	if err != nil {
		return "", "", errors.New("failed to generate new refresh token")
	}

	err = s.UserRepo.StoreRefreshToken(user.ID, newRefreshToken, newExpiryTime)
	if err != nil {
		return "", "", errors.New("failed to store new refresh token")
	}

	return newAccessToken, newRefreshToken, nil
}
