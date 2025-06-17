package models

import (
	"gorm.io/gorm"
)

type Order struct {
	gorm.Model
	BasketID              uint    `json:"basket_id" binding:"required" gorm:"not null"`             // ID du panier associé
	UserID                uint    `json:"user_id" binding:"required" gorm:"not null"`               // ID de l'utilisateur qui a passé la commande
	Code                  string  `json:"code" gorm:"type:varchar(20);unique;not null"`             // Code unique de la commande
	Status                string  `json:"status" gorm:"type:varchar(20);default:'pending'"`         // Statut de la commande (pending, confirmed, delivered, cancelled)
	StripePaymentIntentID string  `json:"stripe_payment_intent_id" gorm:"type:varchar(255);unique"` // ID de l'intention de paiement Stripe
	ReservedAt            *string `json:"reserved_at" gorm:"type:datetime"`                         // Date et heure de la réservation (optionnel)
	ExpiredAt             *string `json:"expired_at" gorm:"type:datetime"`                          // Date et heure d'expiration de la commande (optionnel)

	Basket Basket `json:"basket" gorm:"foreignKey:BasketID;constraint:OnDelete:CASCADE"` // Relation avec Basket (clé étrangère)
	User   User   `json:"user" gorm:"foreignKey:UserID;constraint:OnDelete:CASCADE"`     // Relation avec User (clé étrangère)
}
