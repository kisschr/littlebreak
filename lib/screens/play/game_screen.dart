import 'dart:async';

import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:provider/provider.dart';

import '../../app/app_state.dart';
import '../../data/content.dart';
import '../../design/components.dart';
import '../../design/icons.dart';
import '../../design/palette.dart';
import '../../domain/models.dart';
import '../../games/game_framework.dart';
import '../../games/game_registry.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../l10n/texts.dart';
import 'how_to_sheet.dart';
import 'result_screen.dart';
import '../../widgets/dialog.dart';

/// One level of one day: glass toolbar, the engine's opaque board, pause,
/// hints, the first-time "So geht's" and the hand-over to the result.
class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.plan, required this.difficulty});

  final DayPlan plan;
  final Difficulty difficulty;

  static Route<void> route({required DayPlan plan, required Difficulty difficulty}) => PageRouteBuilder<void>(
    settings: const RouteSettings(name: 'game'),
    transitionDuration: const Duration(milliseconds: 320),
    pageBuilder: (_, _, _) => GameScreen(plan: plan, difficulty: difficulty),
    transitionsBuilder: (_, animation, _, child) => FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
      child: child,
    ),
  );

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with WidgetsBindingObserver {
  late final AppState state = context.read<AppState>();
  late final GameController controller = GameController(onFinished: _onFinished);
  late final definition = GameRegistry.of(widget.plan.type);
  Future<GameContent>? _content;
  Timer? _clock;
  int seconds = 0;
  bool _howToShown = false;

  bool get isKid => state.audience == Audience.kid;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _clock = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!controller.paused && !controller.finished && mounted) setState(() => seconds++);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _content ??= state.contentFor(Localizations.localeOf(context).languageCode);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _clock?.cancel();
    controller.dispose();
    state.speech.stop();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycle) {
    if (lifecycle != AppLifecycleState.resumed && !controller.finished) controller.setPaused(true);
  }

  void _maybeShowHowTo() {
    if (_howToShown || state.hasSeenTutorial(widget.plan.type)) return;
    _howToShown = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => _showHowTo());
  }

  Future<void> _showHowTo() async {
    controller.setPaused(true);
    await showHowToSheet(context, widget.plan.type);
    await state.markTutorialSeen(widget.plan.type);
    if (mounted) controller.setPaused(false);
  }

  Future<void> _onFinished(GameOutcome outcome) async {
    final stars = controller.starsFor(outcome, isKid: isKid);
    final result = LevelResult(
      stars: stars,
      seconds: seconds,
      mistakes: controller.mistakes,
      completedAt: DateTime.now(),
    );
    await state.recordResult(widget.plan, widget.difficulty, result);
    final artwork = outcome.artwork;
    if (artwork != null) await state.addToGallery(artwork);
    // Let the solved board be seen for a moment.
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    unawaited(
      Navigator.of(context).pushReplacement(
        ResultScreen.route(
          GameSummary(
            plan: widget.plan,
            difficulty: widget.difficulty,
            stars: stars,
            seconds: seconds,
            stat: definition.stat,
            statValue: switch (definition.stat) {
              GameStat.mistakes => controller.mistakes,
              GameStat.moves || GameStat.attempts => controller.moves,
              GameStat.score => outcome.score ?? 0,
            },
          ),
        ),
      ),
    );
  }

  Future<bool> _confirmLeave() async {
    if (controller.finished) return true;
    final l = AppLocalizations.of(context);
    final wasPaused = controller.paused;
    controller.setPaused(true);
    var leave = false;
    await KpDialog.show<void>(
      context: context,
      title: l.leaveTitle,
      message: l.leaveBody,
      actions: [
        KpDialogAction(label: l.keepPlaying, isPrimary: true, onPressed: () => Navigator.of(context).pop()),
        KpDialogAction(
          label: l.leave,
          isDestructive: true,
          onPressed: () {
            leave = true;
            Navigator.of(context).pop();
          },
        ),
      ],
    );
    if (!leave && mounted) controller.setPaused(wasPaused);
    return leave;
  }

  Future<void> _leave() async {
    if (await _confirmLeave() && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _leave();
      },
      child: GlassScaffold(
        settings: KpGlassStyle.of(context),
        background: const KpBackground(variant: 0),
        body: FutureBuilder<GameContent>(
          future: _content,
          builder: (context, snapshot) {
            final content = snapshot.data;
            if (content == null) return const Center(child: CircularProgressIndicator());
            _maybeShowHowTo();
            final session = GameSession(
              plan: widget.plan,
              difficulty: widget.difficulty,
              audience: state.audience,
              content: content,
              quotes: state.quotes,
              controller: controller,
            );
            final insets = MediaQuery.paddingOf(context);
            return Stack(
              children: [
                ListView(
                  padding: EdgeInsets.fromLTRB(
                    kpSideInset(context, 16),
                    insets.top + 12,
                    kpSideInset(context, 16),
                    insets.bottom + 24,
                  ),
                  children: [
                    _Toolbar(
                      title: '${l.gameName(widget.plan.type)} · ${l.difficultyName(widget.difficulty)}',
                      seconds: seconds,
                      showTimer: definition.showsTimer && !isKid,
                      controller: controller,
                      usesHints: definition.usesHints,
                      onClose: _leave,
                    ),
                    const SizedBox(height: 18),
                    _SessionHost(session: session, definition: definition),
                  ],
                ),
                ListenableBuilder(
                  listenable: controller,
                  builder: (context, _) => controller.paused && !controller.finished && _howToShownOrSeen
                      ? _PauseOverlay(
                          onResume: () => controller.setPaused(false),
                          onHowTo: () async {
                            await showHowToSheet(context, widget.plan.type);
                          },
                          onLeave: () => Navigator.of(context).pop(),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// The how-to sheet pauses the game itself; the pause card only shows for
  /// a real pause.
  bool get _howToShownOrSeen => state.hasSeenTutorial(widget.plan.type);
}

/// Builds the engine once; later rebuilds of the screen (timer ticks) must
/// not rebuild the board.
class _SessionHost extends StatefulWidget {
  const _SessionHost({required this.session, required this.definition});

  final GameSession session;
  final GameDefinition definition;

  @override
  State<_SessionHost> createState() => _SessionHostState();
}

class _SessionHostState extends State<_SessionHost> {
  late final Widget _board = widget.definition.build(context, widget.session);

  @override
  Widget build(BuildContext context) => _board;
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({
    required this.title,
    required this.seconds,
    required this.showTimer,
    required this.controller,
    required this.usesHints,
    required this.onClose,
  });

  final String title;
  final int seconds;
  final bool showTimer;
  final GameController controller;
  final bool usesHints;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final palette = KpPalette.of(context);
    return KpGlassCard(
      radius: 28,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: SizedBox(
        height: 56,
        child: Row(
          children: [
            _ToolbarButton(
              label: l.leaveGame,
              onTap: onClose,
              child: KpIcon(KpIcons.close, size: 18, strokeWidth: 2.5, color: palette.ink),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: KpText.label(palette.inkSoft, size: 13),
                  ),
                  if (showTimer)
                    Text(
                      formatDuration(seconds),
                      style: KpText.title(
                        palette.ink,
                        size: 20,
                      ).copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
                    ),
                ],
              ),
            ),
            ListenableBuilder(
              listenable: controller,
              builder: (context, _) => Opacity(
                opacity: usesHints && controller.hintsAvailable ? 1 : 0.3,
                child: _ToolbarButton(
                  label: l.hint,
                  onTap: usesHints && controller.hintsAvailable && !controller.paused ? controller.requestHint : null,
                  child: KpIcon(KpIcons.bulb, size: 20, color: palette.ink),
                ),
              ),
            ),
            _ToolbarButton(
              label: l.pause,
              onTap: () => controller.setPaused(true),
              child: CustomPaint(size: const Size(20, 20), painter: _PausePainter(palette.ink)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  const _ToolbarButton({required this.label, required this.onTap, required this.child});

  final String label;
  final VoidCallback? onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    enabled: onTap != null,
    label: label,
    excludeSemantics: true,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(width: 44, height: 44, child: Center(child: child)),
    ),
  );
}

class _PausePainter extends CustomPainter {
  _PausePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24;
    final paint = Paint()..color = color;
    canvas
      ..drawRRect(RRect.fromLTRBR(6 * s, 5 * s, 10 * s, 19 * s, Radius.circular(1.5 * s)), paint)
      ..drawRRect(RRect.fromLTRBR(14 * s, 5 * s, 18 * s, 19 * s, Radius.circular(1.5 * s)), paint);
  }

  @override
  bool shouldRepaint(_PausePainter old) => old.color != color;
}

class _PauseOverlay extends StatelessWidget {
  const _PauseOverlay({required this.onResume, required this.onHowTo, required this.onLeave});

  final VoidCallback onResume;
  final VoidCallback onHowTo;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final palette = KpPalette.of(context);
    return Positioned.fill(
      child: ColoredBox(
        // The board is hidden while paused, so the clock stays fair.
        color: palette.background.withValues(alpha: 0.94),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: KpGlassCard(
              radius: 32,
              padding: const EdgeInsets.all(22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(l.pausedTitle, textAlign: TextAlign.center, style: KpText.display(palette.ink, size: 32)),
                  const SizedBox(height: 6),
                  Text(l.pausedBody, textAlign: TextAlign.center, style: KpText.body(palette.inkSoft)),
                  const SizedBox(height: 18),
                  KpPrimaryButton(label: l.resume, onPressed: onResume),
                  const SizedBox(height: 10),
                  _TextAction(label: l.howToTitle, onTap: onHowTo),
                  _TextAction(label: l.leaveGame, onTap: onLeave),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TextAction extends StatelessWidget {
  const _TextAction({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(label, textAlign: TextAlign.center, style: KpText.label(KpPalette.of(context).accent, size: 16)),
      ),
    ),
  );
}

/// "05:48"; hours appear only when needed.
String formatDuration(int seconds) {
  final h = seconds ~/ 3600, m = (seconds % 3600) ~/ 60, s = seconds % 60;
  String two(int v) => v.toString().padLeft(2, '0');
  return h > 0 ? '$h:${two(m)}:${two(s)}' : '${two(m)}:${two(s)}';
}
