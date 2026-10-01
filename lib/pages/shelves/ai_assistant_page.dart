import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────────────────────
// FARMTAB DESIGN TOKENS (same system used across the app)
// ─────────────────────────────────────────────────────────────
class FarmTabTheme {
  static const Color forest = Color(0xFF1B4332);
  static const Color grove = Color(0xFF2D6A4F);
  static const Color fern = Color(0xFF40916C);
  static const Color mint = Color(0xFF95D5B2);
  static const Color mist = Color(0xFFD8F3DC);
  static const Color white = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE8E8E8);
  static const Color textH = Color(0xFF111111);
  static const Color textB = Color(0xFF444444);
  static const Color textM = Color(0xFF888888);
  static const Color alertRed = Color(0xFFE63946);

  static TextStyle font({
    required double size,
    required FontWeight weight,
    required Color color,
    double? letterSpacing,
    double? height,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }
}

// ─────────────────────────────────────────────────────────────
// AI ASSISTANT PAGE — basic chat UI shell.
//
// This is UI only for now: no real AI is wired up yet. Send,
// attach image, and chat history are all placeholders that will
// be connected later (e.g. to an Ollama-backed endpoint).
// ─────────────────────────────────────────────────────────────
class AiAssistantPage extends StatefulWidget {
  final Map<String, dynamic> shelf;
  final Map<String, dynamic> organisation;
  final bool embedded;

  const AiAssistantPage({
    super.key,
    required this.shelf,
    required this.organisation,
    this.embedded = false,
  });

  @override
  State<AiAssistantPage> createState() => _AiAssistantPageState();
}

class _AiAssistantPageState extends State<AiAssistantPage> {
  final TextEditingController _chatInputController = TextEditingController();

  @override
  void dispose() {
    _chatInputController.dispose();
    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    if (widget.embedded) {
      return Container(color: FarmTabTheme.white, child: _buildContent());
    }

    return Scaffold(
      backgroundColor: FarmTabTheme.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 3,
        shadowColor: FarmTabTheme.fern.withOpacity(0.35),
        centerTitle: false,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
        ),
        iconTheme: const IconThemeData(color: FarmTabTheme.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [FarmTabTheme.fern, Color(0xFF52B788)],
            ),
          ),
        ),
        title: Text(
          'AI Assistant',
          style: FarmTabTheme.font(
            size: 17,
            weight: FontWeight.w700,
            color: FarmTabTheme.white,
            letterSpacing: -0.2,
          ),
        ),
        actions: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: _showChatHistory,
              child: Container(
                width: 38,
                height: 38,
                margin: const EdgeInsets.only(right: 14),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white.withOpacity(0.25)),
                ),
                child: const Icon(
                  Icons.history_rounded,
                  size: 19,
                  color: FarmTabTheme.white,
                ),
              ),
            ),
          ),
        ],
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        // ── Embedded header row with chat history button
        // (only shown when embedded inside another page's own
        // AppBar, e.g. Shelf Detail's function tabs).
        if (widget.embedded) _buildEmbeddedHeader(),

        // ── Empty conversation state
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      color: FarmTabTheme.mist,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Icon(
                      Icons.smart_toy_rounded,
                      size: 38,
                      color: FarmTabTheme.fern,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Ask me anything',
                    style: FarmTabTheme.font(
                      size: 19,
                      weight: FontWeight.w700,
                      color: FarmTabTheme.textH,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Ask about this shelf\'s sensor readings, growing '
                    'cycle, or anything else on your mind.',
                    textAlign: TextAlign.center,
                    style: FarmTabTheme.font(
                      size: 13,
                      weight: FontWeight.w400,
                      color: FarmTabTheme.textM,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // ── Chat input bar
        Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          decoration: const BoxDecoration(
            color: FarmTabTheme.white,
            border: Border(top: BorderSide(color: FarmTabTheme.border)),
          ),
          child: SafeArea(
            top: false,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // ── Attach image button
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: _showComingSoonChatAction,
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F7F7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.image_outlined,
                        size: 20,
                        color: FarmTabTheme.textM,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // ── Text input
                Expanded(
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 120),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F7F7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextField(
                      controller: _chatInputController,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.newline,
                      style: FarmTabTheme.font(
                        size: 14,
                        weight: FontWeight.w400,
                        color: FarmTabTheme.textH,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Message AI Assistant…',
                        hintStyle: FarmTabTheme.font(
                          size: 14,
                          weight: FontWeight.w400,
                          color: FarmTabTheme.textM,
                        ),
                        filled: true,
                        fillColor: Colors.transparent,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 11,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // ── Send button
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: _showComingSoonChatAction,
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [FarmTabTheme.grove, FarmTabTheme.fern],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: FarmTabTheme.fern.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.send_rounded,
                        size: 18,
                        color: FarmTabTheme.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // When embedded inside Shelf Detail's own header/tabs, there's
  // no AppBar of our own to put the "Chat History" icon in — so
  // we show a slim header row here instead.
  // ------------------------------------------------------------
  Widget _buildEmbeddedHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: const BoxDecoration(
        color: FarmTabTheme.white,
        border: Border(bottom: BorderSide(color: FarmTabTheme.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Chat with AI Assistant',
              style: FarmTabTheme.font(
                size: 14,
                weight: FontWeight.w600,
                color: FarmTabTheme.textM,
              ),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: _showChatHistory,
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7F7),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.history_rounded,
                  size: 17,
                  color: FarmTabTheme.textM,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoonChatAction() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('The AI Assistant will be connected soon.')),
    );
  }

  void _showChatHistory() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: FarmTabTheme.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chat History',
                    style: FarmTabTheme.font(
                      size: 18,
                      weight: FontWeight.w700,
                      color: FarmTabTheme.textH,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: FarmTabTheme.mist,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Icon(
                            Icons.history_rounded,
                            size: 28,
                            color: FarmTabTheme.fern,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'No past conversations yet',
                          style: FarmTabTheme.font(
                            size: 14.5,
                            weight: FontWeight.w600,
                            color: FarmTabTheme.textH,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Conversations with this shelf\'s AI Assistant '
                          'will appear here.',
                          textAlign: TextAlign.center,
                          style: FarmTabTheme.font(
                            size: 12.5,
                            weight: FontWeight.w400,
                            color: FarmTabTheme.textM,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
