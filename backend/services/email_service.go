package services

import (
	"net/smtp"
)

type SMTPEmailService struct {
	SMTPHost string
	SMTPPort string
	Username string
	Password string
	From     string
}

func NewEmailService(host, port, username, password, from string) *SMTPEmailService {
	return &SMTPEmailService{host, port, username, password, from}
}

func (s *SMTPEmailService) SendEmail(to, subject, body string) error {
	headers := "From: " + s.From + "\n" +
		"To: " + to + "\n" +
		"Subject: " + subject + "\n" +
		"MIME-version: 1.0;\n" +
		"Content-Type: text/html; charset=\"UTF-8\";\n\n"

	msg := []byte(headers + body)

	auth := smtp.PlainAuth("", s.Username, s.Password, s.SMTPHost)
	return smtp.SendMail(s.SMTPHost+":"+s.SMTPPort, auth, s.From, []string{to}, msg)
}

// NoopEmailService est une implémentation simple qui ne fait rien
// Utile pour le développement ou les tests
type NoopEmailService struct{}

func NewNoopEmailService() EmailService {
	return &NoopEmailService{}
}

// SendInvitationEmail implémente l'interface EmailService mais ne fait rien
func (s *NoopEmailService) SendInvitationEmail(email, invitationURL string) error {

	return nil
}
