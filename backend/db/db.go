package db

import (
	"github.com/Sebiche09/app-anti-gaspillage.git/models"
	"github.com/Sebiche09/app-anti-gaspillage.git/utils"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

func Init() *gorm.DB {
	dbURL := utils.GetEnv("DATABASE_URL")
	db, err := gorm.Open(postgres.Open(dbURL), &gorm.Config{})

	if err != nil {
		panic("failed to connect database")
	}

	// Auto-migrations
	db.AutoMigrate(
		&models.Basket{},
		&models.User{},
		&models.Merchant{},
		&models.MerchantRequest{},
		&models.Notification{},
		&models.Restaurant{},
		&models.RestaurantStaff{},
		&models.Invitation{},
		&models.Category{},
	)
	initDefaultCategories(db)
	return db

}

func initDefaultCategories(db *gorm.DB) {
	defaultCategories := []models.Category{
		{Name: "Boulangerie"},
		{Name: "Epicerie"},
		{Name: "Sushi"},
		{Name: "Végétarien"},
	}

	for _, category := range defaultCategories {
		var existingCategory models.Category
		result := db.Where("name = ?", category.Name).First(&existingCategory)

		if result.RowsAffected == 0 {
			db.Create(&category)
		}
	}
}
