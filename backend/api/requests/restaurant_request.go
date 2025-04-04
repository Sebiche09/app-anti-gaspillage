package requests

type CreateRestaurantRequest struct {
	Name        string `json:"name" example:"petit bateau 1" gorm:"type:varchar(255);not null"`  // Nom du restaurant (obligatoire)
	SIREN       string `json:"siren" example:"123456789" gorm:"type:varchar(9);unique;not null"` // SIREN (exactement 9 chiffres, unique)
	Address     string `json:"address" example:"route de baduel 11" gorm:"type:text;not null"`   // Adresse complète
	City        string `json:"city" example:"cayenne" gorm:"type:varchar(100);not null"`         // Ville
	PostalCode  string `json:"postal_code" example:"97300" gorm:"type:varchar(10);not null"`     // Code postal (limité à 10 caractères pour compatibilité internationale)
	PhoneNumber string `json:"phone_number" example:"+32470542125" gorm:"type:varchar(15)"`      // Numéro de téléphone (optionnel, max 15 caractères)
	CategoryID  uint   `json:"category_id" example:"1" gorm:"type:int;not null"`                 // ID de la catégorie (obligatoire)
}

type UpdateRestaurantRequest struct {
	Name        string `json:"name" example:"petit bateau 2" gorm:"type:varchar(255);not null"`  // Nom du restaurant (obligatoire)
	SIREN       string `json:"siren" example:"123456780" gorm:"type:varchar(9);unique;not null"` // SIREN (exactement 9 chiffres, unique)
	Address     string `json:"address" example:"route de baduel 12" gorm:"type:text;not null"`   // Adresse complète
	City        string `json:"city" example:"remire" gorm:"type:varchar(100);not null"`          // Ville
	PostalCode  string `json:"postal_code" example:"97301" gorm:"type:varchar(10);not null"`     // Code postal (limité à 10 caractères pour compatibilité internationale)
	PhoneNumber string `json:"phone_number" example:"+32470542125" gorm:"type:varchar(15)"`      // Numéro de téléphone (optionnel, max 15 caractères)
	CategoryID  uint   `json:"category_id" example:"1" gorm:"type:int;not null"`                 // ID de la catégorie (obligatoire)
}

type InviteStaffRequest struct {
	Email        string `json:"email" example:"" gorm:"type:varchar(255);not null"` // Email de l'utilisateur à inviter
	RestaurantID uint   `json:"restaurant_id" example:"1" gorm:"type:int;not null"` // ID du restaurant
}
