import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconfy_icon/iconfy_icon.dart';
import 'package:motor/motor.dart';
import 'package:vncoughalert/design_system/design_system.dart';
import 'package:vncoughalert/features/chat/data/mistral_config.dart';
import 'package:vncoughalert/features/chat/data/voice_recorder.dart';
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
  Timer? _recordingTimer;
  DateTime? _recordingStartedAt;
  Duration _recordingElapsed = Duration.zero;

  static const _flingVelocity = 700.0;
  static const _showJumpPixels = 64.0;
  static const _hideJumpPixels = 24.0;
  static const _maxRecordingDuration = Duration(seconds: 5);

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
    _recordingTimer?.cancel();
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

  double _sidebarWidth() {
    final width = MediaQuery.sizeOf(context).width;
    return (width * 0.82).clamp(280.0, 360.0);
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
          ? (details) => _onSidebarDragUpdate(details.delta.dx, _sidebarWidth())
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

  void _showPlaceholder(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _showPrivacyDialog() async {
    var accepted = false;
    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Điều khoản & quyền riêng tư'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'VNCoughAlert chỉ cung cấp cảnh báo tham khảo, không thay thế chẩn đoán hoặc điều trị của bác sĩ.',
                      style: AppTextStyle.bodySm(),
                    ),
                    const SizedBox(height: AppSpace.sm),
                    Text(
                      'Khi ghi âm, dữ liệu âm thanh được gửi cùng phiên chat để xử lý. Không nhập thông tin định danh nhạy cảm.',
                      style: AppTextStyle.bodySm(),
                    ),
                    const SizedBox(height: AppSpace.sm),
                    CheckboxListTile(
                      value: accepted,
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: const Text('Tôi đã hiểu và đồng ý tiếp tục.'),
                      onChanged: (value) {
                        setDialogState(() => accepted = value ?? false);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Đóng'),
                ),
                FilledButton(
                  onPressed: accepted ? () => Navigator.pop(context) : null,
                  child: const Text('Tiếp tục'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _submit(String raw, {List<VoiceClip>? forceClips}) async {
    final clips = forceClips ?? List<VoiceClip>.from(_voiceDrafts);
    if (_recording) {
      final clip = await _finishActiveRecording();
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

  Future<VoiceClip?> _finishActiveRecording() async {
    _recordingTimer?.cancel();
    _recordingTimer = null;
    _amplitudeSub?.cancel();
    _amplitudeSub = null;
    final clip = await _recorder.stop();
    if (!mounted) {
      return clip;
    }
    setState(() {
      _recording = false;
      _recordingStartedAt = null;
      _recordingElapsed = Duration.zero;
      _waveformLevels = const [];
    });
    return clip;
  }

  bool _isTooNoisy(VoiceClip clip) {
    if (clip.levels.length < 8) {
      return false;
    }
    final loudSamples = clip.levels.where((level) => level > 0.86).length;
    return loudSamples / clip.levels.length > 0.7;
  }

  Future<void> _autoSubmitRecording() async {
    final clip = await _finishActiveRecording();
    if (!mounted || clip == null) {
      return;
    }
    if (_isTooNoisy(clip)) {
      await _recorder.deleteClip(clip);
      _showPlaceholder(
        'Môi trường đang có nhiều tiếng ồn. Vui lòng thu âm lại ở nơi yên tĩnh hơn.',
      );
      return;
    }
    await _submit('', forceClips: [clip]);
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
      _recordingStartedAt = DateTime.now();
      _recordingElapsed = Duration.zero;
      _waveformLevels = const [];
    });
    _amplitudeSub?.cancel();
    _amplitudeSub = _recorder.amplitudes.listen((_) {
      if (!mounted || !_recording) {
        return;
      }
      setState(() => _waveformLevels = _recorder.levels);
    });
    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (!mounted || !_recording) {
        return;
      }
      final startedAt = _recordingStartedAt;
      if (startedAt == null) {
        return;
      }
      final elapsed = DateTime.now().difference(startedAt);
      setState(() => _recordingElapsed = elapsed);
      if (elapsed >= _maxRecordingDuration) {
        _recordingTimer?.cancel();
        _recordingTimer = null;
        unawaited(_autoSubmitRecording());
      }
    });
  }

  Future<void> _stopRecording() async {
    if (!_recording) {
      return;
    }
    final clip = await _finishActiveRecording();
    if (!mounted) {
      return;
    }
    setState(() {
      if (clip != null) {
        _voiceDrafts.add(clip);
      }
      _waveformLevels = const [];
    });
  }

  Future<void> _cancelRecording() async {
    if (!_recording) {
      return;
    }
    _recordingTimer?.cancel();
    _recordingTimer = null;
    _amplitudeSub?.cancel();
    _amplitudeSub = null;
    await _recorder.cancel();
    if (!mounted) {
      return;
    }
    setState(() {
      _recording = false;
      _recordingStartedAt = null;
      _recordingElapsed = Duration.zero;
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 960;
        final panelWidth = _sidebarWidth();

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
            resizeToAvoidBottomInset: isWide || !sidebarOpen,
            body: isWide
                ? _buildWideLayout(messages, recents)
                : Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IgnorePointer(
                        ignoring:
                            (_dragging ? _dragT : (sidebarOpen ? 1.0 : 0.0)) <
                            0.5,
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
                                _onSidebarDragUpdate(
                                  details.delta.dx,
                                  panelWidth,
                                ),
                            onHorizontalDragEnd: _onSidebarDragEnd,
                          ),
                        ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _buildWideLayout(
    List<ChatMessage> messages,
    List<ChatSession> recents,
  ) {
    return Row(
      children: [
        SizedBox(width: 300, child: _buildSidebar(recents)),
        const VerticalDivider(width: 1),
        Expanded(child: _buildChatColumn(messages, isWide: true)),
      ],
    );
  }

  Widget _buildChatColumn(List<ChatMessage> messages, {bool isWide = false}) {
    return Column(
      children: [
        Container(
          color: AppColor.headerTeal,
          child: SafeArea(bottom: false, child: _buildHeader(isWide: isWide)),
        ),
        Expanded(child: _buildMessages(messages)),
        SafeArea(
          top: false,
          child: DecoratedBox(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColor.divider)),
            ),
            child: Align(
              alignment: Alignment.center,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 860),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpace.md,
                    AppSpace.sm,
                    AppSpace.md,
                    AppSpace.sm,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpace.xs),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.verified_user_outlined,
                              size: 15,
                              color: AppColor.accentVoice,
                            ),
                            const SizedBox(width: AppSpace.xxs),
                            Expanded(
                              child: Text(
                                'Cảnh báo tham khảo • Không thay thế bác sĩ',
                                style: AppTextStyle.caption(
                                  color: AppColor.textMedium,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: _showPrivacyDialog,
                              child: const Text('Quyền riêng tư'),
                            ),
                          ],
                        ),
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(bottom: AppSpace.sm),
                        child: Row(
                          children: [
                            DsDemoActionChip(
                              label: 'Bắt đầu sàng lọc AI',
                              icon: const Icon(
                                Icons.health_and_safety_outlined,
                                size: 16,
                                color: AppColor.accentVoice,
                              ),
                              onTap: () =>
                                  _submit(MistralChatConfig.screeningPrompt),
                            ),
                            const SizedBox(width: AppSpace.xs),
                            DsDemoActionChip(
                              label: 'Hỏi về ho',
                              icon: const Icon(
                                Icons.trending_up_rounded,
                                size: 16,
                                color: AppColor.accentVoice,
                              ),
                              onTap: () => _submit(
                                'Ho kéo dài bao lâu thì cần đi khám?',
                              ),
                            ),
                            const SizedBox(width: AppSpace.xs),
                            DsDemoActionChip(
                              label: 'Theo dõi sức khỏe',
                              icon: const Icon(
                                Icons.description_outlined,
                                size: 16,
                                color: AppColor.accentVoice,
                              ),
                              onTap: () => _submit(
                                'Tôi nên theo dõi những dấu hiệu sức khỏe nào?',
                              ),
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
                              hintText: 'Nhập tin nhắn...',
                              onAttach: () =>
                                  _showPlaceholder('Attachments coming soon'),
                              onMic: _startRecording,
                              onSubmitted: _submit,
                              isRecording: _recording,
                              waveformLevels: _waveformLevels,
                              recordingElapsed: _recordingElapsed,
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
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader({required bool isWide}) {
    final apiReady = ref.watch(mistralChatConfigProvider).hasApiKey;
    return Container(
      color: AppColor.headerTeal,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpace.md,
          vertical: AppSpace.xs,
        ),
        child: Row(
          children: [
            if (isWide)
              const SizedBox(width: 40)
            else
              DsIconButton(
                icon: IconfyIcons.editor.hamburgerMenu.outline.regular,
                tooltip: 'Menu',
                iconColor: AppColor.iconOnAccent,
                onPressed: () => ref.read(sidebarOpenProvider.notifier).open(),
              ),
            Expanded(
              child: Row(
                mainAxisAlignment: isWide
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.center,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Color(0x38FFFFFF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.health_and_safety_outlined,
                      color: AppColor.iconOnAccent,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSpace.xs),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'VN Cough Alert',
                        style: AppTextStyle.label(color: AppColor.textOnAccent),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: apiReady
                                  ? const Color(0xFFB9FFE9)
                                  : AppColor.warning,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: AppSpace.xxs),
                          Text(
                            apiReady ? 'API AI sẵn sàng' : 'Thiếu API key',
                            style: AppTextStyle.caption(
                              color: AppColor.textOnAccent,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  tooltip: 'Thông báo',
                  onPressed: () => _showPlaceholder('Chưa có thông báo mới'),
                  icon: const Icon(
                    Icons.notifications_none_rounded,
                    color: AppColor.iconOnAccent,
                  ),
                ),
                Positioned(
                  top: 3,
                  right: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: AppColor.accentPurple,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text(
                      '4',
                      style: AppTextStyle.caption(
                        color: AppColor.textOnAccent,
                      ).copyWith(fontSize: 10),
                    ),
                  ),
                ),
              ],
            ),
            DsIconButton(
              icon: IconfyIcons.essential.editSquare.outline.regular,
              tooltip: 'Cuộc trò chuyện mới',
              iconColor: AppColor.iconOnAccent,
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
      ),
    );
  }

  Widget _buildMessages(List<ChatMessage> messages) {
    if (messages.isEmpty) {
      return _buildEmptyState();
    }
    return Stack(
      children: [
        ListView.builder(
          controller: _scroll,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpace.lg,
            vertical: AppSpace.md,
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

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpace.lg,
          AppSpace.xl,
          AppSpace.lg,
          AppSpace.md,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: AppColor.accentSoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.health_and_safety_outlined,
                  color: AppColor.accentVoice,
                  size: 38,
                ),
              ),
              const SizedBox(height: AppSpace.lg),
              Text(
                'Bạn đang lo về triệu chứng hô hấp?',
                textAlign: TextAlign.center,
                style: AppTextStyle.display(),
              ),
              const SizedBox(height: AppSpace.sm),
              Text(
                'Mô tả điều bạn đang gặp phải. Mình sẽ giúp bạn sắp xếp thông tin và gợi ý bước tiếp theo.',
                textAlign: TextAlign.center,
                style: AppTextStyle.bodySm(),
              ),
              const SizedBox(height: AppSpace.md),
              Container(
                padding: const EdgeInsets.all(AppSpace.sm),
                decoration: BoxDecoration(
                  color: AppColor.surfaceSoft,
                  borderRadius: BorderRadius.circular(AppRadius.control),
                  border: Border.all(color: AppColor.border),
                ),
                child: const Row(
                  children: [
                    _FlowStep(number: '1', label: 'Thông tin'),
                    _FlowArrow(),
                    _FlowStep(number: '2', label: 'Ho 5 giây'),
                    _FlowArrow(),
                    _FlowStep(number: '3', label: 'Cảnh báo AI'),
                  ],
                ),
              ),
              const SizedBox(height: AppSpace.lg),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: AppSpace.xs,
                runSpacing: AppSpace.xs,
                children: [
                  _SuggestionChip(
                    label: 'Ho kéo dài bao lâu thì cần khám?',
                    onTap: () => _submit('Ho kéo dài bao lâu thì cần khám?'),
                  ),
                  _SuggestionChip(
                    label: 'Phân biệt cảm lạnh và cúm',
                    onTap: () => _submit('Phân biệt cảm lạnh và cúm'),
                  ),
                  _SuggestionChip(
                    label: 'Cách theo dõi triệu chứng',
                    onTap: () => _submit('Cách theo dõi triệu chứng'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpace.sm),
              TextButton.icon(
                onPressed: _showPrivacyDialog,
                icon: const Icon(Icons.privacy_tip_outlined, size: 16),
                label: const Text('Xem điều khoản & quyền riêng tư'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSidebar(List<ChatSession> recents) {
    return DsSidebarPanel(
      title: 'VN Cough Alert',
      searchHint: 'Tìm kiếm',
      searchController: _search,
      onSearchChanged: (value) => setState(() => _query = value),
      recentsLabel: 'Gần đây',
      navItems: [
        DsSidebarNavItem(
          icon: IconfyIcons.essential.document.outline.regular,
          label: 'Thông tin sức khỏe',
          onTap: () {
            _closeSidebar();
            unawaited(
              _submit(
                'Hãy giúp tôi tổng hợp thông tin sức khỏe hô hấp cần cung cấp: tuổi, tiền sử bệnh và triệu chứng hiện tại.',
              ),
            );
          },
        ),
        DsSidebarNavItem(
          icon: IconfyIcons.essential.folder.outline.regular,
          label: 'Lịch sử chẩn đoán',
          onTap: () => _showPlaceholder('Tính năng đang được phát triển'),
        ),
        DsSidebarNavItem(
          icon: IconfyIcons.essential.category.outline.regular,
          label: 'Cơ sở y tế',
          onTap: () {
            _closeSidebar();
            unawaited(
              _submit(
                'Hãy hướng dẫn tôi cách tìm cơ sở y tế gần nhất và khi nào cần đi cấp cứu.',
              ),
            );
          },
        ),
        DsSidebarNavItem(
          icon: IconfyIcons.essential.moreCircle.outline.regular,
          label: 'Cài đặt',
          onTap: _showPrivacyDialog,
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
      footer: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              color: AppColor.accentTint,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_outline,
              color: AppColor.accentVoice,
              size: 19,
            ),
          ),
          const SizedBox(width: AppSpace.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Khách', style: AppTextStyle.label()),
              Text('Tài khoản dùng thử', style: AppTextStyle.caption()),
            ],
          ),
        ],
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  const _SuggestionChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      onPressed: onTap,
      label: Text(label),
      labelStyle: AppTextStyle.label(color: AppColor.accentVoice),
      backgroundColor: AppColor.accentTint,
      side: const BorderSide(color: AppColor.border),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpace.xs,
        vertical: AppSpace.xxs,
      ),
    );
  }
}

class _FlowStep extends StatelessWidget {
  const _FlowStep({required this.number, required this.label});

  final String number;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 13,
            backgroundColor: AppColor.accentVoice,
            child: Text(
              number,
              style: AppTextStyle.caption(color: AppColor.textOnAccent),
            ),
          ),
          const SizedBox(height: AppSpace.xxs),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyle.caption(color: AppColor.textMedium),
          ),
        ],
      ),
    );
  }
}

class _FlowArrow extends StatelessWidget {
  const _FlowArrow();

  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.arrow_forward_rounded,
      size: 16,
      color: AppColor.border,
    );
  }
}
