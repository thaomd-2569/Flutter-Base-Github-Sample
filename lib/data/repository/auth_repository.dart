abstract class AuthRepository {
  Future<void> saveAuthToken(String token);

  Future<String?> getAuthToken();

  Future<void> deleteAuthToken();

  Future<bool> isAuthenticated();

  Future<void> clearAuthData();
}
