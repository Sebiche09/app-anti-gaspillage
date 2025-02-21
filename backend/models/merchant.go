package models

import (
	"gorm.io/gorm"
)

type Merchant struct {
	gorm.Model
	BusinessName     string `json:"business_name" binding:"required" gorm:"type:varchar(255);not null"`      // Nom de l'entreprise
	EmailPro         string `json:"email_pro" binding:"required,email" gorm:"type:varchar(255);not null"`    // Email valide requis
	SIRET            string `json:"siret" binding:"required,len=14" gorm:"type:varchar(14);unique;not null"` // Numéro SIRET
	KbisFile         []byte `json:"kbis_file,omitempty" gorm:"type:bytea"`                                   // Optionnel : fichier KBIS
	IdentityCardFile []byte `json:"identity_card_file,omitempty" gorm:"type:bytea"`                          // Optionnel : fichier Carte d'identité
	PhoneNumber      string `json:"phone_number" gorm:"type:varchar(15)"`                                    // Numéro de téléphone (optionnel, max 15 caractères)
	// Relation 1 à 1 vers User
	UserID uint `json:"user_id" gorm:"uniqueIndex;not null"`      // Chaque marchand correspond exactement à un utilisateur
	User   User `json:"user" gorm:"constraint:OnDelete:CASCADE;"` // Relation vers User (clé étrangère avec cascade)
}

type MerchantRequest struct {
	gorm.Model
	BusinessName     string `json:"business_name" binding:"required" gorm:"type:varchar(255);not null"`
	EmailPro         string `json:"email_pro" binding:"required,email" gorm:"type:varchar(255);not null"`
	SIRET            string `json:"siret" binding:"required,len=14" gorm:"type:varchar(14);unique;not null"`
	KbisFile         []byte `json:"kbis_file,omitempty" gorm:"type:bytea"`
	IdentityCardFile []byte `json:"identity_card_file,omitempty" gorm:"type:bytea"`
	PhoneNumber      string `json:"phone_number" gorm:"type:varchar(15)"`
	Status           string `json:"status" gorm:"type:varchar(20);default:'pending'"` // pending, approved, rejected

	// Relation avec l'utilisateur qui fait la demande
	UserID uint `json:"user_id" gorm:"not null"`
	User   User `json:"user" gorm:"constraint:OnDelete:CASCADE;"`
}
