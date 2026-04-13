import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitcoach/core/theme/app_theme.dart';
import 'package:fitcoach/data/models/chat_message.dart';
import 'package:fitcoach/data/services/ai_service.dart';
import 'package:fitcoach/data/services/home_provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AIService _ai = AIService();
  final List<ChatMessage> _mensajes = [];
  bool _enviando = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<HomeProvider>();
      final nombre = provider.perfil?.nombre ?? '';
      final saludo = nombre.isNotEmpty
          ? 'Hola $nombre, soy tu entrenador personal.'
          : 'Hola, soy tu entrenador personal.';
      setState(() {
        _mensajes.add(ChatMessage.deIA(
          '$saludo Puedes preguntarme sobre tu plan, suplementación, nutrición o cualquier duda sobre tu entrenamiento.',
        ));
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    final texto = _controller.text.trim();
    if (texto.isEmpty || _enviando) return;

    final provider = context.read<HomeProvider>();
    _controller.clear();

    setState(() {
      _mensajes.add(ChatMessage.deUsuario(texto));
      _mensajes.add(ChatMessage.cargando());
      _enviando = true;
    });
    _scrollToBottom();

    try {
      final historial = _mensajes
          .where((m) => !m.estaCargando)
          .take(_mensajes.length - 2)
          .toList();

      final respuesta = await _ai.enviarMensaje(
        historial: historial,
        mensajeUsuario: texto,
        systemPrompt: provider.buildSystemPromptChat(),
      );

      setState(() {
        _mensajes.removeLast();
        _mensajes.add(ChatMessage.deIA(respuesta));
        _enviando = false;
      });
    } catch (e) {
      setState(() {
        _mensajes.removeLast();
        _mensajes.add(ChatMessage.deIA(
            'Lo siento, ocurrió un error. Por favor intenta de nuevo.'));
        _enviando = false;
      });
    }
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.background,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 1.5),
              ),
              child: const Center(
                child: Text(
                  'FC',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Entrenador FitCoach',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Siempre disponible',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _mensajes.length,
              itemBuilder: (context, i) => _BubbleWidget(
                mensaje: _mensajes[i],
              ),
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.backgroundCard,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _controller,
                style: const TextStyle(
                    color: AppColors.textPrimary, fontSize: 14),
                maxLines: 4,
                minLines: 1,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _enviar(),
                decoration: const InputDecoration(
                  hintText: 'Pregunta algo...',
                  hintStyle: TextStyle(
                      color: AppColors.textSecondary, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _enviar,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _enviando
                    ? AppColors.backgroundElevated
                    : AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: _enviando
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.textSecondary,
                      ),
                    )
                  : const Icon(Icons.arrow_upward,
                      color: AppColors.background, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class _BubbleWidget extends StatelessWidget {
  final ChatMessage mensaje;

  const _BubbleWidget({required this.mensaje});

  @override
  Widget build(BuildContext context) {
    if (mensaje.estaCargando) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12, right: 60),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.backgroundCard,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dot(0),
              const SizedBox(width: 4),
              _dot(1),
              const SizedBox(width: 4),
              _dot(2),
            ],
          ),
        ),
      );
    }

    return Align(
      alignment:
          mensaje.esUsuario ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          bottom: 12,
          left: mensaje.esUsuario ? 60 : 0,
          right: mensaje.esUsuario ? 0 : 60,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: mensaje.esUsuario
              ? AppColors.primary
              : AppColors.backgroundCard,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(mensaje.esUsuario ? 18 : 4),
            bottomRight: Radius.circular(mensaje.esUsuario ? 4 : 18),
          ),
        ),
        child: Text(
          mensaje.contenido,
          style: TextStyle(
            color: mensaje.esUsuario
                ? AppColors.background
                : AppColors.textPrimary,
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _dot(int idx) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.4, end: 1.0),
      duration: Duration(milliseconds: 600 + idx * 200),
      builder: (context, v, child) => Opacity(
        opacity: v,
        child: Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: AppColors.textSecondary,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
