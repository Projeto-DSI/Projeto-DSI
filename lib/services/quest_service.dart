import '../models/user_quest.dart';
import 'supabase_service.dart';

class QuestService {
  Future<List<UserQuest>> fetchByUser(String userId) async {
    final data = await supabase
        .from('user_quests')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return (data as List)
        .map((e) => UserQuest.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<UserQuest> create(UserQuest quest) async {
    final data = await supabase
        .from('user_quests')
        .insert(quest.toMap())
        .select()
        .single();
    return UserQuest.fromMap(data);
  }

  Future<void> update(UserQuest quest) async {
    await supabase
        .from('user_quests')
        .update(quest.toMap())
        .eq('id', quest.id);
  }

  Future<void> delete(String questId) async {
    await supabase.from('user_quests').delete().eq('id', questId);
  }
}

final questService = QuestService();
