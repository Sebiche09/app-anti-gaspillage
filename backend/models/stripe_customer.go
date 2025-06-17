package models

import (
	"gorm.io/gorm"
)

type StripeCustomer struct {
	gorm.Model
	UserID                uint   `json:"user_id" gorm:"not null;index"`                                     // ID de l'utilisateur associé
	StripeCustomerID      string `json:"stripe_customer_id" gorm:"type:varchar(255);unique;not null"`       // ID du client Stripe
	StripePaymentMethodID string `json:"stripe_payment_method_id" gorm:"type:varchar(255);unique;not null"` // ID du moyen de paiement Stripe

	User User `gorm:"foreignKey:UserID;constraint:OnDelete:CASCADE"` // Relation avec User (clé étrangère)
}
