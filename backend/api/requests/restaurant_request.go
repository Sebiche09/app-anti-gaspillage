package requests

type CreateRestaurantRequest struct {
	Name        string `json:"name" example:"petit bateau 1" gorm:"type:varchar(255);not null"` // Nom du restaurant (obligatoire)
	Address     string `json:"address" example:"route de baduel 11" gorm:"type:text;not null"`  // Adresse complète
	City        string `json:"city" example:"cayenne" gorm:"type:varchar(100);not null"`        // Ville
	PostalCode  string `json:"postal_code" example:"97300" gorm:"type:varchar(10);not null"`    // Code postal (limité à 10 caractères pour compatibilité internationale)
	PhoneNumber string `json:"phone_number" example:"+32470542125" gorm:"type:varchar(15)"`     // Numéro de téléphone (optionnel, max 15 caractères)
	CategoryID  uint   `json:"category_id" example:"1" gorm:"type:int;not null"`                // ID de la catégorie (obligatoire)
}

type UpdateRestaurantRequest struct {
	Name        string `json:"name" example:"petit bateau 2" gorm:"type:varchar(255);not null"` // Nom du restaurant (obligatoire)
	Address     string `json:"address" example:"route de baduel 12" gorm:"type:text;not null"`  // Adresse complète
	City        string `json:"city" example:"remire" gorm:"type:varchar(100);not null"`         // Ville
	PostalCode  string `json:"postal_code" example:"97301" gorm:"type:varchar(10);not null"`    // Code postal (limité à 10 caractères pour compatibilité internationale)
	PhoneNumber string `json:"phone_number" example:"+32470542125" gorm:"type:varchar(15)"`     // Numéro de téléphone (optionnel, max 15 caractères)
	CategoryID  uint   `json:"category_id" example:"1" gorm:"type:int;not null"`                // ID de la catégorie (obligatoire)
}

type InviteStaffRequest struct {
	Email        string `json:"email" example:"" gorm:"type:varchar(255);not null"` // Email de l'utilisateur à inviter
	RestaurantID uint   `json:"restaurant_id" example:"1" gorm:"type:int;not null"` // ID du restaurant
}

type BasketConfigurationRequest struct {
	Price               float64                    `json:"price" example:"9.99" binding:"required,gt=0"`      // Prix du panier (obligatoire, doit être supérieur à 0)
	VideoURL            string                     `json:"video_url" example:"https://example.com/video.mp4"` // URL facultative d'une vidéo de présentation
	DailyAvailabilities []DailyAvailabilityRequest `json:"daily_availabilities" binding:"required,dive"`      // Configuration des disponibilités par jour (obligatoire)
}

type DailyAvailabilityRequest struct {
	DayOfWeek       int `json:"day_of_week" example:"2" binding:"required,min=1,max=7"` // Jour de la semaine (1=Lundi, 7=Dimanche)
	NumberOfBaskets int `json:"number_of_baskets" example:"5" binding:"required,min=0"` // Nombre de paniers disponibles ce jour
}
