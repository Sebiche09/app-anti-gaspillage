class MapboxConfig {
  static const String accessToken = "pk.eyJ1Ijoic2ViaWNoZTA5IiwiYSI6ImNtOTJxemFpazBlNjkybXB3ampobHl4ZGoifQ.qQWvlmHJ731fIGTgpipoUQ";
  
  // Vérifiez si le token est disponible
  static bool get isAccessTokenValid => 
      accessToken.isNotEmpty && accessToken != "null";
}
