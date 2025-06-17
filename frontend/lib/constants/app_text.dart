class TextLogin {
  // Textes
  static const String loginTitle = 'Content de te revoir';
  static const String loginSubtitle = 'Connecte-toi à ton compte';
  static const String emailHint = 'Email';
  static const String passwordHint = 'Mot de passe';
  static const String loginButton = 'Se connecter';
  static const String forgotPassword = 'Mot de passe oublié ?';
  static const String registerPrompt = 'Pas encore de compte ?';
  static const String registerLink = 'INSCRIPTION';

  //validation
  static const String RegexEmailPattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
  static const String ValidatorMessageEmailEmpty = 'Veuillez entrer votre email';
  static const String ValidatorMessageEmailInvalid = 'Veuillez entrer un email valide';
  static const String ValidatorMessagePasswordEmpty = 'Veuillez entrer votre mot de passe';
  static const String ValidatorMessagePasswordShort = 'Le mot de passe doit contenir au moins 6 caractères';

  //routes
  static const String registerRoute = '/register';
  static const String homeRoute = '/home';
  static const String validationRoute = '/validation';
  static const String merchantRoute = '/merchant';

  //Erreurs
  static const String loginFailedMessage = 'Échec de la connexion. Veuillez vérifier vos identifiants.';
  static const String confirmEmailCode = 'confirm_email';
  static const String emailNotConfirmedMessage = 'Votre email n\'est pas confirmé. Veuillez vérifier votre boîte de réception pour le lien de confirmation.';
  static const String IncorrectCredentials = 'Identifiants incorrects. Veuillez réessayer.';
}

class AppText {
  static const String appName = 'Sové Manjé';



  static const String registerTitle = 'Rejoins Sové Manjé';
  static const String registerSubtitle = 'Sauve tes plats, Gaspille moins !';

  static const String emailHint = 'Email';
  static const String passwordHint = 'Mot de passe';
  static const String loginButton = 'Se connecter';
  static const String forgotPassword = 'Mot de passe oublié ?';
  static const String registerPrompt = 'Pas encore de compte ?';
  static const String registerLink = 'Inscrivez-vous!';


}
