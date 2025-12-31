
import 'package:app/data/repository/auth_repository.dart';
import 'package:app/foundation/keys.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._secureStorage);

  final FlutterSecureStorage _secureStorage;

  @override
  Future<void> saveAuthToken(String token) async {
    await _secureStorage.write(key: Keys.authToken, value: token);
  }

  @override
  Future<String?> getAuthToken() async {
    return _secureStorage.read(key: Keys.authToken);
  }

  @override
  Future<void> deleteAuthToken() async {
    await _secureStorage.delete(key: Keys.authToken);
  }

  @override
  Future<bool> isAuthenticated() async {
    final token = await getAuthToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<void> clearAuthData() async {
    await deleteAuthToken();
  }

}
