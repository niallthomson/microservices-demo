package model

// PaymentIntent exported
type PaymentIntent struct {
	CartID       string `json:"cartId" db:"cart_id"`
	OrderID      string `json:"orderId" db:"order_id"`
	ClientSecret string `json:"clientSecret" db:"client_secret"`
	Status       string `json:"status" db:"status"`
	Currency     string `json:"currency" db:"currency"`
	Amount       int    `json:"amount" db:"amount"`
	Last4        string `json:"last4" db:"last4"`
	ExpiresMonth int    `json:"expiresMonth" db:"expires_month"`
	ExpiresYear  int    `json:"expiresYear" db:"expires_year"`
	// TODO: DateCharged, DateCreated
}
