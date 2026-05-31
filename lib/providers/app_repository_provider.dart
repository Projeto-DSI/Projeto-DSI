import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../repositories/app_repository.dart';

final appRepositoryProvider = Provider<AppRepository>((ref) {
  return AppRepository();
});

final appDataLoaderProvider = StreamProvider<User?>((ref) async* {
  final repo = ref.read(appRepositoryProvider);

  await for (final user in FirebaseAuth.instance.authStateChanges()) {
    if (user != null) {
      await repo.loadAll();
    } else {
      repo.clear();
    }
    yield user;
  }
});