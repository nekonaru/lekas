import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/theme.dart';
import '../../core/components/lekas_logo.dart';
import '../../core/components/motion.dart';
import '../../data/providers.dart';
import '../../data/models.dart';
import '../../l10n/app_localizations.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _step = 0;
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _habitController = TextEditingController();
  String _level = 'college';
  String _language = 'id';

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _habitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              // The brand band: the launcher gradient carries the logo, so
              // the first frame already looks like the app.
              Container(
                decoration: BoxDecoration(
                  gradient: AppTheme.brandGradient,
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: const FadeSlideIn(
                  child: Center(child: LekasLogo(size: 72)),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _step == 0
                    ? l10n.welcome
                    : _step == 1
                        ? l10n.addFirstSpace
                        : l10n.onboardHabitTitle,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _step == 0
                    ? l10n.welcomeSubtitle
                    : _step == 1
                        ? l10n.enterFirstCourseSubtitle
                        : l10n.onboardHabitSubtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),
              if (_step == 2) ...[
                TextField(
                  controller: _habitController,
                  decoration: InputDecoration(
                    labelText: l10n.onboardHabitName,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.onboardHabitSubtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                ),
              ] else if (_step == 0) ...[
                _languageSelector(l10n),
                const SizedBox(height: 16),
                _levelSelector(l10n),
                const SizedBox(height: 24),
              ] else ...[
                TextField(
                  controller: _nameController,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: l10n.spaceNameLabel,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _codeController,
                  decoration: InputDecoration(
                    labelText: l10n.spaceCode,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
              ],
              const Spacer(),
              _stepDots(),
              const SizedBox(height: 16),
              Row(
                children: [
                  if (_step > 0)
                    TextButton(
                      onPressed: () => setState(() => _step--),
                      child: Text(l10n.back),
                    ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _next,
                    child: Text(
                      _step == 0
                          ? l10n.start
                          : _step == 1
                              ? l10n.saveContinue
                              : l10n.finish,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  /// Two dots that stretch into a pill on the active step and shrink back
  /// on the other, so moving forward reads as one motion instead of a
  /// page swap.
  Widget _stepDots() {
    final colors = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var step = 0; step < 3; step++) ...[
          if (step > 0) const SizedBox(width: 8),
          AnimatedContainer(
            duration: AppMotion.fast,
            curve: AppMotion.ease,
            width: _step == step ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: _step == step
                  ? colors.primary
                  : colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ],
      ],
    );
  }

  Widget _languageSelector(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.chooseLanguage,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _choiceButton(
                selected: _language == 'id',
                label: l10n.indonesian,
                onPressed: () => _selectLanguage('id'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _choiceButton(
                selected: _language == 'en',
                label: l10n.english,
                onPressed: () => _selectLanguage('en'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _levelSelector(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.chooseLevel,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _choiceButton(
                selected: _level == 'college',
                label: l10n.college,
                onPressed: () => setState(() => _level = 'college'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _choiceButton(
                selected: _level == 'school',
                label: l10n.school,
                onPressed: () => setState(() => _level = 'school'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// One option of the language and level rows. The chosen option is filled
  /// with the accent color and shows a check, the other one stays outlined,
  /// and the two crossfade on every tap so a press always answers back.
  Widget _choiceButton({
    required bool selected,
    required String label,
    required VoidCallback onPressed,
  }) {
    return AnimatedSwitcher(
      duration: AppMotion.fast,
      transitionBuilder: (child, animation) =>
          FadeTransition(opacity: animation, child: child),
      child: selected
          ? ElevatedButton(
              key: const ValueKey('onboarding-choice-selected'),
              onPressed: onPressed,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_rounded, size: 18),
                  const SizedBox(width: 6),
                  Flexible(child: Text(label, textAlign: TextAlign.center)),
                ],
              ),
            )
          : OutlinedButton(
              key: const ValueKey('onboarding-choice-idle'),
              onPressed: onPressed,
              child: Text(label, textAlign: TextAlign.center),
            ),
    );
  }

  /// Applies the picked language right away: the choice flips on screen and
  /// the whole setup switches language before the next tap, so the control
  /// never feels dead (the stored value is what every later launch reads).
  Future<void> _selectLanguage(String language) async {
    setState(() => _language = language);
    await ref.read(settingsRepositoryProvider).setLanguage(language);
    if (!mounted) return;
    ref.invalidate(localeProvider);
  }

  bool _savingSpace = false;

  void _next() {
    if (_step == 0 || _step == 1) {
      setState(() => _step++);
    } else if (!_savingSpace) {
      _saveSpace();
    }
  }

  Future<void> _saveSpace() async {
    _savingSpace = true;
    final spaceRepo = ref.read(spaceRepositoryProvider);
    final settingsRepo = ref.read(settingsRepositoryProvider);
    final fallbackName = AppLocalizations.of(context)!.firstCourseFallback;
    final space = Space(
      id: const Uuid().v4(),
      name: _nameController.text.isEmpty ? fallbackName : _nameController.text,
      code: _codeController.text.isEmpty ? null : _codeController.text,
      color: AppTheme.containerColors[0].toARGB32(),
      level: _level,
      kind: 'course',
      archived: false,
      sortOrder: 0,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
    try {
      await spaceRepo.insertSpace(space);
      final habitName = _habitController.text.trim();
      if (habitName.isNotEmpty) {
        await ref.read(habitRepositoryProvider).createHabit(name: habitName);
      }
      await settingsRepo.set('language', _language);
      await settingsRepo.set('level', _level);
      await settingsRepo.set('onboarded', 'true');
    } catch (_) {
      if (!mounted) return;
      _savingSpace = false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.saveFailed)),
      );
      return;
    }
    if (!mounted) return;
    // Onboarding is the root route, so popping it would empty the navigator
    // and leave a black screen (the v1.4.1 bug on real devices). Flip the
    // flag instead and let _Home swap this screen for the shell in place.
    ref.invalidate(onboardedProvider);
  }
}
