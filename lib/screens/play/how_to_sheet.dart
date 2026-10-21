import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:provider/provider.dart';

import '../../app/app_state.dart';
import '../../design/components.dart';
import '../../design/icons.dart';
import '../../design/palette.dart';
import '../../domain/models.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../l10n/texts.dart';

/// "So geht's" — the rules of a game, with read-aloud for kids.
Future<void> showHowToSheet(BuildContext context, GameType type) {
  final state = context.read<AppState>();
  return GlassModalSheet.show<void>(
    context: context,
    topBorderRadius: KpGlassStyle.sheetRadius,
    bottomBorderRadius: KpGlassStyle.sheetRadius,
    settings: KpGlassStyle.sheet,
    halfSize: 0.5,
    detents: const {GlassSheetDetent.medium},
    builder: (_) => SingleChildScrollView(child: HowToBody(type: type, state: state)),
  );
}

class HowToBody extends StatelessWidget {
  const HowToBody({super.key, required this.type, required this.state});

  final GameType type;
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final palette = KpPalette.of(context);
    final kid = state.audience == Audience.kid;
    final text = kid ? l.kidPrompt(type) : l.gameHowTo(type);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.gameName(type), style: KpText.label(palette.inkSoft, size: 14)),
          Text(l.howToTitle, style: KpText.title(palette.ink, size: 28)),
          const SizedBox(height: 12),
          Text(text, style: KpText.body(palette.ink, size: kid ? 20 : 17)),
          const SizedBox(height: 20),
          Row(
            children: [
              if (kid) ...[
                SpeakButton(text: '${l.gameName(type)}. $text'),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: KpPrimaryButton(
                  label: l.letsGo,
                  height: kid ? 72 : 58,
                  fontSize: kid ? 24 : 19,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The round "Vorlesen" button of the kids' screens (72 px, opaque).
class SpeakButton extends StatelessWidget {
  const SpeakButton({super.key, required this.text, this.size = 72});

  final String text;
  final double size;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final palette = KpPalette.of(context);
    return KpSoftButton(
      size: size,
      opacity: 0.8,
      semanticLabel: l.readAloud,
      onPressed: () => context.read<AppState>().speech.speak(text, languageCode: Localizations.localeOf(context).languageCode),
      child: KpIcon(KpIcons.speaker, size: size * 0.42, color: palette.successText, strokeWidth: 2.2),
    );
  }
}
