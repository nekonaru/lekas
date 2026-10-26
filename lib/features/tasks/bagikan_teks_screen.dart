import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';

class BagikanTeksScreen extends ConsumerStatefulWidget {
  const BagikanTeksScreen({super.key});

  @override
  ConsumerState<BagikanTeksScreen> createState() => _BagikanTeksScreenState();
}

class _BagikanTeksScreenState extends ConsumerState<BagikanTeksScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.shareAsTextTitle)),
      body: Center(child: Text(l10n.shareAsTextBody)),
    );
  }
}
