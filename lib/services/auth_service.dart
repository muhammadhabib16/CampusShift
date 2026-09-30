import '../data/auth_repository.dart';

class AuthService {
  final AuthRepository _repository;

  AuthService({
    AuthRepository? repository,
  }) : _repository = repository ?? AuthRepository();

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    return await _repository.login(
      email: email,
      password: password,
    );
  }

  Future<Map<String, dynamic>> register({
    required String fullName,
    required String nim,
    required String email,
    required String password,
  }) async {
    return await _repository.register(
      fullName: fullName,
      nim: nim,
      email: email,
      password: password,
    );
  }

  Future<void> logout() async {
    await _repository.logout();
  }

  Future<List<Map<String, String>>> getUsers() async {
    return await _repository.getUsers();
  }
}