package models

import (
	"time"

	"gorm.io/gorm"
)

type Notification struct {
	ID        int       `json:"id" gorm:"primaryKey;autoIncrement"` // ID unique avec auto-incrémentation
	UserID    int       `json:"user_id" gorm:"not null"`            // ID du user (non null)
	User      User      `json:"user" gorm:"foreignKey:UserID;references:ID;constraint:OnDelete:CASCADE"`
	Title     string    `json:"title" binding:"required" gorm:"unique;not null"` // Nom requis, unique
	IsRead    bool      `json:"is_read" gorm:"default:false"`                    // Lu avec valeur par défaut
	CreatedAt time.Time `json:"created_at" gorm:"autoCreateTime"`                // Date de création automatique
}

func (n *Notification) Save(db *gorm.DB) error {
	if err := db.Create(n).Error; err != nil {
		return err
	}
	return nil
}

func (n *Notification) Update(db *gorm.DB, updates Notification) error {
	if err := db.Model(n).Updates(updates).Error; err != nil {
		return err
	}
	return nil
}

func GetAllNotifications(db *gorm.DB) ([]Notification, error) {
	var notifications []Notification
	if err := db.Find(&notifications).Error; err != nil {
		return nil, err
	}
	return notifications, nil
}

func GetNotificationById(db *gorm.DB, id int) (*Notification, error) {
	var notification Notification
	if err := db.First(&notification, id).Error; err != nil {
		return nil, err
	}
	return &notification, nil
}
