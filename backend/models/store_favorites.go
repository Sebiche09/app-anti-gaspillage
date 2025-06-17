package models

import "time"

type StoreFavorite struct {
	UserID    uint      `json:"user_id" gorm:"not null;index"`                  // ID de l'utilisateur (clé étrangère)
	StoreID   uint      `json:"store_id" gorm:"not null;index"`                 // ID du restaurant (clé étrangère)
	CreatedAt time.Time `json:"created_at" gorm:"autoCreateTime"`               // Date de création (automatique)
	Store     Store     `gorm:"foreignKey:StoreID;constraint:OnDelete:CASCADE"` // Relation avec Store (clé étrangère)
	User      User      `gorm:"foreignKey:UserID;constraint:OnDelete:CASCADE"`  // Relation avec User (clé étrangère)
}
