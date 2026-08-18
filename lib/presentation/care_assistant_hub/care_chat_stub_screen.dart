import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../models/plant.dart';
import '../../providers/plant_ai_service_provider.dart';
import '../../services/plant_ai_service.dart';

class CareChatStubScreen extends StatefulWidget {
  const CareChatStubScreen({super.key, this.plant});

  final Plant? plant;

  @override
  State<CareChatStubScreen> createState() => _CareChatStubScreenState();
}

class _CareChatStubScreenState extends State<CareChatStubScreen> {
  final TextEditingController _inputController = TextEditingController();
  final List<ChatMessage> _messages = [];
  PlantAiService _service = const StubPlantAiService();
  PlantAiError? _chatError;
  bool _isTyping = false;
  bool _isOnline = true;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _inputController.addListener(_handleInputChanged);
    final connectivity = Connectivity();
    _connectivitySubscription = connectivity.onConnectivityChanged.listen(
      _handleConnectivityChanged,
      onError: (_) {},
    );
    connectivity
        .checkConnectivity()
        .then(_handleConnectivityChanged)
        .catchError((_) {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final service = PlantAiServiceProvider.of(context);
    if (!identical(service, _service)) {
      _service = service;
    }
  }

  @override
  void dispose() {
    _inputController.removeListener(_handleInputChanged);
    _inputController.dispose();
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  void _handleInputChanged() {
    setState(() {});
  }

  void _handleConnectivityChanged(List<ConnectivityResult> results) {
    final isOnline = !results.contains(ConnectivityResult.none);
    if (mounted && isOnline != _isOnline) {
      setState(() => _isOnline = isOnline);
    }
  }

  bool get _canSend =>
      _inputController.text.trim().isNotEmpty && !_isTyping && _isOnline;

  void _sendMessage() {
    final text = _inputController.text.trim();
    if (!_canSend) return;
    setState(() {
      _messages.add(ChatMessage(role: 'user', text: text));
      _chatError = null;
      _isTyping = true;
    });
    _inputController.clear();
    FocusScope.of(context).unfocus();
    _requestReply();
  }

  Future<void> _requestReply() async {
    try {
      final reply = await _service.chatAboutPlant(_buildRequest());
      if (!mounted) return;
      setState(() {
        _messages.add(ChatMessage(role: 'assistant', text: reply));
        _isTyping = false;
      });
    } on PlantAiError catch (error) {
      if (!mounted) return;
      setState(() {
        _chatError = error;
        _isTyping = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _chatError = const UnknownError();
        _isTyping = false;
      });
    }
  }

  ChatRequest _buildRequest() {
    final history = _messages.length > plantAiChatHistoryLimit
        ? _messages.sublist(_messages.length - plantAiChatHistoryLimit)
        : _messages;
    final plant = widget.plant;
    return ChatRequest(
      plantName: plant?.name ?? 'your plant',
      species: plant?.species,
      light: plant?.light,
      humidity: plant?.humidity,
      location: plant?.location,
      careSchedule: plant?.careSchedule ?? const {},
      notes: plant?.careNotes,
      messages: history,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Care chat',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _messages.isEmpty
                  ? const _ChatWelcome()
                  : ListView.builder(
                      padding: EdgeInsets.all(4.w),
                      itemCount: _messages.length + (_isTyping ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _messages.length) {
                          return const _TypingBubble();
                        }
                        return _MessageBubble(message: _messages[index]);
                      },
                    ),
            ),
            if (_chatError != null) _RestingCard(error: _chatError!),
            _Composer(
              controller: _inputController,
              canSend: _canSend,
              onSend: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatWelcome extends StatelessWidget {
  const _ChatWelcome();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chat_outlined,
                size: 8.w,
                color: colorScheme.primary,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Ask about watering, light, pests and more',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            SizedBox(height: 1.h),
            Text(
              'The assistant answers using your plant profile, '
              'care schedule and health history.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white70 : const Color(0xFF888888),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';
    final colorScheme = Theme.of(context).colorScheme;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 1.5.h),
        padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 1.5.h),
        constraints: BoxConstraints(maxWidth: 78.w),
        decoration: BoxDecoration(
          color: isUser ? colorScheme.primary : Theme.of(context).cardColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            fontSize: 14,
            height: 1.3,
            color: isUser
                ? colorScheme.onPrimary
                : colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 1.5.h),
        padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 1.5.h),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          'Assistant is typing…',
          style: TextStyle(
            fontSize: 13,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _RestingCard extends StatelessWidget {
  const _RestingCard({required this.error});

  final PlantAiError error;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: EdgeInsets.fromLTRB(4.w, 0, 4.w, 1.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: isDark ? Theme.of(context).cardColor : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(2.5.w),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.self_improvement,
              size: 5.w,
              color: colorScheme.primary,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'The assistant is resting',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                SizedBox(height: 0.3.h),
                Text(
                  error.message,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white70 : const Color(0xFF888888),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.canSend,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool canSend;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.fromLTRB(4.w, 1.h, 4.w, 2.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) {
                if (canSend) onSend();
              },
              decoration: InputDecoration(
                hintText: 'Ask about your plant...',
                filled: true,
                fillColor: isDark ? Theme.of(context).cardColor : Colors.white,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 3.5.w,
                  vertical: 1.5.h,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color: colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          SizedBox(width: 2.w),
          IconButton.filled(
            onPressed: canSend ? onSend : null,
            icon: Icon(Icons.send, size: 5.w),
          ),
        ],
      ),
    );
  }
}