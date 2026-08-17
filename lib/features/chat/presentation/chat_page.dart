import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconfy_icon/iconfy_icon.dart';
import 'package:motor/motor.dart';
import 'package:vncoughalert/design_system/design_system.dart';
import 'package:vncoughalert/features/chat/data/voice_recorder.dart';
import 'package:vncoughalert/features/chat/data/demo_diagnosis.dart';
import 'package:vncoughalert/features/chat/domain/models/diagnosis_models.dart';
import 'package:vncoughalert/features/chat/domain/models/chat_models.dart';
import 'package:vncoughalert/features/chat/providers/chat_providers.dart';

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({
    super.key,
    required this.chatId,
    required this.onNewChat,
    required this.onOpenChat,
  });

  final String? chatId;
  final VoidCallback onNewChat;
  final ValueChanged<String> onOpenChat;

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final TextEditingController _composer = TextEditingController();
  final TextEditingController _search = TextEditingController();
  final ScrollController _scroll = ScrollController();
  String _query = '';
  String? _draftChatId;
  var _dragging = false;
  var _dragT = 0.0;
  var _atLatest = true;
  final _recorder = VoiceRecorder();
  StreamSubscription<double>? _amplitudeSub;
  var _recording = false;
  final List<VoiceClip> _voiceDrafts = [];
  List<double> _waveformLevels = const [];
  Timer? _demoRecordTimer;

  static const _flingVelocity = 700.0;
  static const _showJumpPixels = 64.0;
  static const _hideJumpPixels = 24.0;

  @override
  void initState() {
    super.initState();
    _composer.addListener(() => setState(() {}));
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _composer.dispose();
    _search.dispose();
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    _demoRecordTimer?.cancel();
    _amplitudeSub?.cancel();
    _recorder.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scroll.hasClients) {
      return;
    }
    final pixels = _scroll.position.pixels;
    final max = _scroll.position.maxScrollExtent;
    final bool atLatest;
    if (max <= 0) {
      atLatest = true;
    } else if (pixels < max - _showJumpPixels) {
      atLatest = false;
    } else if (pixels > max - _hideJumpPixels) {
      atLatest = true;
    } else {
      return;
    }
    if (atLatest == _atLatest) {
      return;
    }
    setState(() => _atLatest = atLatest);
  }

  void _scheduleStickToLatest({required bool animate}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_atLatest || !_scroll.hasClients) {
        return;
      }
      final max = _scroll.position.maxScrollExtent;
      if (max <= 0) {
        return;
      }
      if ((_scroll.position.pixels - max).abs() < 2) {
        return;
      }
      if (animate) {
        _scroll.animateTo(
          max,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOut,
        );
      } else {
        _scroll.jumpTo(max);
      }
    });
  }

  void _jumpToLatest() {
    setState(() => _atLatest = true);
    _scheduleStickToLatest(animate: true);
  }

  bool get _edgeOpenEnabled {
    switch (Theme.of(context).platform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return true;
      default:
        return false;
    }
  }

  void _closeSidebar() => ref.read(sidebarOpenProvider.notifier).close();

  void _onSidebarDragStart({required bool open}) {
    setState(() {
      _dragging = true;
      _dragT = open ? 1.0 : 0.0;
    });
  }

  void _onSidebarDragUpdate(double dx, double panelWidth) {
    setState(() {
      _dragT = (_dragT + dx / panelWidth).clamp(0.0, 1.0);
    });
  }

  void _onSidebarDragEnd(DragEndDetails details) {
    final vx = details.velocity.pixelsPerSecond.dx;
    final bool shouldOpen;
    if (vx > _flingVelocity) {
      shouldOpen = true;
    } else if (vx < -_flingVelocity) {
      shouldOpen = false;
    } else {
      shouldOpen = _dragT > 0.5;
    }
    setState(() => _dragging = false);
    if (shouldOpen) {
      ref.read(sidebarOpenProvider.notifier).open();
    } else {
      _closeSidebar();
    }
  }

  Widget _buildChatSheet({
    required double t,
    required bool sidebarOpen,
    required Widget? child,
  }) {
    final progress = t.clamp(0.0, 1.0);
    final radius = AppRadius.bubble * progress;
    final shape = AppRadius.superellipse(radius);
    return GestureDetector(
      onTap: progress > 0.5 ? _closeSidebar : null,
      onHorizontalDragStart: sidebarOpen
          ? (_) => _onSidebarDragStart(open: true)
          : null,
      onHorizontalDragUpdate: sidebarOpen
          ? (details) => _onSidebarDragUpdate(
              details.delta.dx,
              MediaQuery.sizeOf(context).width * 0.82,
            )
          : null,
      onHorizontalDragEnd: sidebarOpen ? _onSidebarDragEnd : null,
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: AppColor.canvas,
          shape: shape,
          shadows: [
            BoxShadow(
              color: AppColor.textHigh.withValues(alpha: 0.18 * progress),
              blurRadius: 24 * progress,
            ),
          ],
        ),
        child: ClipPath(
          clipper: ShapeBorderClipper(shape: shape),
          child: AbsorbPointer(absorbing: progress > 0.5, child: child),
        ),
      ),
    );
  }

  String? get _activeChatId => widget.chatId ?? _draftChatId;

  DiagnosisDemoPhase get _demoPhase =>
      ref.read(chatStoreProvider).phaseOf(_activeChatId);

  List<DsDiagnosisSummary> _mapDiagnoses(List<DiagnosisResult> items) {
    return [
      for (final item in items)
        DsDiagnosisSummary(
          title: item.name,
          subtitle: item.nameEn,
          severityLabel: item.severityLabel,
          confidencePercent: item.confidencePercent,
          summary: item.summary,
          matchedSymptoms: item.matchedSymptoms,
          recommendations: item.recommendations,
        ),
    ];
  }

  void _showCaseStudy() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(AppSpace.md),
          child: DsMarkdownBody(data: DemoDiagnosis.caseStudyBody),
        );
      },
    );
  }

  Future<void> _startNewDiagnosisDemo() async {
    await _cancelRecording();
    await _clearVoiceDrafts();
    final chatId = ref.read(chatStoreProvider.notifier).newChatId();
    if (!mounted) return;
    setState(() {
      _draftChatId = chatId;
      _composer.clear();
      _atLatest = true;
    });
    widget.onNewChat();
    await ref.read(chatStoreProvider.notifier).startDiagnosisDemo(chatId);
    if (!mounted) return;
    _scheduleStickToLatest(animate: true);
  }

  Future<void> _submitDemoCoughRecording() async {
    _demoRecordTimer?.cancel();
    await _amplitudeSub?.cancel();
    _amplitudeSub = null;
    final clip = await _recorder.stop();
    if (!mounted) return;
    setState(() {
      _recording = false;
      _waveformLevels = const [];
    });
    if (clip == null) return;
    await _submit('', forceClips: [clip]);
  }

  void _showPlaceholder(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _submit(String raw, {List<VoiceClip>? forceClips}) async {
    final clips = forceClips ?? List<VoiceClip>.from(_voiceDrafts);
    if (_recording) {
      _demoRecordTimer?.cancel();
      _amplitudeSub?.cancel();
      _amplitudeSub = null;
      final clip = await _recorder.stop();
      if (!mounted) {
        return;
      }
      setState(() {
        _recording = false;
        _waveformLevels = const [];
      });
      if (clip != null) {
        clips.add(clip);
      }
    }
    final text = raw.trim();
    if (text.isEmpty && clips.isEmpty) {
      return;
    }
    var chatId = widget.chatId;
    if (chatId == null || chatId.isEmpty) {
      chatId = _draftChatId ?? ref.read(chatStoreProvider.notifier).newChatId();
      _draftChatId = chatId;
    }
    _composer.clear();
    setState(() {
      _atLatest = true;
      _voiceDrafts.clear();
    });
    await ref
        .read(chatStoreProvider.notifier)
        .send(
          chatId: chatId,
          text: text,
          audios: [
            for (final clip in clips)
              ChatAudio(
                path: clip.path,
                duration: clip.duration,
                levels: clip.levels,
              ),
          ],
        );
    if (!mounted) {
      return;
    }
    _scheduleStickToLatest(animate: true);
  }

  Future<void> _startRecording() async {
    if (_recording) {
      return;
    }
    final allowed = await _recorder.hasPermission();
    if (!mounted) {
      return;
    }
    if (!allowed) {
      _showPlaceholder('Microphone permission is required');
      return;
    }
    final started = await _recorder.start();
    if (!mounted) {
      return;
    }
    if (!started) {
      _showPlaceholder('Microphone permission is required');
      return;
    }
    setState(() {
      _recording = true;
      _waveformLevels = const [];
    });
    _demoRecordTimer?.cancel();
    _amplitudeSub?.cancel();
    _amplitudeSub = _recorder.amplitudes.listen((_) {
      if (!mounted || !_recording) {
        return;
      }
      setState(() => _waveformLevels = _recorder.levels);
    });
    if (_demoPhase == DiagnosisDemoPhase.waitingCough) {
      _demoRecordTimer = Timer(const Duration(seconds: 5), () {
        if (mounted && _recording) {
          unawaited(_submitDemoCoughRecording());
        }
      });
    }
  }

  Future<void> _stopRecording() async {
    if (!_recording) {
      return;
    }
    _demoRecordTimer?.cancel();
    _amplitudeSub?.cancel();
    _amplitudeSub = null;
    final clip = await _recorder.stop();
    if (!mounted) {
      return;
    }
    setState(() {
      _recording = false;
      if (clip != null) {
        _voiceDrafts.add(clip);
      }
      _waveformLevels = const [];
    });
  }

  Future<void> _cancelRecording() async {
    _demoRecordTimer?.cancel();
    if (!_recording) {
      return;
    }
    _amplitudeSub?.cancel();
    _amplitudeSub = null;
    await _recorder.cancel();
    if (!mounted) {
      return;
    }
    setState(() {
      _recording = false;
      _waveformLevels = const [];
    });
  }

  Future<void> _removeVoiceDraft(VoiceClip clip) async {
    await _recorder.deleteClip(clip);
    if (!mounted) {
      return;
    }
    setState(() => _voiceDrafts.removeWhere((item) => item.path == clip.path));
  }

  Future<void> _clearVoiceDrafts() async {
    for (final clip in List<VoiceClip>.from(_voiceDrafts)) {
      await _recorder.deleteClip(clip);
    }
    if (!mounted) {
      return;
    }
    setState(() => _voiceDrafts.clear());
  }

  @override
  Widget build(BuildContext context) {
    final store = ref.watch(chatStoreProvider);
    final sidebarOpen = ref.watch(sidebarOpenProvider);
    final messages = store.messagesOf(widget.chatId ?? _draftChatId);
    if (_atLatest) {
      _scheduleStickToLatest(animate: false);
    }
    final recents = store.sessions.where((session) {
      if (_query.trim().isEmpty) {
        return true;
      }
      return session.title.toLowerCase().contains(_query.toLowerCase());
    }).toList();
    final panelWidth = MediaQuery.sizeOf(context).width * 0.82;

    return PopScope(
      canPop: !sidebarOpen,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
        _closeSidebar();
      },
      child: Scaffold(
        backgroundColor: AppColor.sidebar,
        resizeToAvoidBottomInset: !sidebarOpen,
        body: Stack(
          clipBehavior: Clip.none,
          children: [
            IgnorePointer(
              ignoring: (_dragging ? _dragT : (sidebarOpen ? 1.0 : 0.0)) < 0.5,
              child: Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: panelWidth,
                  child: _buildSidebar(recents),
                ),
              ),
            ),
            SingleMotionBuilder(
              motion: const CupertinoMotion.bouncy(),
              active: !_dragging,
              value: _dragging ? _dragT : (sidebarOpen ? 1.0 : 0.0),
              builder: (context, t, child) {
                return Transform.translate(
                  offset: Offset(panelWidth * t, 0),
                  child: _buildChatSheet(
                    t: t,
                    sidebarOpen: sidebarOpen,
                    child: child,
                  ),
                );
              },
              child: _buildChatColumn(messages),
            ),
            if ((_edgeOpenEnabled && !sidebarOpen) || _dragging)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: AppSpace.xl,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onHorizontalDragStart: (_) =>
                      _onSidebarDragStart(open: sidebarOpen),
                  onHorizontalDragUpdate: (details) =>
                      _onSidebarDragUpdate(details.delta.dx, panelWidth),
                  onHorizontalDragEnd: _onSidebarDragEnd,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _composerHint(DiagnosisDemoPhase phase) {
    return switch (phase) {
      DiagnosisDemoPhase.waitingIntake => 'Nhập triệu chứng…',
      DiagnosisDemoPhase.waitingCough => 'Ghi âm tiếng ho…',
      DiagnosisDemoPhase.idle ||
      DiagnosisDemoPhase.analyzing ||
      DiagnosisDemoPhase.done => 'Nhập tin nhắn...',
    };
  }

  Widget _buildChatColumn(List<ChatMessage> messages) {
    final demoPhase = ref.watch(chatStoreProvider).phaseOf(_activeChatId);
    return Column(
      children: [
        SafeArea(bottom: false, child: _buildHeader()),
        Expanded(child: _buildMessages(messages)),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpace.xs,
              AppSpace.xs,
              AppSpace.md,
              AppSpace.sm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(
                    left: AppSpace.sm,
                    right: AppSpace.sm,
                    bottom: AppSpace.sm,
                  ),
                  child: Row(
                    children: [
                      DsDemoActionChip(
                        label: 'Chẩn đoán mới',
                        onTap: _startNewDiagnosisDemo,
                      ),
                      const SizedBox(width: AppSpace.xs),
                      DsDemoActionChip(
                        label: 'Xu hướng',
                        onTap: () =>
                            _showPlaceholder(DemoDiagnosis.trendMessage),
                      ),
                      const SizedBox(width: AppSpace.xs),
                      DsDemoActionChip(
                        label: 'Báo cáo',
                        onTap: () =>
                            _showPlaceholder(DemoDiagnosis.reportMessage),
                      ),
                    ],
                  ),
                ),
                if (_voiceDrafts.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpace.sm),
                    child: SizedBox(
                      height: DsVoiceDraftCard.extentHeight,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        clipBehavior: Clip.none,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpace.sm,
                        ),
                        itemCount: _voiceDrafts.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: AppSpace.xs),
                        itemBuilder: (context, index) {
                          final clip = _voiceDrafts[index];
                          return DsVoiceDraftCard(
                            duration: clip.duration,
                            onRemove: () => _removeVoiceDraft(clip),
                          );
                        },
                      ),
                    ),
                  ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: DsComposer(
                        controller: _composer,
                        hintText: _composerHint(demoPhase),
                        onAttach: () =>
                            _showPlaceholder('Attachments coming soon'),
                        onMic: _startRecording,
                        onSubmitted: _submit,
                        isRecording: _recording,
                        waveformLevels: _waveformLevels,
                        onCancelRecording: _cancelRecording,
                        onStopRecording: _stopRecording,
                      ),
                    ),
                    const SizedBox(width: AppSpace.xs),
                    DsVoiceButton(
                      enabled:
                          _recording ||
                          _voiceDrafts.isNotEmpty ||
                          _composer.text.trim().isNotEmpty,
                      onPressed: () => _submit(_composer.text),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpace.xs,
        vertical: AppSpace.xxs,
      ),
      child: Row(
        children: [
          DsIconButton(
            icon: IconfyIcons.editor.hamburgerMenu.outline.regular,
            tooltip: 'Menu',
            onPressed: () => ref.read(sidebarOpenProvider.notifier).open(),
          ),
          const Spacer(),
          DsIconButton(
            icon: IconfyIcons.essential.editSquare.outline.regular,
            tooltip: 'New chat',
            onPressed: () async {
              await _cancelRecording();
              await _clearVoiceDrafts();
              if (!mounted) {
                return;
              }
              setState(() {
                _draftChatId = null;
                _composer.clear();
              });
              widget.onNewChat();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMessages(List<ChatMessage> messages) {
    if (messages.isEmpty) {
      return const SizedBox.expand();
    }
    return Stack(
      children: [
        ListView.builder(
          controller: _scroll,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpace.md,
            vertical: AppSpace.sm,
          ),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            return DsMessageBubble(
              key: ValueKey(message.id),
              role: message.role == ChatRole.user
                  ? DsMessageRole.user
                  : DsMessageRole.assistant,
              text: message.text,
              isPending: message.isPending,
              diagnoses: _mapDiagnoses(message.diagnoses),
              onCaseStudy: message.diagnoses.isEmpty ? null : _showCaseStudy,
              onConnectDoctor: message.diagnoses.isEmpty
                  ? null
                  : () => _showPlaceholder(DemoDiagnosis.connectDoctorMessage),
              audios: [
                for (final audio in message.audios)
                  DsVoiceAttachment(
                    path: audio.path,
                    duration: audio.duration,
                    levels: audio.levels,
                  ),
              ],
            );
          },
        ),
        if (!_atLatest)
          Positioned(
            right: AppSpace.md,
            bottom: AppSpace.sm,
            child: Material(
              color: AppColor.canvas,
              shape: CircleBorder(side: BorderSide(color: AppColor.border)),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: _jumpToLatest,
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: Tooltip(
                    message: 'Latest',
                    child: Center(
                      child: IconfyIconWidget(
                        IconfyIcons.essential.arrowDown.outline.regular,
                        size: 20,
                        color: AppColor.iconDefault,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSidebar(List<ChatSession> recents) {
    return DsSidebarPanel(
      title: 'VNCoughAlert',
      searchHint: 'Search',
      searchController: _search,
      onSearchChanged: (value) => setState(() => _query = value),
      recentsLabel: 'Recents',
      navItems: [
        DsSidebarNavItem(
          icon: IconfyIcons.essential.document.outline.regular,
          label: 'Library',
          onTap: () => _showPlaceholder('Library coming soon'),
        ),
        DsSidebarNavItem(
          icon: IconfyIcons.essential.folder.outline.regular,
          label: 'Projects',
          onTap: () => _showPlaceholder('Projects coming soon'),
        ),
        DsSidebarNavItem(
          icon: IconfyIcons.essential.category.outline.regular,
          label: 'Plugins',
          onTap: () => _showPlaceholder('Plugins coming soon'),
        ),
        DsSidebarNavItem(
          icon: IconfyIcons.essential.moreCircle.outline.regular,
          label: 'More',
          onTap: () => _showPlaceholder('More coming soon'),
        ),
      ],
      recents: [
        for (final session in recents)
          DsRecentRow(
            title: session.title,
            selected: session.id == (widget.chatId ?? _draftChatId),
            onTap: () {
              _closeSidebar();
              if (session.id == (widget.chatId ?? _draftChatId)) {
                return;
              }
              widget.onOpenChat(session.id);
            },
          ),
      ],
    );
  }
}
