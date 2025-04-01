package repositories_test

import (
	"testing"

	"github.com/Sebiche09/app-anti-gaspillage.git/models"
	"github.com/Sebiche09/app-anti-gaspillage.git/repositories"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
)

func SetupTestDB() (*gorm.DB, func()) {
	// Crée une base de données SQLite en mémoire
	db, err := gorm.Open(sqlite.Open(":memory:"), &gorm.Config{})
	if err != nil {
		panic("failed to connect database")
	}

	// Migrer le modèle User et Merchant
	db.AutoMigrate(&models.User{}, &models.Merchant{})

	// Fonction de nettoyage
	cleanup := func() {
		db.Exec("DELETE FROM users")     // Effacer les utilisateurs
		db.Exec("DELETE FROM merchants") // Effacer les commerçants
	}

	return db, cleanup
}

func TestUserRepository_Create(t *testing.T) {
	db, cleanup := SetupTestDB()
	defer cleanup()

	userRepo := repositories.NewUserRepository(db)

	user := &models.User{
		Email:        "test@example.com",
		PasswordHash: "password123",
		FullName:     "Test User",
		Phone:        "1234567890",
	}

	err := userRepo.Create(user)
	if err != nil {
		t.Fatalf("Expected no error, got %v", err)
	}
}

func TestUserRepository_FindByEmail(t *testing.T) {
	db, cleanup := SetupTestDB()
	defer cleanup()

	userRepo := repositories.NewUserRepository(db)

	user := &models.User{
		Email:        "test@example.com",
		PasswordHash: "password123",
		FullName:     "Test User",
		Phone:        "1234567890",
	}

	// Créer l'utilisateur dans la base de données
	userRepo.Create(user)

	// Trouver l'utilisateur par email
	foundUser, err := userRepo.FindByEmail(user.Email)
	if err != nil {
		t.Fatalf("Expected no error, got %v", err)
	}

	if foundUser.Email != user.Email {
		t.Errorf("Expected email %s, got %s", user.Email, foundUser.Email)
	}
}

func TestUserRepository_IsMerchant(t *testing.T) {
	db, cleanup := SetupTestDB()
	defer cleanup()

	userRepo := repositories.NewUserRepository(db)

	user := &models.User{
		Email:        "merchant@example.com",
		PasswordHash: "password123",
		FullName:     "Merchant User",
		Phone:        "0987654321",
	}

	// Créer l'utilisateur
	err := userRepo.Create(user)
	if err != nil {
		t.Fatalf("Expected no error, got %v", err)
	}

	// Simuler l'ajout d'un commerçant
	merchant := models.Merchant{UserID: user.ID}
	db.Create(&merchant)

	// Vérifier si l'utilisateur est un commerçant
	isMerchant, err := userRepo.IsMerchant(user.ID)
	if err != nil {
		t.Fatalf("Expected no error, got %v", err)
	}

	// Vérifier le fait que l'utilisateur soit un commerçant
	if !isMerchant {
		t.Errorf("Expected user to be a merchant")
	}
}

func TestUserRepository_GetUsers(t *testing.T) {
	db, cleanup := SetupTestDB()
	defer cleanup()

	userRepo := repositories.NewUserRepository(db)

	// Créer plusieurs utilisateurs
	users := []*models.User{
		{Email: "user1@example.com", PasswordHash: "password123", FullName: "User One", Phone: "1234567890"},
		{Email: "user2@example.com", PasswordHash: "password123", FullName: "User Two", Phone: "0987654321"},
	}

	for _, user := range users {
		err := userRepo.Create(user)
		if err != nil {
			t.Fatalf("Expected no error, got %v", err)
		}
	}

	// Récupérer les utilisateurs
	retrievedUsers, err := userRepo.GetUsers()
	if err != nil {
		t.Fatalf("Expected no error, got %v", err)
	}

	// Vérifier que tous les utilisateurs sont récupérés
	if len(retrievedUsers) != len(users) {
		t.Fatalf("Expected %d users, got %d", len(users), len(retrievedUsers))
	}
}
