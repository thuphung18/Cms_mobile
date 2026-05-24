class AuthenticatedResult {
  final String? token;
  final String? refreshToken;

  AuthenticatedResult({this.token, this.refreshToken});

  factory AuthenticatedResult.fromJson(Map<String, dynamic> json) {
    return AuthenticatedResult(
      token: json['token'],
      refreshToken: json['refreshToken'],
    );
  }
}