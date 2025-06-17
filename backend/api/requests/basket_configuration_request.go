package requests

type CreateBasketConfigurationRequest struct {
	Name               string  `json:"name" binding:"required"`
	Description        string  `json:"description"`
	DiscountPercentage float64 `json:"discount_percentage" binding:"required"`
	Quantity           int     `json:"quantity" binding:"required"`
}
type UpdateBasketConfigurationRequest struct {
	Name               string  `json:"name" binding:"required"`
	Description        string  `json:"description"`
	DiscountPercentage float64 `json:"discount_percentage" binding:"required"`
	Quantity           int     `json:"quantity" binding:"required"`
}
