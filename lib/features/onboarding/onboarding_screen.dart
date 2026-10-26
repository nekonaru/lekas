import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme.dart';
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
  String _level = 'college';
  String _language = 'id';

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              Text(
                _step == 0 ? l10n.welcome : l10n.addFirstSpace,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _step == 0
                    ? 'Lekas membantu kamu mencatat tugas dan deadline kuliah.'
                    : 'Masukkan nama matkul pertama kamu.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),
              if (_step == 0) ...[
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
                  decoration: const InputDecoration(
                    labelText: 'Kode (opsional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
              ],
              const Spacer(),
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
                    child: Text(_step == 0
                        ? l10n.start
                        : _step == 1
                            ? l10n.saveContinue
                            : l10n.finish),
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

  Widget _languageSelector(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.chooseLanguage, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => setState(() => _language = 'id'),
                child: Text(l10n.indonesian),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _language = 'en'),
                child: Text(l10n.english),
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
        Text(l10n.chooseLevel, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => setState(() => _level = 'college'),
                child: Text(l10n.college),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _level = 'school'),
                child: Text(l10n.school),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _next() {
    if (_step == 0) {
      setState(() => _step = 1);
    } else {
      _saveSpace();
    }
  }

  Future<void> _saveSpace() async {
    final spaceRepo = ref.read(spaceRepositoryProvider);
    final settingsRepo = ref.read(settingsRepositoryProvider);
    final space = Space(
      id: const Uuid().v4(),
      name: _nameController.text.isEmpty ? 'Matkul Pertama' : _nameController.text,
      code: _codeController.text.isEmpty ? null : _codeController.text,
      color: AppTheme.containerColors[0].value,
      level: _level,
      kind: 'course',
      archived: false,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
    await spaceRepo.insertSpace(space);
    await settingsRepo.set('language', _language);
    await settingsRepo.set('onboarded', 'true');
    if (mounted) Navigator.pop(context);
  }
}
