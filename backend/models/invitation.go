package models

import (
	"time"

	"gorm.io/gorm"
)

type Invitation struct {
	gorm.Model
	RestaurantID uint
	Restaurant   Restaurant `gorm:"foreignKey:RestaurantID"`
	SenderID     uint
	Sender       User   `gorm:"foreignKey:SenderID"`
	Email        string `gorm:"index"`
	Code         string `gorm:"index"`
	Token        string `gorm:"uniqueIndex"`
	Status       InvitationStatus
	Role         string
	ExpiresAt    time.Time
}
type InvitationStatus string

const (
	InvitationPending  InvitationStatus = "PENDING"
	InvitationAccepted InvitationStatus = "ACCEPTED"
	InvitationRejected InvitationStatus = "REJECTED"
	InvitationExpired  InvitationStatus = "EXPIRED"
)
