import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_client.dart';
import '../../../core/realtime/signalr_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/mono_text.dart';
import '../../../features/auth/bloc/auth_bloc.dart';
import '../../../shared/models/chat_message_model.dart';
import '../bloc/chat_bloc.dart';
import '../data/chat_repository.dart';

class EventChatPage extends StatefulWidget {
  final String eventId;
  final String eventTitle;
  final SignalRService signalRService;
  final ApiClient apiClient;

  const EventChatPage({
    super.key,
    required this.eventId,
    required this.eventTitle,
    required this.signalRService,
    required this.apiClient,
  });

  @override
  State<EventChatPage> createState() => _EventChatPageState();
}

class _EventChatPageState extends State<EventChatPage> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ChatBloc(
        repository: ChatRepository(widget.apiClient),
        signalRService: widget.signalRService,
      )..add(ChatStarted(widget.eventId)),
      child: Scaffold(
        backgroundColor: AppColors.bgVoid,
        appBar: AppBar(
          backgroundColor: AppColors.bgSurface,
          foregroundColor: AppColors.fgPrimary,
          title: Text(
            widget.eventTitle.toUpperCase(),
            style: AppTextStyles.monoDisplay.copyWith(fontSize: 12),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: AppColors.fgMuted),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: BlocConsumer<ChatBloc, ChatState>(
                listener: (context, state) {
                  if (state is ChatLoaded) _scrollToBottom();
                },
                builder: (context, state) {
                  if (state is ChatLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.phosphor),
                    );
                  }
                  if (state is ChatError) {
                    return Center(
                      child: MonoText(state.message,
                          color: AppColors.fgSecondary),
                    );
                  }
                  if (state is ChatLoaded) {
                    final authState = context.watch<AuthBloc>().state;
                    final myId = authState is AuthAuthenticated
                        ? authState.userId
                        : null;
                    if (state.messages.isEmpty) {
                      return const Center(
                        child: MonoText(
                          'sin mensajes aún',
                          color: AppColors.fgSecondary,
                        ),
                      );
                    }
                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(12),
                      itemCount: state.messages.length,
                      itemBuilder: (context, i) {
                        final msg = state.messages[i];
                        return _ChatBubble(
                          message: msg,
                          isMe: msg.senderId == myId,
                        );
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            Builder(
              builder: (ctx) => _ChatInput(
                controller: _textController,
                onSend: () {
                  final text = _textController.text.trim();
                  if (text.isEmpty) return;
                  ctx.read<ChatBloc>().add(ChatMessageSent(text));
                  _textController.clear();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessageModel message;
  final bool isMe;

  const _ChatBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final bubbleColor =
        isMe ? AppColors.phosphor.withAlpha(20) : AppColors.bgElevated;
    final handleColor =
        isMe ? AppColors.phosphor : AppColors.fgSecondary;
    final time =
        '${message.sentAt.hour.toString().padLeft(2, '0')}:${message.sentAt.minute.toString().padLeft(2, '0')}';

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bubbleColor,
          border: Border.all(
            color: isMe ? AppColors.phosphor : AppColors.fgMuted,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            MonoText(
              message.senderHandle,
              color: handleColor,
              size: 10,
            ),
            const SizedBox(height: 4),
            Text(
              message.content,
              style: const TextStyle(
                color: AppColors.fgPrimary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            MonoText(time, color: AppColors.fgSecondary, size: 9),
          ],
        ),
      ),
    );
  }
}

class _ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const _ChatInput({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bgSurface,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              style: const TextStyle(color: AppColors.fgPrimary, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'mensaje...',
                hintStyle: const TextStyle(
                    color: AppColors.fgSecondary, fontSize: 13),
                filled: true,
                fillColor: AppColors.bgElevated,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                enabledBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                  borderSide: BorderSide(color: AppColors.fgMuted),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                  borderSide: BorderSide(color: AppColors.phosphor),
                ),
              ),
              onSubmitted: (_) => onSend(),
              textInputAction: TextInputAction.send,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onSend,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.phosphor),
              ),
              child: const Icon(Icons.send,
                  color: AppColors.phosphor, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}
