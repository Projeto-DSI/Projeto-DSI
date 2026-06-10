import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../models/favorite_city.dart';
import '../models/itinerary.dart';
import '../providers/auth_provider.dart';
import '../providers/city_provider.dart';
import '../providers/firestore_provider.dart';
import '../providers/itinerary_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_text_field.dart';
 
class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});
 
  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}
 
class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _nameController = TextEditingController();
  bool _editing = false;
  bool _saving = false;
  bool _loaded = false;
 
  List<FavoriteCity> _favCities = [];
  int _questCount = 0;
  int _totalXp = 0;
 
  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
 
  Future<void> _load(String userId) async {
    if (_loaded) return;
    _loaded = true;
 
    try {
      final service = ref.read(firestoreServiceProvider);
 
      // Perfil
      final profile = await service.getProfile(userId);
      if (profile != null && profile['display_name'] != null) {
        _nameController.text = profile['display_name'] as String;
      }
 
      // Quests completadas
      final quests = await service.getCompletedQuests(userId);
      _questCount = quests.length;
      _totalXp = quests.fold<int>(
        0,
        (sum, q) => sum + ((q['xp_earned'] as int?) ?? 0),
      );
 
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('ProfilePage _load error: $e');
    }
  }
 
  Future<void> _save(String userId) async {
    setState(() => _saving = true);
    try {
      await ref
          .read(firestoreServiceProvider)
          .updateProfile(userId, {'display_name': _nameController.text});
      _toast('Perfil atualizado!');
      setState(() => _editing = false);
    } catch (e) {
      debugPrint('ProfilePage _save error: $e');
      _toast('Erro ao salvar perfil', error: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
 
  void _toast(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? AppColors.destructive : AppColors.foreground,
      behavior: SnackBarBehavior.floating,
    ));
  }
 
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    if (user != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _load(user.uid));
    }
 
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 56, 24, 112),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Meu Perfil',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.foreground)),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        color: AppColors.coral,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(LucideIcons.user,
                          size: 28, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_editing)
                            Row(
                              children: [
                                Expanded(
                                  child: AppTextField(
                                    controller: _nameController,
                                    hint: 'Seu nome',
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton.filled(
                                  onPressed: _saving
                                      ? null
                                      : () => _save(user!.uid),
                                  style: IconButton.styleFrom(
                                    backgroundColor: AppColors.coral,
                                    foregroundColor: Colors.white,
                                  ),
                                  icon: const Icon(LucideIcons.save, size: 16),
                                ),
                              ],
                            )
                          else
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _nameController.text.isEmpty
                                        ? 'Sem nome'
                                        : _nameController.text,
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.foreground),
                                  ),
                                ),
                                InkWell(
                                  onTap: () => setState(() => _editing = true),
                                  child: const Icon(LucideIcons.pencil,
                                      size: 14,
                                      color: AppColors.mutedForeground),
                                ),
                              ],
                            ),
                          Text(user?.email ?? '',
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.mutedForeground)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                        child: _StatCard(
                      icon: LucideIcons.trophy,
                      value: _totalXp.toString(),
                      label: 'XP Total',
                    )),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _StatCard(
                      icon: LucideIcons.mapPin,
                      value: _favCities.length.toString(),
                      label: 'Cidades Exploradas',
                    )),
                  ],
                ),
                const SizedBox(height: 32),
                const Text('Cidades Favoritas',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.foreground)),
                const SizedBox(height: 12),
                if (_favCities.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Text(
                      'Nenhuma cidade salva ainda. Busque uma cidade no quiz!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 13, color: AppColors.mutedForeground),
                    ),
                  )
                else
                  Column(
                    children: _favCities
                        .map((c) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.secondary,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(LucideIcons.mapPin,
                                        size: 16, color: AppColors.coral),
                                    const SizedBox(width: 12),
                                    Text(c.cityName,
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.foreground)),
                                  ],
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                const SizedBox(height: 32),
                // ── Meus Roteiros ────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Meus Roteiros',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.foreground),
                    ),
                    GestureDetector(
                      onTap: () => ref.read(activeTabProvider.notifier).setTab(2),
                      child: const Text(
                        'Ver todos',
                        style: TextStyle(
                            fontSize: 12,
                            color: AppColors.coral,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Consumer(
                  builder: (context, ref, _) {
                    final itinerariesAsync = ref.watch(itineraryProvider);
                    return itinerariesAsync.when(
                      loading: () => const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: CircularProgressIndicator(
                              color: AppColors.coral, strokeWidth: 2),
                        ),
                      ),
                      error: (e, _) => Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Text(
                          'Erro ao carregar roteiros.',
                          style: TextStyle(
                              fontSize: 13, color: AppColors.mutedForeground),
                        ),
                      ),
                      data: (itineraries) {
                        if (itineraries.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.secondary,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  'Nenhum roteiro criado ainda.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.mutedForeground),
                                ),
                                const SizedBox(height: 10),
                                TextButton.icon(
                                  onPressed: () => ref.read(activeTabProvider.notifier).setTab(2),
                                  icon: const Icon(LucideIcons.plus, size: 14),
                                  label: const Text('Criar meu primeiro roteiro'),
                                  style: TextButton.styleFrom(
                                      foregroundColor: AppColors.coral),
                                ),
                              ],
                            ),
                          );
                        }

                        // Mostra até 3 roteiros recentes
                        final recent = itineraries.take(3).toList();
                        return Column(
                          children: [
                            ...recent.map((it) => _ItineraryTile(
                                  itinerary: it,
                                  onTap: () => ref.read(activeTabProvider.notifier).setTab(2),
                                )),
                            if (itineraries.length > 3)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: GestureDetector(
                                  onTap: () => ref.read(activeTabProvider.notifier).setTab(2),
                                  child: Text(
                                    '+ ${itineraries.length - 3} roteiro(s) a mais',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.coral,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 32),
                const Text('Progresso das Missões',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.foreground)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$_questCount missões completadas',
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.foreground)),
                      const SizedBox(height: 4),
                      const Text(
                        'Continue explorando para ganhar mais XP!',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.mutedForeground),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                OutlinedButton.icon(
                  onPressed: () => ref.read(authControllerProvider).signOut(),
                  icon: const Icon(LucideIcons.logOut, size: 16),
                  label: const Text('Sair da Conta'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.destructive,
                    side: BorderSide(
                        color: AppColors.destructive.withValues(alpha: 0.3)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
 
class _ItineraryTile extends StatelessWidget {
  final Itinerary itinerary;
  final VoidCallback onTap;

  const _ItineraryTile({required this.itinerary, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.secondary,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.coralLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(LucideIcons.mapPin,
                    size: 18, color: AppColors.coral),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      itinerary.name,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.foreground),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${itinerary.cityName} · ${itinerary.placeCount} local${itinerary.placeCount != 1 ? 'is' : ''}',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.mutedForeground),
                    ),
                  ],
                ),
              ),
              const Icon(LucideIcons.chevronRight,
                  size: 16, color: AppColors.mutedForeground),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
 
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });
 
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: AppColors.coral),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.foreground)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.mutedForeground),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}