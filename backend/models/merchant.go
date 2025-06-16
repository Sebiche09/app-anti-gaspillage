package models

import (
	"gorm.io/gorm"
)

type Merchant struct {
	gorm.Model
	BusinessName string `json:"business_name" binding:"required" gorm:"type:varchar(255);not null"`    // Nom de l'entreprise
	EmailPro     string `json:"email_pro" binding:"required,email" gorm:"type:varchar(255);not null"`  // Email valide requis
	SIREN        string `json:"siren" binding:"required,len=9" gorm:"type:varchar(9);unique;not null"` // Numéro SIREN
	PhoneNumber  string `json:"phone_number" gorm:"type:varchar(15)"`                                  // Numéro de téléphone (optionnel, max 15 caractères)
	// Relation 1 à 1 vers User
	UserID uint `json:"user_id" gorm:"uniqueIndex;not null"`      // Chaque marchand correspond exactement à un utilisateur
	User   User `json:"user" gorm:"constraint:OnDelete:CASCADE;"` // Relation vers User (clé étrangère avec cascade)
}

type MerchantRequest struct {
	gorm.Model
	BusinessName string `json:"business_name" binding:"required" gorm:"type:varchar(255);not null"`
	EmailPro     string `json:"email_pro" binding:"required,email" gorm:"type:varchar(255);not null"`
	SIREN        string `json:"siren" binding:"required,len=9" gorm:"type:varchar(9);unique;not null"`
	PhoneNumber  string `json:"phone_number" gorm:"type:varchar(15)"`
	Status       string `json:"status" gorm:"type:varchar(20);default:'pending'"` // pending, approved, rejected

	// Relation avec l'utilisateur qui fait la demande
	UserID uint `json:"user_id" gorm:"not null"`
	User   User `json:"user" gorm:"constraint:OnDelete:CASCADE;"`
}
