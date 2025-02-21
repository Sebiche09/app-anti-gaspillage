package models

import (
	"gorm.io/gorm"
)

type User struct {
	gorm.Model
	Email        string `json:"email" binding:"required,email" gorm:"unique;not null"` // Validation d'email
	PasswordHash string `json:"password_hash" binding:"required" gorm:"not null"`      // Hash du mot de passe
	FullName     string `json:"full_name" binding:"required" gorm:"not null"`          // Nom complet requis
	Phone        string `json:"phone" binding:"required"  gorm:"not null"`             // Téléphone requis
	IsAdmin      bool   `json:"is_admin" gorm:"default:false"`                         // Est-ce un administrateur ?
}
