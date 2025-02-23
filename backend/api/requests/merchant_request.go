package requests

type CreateMerchantRequestInput struct {
	BusinessName string `json:"business_name" example:"petit bateau" binding:"required"`
	EmailPro     string `json:"email_pro" example:"merchant@example.com" binding:"required,email"`
	SIRET        string `json:"siret" example:"78467169500087" binding:"required,len=14"`
	PhoneNumber  string `json:"phone_number" example:"+32452101010"`
}
