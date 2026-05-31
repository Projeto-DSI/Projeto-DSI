import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
 
import '../models/favorite_city.dart';
import '../models/quest_progress.dart';
import '../models/user_profile.dart';
import '../models/user_quest.dart';
 
class AppRepository {
  final _db = FirebaseFirestore.instance;
 
  // ── Estado em memória ─────────────────────────────────────────────────────
  UserProfile? _profile;
  QuestProgress? _questProgress;
  List<FavoriteCity> _favoriteCities = [];
  List<UserQuest> _userQuests = [];
 
  // ── Getters ───────────────────────────────────────────────────────────────
  UserProfile? get profile => _profile;
  QuestProgress? get questProgress => _questProgress;
  List<FavoriteCity> get favoriteCities => List.unmodifiable(_favoriteCities);
  List<UserQuest> get userQuests => List.unmodifiable(_userQuests);
 
  String get _uid => FirebaseAuth.instance.currentUser!.uid;
 
  // ── Carregamento inicial ──────────────────────────────────────────────────
 
  Future<void> loadAll() async {
    await Future.wait([
      _loadProfile(),
      _loadQuestProgress(),
      _loadFavoriteCities(),
      _loadUserQuests(),
    ]);
  }
 
  void clear() {
    _profile = null;
    _questProgress = null;
    _favoriteCities = [];
    _userQuests = [];
  }
 
  // ── Perfil ────────────────────────────────────────────────────────────────
 
  Future<void> _loadProfile() async {
    final doc = await _db.collection('user_profiles').doc(_uid).get();
    _profile = doc.exists
        ? UserProfile.fromMap(_uid, doc.data()!)
        : UserProfile(
            uid: _uid,
            displayName: '',
            email: FirebaseAuth.instance.currentUser?.email ?? '',
          );
  }
 
  Future<void> updateDisplayName(String name) async {
    await _db.collection('user_profiles').doc(_uid).set(
          {'display_name': name, 'email': _profile?.email ?? ''},
          SetOptions(merge: true),
        );
    _profile = _profile?.copyWith(displayName: name) ??
        UserProfile(uid: _uid, displayName: name, email: '');
  }
 
  // ── Quest Progress ────────────────────────────────────────────────────────
 
  Future<void> _loadQuestProgress() async {
    final doc = await _db.collection('quest_progress').doc(_uid).get();
    _questProgress = doc.exists
        ? QuestProgress.fromMap(_uid, doc.data()!)
        : QuestProgress.empty(_uid);
  }
 
  Future<void> completeQuest(String questId) async {
    await _db.collection('quest_progress').doc(_uid).set({
      'completed': FieldValue.arrayUnion([questId]),
      'last_updated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    _questProgress = _questProgress?.withCompleted(questId) ??
        QuestProgress(uid: _uid, completedIds: [questId]);
  }
 
  bool isQuestCompleted(String questId) =>
      _questProgress?.isCompleted(questId) ?? false;
 
  // ── Cidades Favoritas ─────────────────────────────────────────────────────
 
  Future<void> _loadFavoriteCities() async {
    final snap = await _db
        .collection('favorite_cities')
        .where('uid', isEqualTo: _uid)
        .orderBy('created_at', descending: true)
        .get();
    _favoriteCities = snap.docs
        .map((d) => FavoriteCity.fromMap(d.id, d.data()))
        .toList();
  }
 
  Future<void> addFavoriteCity({
    required String cityName,
    required String district,
  }) async {
    // Evita duplicatas em memória sem ir ao banco
    final alreadyExists = _favoriteCities.any(
      (c) =>
          c.cityName.toLowerCase() == cityName.toLowerCase() &&
          c.district.toLowerCase() == district.toLowerCase(),
    );
    if (alreadyExists) return;
 
    final ref = await _db.collection('favorite_cities').add({
      'uid': _uid,
      'city_name': cityName,
      'district': district,
      'created_at': FieldValue.serverTimestamp(),
    });
 
    _favoriteCities = [
      FavoriteCity(
        id: ref.id,
        cityName: cityName,
        district: district,
        createdAt: DateTime.now(),
      ),
      ..._favoriteCities,
    ];
  }
 
  Future<void> removeFavoriteCity(String id) async {
    await _db.collection('favorite_cities').doc(id).delete();
    _favoriteCities = _favoriteCities.where((c) => c.id != id).toList();
  }
 
  bool isFavorited(String cityName, String district) => _favoriteCities.any(
        (c) =>
            c.cityName.toLowerCase() == cityName.toLowerCase() &&
            c.district.toLowerCase() == district.toLowerCase(),
      );
 
  /// Busca em memória por cidade ou distrito — sem ir ao banco.
  List<FavoriteCity> searchFavorites(String query) {
    if (query.isEmpty) return favoriteCities;
    return _favoriteCities.where((c) => c.matchesQuery(query)).toList();
  }
 
  // ── User Quests ───────────────────────────────────────────────────────────
 
  Future<void> _loadUserQuests() async {
    final snap = await _db
        .collection('user_quests')
        .where('user_id', isEqualTo: _uid)
        .orderBy('created_at', descending: true)
        .get();
    _userQuests = snap.docs
        .map((d) => UserQuest.fromMap({...d.data(), 'id': d.id}))
        .toList();
  }
 
  Future<void> addUserQuest(UserQuest quest) async {
    final ref = await _db.collection('user_quests').add({
      ...quest.toMap(),
      'user_id': _uid,
      'created_at': FieldValue.serverTimestamp(),
    });
    final doc = await ref.get();
    final created = UserQuest.fromMap({...doc.data()!, 'id': doc.id});
    _userQuests = [created, ..._userQuests];
  }
 
  Future<void> updateUserQuest(UserQuest quest) async {
    await _db.collection('user_quests').doc(quest.id).update(quest.toMap());
    _userQuests = [
      for (final q in _userQuests) q.id == quest.id ? quest : q,
    ];
  }
 
  Future<void> deleteUserQuest(String questId) async {
    await _db.collection('user_quests').doc(questId).delete();
    _userQuests = _userQuests.where((q) => q.id != questId).toList();
  }
 
  List<UserQuest> searchQuestsByTitle(String query) {
    final lower = query.toLowerCase();
    return _userQuests.where((q) => q.title.toLowerCase().contains(lower)).toList();
  }
}