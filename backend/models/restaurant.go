package models

import (
	"gorm.io/gorm"
)

type Restaurant struct {
	gorm.Model
	MerchantID  uint   `json:"merchant_id" gorm:"not null;index"`            // ID du commerçant (clé étrangère)
	Name        string `json:"name" gorm:"type:varchar(255);not null"`       // Nom du restaurant (obligatoire)
	SIREN       string `json:"siren" gorm:"type:varchar(9);unique;not null"` // SIREN (exactement 9 chiffres, unique)
	Address     string `json:"address" gorm:"type:text;not null"`            // Adresse complète
	City        string `json:"city" gorm:"type:varchar(100);not null"`       // Ville
	PostalCode  string `json:"postal_code" gorm:"type:varchar(10);not null"` // Code postal (limité à 10 caractères pour compatibilité internationale)
	PhoneNumber string `json:"phone_number" gorm:"type:varchar(15)"`         // Numéro de téléphone (optionnel, max 15 caractères)

	// Relation avec le commerçant
	Merchant Merchant `json:"merchant" gorm:"foreignKey:MerchantID;constraint:OnDelete:CASCADE"` // Relation avec Merchant (clé étrangère)
}
