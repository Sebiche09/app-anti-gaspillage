package services

// NoopEmailService est une implémentation simple qui ne fait rien
// Utile pour le développement ou les tests
type NoopEmailService struct{}

// NewNoopEmailService crée une nouvelle instance de NoopEmailService
func NewNoopEmailService() EmailService {
	return &NoopEmailService{}
}

// SendInvitationEmail implémente l'interface EmailService mais ne fait rien
// Vous pourriez ajouter un log ici pour le développement
func (s *NoopEmailService) SendInvitationEmail(email, invitationURL string) error {
	// Ne fait rien, juste pour satisfaire l'interface
	// En production, vous remplaceriez cela par une vraie implémentation
	return nil
}
