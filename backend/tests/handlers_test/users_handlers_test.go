package handlers_test

import (
	"bytes"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/Sebiche09/app-anti-gaspillage.git/api/handlers"
	"github.com/Sebiche09/app-anti-gaspillage.git/api/requests"
	"github.com/gin-gonic/gin"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/mock"
)

// Mock de UserService
type MockUserService struct {
	mock.Mock
}

func (m *MockUserService) Create(req requests.RegisterRequest) error {
	args := m.Called(req)
	return args.Error(0)
}

func TestSignup(t *testing.T) {
	// Configuration de Gin pour les tests
	gin.SetMode(gin.TestMode)
	router := gin.Default()
	userService := new(MockUserService)
	userHandler := handlers.NewUserHandler(userService)

	router.POST("/api/auth/signup", userHandler.Signup)

	// Préparation de la requête JSON
	userJSON := `{"email":"test@example.com","password":"test123", "full_name":"Test User","phone":"1234567890"}`
	req, _ := http.NewRequest("POST", "/api/auth/signup", bytes.NewBufferString(userJSON))
	w := httptest.NewRecorder()

	// Expected behavior from mock
	userService.On("Create", mock.Anything).Return(nil)

	// Exécution de la requête
	router.ServeHTTP(w, req)

	// Assertions
	assert.Equal(t, http.StatusCreated, w.Code)
	userService.AssertExpectations(t)
}

// Autres tests...
