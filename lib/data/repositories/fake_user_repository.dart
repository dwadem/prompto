import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/user_repository.dart';
import '../sources/in_memory_store.dart';

/// Local anonymous profile over the [InMemoryStore].
///
/// TODO: replace with a real auth-backed implementation (e.g. Firebase/OAuth)
/// that satisfies this same interface; billing wires into [upgradeToPro].
class FakeUserRepository implements UserRepository {
  FakeUserRepository(this._store);

  final InMemoryStore _store;

  @override
  Future<UserProfile> getCurrentUser() async => _store.user;

  @override
  Stream<UserProfile> watchCurrentUser() async* {
    yield _store.user;
    yield* _store.userStream;
  }

  @override
  Future<void> upgradeToPro() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    _store.setUser(_store.user.copyWith(plan: SubscriptionPlan.pro));
  }
}
