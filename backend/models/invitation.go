package models

import (
	"time"

	"gorm.io/gorm"
)

type Invitation struct {
	gorm.Model
	StoreID    uint
	Store      Store `gorm:"foreignKey:StoreID;constraint:OnDelete:CASCADE"`
	SenderID   uint
	Sender     User   `gorm:"foreignKey:SenderID"`
	Email      string `gorm:"index"`
	Code       string `gorm:"index"`
	Token      string `gorm:"uniqueIndex"`
	Status     InvitationStatus
	ExpiresAt  time.Time  `gorm:"not null"`
	AcceptedAt *time.Time `gorm:"default:NULL"`
}

type InvitationStatus string

const (
	InvitationPending  InvitationStatus = "PENDING"
	InvitationAccepted InvitationStatus = "ACCEPTED"
	InvitationRejected InvitationStatus = "REJECTED"
	InvitationExpired  InvitationStatus = "EXPIRED"
)
