package db

import (
	"github.com/Sebiche09/app-anti-gaspillage.git/models"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

func Init() *gorm.DB {
	dbURL := "postgres://user:password@db:5432/anti_gaspillage?sslmode=disable"

	db, err := gorm.Open(postgres.Open(dbURL), &gorm.Config{})

	if err != nil {
		panic("failed to connect database")
	}

	db.AutoMigrate(&models.Basket{})
	db.AutoMigrate(&models.User{})
	db.AutoMigrate(&models.Merchant{}, &models.MerchantRequest{})
	db.AutoMigrate(&models.Notification{})
	return db

}
