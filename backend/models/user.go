package models

import (
	"gorm.io/gorm"
)

type User struct {
	gorm.Model
	Email            string `json:"email" binding:"required,email" gorm:"unique;not null"` // Validation d'email
	PasswordHash     string `json:"password_hash" binding:"required" gorm:"not null"`      // Hash du mot de passe
	IsAdmin          bool   `json:"is_admin" gorm:"default:false"`                         // Est-ce un administrateur ?
	ValidationCode   string `gorm:"size:6"`                                                // Code de validation pour l'inscription
	IsEmailConfirmed bool   `gorm:"default:false"`                                         // L'email a-t-il été confirmé ?
}
