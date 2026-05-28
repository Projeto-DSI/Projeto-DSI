import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_quest.dart';
import '../providers/auth_provider.dart';
import '../services/quest_service.dart';

final userQuestsProvider =
    StateNotifierProvider<UserQuestNotifier, AsyncValue<List<UserQuest>>>(
  (ref) => UserQuestNotifier(ref),
);

class UserQuestNotifier
    extends StateNotifier<AsyncValue<List<UserQuest>>> {
  UserQuestNotifier(this._ref) : super(const AsyncValue.data(<UserQuest>[])) {
    _init();
  }

  final Ref _ref;

  void _init() {
    _ref.listen<User?>(currentUserProvider, (previous, next) {
      if (next == null) {
        state = const AsyncValue.data(<UserQuest>[]);
        return;
      }

      if (previous?.id != next.id) {
        load(next.id);
      }
    }, fireImmediately: true);
  }

  Future<void> load(String userId) async {
    state = const AsyncValue.loading();
    try {
      final quests = await questService.fetchByUser(userId);
      state = AsyncValue.data(quests);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> add(UserQuest quest) async {
    final created = await questService.create(quest);
    state.whenData((list) {
      state = AsyncValue.data([created, ...list]);
    });
  }

  Future<void> edit(UserQuest quest) async {
    await questService.update(quest);
    state.whenData((list) {
      state = AsyncValue.data([
        for (final q in list) q.id == quest.id ? quest : q,
      ]);
    });
  }

  Future<void> remove(String questId) async {
    await questService.delete(questId);
    state.whenData((list) {
      state = AsyncValue.data(list.where((q) => q.id != questId).toList());
    });
  }
}
