package models

import (
	"gorm.io/gorm"
)

type Store struct {
	gorm.Model
	MerchantID  uint    `json:"merchant_id" gorm:"not null;index"`            // ID du commerçant (clé étrangère)
	Name        string  `json:"name" gorm:"type:varchar(255);not null"`       // Nom du restaurant (obligatoire)
	Latitude    float64 `json:"latitude" gorm:"type:decimal(10,8);not null"`  // Latitude (format décimal)
	Longitude   float64 `json:"longitude" gorm:"type:decimal(11,8);not null"` // Longitude (format décimal)
	Address     string  `json:"address" gorm:"type:text;not null"`            // Adresse complète
	City        string  `json:"city" gorm:"type:varchar(100);not null"`       // Ville
	PostalCode  string  `json:"postal_code" gorm:"type:varchar(10);not null"` // Code postal (limité à 10 caractères pour compatibilité internationale)
	PhoneNumber string  `json:"phone_number" gorm:"type:varchar(15)"`         // Numéro de téléphone (optionnel, max 15 caractères)
	Rating      float64 `json:"rating" gorm:"default:0.00"`                   // Note moyenne (sur 5)
	CategoryID  uint    `json:"category_id" gorm:"not null;index"`            // ID de la catégorie (clé étrangère)

	Merchant Merchant `json:"merchant" gorm:"foreignKey:MerchantID;constraint:OnDelete:CASCADE"` // Relation avec Merchant (clé étrangère)
	Category Category `json:"category" gorm:"foreignKey:CategoryID"`                             // Relation avec Category (clé étrangère)
}
