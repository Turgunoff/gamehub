class ApiResponse {
  final bool success;
  final String? message;
  final Map<String, dynamic>? data;

  ApiResponse({required this.success, this.message, this.data});

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      success: json['success'] ?? true,
      message: json['message'],
      data: json['data'],
    );
  }

  factory ApiResponse.success([Map<String, dynamic>? data, String? message]) {
    return ApiResponse(success: true, data: data, message: message);
  }

  factory ApiResponse.error(String message) {
    return ApiResponse(success: false, message: message);
  }
}

class AuthResponse {
  final bool success;
  final String? message;
  final bool isNewUser;
  final int? expiresIn;

  AuthResponse({
    required this.success,
    this.message,
    this.isNewUser = false,
    this.expiresIn,
  });

  factory AuthResponse.fromSendOTP(Map<String, dynamic> json) {
    return AuthResponse(
      success: true,
      message: json['message'],
      expiresIn: json['expires_in'] ?? 120,
    );
  }

  factory AuthResponse.fromVerifyOTP(Map<String, dynamic> json) {
    return AuthResponse(success: true, isNewUser: json['is_new_user'] ?? false);
  }

  factory AuthResponse.error(String message) {
    return AuthResponse(success: false, message: message);
  }
}
