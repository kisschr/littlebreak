import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../design/components.dart';
import '../../design/palette.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/sheet.dart';

/// "Frag deine Eltern": a multiplication only grown-ups solve quickly. Guards
/// purchases, settings and leaving a kids profile.
abstract final class ParentalGate {
  static Future<bool> ask(BuildContext context, {math.Random? random}) async {
    final ok = await showKpSheet<bool>(
      context: context,
      halfSize: 0.6,
      builder: (_) => SingleChildScrollView(child: _GatePanel(random: random ?? math.Random())),
    );
    return ok ?? false;
  }
}

class _GatePanel extends StatefulWidget {
  const _GatePanel({required this.random});

  final math.Random random;

  @override
  State<_GatePanel> createState() => _GatePanelState();
}

class _GatePanelState extends State<_GatePanel> {
  late int a, b;
  late List<int> options;
  bool wrong = false;

  @override
  void initState() {
    super.initState();
    _newTask();
  }

  void _newTask() {
    final r = widget.random;
    a = 6 + r.nextInt(4);
    b = 6 + r.nextInt(4);
    final answer = a * b;
    final set = <int>{answer};
    while (set.length < 4) {
      final v = answer + (r.nextInt(17) - 8);
      if (v > 0) set.add(v);
    }
    options = set.toList()..shuffle(r);
  }

  void _pick(int v) {
    if (v == a * b) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        wrong = true;
        _newTask();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final palette = KpPalette.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.gateTitle, style: KpText.title(palette.ink, size: 26)),
          const SizedBox(height: 6),
          Text(l.gateBody, style: KpText.body(palette.inkSoft)),
          const SizedBox(height: 16),
          Text(l.gateQuestion(a, b), textAlign: TextAlign.center, style: KpText.display(palette.ink, size: 34)),
          if (wrong) ...[
            const SizedBox(height: 6),
            Text(l.gateWrong, textAlign: TextAlign.center, style: KpText.label(const Color(0xFFB3261E))),
          ],
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.6,
            children: [
              for (final v in options)
                Semantics(
                  button: true,
                  child: GestureDetector(
                    onTap: () => _pick(v),
                    child: Container(
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.85), borderRadius: BorderRadius.circular(20)),
                      alignment: Alignment.center,
                      child: Text('$v', style: KpText.title(palette.ink, size: 24)),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
