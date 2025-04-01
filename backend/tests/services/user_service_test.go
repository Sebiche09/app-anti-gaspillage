package services_test

import (
	"testing"

	"github.com/Sebiche09/app-anti-gaspillage.git/api/requests"
	"github.com/Sebiche09/app-anti-gaspillage.git/models"
	"github.com/Sebiche09/app-anti-gaspillage.git/services"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/mock"
)

// Mock du UserRepository
type MockUserRepository struct {
	mock.Mock
}

func (m *MockUserRepository) Create(user *models.User) error {
	args := m.Called(user)
	return args.Error(0)
}

func (m *MockUserRepository) FindByEmail(email string) (*models.User, error) {
	args := m.Called(email)
	return args.Get(0).(*models.User), args.Error(1)
}

func TestUserService_Create(t *testing.T) {
	userRepo := new(MockUserRepository)
	userService := services.NewUserService(userRepo)

	req := requests.RegisterRequest{
		Email:    "test@example.com",
		Password: "test123",
		FullName: "Test User",
		Phone:    "1234567890",
	}

	userRepo.On("FindByEmail", req.Email).Return(nil, nil) // Pas d'utilisateur existant

	err := userService.Create(req)

	assert.NoError(t, err)
	userRepo.AssertExpectations(t)
}
