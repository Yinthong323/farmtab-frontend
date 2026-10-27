// import 'dart:typed_data';

// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';

// import '../../services/assistant_service.dart';
// import '../../services/layer_service.dart';
// import 'growth_style.dart';

// // ─────────────────────────────────────────────────────────────
// // AI ASSISTANT PAGE
// // A chat: ask about lettuce growing or your farm, attach a photo (from the
// // phone, or one of the farm's own camera photos) and have it analysed.
// // Every chat is saved on the server and can be reopened from History.
// // ─────────────────────────────────────────────────────────────

// const List<String> _months = [
//   'Jan',
//   'Feb',
//   'Mar',
//   'Apr',
//   'May',
//   'Jun',
//   'Jul',
//   'Aug',
//   'Sep',
//   'Oct',
//   'Nov',
//   'Dec',
// ];

// String _shortDateTime(dynamic iso) {
//   final date = DateTime.tryParse(iso?.toString() ?? '')?.toLocal();

//   if (date == null) return '';

//   final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
//   final minute = date.minute.toString().padLeft(2, '0');

//   return '${date.day} ${_months[date.month - 1]}, '
//       '$hour:$minute ${date.hour >= 12 ? 'PM' : 'AM'}';
// }

// String _timeAgo(dynamic iso) {
//   final date = DateTime.tryParse(iso?.toString() ?? '')?.toLocal();

//   if (date == null) return '';

//   final diff = DateTime.now().difference(date);

//   if (diff.inMinutes < 1) return 'just now';
//   if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
//   if (diff.inHours < 24) return '${diff.inHours} h ago';
//   if (diff.inDays == 1) return 'yesterday';
//   if (diff.inDays < 7) return '${diff.inDays} days ago';

//   return '${date.day} ${_months[date.month - 1]}';
// }

// class _ChatMessage {
//   final bool isUser;
//   final String text;
//   final bool isError;

//   // A photo shown inside the user's bubble. Only one of these is set:
//   final Uint8List? image; //        a photo just attached on this device
//   final int? thumbMessageId; //     a saved preview, loaded from the server
//   final String? farmUrl; //         one of the farm's own photos (path)
//   final String? farmLabel; //       e.g. "Layer 1 · Day 6"
//   final bool photoMissing; //       the photo existed but is no longer there

//   _ChatMessage({
//     required this.isUser,
//     required this.text,
//     this.isError = false,
//     this.image,
//     this.thumbMessageId,
//     this.farmUrl,
//     this.farmLabel,
//     this.photoMissing = false,
//   });
// }

// // One of the farm's own camera photos, chosen in the picker
// class _FarmPhoto {
//   final int imageId;
//   final String path;
//   final String label;

//   _FarmPhoto({required this.imageId, required this.path, required this.label});
// }

// class AiAssistantPage extends StatefulWidget {
//   final Map<String, dynamic> shelf;
//   final Map<String, dynamic> organisation;
//   final bool embedded;

//   const AiAssistantPage({
//     super.key,
//     required this.shelf,
//     required this.organisation,
//     this.embedded = false,
//   });

//   @override
//   State<AiAssistantPage> createState() => _AiAssistantPageState();
// }

// class _AiAssistantPageState extends State<AiAssistantPage> {
//   final AssistantService _service = AssistantService();
//   final ImagePicker _picker = ImagePicker();

//   final TextEditingController _input = TextEditingController();
//   final ScrollController _scroll = ScrollController();

//   final List<_ChatMessage> _messages = [];

//   // Previews of earlier uploaded photos, loaded once each
//   final Map<int, Future<Uint8List>> _thumbCache = {};

//   int? _conversationId; // null = a new chat that is not saved yet
//   String? _title;

//   bool _sending = false;
//   bool _loadingChat = false;

//   // The photo attached to the chat: either one uploaded from this device ...
//   Uint8List? _image;
//   String? _imageName;
//   bool _imageShownInChat = false;

//   // ... or one of the farm's own photos. It is sent with every question until
//   // the user removes it, so follow-up questions are about the same photo.
//   _FarmPhoto? _farmPhoto;
//   bool _farmShownInChat = false;

//   static const List<String> _suggestions = [
//     'What is the best EC for lettuce?',
//     'What pH range should I keep?',
//     'Is my current sensor reading okay?',
//     'What water temperature suits lettuce roots?',
//   ];

//   int get _siteId => widget.shelf['site_id'] as int;
//   int get _shelfId => widget.shelf['id'] as int;

//   bool get _hasPhoto => _image != null || _farmPhoto != null;

//   @override
//   void dispose() {
//     _input.dispose();
//     _scroll.dispose();
//     super.dispose();
//   }

//   // ============================================================
//   // ACTIONS
//   // ============================================================

//   Future<void> _send([String? preset]) async {
//     if (_sending || _loadingChat) return;

//     final typed = (preset ?? _input.text).trim();

//     if (typed.isEmpty && !_hasPhoto) return;

//     final question = typed.isEmpty
//         ? 'Please look at this photo of my lettuce and tell me what you see.'
//         : typed;

//     final uploadBytes = _image;
//     final uploadName = _imageName;
//     final farm = _farmPhoto;

//     // Show a photo in the chat only the first time it is used
//     final showUpload = uploadBytes != null && !_imageShownInChat;
//     final showFarm = farm != null && !_farmShownInChat;

//     setState(() {
//       _messages.add(
//         _ChatMessage(
//           isUser: true,
//           text: question,
//           image: showUpload ? uploadBytes : null,
//           farmUrl: showFarm ? farm?.path : null,
//           farmLabel: showFarm ? farm?.label : null,
//         ),
//       );

//       if (uploadBytes != null) _imageShownInChat = true;
//       if (farm != null) _farmShownInChat = true;

//       _input.clear();
//       _sending = true;
//     });

//     _scrollToBottom();

//     try {
//       final result = await _service.sendMessage(
//         siteId: _siteId,
//         shelfId: _shelfId,
//         message: question,
//         conversationId: _conversationId,
//         layerImageId: farm?.imageId,
//         imageBytes: uploadBytes,
//         imageName: uploadName,
//       );

//       if (!mounted) return;

//       setState(() {
//         _conversationId = result['conversation_id'] as int?;
//         _title = result['title']?.toString();
//         _messages.add(
//           _ChatMessage(isUser: false, text: (result['reply'] ?? '').toString()),
//         );
//       });
//     } catch (e) {
//       if (!mounted) return;

//       setState(() {
//         _messages.add(
//           _ChatMessage(
//             isUser: false,
//             isError: true,
//             text: e.toString().replaceFirst('Exception: ', ''),
//           ),
//         );
//       });
//     } finally {
//       if (mounted) {
//         setState(() {
//           _sending = false;
//         });

//         _scrollToBottom();
//       }
//     }
//   }

//   void _scrollToBottom({bool jump = false}) {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (!_scroll.hasClients) return;

//       final end = _scroll.position.maxScrollExtent;

//       if (jump) {
//         _scroll.jumpTo(end);
//       } else {
//         _scroll.animateTo(
//           end,
//           duration: const Duration(milliseconds: 250),
//           curve: Curves.easeOut,
//         );
//       }
//     });
//   }

//   void _clearAttachments() {
//     _image = null;
//     _imageName = null;
//     _imageShownInChat = false;
//     _farmPhoto = null;
//     _farmShownInChat = false;
//   }

//   // Starts a fresh chat. The old one stays saved in History.
//   void _newChat() {
//     if (_sending) return;

//     setState(() {
//       _messages.clear();
//       _conversationId = null;
//       _title = null;
//       _clearAttachments();
//       _input.clear();
//     });
//   }

//   _ChatMessage _fromServer(Map<String, dynamic> m) {
//     final rawPhoto = m['photo'];

//     final Map<String, dynamic>? photo = rawPhoto is Map
//         ? Map<String, dynamic>.from(rawPhoto)
//         : null;

//     int? thumbMessageId;
//     String? farmUrl;
//     String? farmLabel;
//     bool photoMissing = false;

//     if (photo != null) {
//       final kind = photo['kind'];
//       final available = photo['available'] == true;

//       if (kind == 'upload' && available) {
//         thumbMessageId = m['id'] as int;
//       } else if (kind == 'farm') {
//         farmLabel = photo['label']?.toString();

//         if (available) {
//           farmUrl = photo['url']?.toString();
//         }
//       }

//       photoMissing = !available;
//     }

//     return _ChatMessage(
//       isUser: m['role'] == 'user',
//       text: (m['text'] ?? '').toString(),
//       thumbMessageId: thumbMessageId,
//       farmUrl: farmUrl,
//       farmLabel: farmLabel,
//       photoMissing: photoMissing,
//     );
//   }

//   Future<void> _openConversation(int id) async {
//     setState(() {
//       _loadingChat = true;
//     });

//     try {
//       final data = await _service.getConversation(
//         siteId: _siteId,
//         shelfId: _shelfId,
//         conversationId: id,
//       );

//       if (!mounted) return;

//       final loaded = (data['messages'] as List)
//           .map((m) => _fromServer(Map<String, dynamic>.from(m as Map)))
//           .toList();

//       setState(() {
//         _messages
//           ..clear()
//           ..addAll(loaded);
//         _conversationId = id;
//         _title = data['title']?.toString();
//         _clearAttachments();
//         _loadingChat = false;
//       });

//       _scrollToBottom(jump: true);
//     } catch (e) {
//       if (!mounted) return;

//       setState(() {
//         _loadingChat = false;
//       });

//       _toast(e.toString().replaceFirst('Exception: ', ''));
//     }
//   }

//   void _toast(String text) {
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
//   }

//   // Camera is offered on phones and the web; desktop only has the gallery
//   bool get _cameraAvailable =>
//       kIsWeb ||
//       defaultTargetPlatform == TargetPlatform.android ||
//       defaultTargetPlatform == TargetPlatform.iOS;

//   Future<void> _pickImage(ImageSource source) async {
//     try {
//       final file = await _picker.pickImage(
//         source: source,
//         maxWidth: 1600,
//         imageQuality: 85,
//       );

//       if (file == null) return;

//       final bytes = await file.readAsBytes();

//       if (!mounted) return;

//       setState(() {
//         _clearAttachments();
//         _image = bytes;
//         _imageName = file.name;
//       });
//     } catch (e) {
//       if (!mounted) return;

//       _toast('Could not open the photo picker.');
//     }
//   }

//   Future<void> _pickFarmPhoto() async {
//     final picked = await showModalBottomSheet<_FarmPhoto>(
//       context: context,
//       isScrollControlled: true,
//       showDragHandle: true,
//       backgroundColor: Colors.white,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
//       ),
//       builder: (sheetContext) {
//         return _FarmPhotoSheet(
//           layerService: LayerService(),
//           siteId: _siteId,
//           shelfId: _shelfId,
//         );
//       },
//     );

//     if (picked == null || !mounted) return;

//     setState(() {
//       _clearAttachments();
//       _farmPhoto = picked;
//     });
//   }

//   void _chooseImageSource() {
//     showModalBottomSheet(
//       context: context,
//       showDragHandle: true,
//       backgroundColor: Colors.white,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
//       ),
//       builder: (sheetContext) {
//         return SafeArea(
//           child: Padding(
//             padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 _sourceTile(
//                   sheetContext,
//                   Icons.spa_outlined,
//                   'Farm photo',
//                   'A photo taken by one of your cameras',
//                   _pickFarmPhoto,
//                 ),
//                 _sourceTile(
//                   sheetContext,
//                   Icons.photo_library_outlined,
//                   'Choose from gallery',
//                   'A photo from this device',
//                   () => _pickImage(ImageSource.gallery),
//                 ),
//                 if (_cameraAvailable)
//                   _sourceTile(
//                     sheetContext,
//                     Icons.photo_camera_outlined,
//                     'Take a photo',
//                     'Use the camera now',
//                     () => _pickImage(ImageSource.camera),
//                   ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _sourceTile(
//     BuildContext sheetContext,
//     IconData icon,
//     String title,
//     String subtitle,
//     VoidCallback onTap,
//   ) {
//     return ListTile(
//       leading: GrowthStyle.iconChip(
//         icon,
//         GrowthColors.accentStrong,
//         GrowthColors.accentSoft,
//         size: 42,
//       ),
//       title: Text(
//         title,
//         style: GrowthStyle.text(size: 14.5, weight: FontWeight.w700),
//       ),
//       subtitle: Text(
//         subtitle,
//         style: GrowthStyle.text(
//           size: 12,
//           weight: FontWeight.w400,
//           color: GrowthColors.muted,
//         ),
//       ),
//       onTap: () {
//         Navigator.pop(sheetContext);
//         onTap();
//       },
//     );
//   }

//   void _showHistory() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       showDragHandle: true,
//       backgroundColor: Colors.white,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
//       ),
//       builder: (sheetContext) {
//         return _HistorySheet(
//           service: _service,
//           siteId: _siteId,
//           shelfId: _shelfId,
//           currentId: _conversationId,
//           onOpen: (id) {
//             Navigator.pop(sheetContext);
//             _openConversation(id);
//           },
//           onDeleted: (id) {
//             // Deleting the chat that is open starts a fresh one
//             if (id == _conversationId) _newChat();
//           },
//         );
//       },
//     );
//   }

//   // ============================================================
//   // BUILD
//   // ============================================================

//   @override
//   Widget build(BuildContext context) {
//     final body = Container(color: GrowthColors.page, child: _buildContent());

//     if (widget.embedded) return body;

//     return Scaffold(
//       backgroundColor: GrowthColors.page,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         surfaceTintColor: Colors.white,
//         elevation: 0,
//         iconTheme: const IconThemeData(color: GrowthColors.ink),
//         title: Text(
//           'AI Assistant',
//           style: GrowthStyle.text(size: 17, weight: FontWeight.w800),
//         ),
//       ),
//       body: body,
//     );
//   }

//   Widget _buildContent() {
//     return Column(
//       children: [
//         _buildHeader(),
//         Expanded(child: _buildBody()),
//         if (_hasPhoto) _buildAttachmentChip(),
//         _buildInputBar(),
//       ],
//     );
//   }

//   Widget _buildBody() {
//     if (_loadingChat) {
//       return const Center(
//         child: CircularProgressIndicator(color: GrowthColors.accent),
//       );
//     }

//     return _messages.isEmpty ? _buildEmptyState() : _buildMessageList();
//   }

//   Widget _buildHeader() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.fromLTRB(20, 10, 8, 10),
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         border: Border(bottom: BorderSide(color: GrowthColors.line)),
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   _title ?? 'Ask about your farm',
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                   style: GrowthStyle.text(size: 14.5, weight: FontWeight.w700),
//                 ),
//                 Text(
//                   _conversationId == null
//                       ? 'Questions, or a photo of your lettuce'
//                       : 'Saved chat',
//                   style: GrowthStyle.text(
//                     size: 12,
//                     weight: FontWeight.w400,
//                     color: GrowthColors.muted,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           IconButton(
//             tooltip: 'Chat history',
//             onPressed: _showHistory,
//             icon: const Icon(
//               Icons.history_rounded,
//               color: GrowthColors.accentStrong,
//             ),
//           ),
//           IconButton(
//             tooltip: 'New chat',
//             onPressed: (_messages.isEmpty || _sending) ? null : _newChat,
//             icon: const Icon(Icons.add_comment_outlined),
//             color: GrowthColors.accentStrong,
//             disabledColor: GrowthColors.muted.withOpacity(0.5),
//           ),
//         ],
//       ),
//     );
//   }

//   // ── Empty state with example questions
//   Widget _buildEmptyState() {
//     return Center(
//       child: SingleChildScrollView(
//         padding: const EdgeInsets.all(24),
//         child: ConstrainedBox(
//           constraints: const BoxConstraints(maxWidth: 520),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 width: 76,
//                 height: 76,
//                 decoration: const BoxDecoration(
//                   shape: BoxShape.circle,
//                   gradient: LinearGradient(
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                     colors: [Color(0xFF52C48F), Color(0xFF86DDB6)],
//                   ),
//                 ),
//                 child: const Icon(
//                   Icons.smart_toy_rounded,
//                   size: 36,
//                   color: Colors.white,
//                 ),
//               ),
//               const SizedBox(height: 18),
//               Text(
//                 'How can I help?',
//                 style: GrowthStyle.text(
//                   size: 20,
//                   weight: FontWeight.w800,
//                   letterSpacing: -0.4,
//                 ),
//               ),
//               const SizedBox(height: 6),
//               Text(
//                 'Ask about the best pH, EC, temperature or ORP for lettuce, '
//                 'check your readings, or analyse a photo of your plants.',
//                 textAlign: TextAlign.center,
//                 style: GrowthStyle.text(
//                   size: 13,
//                   weight: FontWeight.w400,
//                   color: GrowthColors.muted,
//                   height: 1.5,
//                 ),
//               ),
//               const SizedBox(height: 22),
//               Wrap(
//                 alignment: WrapAlignment.center,
//                 spacing: 8,
//                 runSpacing: 8,
//                 children: [
//                   for (final text in _suggestions)
//                     ActionChip(
//                       label: Text(
//                         text,
//                         style: GrowthStyle.text(
//                           size: 12.5,
//                           weight: FontWeight.w600,
//                           color: GrowthColors.body,
//                         ),
//                       ),
//                       backgroundColor: Colors.white,
//                       side: const BorderSide(color: GrowthColors.line),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       onPressed: () => _send(text),
//                     ),
//                   ActionChip(
//                     avatar: const Icon(
//                       Icons.spa_outlined,
//                       size: 16,
//                       color: GrowthColors.accentStrong,
//                     ),
//                     label: Text(
//                       'Analyze a farm photo',
//                       style: GrowthStyle.text(
//                         size: 12.5,
//                         weight: FontWeight.w700,
//                         color: GrowthColors.accentStrong,
//                       ),
//                     ),
//                     backgroundColor: GrowthColors.accentSoft,
//                     side: const BorderSide(color: GrowthColors.accentMid),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     onPressed: _pickFarmPhoto,
//                   ),
//                   ActionChip(
//                     avatar: const Icon(
//                       Icons.add_photo_alternate_outlined,
//                       size: 16,
//                       color: GrowthColors.accentStrong,
//                     ),
//                     label: Text(
//                       'Upload a photo',
//                       style: GrowthStyle.text(
//                         size: 12.5,
//                         weight: FontWeight.w700,
//                         color: GrowthColors.accentStrong,
//                       ),
//                     ),
//                     backgroundColor: GrowthColors.accentSoft,
//                     side: const BorderSide(color: GrowthColors.accentMid),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     onPressed: () => _pickImage(ImageSource.gallery),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // ── The conversation
//   Widget _buildMessageList() {
//     return SelectionArea(
//       child: Center(
//         child: ConstrainedBox(
//           constraints: const BoxConstraints(maxWidth: 820),
//           child: ListView.builder(
//             controller: _scroll,
//             padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
//             itemCount: _messages.length + (_sending ? 1 : 0),
//             itemBuilder: (context, index) {
//               if (index == _messages.length) return _buildTypingBubble();

//               final message = _messages[index];

//               return message.isUser
//                   ? _buildUserBubble(message)
//                   : _buildAssistantBubble(message);
//             },
//           ),
//         ),
//       ),
//     );
//   }

//   double _bubbleMaxWidth(BuildContext context) {
//     final width = MediaQuery.sizeOf(context).width;
//     return (width * 0.82).clamp(220.0, 600.0).toDouble();
//   }

//   Future<Uint8List> _thumb(int messageId) {
//     return _thumbCache.putIfAbsent(
//       messageId,
//       () => _service.getMessageImage(
//         siteId: _siteId,
//         shelfId: _shelfId,
//         messageId: messageId,
//       ),
//     );
//   }

//   Widget _photoPlaceholder(IconData? icon) {
//     return Container(
//       color: GrowthColors.accentSoft,
//       alignment: Alignment.center,
//       child: icon == null
//           ? const SizedBox(
//               width: 20,
//               height: 20,
//               child: CircularProgressIndicator(
//                 strokeWidth: 2,
//                 color: GrowthColors.accent,
//               ),
//             )
//           : Icon(icon, color: GrowthColors.muted),
//     );
//   }

//   // The photo inside a user's bubble (or null when the message has none)
//   Widget? _bubblePhoto(_ChatMessage m) {
//     Widget? picture;

//     if (m.image != null) {
//       picture = Image.memory(m.image!, fit: BoxFit.cover);
//     } else if (m.thumbMessageId != null) {
//       picture = FutureBuilder<Uint8List>(
//         future: _thumb(m.thumbMessageId!),
//         builder: (context, snapshot) {
//           if (snapshot.hasData) {
//             return Image.memory(snapshot.data!, fit: BoxFit.cover);
//           }

//           return _photoPlaceholder(
//             snapshot.hasError ? Icons.broken_image_outlined : null,
//           );
//         },
//       );
//     } else if (m.farmUrl != null) {
//       picture = Image.network(
//         LayerService.imageUrl(m.farmUrl!),
//         fit: BoxFit.cover,
//         errorBuilder: (context, error, stackTrace) =>
//             _photoPlaceholder(Icons.broken_image_outlined),
//       );
//     } else if (m.photoMissing) {
//       return Container(
//         margin: const EdgeInsets.only(bottom: 8),
//         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//         decoration: BoxDecoration(
//           color: Colors.white.withOpacity(0.25),
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Text(
//           'Photo no longer available',
//           style: GrowthStyle.text(
//             size: 11.5,
//             weight: FontWeight.w600,
//             color: Colors.white,
//           ),
//         ),
//       );
//     } else {
//       return null;
//     }

//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(12),
//         child: SizedBox(
//           width: 220,
//           height: 160,
//           child: Stack(
//             fit: StackFit.expand,
//             children: [
//               picture,
//               if (m.farmLabel != null)
//                 Positioned(
//                   left: 8,
//                   bottom: 8,
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 9,
//                       vertical: 4,
//                     ),
//                     decoration: BoxDecoration(
//                       color: Colors.black.withOpacity(0.55),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Text(
//                       m.farmLabel!,
//                       style: GrowthStyle.text(
//                         size: 11,
//                         weight: FontWeight.w700,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildUserBubble(_ChatMessage message) {
//     final photo = _bubblePhoto(message);

//     return Align(
//       alignment: Alignment.centerRight,
//       child: ConstrainedBox(
//         constraints: BoxConstraints(maxWidth: _bubbleMaxWidth(context)),
//         child: Container(
//           margin: const EdgeInsets.only(bottom: 14, left: 40),
//           padding: const EdgeInsets.all(12),
//           decoration: const BoxDecoration(
//             color: GrowthColors.accent,
//             borderRadius: BorderRadius.only(
//               topLeft: Radius.circular(18),
//               topRight: Radius.circular(18),
//               bottomLeft: Radius.circular(18),
//               bottomRight: Radius.circular(4),
//             ),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               if (photo != null) photo,
//               Text(
//                 message.text,
//                 style: GrowthStyle.text(
//                   size: 14,
//                   weight: FontWeight.w500,
//                   color: Colors.white,
//                   height: 1.4,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _assistantAvatar() {
//     return Container(
//       width: 32,
//       height: 32,
//       margin: const EdgeInsets.only(right: 8, top: 2),
//       decoration: const BoxDecoration(
//         color: GrowthColors.accentSoft,
//         shape: BoxShape.circle,
//       ),
//       alignment: Alignment.center,
//       child: const Icon(
//         Icons.smart_toy_rounded,
//         size: 17,
//         color: GrowthColors.accentStrong,
//       ),
//     );
//   }

//   Widget _buildAssistantBubble(_ChatMessage message) {
//     return Align(
//       alignment: Alignment.centerLeft,
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           _assistantAvatar(),
//           Flexible(
//             child: ConstrainedBox(
//               constraints: BoxConstraints(maxWidth: _bubbleMaxWidth(context)),
//               child: Container(
//                 margin: const EdgeInsets.only(bottom: 14, right: 24),
//                 padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
//                 decoration: BoxDecoration(
//                   color: message.isError ? GrowthColors.redSoft : Colors.white,
//                   borderRadius: const BorderRadius.only(
//                     topLeft: Radius.circular(4),
//                     topRight: Radius.circular(18),
//                     bottomLeft: Radius.circular(18),
//                     bottomRight: Radius.circular(18),
//                   ),
//                   border: Border.all(
//                     color: message.isError
//                         ? const Color(0xFFF4B9BE)
//                         : GrowthColors.line,
//                   ),
//                 ),
//                 child: message.isError
//                     ? Row(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Icon(
//                             Icons.error_outline_rounded,
//                             size: 18,
//                             color: GrowthColors.red,
//                           ),
//                           const SizedBox(width: 8),
//                           Expanded(
//                             child: Text(
//                               message.text,
//                               style: GrowthStyle.text(
//                                 size: 13.5,
//                                 weight: FontWeight.w500,
//                                 color: GrowthColors.red,
//                                 height: 1.4,
//                               ),
//                             ),
//                           ),
//                         ],
//                       )
//                     : _formattedText(message.text),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTypingBubble() {
//     return Align(
//       alignment: Alignment.centerLeft,
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           _assistantAvatar(),
//           Container(
//             margin: const EdgeInsets.only(bottom: 14),
//             padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(18),
//               border: Border.all(color: GrowthColors.line),
//             ),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const SizedBox(
//                   width: 16,
//                   height: 16,
//                   child: CircularProgressIndicator(
//                     strokeWidth: 2.2,
//                     color: GrowthColors.accent,
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 Text(
//                   'Thinking...',
//                   style: GrowthStyle.text(
//                     size: 13,
//                     weight: FontWeight.w500,
//                     color: GrowthColors.muted,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ------------------------------------------------------------
//   // The assistant writes plain text with "- " bullets and **bold**.
//   // This shows those nicely without needing a markdown package.
//   // ------------------------------------------------------------
//   Widget _formattedText(String text) {
//     final base = GrowthStyle.text(
//       size: 14,
//       weight: FontWeight.w400,
//       color: GrowthColors.ink,
//       height: 1.5,
//     );

//     final children = <Widget>[];

//     for (final rawLine in text.split('\n')) {
//       final line = rawLine.replaceAll('`', '').trimRight();
//       final trimmed = line.trimLeft();

//       if (trimmed.isEmpty) {
//         children.add(const SizedBox(height: 6));
//         continue;
//       }

//       // Headings (# ...) become a bold line
//       if (trimmed.startsWith('#')) {
//         final heading = trimmed.replaceFirst(RegExp(r'^#+\s*'), '');
//         children.add(
//           Padding(
//             padding: const EdgeInsets.only(top: 4, bottom: 2),
//             child: Text(
//               heading.replaceAll('**', ''),
//               style: base.copyWith(fontWeight: FontWeight.w800),
//             ),
//           ),
//         );
//         continue;
//       }

//       final bullet = RegExp(r'^[-*\u2022]\s+(.*)$').firstMatch(trimmed);
//       final numbered = RegExp(r'^(\d+[.)])\s+(.*)$').firstMatch(trimmed);

//       if (bullet != null || numbered != null) {
//         final marker = bullet != null ? '\u2022' : numbered!.group(1)!;
//         final content = bullet != null ? bullet.group(1)! : numbered!.group(2)!;

//         children.add(
//           Padding(
//             padding: const EdgeInsets.only(top: 3, left: 2),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 SizedBox(
//                   width: 22,
//                   child: Text(
//                     marker,
//                     style: base.copyWith(
//                       color: GrowthColors.accentStrong,
//                       fontWeight: FontWeight.w700,
//                     ),
//                   ),
//                 ),
//                 Expanded(
//                   child: Text.rich(TextSpan(children: _spans(content, base))),
//                 ),
//               ],
//             ),
//           ),
//         );
//         continue;
//       }

//       children.add(
//         Padding(
//           padding: const EdgeInsets.only(top: 2),
//           child: Text.rich(TextSpan(children: _spans(line, base))),
//         ),
//       );
//     }

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       mainAxisSize: MainAxisSize.min,
//       children: children,
//     );
//   }

//   // **bold** text between double asterisks
//   List<InlineSpan> _spans(String text, TextStyle base) {
//     final parts = text.split('**');

//     return [
//       for (int i = 0; i < parts.length; i++)
//         TextSpan(
//           text: parts[i],
//           style: i.isOdd ? base.copyWith(fontWeight: FontWeight.w800) : base,
//         ),
//     ];
//   }

//   // ── The attached photo, shown above the input
//   Widget _buildAttachmentChip() {
//     final Widget thumbnail;
//     final String title;

//     if (_farmPhoto != null) {
//       thumbnail = Image.network(
//         LayerService.imageUrl(_farmPhoto!.path),
//         width: 44,
//         height: 44,
//         fit: BoxFit.cover,
//         errorBuilder: (context, error, stackTrace) => Container(
//           width: 44,
//           height: 44,
//           color: GrowthColors.line,
//           child: const Icon(Icons.image_not_supported_outlined, size: 18),
//         ),
//       );
//       title = 'Farm photo \u00B7 ${_farmPhoto!.label}';
//     } else {
//       thumbnail = Image.memory(
//         _image!,
//         width: 44,
//         height: 44,
//         fit: BoxFit.cover,
//       );
//       title = 'Photo attached';
//     }

//     return Container(
//       width: double.infinity,
//       color: Colors.white,
//       padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
//       child: Center(
//         child: ConstrainedBox(
//           constraints: const BoxConstraints(maxWidth: 820),
//           child: Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: GrowthColors.accentSoft,
//               borderRadius: BorderRadius.circular(14),
//             ),
//             child: Row(
//               children: [
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(10),
//                   child: thumbnail,
//                 ),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         title,
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                         style: GrowthStyle.text(
//                           size: 12.5,
//                           weight: FontWeight.w700,
//                           color: GrowthColors.accentStrong,
//                         ),
//                       ),
//                       Text(
//                         'Used for your questions until you remove it',
//                         style: GrowthStyle.text(
//                           size: 11,
//                           weight: FontWeight.w400,
//                           color: GrowthColors.body,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 IconButton(
//                   tooltip: 'Remove photo',
//                   onPressed: () => setState(_clearAttachments),
//                   icon: const Icon(
//                     Icons.close_rounded,
//                     size: 20,
//                     color: GrowthColors.body,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // ── Text field, attach and send buttons
//   Widget _buildInputBar() {
//     final canSend =
//         !_sending &&
//         !_loadingChat &&
//         (_input.text.trim().isNotEmpty || _hasPhoto);

//     return Container(
//       padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         border: Border(top: BorderSide(color: GrowthColors.line)),
//       ),
//       child: SafeArea(
//         top: false,
//         child: Center(
//           child: ConstrainedBox(
//             constraints: const BoxConstraints(maxWidth: 820),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.end,
//                   children: [
//                     Material(
//                       color: GrowthColors.page,
//                       borderRadius: BorderRadius.circular(14),
//                       child: InkWell(
//                         borderRadius: BorderRadius.circular(14),
//                         onTap: (_sending || _loadingChat)
//                             ? null
//                             : _chooseImageSource,
//                         child: const SizedBox(
//                           width: 44,
//                           height: 44,
//                           child: Icon(
//                             Icons.add_photo_alternate_outlined,
//                             size: 22,
//                             color: GrowthColors.accentStrong,
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: Container(
//                         constraints: const BoxConstraints(maxHeight: 120),
//                         decoration: BoxDecoration(
//                           color: GrowthColors.page,
//                           borderRadius: BorderRadius.circular(22),
//                         ),
//                         child: TextField(
//                           controller: _input,
//                           minLines: 1,
//                           maxLines: 4,
//                           textInputAction: TextInputAction.newline,
//                           onChanged: (_) => setState(() {}),
//                           style: GrowthStyle.text(
//                             size: 14,
//                             weight: FontWeight.w400,
//                           ),
//                           decoration: InputDecoration(
//                             hintText: _hasPhoto
//                                 ? 'Ask about this photo...'
//                                 : 'Message the assistant...',
//                             hintStyle: GrowthStyle.text(
//                               size: 14,
//                               weight: FontWeight.w400,
//                               color: GrowthColors.muted,
//                             ),
//                             contentPadding: const EdgeInsets.symmetric(
//                               horizontal: 16,
//                               vertical: 12,
//                             ),
//                             border: InputBorder.none,
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     Material(
//                       color: canSend ? GrowthColors.accent : GrowthColors.line,
//                       borderRadius: BorderRadius.circular(14),
//                       child: InkWell(
//                         borderRadius: BorderRadius.circular(14),
//                         onTap: canSend ? () => _send() : null,
//                         child: const SizedBox(
//                           width: 44,
//                           height: 44,
//                           child: Icon(
//                             Icons.arrow_upward_rounded,
//                             size: 22,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 6),
//                 Text(
//                   'AI can make mistakes. Check important decisions.',
//                   style: GrowthStyle.text(
//                     size: 10.5,
//                     weight: FontWeight.w400,
//                     color: GrowthColors.muted,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────
// // HISTORY SHEET: the user's saved chats for this shelf
// // ─────────────────────────────────────────────────────────────

// class _HistorySheet extends StatefulWidget {
//   final AssistantService service;
//   final int siteId;
//   final int shelfId;
//   final int? currentId;
//   final void Function(int id) onOpen;
//   final void Function(int id) onDeleted;

//   const _HistorySheet({
//     required this.service,
//     required this.siteId,
//     required this.shelfId,
//     required this.currentId,
//     required this.onOpen,
//     required this.onDeleted,
//   });

//   @override
//   State<_HistorySheet> createState() => _HistorySheetState();
// }

// class _HistorySheetState extends State<_HistorySheet> {
//   List<Map<String, dynamic>> _chats = [];
//   bool _loading = true;
//   String? _error;

//   @override
//   void initState() {
//     super.initState();
//     _load();
//   }

//   Future<void> _load() async {
//     setState(() {
//       _loading = true;
//       _error = null;
//     });

//     try {
//       final chats = await widget.service.listConversations(
//         siteId: widget.siteId,
//         shelfId: widget.shelfId,
//       );

//       if (!mounted) return;

//       setState(() {
//         _chats = chats;
//         _loading = false;
//       });
//     } catch (e) {
//       if (!mounted) return;

//       setState(() {
//         _loading = false;
//         _error = e.toString().replaceFirst('Exception: ', '');
//       });
//     }
//   }

//   Future<void> _confirmDelete(Map<String, dynamic> chat) async {
//     final id = chat['id'] as int;

//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (dialogContext) {
//         return AlertDialog(
//           backgroundColor: Colors.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(18),
//           ),
//           title: Text(
//             'Delete this chat?',
//             style: GrowthStyle.text(size: 16, weight: FontWeight.w800),
//           ),
//           content: Text(
//             '"${chat['title']}" and all its messages will be removed.',
//             style: GrowthStyle.text(
//               size: 13.5,
//               weight: FontWeight.w400,
//               color: GrowthColors.body,
//               height: 1.4,
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(dialogContext, false),
//               child: Text(
//                 'Cancel',
//                 style: GrowthStyle.text(
//                   size: 13.5,
//                   weight: FontWeight.w600,
//                   color: GrowthColors.muted,
//                 ),
//               ),
//             ),
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: GrowthColors.red,
//                 foregroundColor: Colors.white,
//                 elevation: 0,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               onPressed: () => Navigator.pop(dialogContext, true),
//               child: Text(
//                 'Delete',
//                 style: GrowthStyle.text(
//                   size: 13.5,
//                   weight: FontWeight.w700,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//           ],
//         );
//       },
//     );

//     if (confirmed != true || !mounted) return;

//     try {
//       await widget.service.deleteConversation(
//         siteId: widget.siteId,
//         shelfId: widget.shelfId,
//         conversationId: id,
//       );

//       if (!mounted) return;

//       setState(() {
//         _chats.removeWhere((c) => c['id'] == id);
//       });

//       widget.onDeleted(id);
//     } catch (e) {
//       if (!mounted) return;

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final maxHeight = MediaQuery.sizeOf(context).height * 0.7;

//     return SafeArea(
//       child: ConstrainedBox(
//         constraints: BoxConstraints(maxHeight: maxHeight),
//         child: Padding(
//           padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Chat history',
//                 style: GrowthStyle.text(
//                   size: 18,
//                   weight: FontWeight.w800,
//                   letterSpacing: -0.3,
//                 ),
//               ),
//               const SizedBox(height: 12),
//               Flexible(child: _buildBody()),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildBody() {
//     if (_loading) {
//       return const Padding(
//         padding: EdgeInsets.symmetric(vertical: 40),
//         child: Center(
//           child: CircularProgressIndicator(color: GrowthColors.accent),
//         ),
//       );
//     }

//     if (_error != null) {
//       return Padding(
//         padding: const EdgeInsets.symmetric(vertical: 24),
//         child: Column(
//           children: [
//             Text(
//               _error!,
//               textAlign: TextAlign.center,
//               style: GrowthStyle.text(
//                 size: 13.5,
//                 weight: FontWeight.w400,
//                 color: GrowthColors.body,
//               ),
//             ),
//             const SizedBox(height: 12),
//             OutlinedButton(
//               onPressed: _load,
//               style: GrowthStyle.outlinedButton,
//               child: const Text('Retry'),
//             ),
//           ],
//         ),
//       );
//     }

//     if (_chats.isEmpty) {
//       return Padding(
//         padding: const EdgeInsets.symmetric(vertical: 32),
//         child: Column(
//           children: [
//             GrowthStyle.iconChip(
//               Icons.history_rounded,
//               GrowthColors.accentStrong,
//               GrowthColors.accentSoft,
//               size: 60,
//             ),
//             const SizedBox(height: 14),
//             Text(
//               'No saved chats yet',
//               style: GrowthStyle.text(size: 14.5, weight: FontWeight.w700),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               'Your conversations will appear here.',
//               style: GrowthStyle.text(
//                 size: 12.5,
//                 weight: FontWeight.w400,
//                 color: GrowthColors.muted,
//               ),
//             ),
//           ],
//         ),
//       );
//     }

//     return ListView.separated(
//       shrinkWrap: true,
//       itemCount: _chats.length,
//       separatorBuilder: (context, index) => const SizedBox(height: 8),
//       itemBuilder: (context, index) {
//         final chat = _chats[index];
//         final isCurrent = chat['id'] == widget.currentId;
//         final count = chat['message_count'] ?? 0;

//         return Material(
//           color: isCurrent ? GrowthColors.accentSoft : GrowthColors.page,
//           borderRadius: BorderRadius.circular(14),
//           child: InkWell(
//             borderRadius: BorderRadius.circular(14),
//             onTap: () => widget.onOpen(chat['id'] as int),
//             child: Padding(
//               padding: const EdgeInsets.fromLTRB(14, 10, 4, 10),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           chat['title']?.toString() ?? 'Chat',
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                           style: GrowthStyle.text(
//                             size: 13.5,
//                             weight: FontWeight.w700,
//                           ),
//                         ),
//                         const SizedBox(height: 3),
//                         Text(
//                           '$count messages  \u00B7  ${_timeAgo(chat['updated_at'])}',
//                           style: GrowthStyle.text(
//                             size: 11.5,
//                             weight: FontWeight.w400,
//                             color: GrowthColors.muted,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   IconButton(
//                     tooltip: 'Delete chat',
//                     onPressed: () => _confirmDelete(chat),
//                     icon: const Icon(
//                       Icons.delete_outline_rounded,
//                       size: 20,
//                       color: GrowthColors.muted,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────
// // FARM PHOTO SHEET: pick a layer, then a day, from the cameras' photos
// // ─────────────────────────────────────────────────────────────

// class _FarmPhotoSheet extends StatefulWidget {
//   final LayerService layerService;
//   final int siteId;
//   final int shelfId;

//   const _FarmPhotoSheet({
//     required this.layerService,
//     required this.siteId,
//     required this.shelfId,
//   });

//   @override
//   State<_FarmPhotoSheet> createState() => _FarmPhotoSheetState();
// }

// class _FarmPhotoSheetState extends State<_FarmPhotoSheet> {
//   List<Map<String, dynamic>> _layers = [];
//   bool _loading = true;
//   String? _error;

//   // Step 2: the photos of one layer
//   Map<String, dynamic>? _layer;
//   List<_FarmPhoto> _photos = [];
//   bool _loadingPhotos = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadLayers();
//   }

//   Future<void> _loadLayers() async {
//     setState(() {
//       _loading = true;
//       _error = null;
//     });

//     try {
//       final layers = await widget.layerService.getShelfLayers(
//         siteId: widget.siteId,
//         shelfId: widget.shelfId,
//       );

//       if (!mounted) return;

//       setState(() {
//         _layers = layers;
//         _loading = false;
//       });
//     } catch (e) {
//       if (!mounted) return;

//       setState(() {
//         _loading = false;
//         _error = e.toString().replaceFirst('Exception: ', '');
//       });
//     }
//   }

//   Future<void> _openLayer(Map<String, dynamic> layer) async {
//     setState(() {
//       _layer = layer;
//       _photos = [];
//       _loadingPhotos = true;
//     });

//     final name = layer['display_name']?.toString() ?? 'Layer';

//     try {
//       final detail = await widget.layerService.getLayerDetail(
//         siteId: widget.siteId,
//         shelfId: widget.shelfId,
//         layerId: layer['layer_id'] as int,
//       );

//       if (!mounted) return;

//       final days = (detail['days'] as List?) ?? const [];
//       final photos = <_FarmPhoto>[];

//       // Newest first
//       for (final d in days.reversed) {
//         final day = Map<String, dynamic>.from(d as Map);

//         if (day['image'] == null) continue;

//         final image = Map<String, dynamic>.from(day['image'] as Map);

//         photos.add(
//           _FarmPhoto(
//             imageId: image['id'] as int,
//             path: image['image_url'].toString(),
//             label: '$name \u00B7 Day ${day['day']}',
//           ),
//         );
//       }

//       // A layer without a growing cycle: offer its latest photo
//       if (photos.isEmpty && layer['latest_image'] != null) {
//         final image = Map<String, dynamic>.from(layer['latest_image'] as Map);

//         photos.add(
//           _FarmPhoto(
//             imageId: image['id'] as int,
//             path: image['image_url'].toString(),
//             label: '$name \u00B7 Latest photo',
//           ),
//         );
//       }

//       setState(() {
//         _photos = photos;
//         _loadingPhotos = false;
//       });
//     } catch (e) {
//       if (!mounted) return;

//       setState(() {
//         _loadingPhotos = false;
//         _error = e.toString().replaceFirst('Exception: ', '');
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final maxHeight = MediaQuery.sizeOf(context).height * 0.75;

//     return SafeArea(
//       child: ConstrainedBox(
//         constraints: BoxConstraints(maxHeight: maxHeight),
//         child: Padding(
//           padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
//           child: _layer == null ? _buildLayerStep() : _buildPhotoStep(),
//         ),
//       ),
//     );
//   }

//   Widget _heading(String title, String subtitle, {VoidCallback? onBack}) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 14),
//       child: Row(
//         children: [
//           if (onBack != null)
//             IconButton(
//               onPressed: onBack,
//               icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
//             ),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: GrowthStyle.text(
//                     size: 18,
//                     weight: FontWeight.w800,
//                     letterSpacing: -0.3,
//                   ),
//                 ),
//                 Text(
//                   subtitle,
//                   style: GrowthStyle.text(
//                     size: 12.5,
//                     weight: FontWeight.w400,
//                     color: GrowthColors.muted,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Step 1: the layers
//   Widget _buildLayerStep() {
//     Widget content;

//     if (_loading) {
//       content = const Padding(
//         padding: EdgeInsets.symmetric(vertical: 40),
//         child: Center(
//           child: CircularProgressIndicator(color: GrowthColors.accent),
//         ),
//       );
//     } else if (_error != null) {
//       content = Padding(
//         padding: const EdgeInsets.symmetric(vertical: 24),
//         child: Column(
//           children: [
//             Text(
//               _error!,
//               textAlign: TextAlign.center,
//               style: GrowthStyle.text(
//                 size: 13.5,
//                 weight: FontWeight.w400,
//                 color: GrowthColors.body,
//               ),
//             ),
//             const SizedBox(height: 12),
//             OutlinedButton(
//               onPressed: _loadLayers,
//               style: GrowthStyle.outlinedButton,
//               child: const Text('Retry'),
//             ),
//           ],
//         ),
//       );
//     } else {
//       content = GridView.builder(
//         shrinkWrap: true,
//         itemCount: _layers.length,
//         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 2,
//           mainAxisSpacing: 12,
//           crossAxisSpacing: 12,
//           childAspectRatio: 1.15,
//         ),
//         itemBuilder: (context, index) => _layerTile(_layers[index]),
//       );
//     }

//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _heading('Choose a layer', 'Then pick the day of the photo'),
//         Flexible(child: content),
//       ],
//     );
//   }

//   Widget _layerTile(Map<String, dynamic> layer) {
//     final image = layer['latest_image'] == null
//         ? null
//         : Map<String, dynamic>.from(layer['latest_image'] as Map);

//     return Material(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(16),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(16),
//         onTap: image == null ? null : () => _openLayer(layer),
//         child: Container(
//           clipBehavior: Clip.antiAlias,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(16),
//             border: Border.all(color: GrowthColors.line),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Expanded(
//                 child: SizedBox(
//                   width: double.infinity,
//                   child: image == null
//                       ? Container(
//                           color: GrowthColors.page,
//                           alignment: Alignment.center,
//                           child: const Icon(
//                             Icons.no_photography_outlined,
//                             color: GrowthColors.muted,
//                           ),
//                         )
//                       : Image.network(
//                           LayerService.imageUrl(image['image_url'].toString()),
//                           fit: BoxFit.cover,
//                           errorBuilder: (context, error, stackTrace) =>
//                               Container(
//                                 color: GrowthColors.page,
//                                 child: const Icon(
//                                   Icons.broken_image_outlined,
//                                   color: GrowthColors.muted,
//                                 ),
//                               ),
//                         ),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       layer['display_name']?.toString() ?? 'Layer',
//                       style: GrowthStyle.text(
//                         size: 13,
//                         weight: FontWeight.w800,
//                       ),
//                     ),
//                     Text(
//                       image == null
//                           ? 'No photo yet'
//                           : _shortDateTime(image['captured_at']),
//                       style: GrowthStyle.text(
//                         size: 11,
//                         weight: FontWeight.w400,
//                         color: GrowthColors.muted,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // Step 2: the photos of the chosen layer
//   Widget _buildPhotoStep() {
//     final name = _layer?['display_name']?.toString() ?? 'Layer';

//     Widget content;

//     if (_loadingPhotos) {
//       content = const Padding(
//         padding: EdgeInsets.symmetric(vertical: 40),
//         child: Center(
//           child: CircularProgressIndicator(color: GrowthColors.accent),
//         ),
//       );
//     } else if (_photos.isEmpty) {
//       content = Padding(
//         padding: const EdgeInsets.symmetric(vertical: 32),
//         child: Center(
//           child: Text(
//             _error ?? 'No photos for this layer yet.',
//             textAlign: TextAlign.center,
//             style: GrowthStyle.text(
//               size: 13.5,
//               weight: FontWeight.w400,
//               color: GrowthColors.muted,
//             ),
//           ),
//         ),
//       );
//     } else {
//       content = ListView.separated(
//         shrinkWrap: true,
//         itemCount: _photos.length,
//         separatorBuilder: (context, index) => const SizedBox(height: 8),
//         itemBuilder: (context, index) {
//           final photo = _photos[index];

//           return Material(
//             color: GrowthColors.page,
//             borderRadius: BorderRadius.circular(14),
//             child: InkWell(
//               borderRadius: BorderRadius.circular(14),
//               onTap: () => Navigator.pop(context, photo),
//               child: Padding(
//                 padding: const EdgeInsets.all(8),
//                 child: Row(
//                   children: [
//                     ClipRRect(
//                       borderRadius: BorderRadius.circular(10),
//                       child: Image.network(
//                         LayerService.imageUrl(photo.path),
//                         width: 72,
//                         height: 54,
//                         fit: BoxFit.cover,
//                         errorBuilder: (context, error, stackTrace) => Container(
//                           width: 72,
//                           height: 54,
//                           color: GrowthColors.line,
//                           child: const Icon(
//                             Icons.broken_image_outlined,
//                             size: 20,
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Text(
//                         photo.label,
//                         style: GrowthStyle.text(
//                           size: 13.5,
//                           weight: FontWeight.w700,
//                         ),
//                       ),
//                     ),
//                     if (index == 0)
//                       GrowthStyle.pill(
//                         'Latest',
//                         GrowthColors.accentStrong,
//                         GrowthColors.accentSoft,
//                       ),
//                     const SizedBox(width: 6),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       );
//     }

//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _heading(
//           name,
//           'Choose the photo to analyse',
//           onBack: () => setState(() {
//             _layer = null;
//             _error = null;
//           }),
//         ),
//         Flexible(child: content),
//       ],
//     );
//   }
// }

import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/assistant_service.dart';
import '../../services/layer_service.dart';
import 'growth_style.dart';

// ─────────────────────────────────────────────────────────────
// AI ASSISTANT PAGE
// A chat: ask about lettuce growing or your farm, attach a photo (from the
// phone, or one of the farm's own camera photos) and have it analysed.
// Every chat is saved on the server and can be reopened from History.
// ─────────────────────────────────────────────────────────────

const List<String> _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String _shortDateTime(dynamic iso) {
  final date = DateTime.tryParse(iso?.toString() ?? '')?.toLocal();

  if (date == null) return '';

  final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
  final minute = date.minute.toString().padLeft(2, '0');

  return '${date.day} ${_months[date.month - 1]}, '
      '$hour:$minute ${date.hour >= 12 ? 'PM' : 'AM'}';
}

String _timeAgo(dynamic iso) {
  final date = DateTime.tryParse(iso?.toString() ?? '')?.toLocal();

  if (date == null) return '';

  final diff = DateTime.now().difference(date);

  if (diff.inMinutes < 1) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
  if (diff.inHours < 24) return '${diff.inHours} h ago';
  if (diff.inDays == 1) return 'yesterday';
  if (diff.inDays < 7) return '${diff.inDays} days ago';

  return '${date.day} ${_months[date.month - 1]}';
}

class _ChatMessage {
  final bool isUser;
  final String text;
  final bool isError;
  final bool isStreaming; //        the answer is still arriving

  // A photo shown inside the user's bubble. Only one of these is set:
  final Uint8List? image; //        a photo just attached on this device
  final int? thumbMessageId; //     a saved preview, loaded from the server
  final String? farmUrl; //         one of the farm's own photos (path)
  final String? farmLabel; //       e.g. "Layer 1 · Day 6"
  final bool photoMissing; //       the photo existed but is no longer there

  _ChatMessage({
    required this.isUser,
    required this.text,
    this.isError = false,
    this.isStreaming = false,
    this.image,
    this.thumbMessageId,
    this.farmUrl,
    this.farmLabel,
    this.photoMissing = false,
  });
}

// One of the farm's own camera photos, chosen in the picker
class _FarmPhoto {
  final int imageId;
  final String path;
  final String label;

  _FarmPhoto({required this.imageId, required this.path, required this.label});
}

// The Shelf Detail page keeps the History and New chat buttons in its own
// "AI Assistant" title row. This object connects those buttons to the chat.
class AssistantController extends ChangeNotifier {
  VoidCallback? _openHistory;
  VoidCallback? _startNewChat;
  bool _canStartNewChat = false;

  // false while the chat is empty or an answer is still arriving
  bool get canStartNewChat => _canStartNewChat;

  void openHistory() => _openHistory?.call();

  void newChat() => _startNewChat?.call();

  // Used by the chat page itself
  void _attach(VoidCallback openHistory, VoidCallback startNewChat) {
    _openHistory = openHistory;
    _startNewChat = startNewChat;
  }

  void _detach() {
    _openHistory = null;
    _startNewChat = null;
  }

  void _update(bool canStart) {
    if (_canStartNewChat == canStart) return;

    _canStartNewChat = canStart;
    notifyListeners();
  }
}

class AiAssistantPage extends StatefulWidget {
  final Map<String, dynamic> shelf;
  final Map<String, dynamic> organisation;
  final bool embedded;

  // Lets the Shelf Detail title row open History and start a New chat
  final AssistantController? controller;

  const AiAssistantPage({
    super.key,
    required this.shelf,
    required this.organisation,
    this.embedded = false,
    this.controller,
  });

  @override
  State<AiAssistantPage> createState() => _AiAssistantPageState();
}

class _AiAssistantPageState extends State<AiAssistantPage> {
  final AssistantService _service = AssistantService();
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _input = TextEditingController();
  final ScrollController _scroll = ScrollController();

  final List<_ChatMessage> _messages = [];

  // Previews of earlier uploaded photos, loaded once each
  final Map<int, Future<Uint8List>> _thumbCache = {};

  int? _conversationId; // null = a new chat that is not saved yet
  String? _title;

  bool _sending = false;
  bool _loadingChat = false;

  // The photo attached to the chat: either one uploaded from this device ...
  Uint8List? _image;
  String? _imageName;
  bool _imageShownInChat = false;

  // ... or one of the farm's own photos. It is sent with every question until
  // the user removes it, so follow-up questions are about the same photo.
  _FarmPhoto? _farmPhoto;
  bool _farmShownInChat = false;

  static const List<String> _suggestions = [
    'What is the best EC for lettuce?',
    'What pH range should I keep?',
    'Is my current sensor reading okay?',
    'What water temperature suits lettuce roots?',
  ];

  int get _siteId => widget.shelf['site_id'] as int;
  int get _shelfId => widget.shelf['id'] as int;

  bool get _hasPhoto => _image != null || _farmPhoto != null;

  @override
  void initState() {
    super.initState();
    widget.controller?._attach(_showHistory, _newChat);
  }

  @override
  void dispose() {
    widget.controller?._detach();
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  // Enter sends and Shift+Enter starts a new line, on desktop and in a desktop
  // browser. On a phone, Enter keeps making a new line.
  bool get _desktopEnterToSend =>
      defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.linux;

  KeyEventResult _onInputKey(FocusNode node, KeyEvent event) {
    if (!_desktopEnterToSend || event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    final key = event.logicalKey;

    if (key != LogicalKeyboardKey.enter &&
        key != LogicalKeyboardKey.numpadEnter) {
      return KeyEventResult.ignored;
    }

    // Shift+Enter = a new line
    if (HardwareKeyboard.instance.isShiftPressed) {
      return KeyEventResult.ignored;
    }

    // An input method (for example Chinese pinyin) is still composing text:
    // Enter belongs to it, so do not send yet
    final composing = _input.value.composing;

    if (composing.isValid && !composing.isCollapsed) {
      return KeyEventResult.ignored;
    }

    _send();

    return KeyEventResult.handled;
  }

  Future<void> _copy(String text) async {
    await Clipboard.setData(ClipboardData(text: text));

    if (!mounted) return;

    _toast('Answer copied');
  }

  // Asks the same question again after a failure
  void _retry() {
    if (_sending) return;

    final lastUser = _messages.lastIndexWhere((m) => m.isUser);

    if (lastUser < 0) return;

    final failed = _messages[lastUser];

    setState(() {
      // A photo that was shown with that question is shown again when re-sent
      if (failed.image != null) _imageShownInChat = false;
      if (failed.farmUrl != null) _farmShownInChat = false;

      // Remove that question and everything after it (a partial answer, the error)
      _messages.removeRange(lastUser, _messages.length);
    });

    _send(failed.text);
  }

  // While an answer streams in, keep the newest text in view
  // (unless the user has scrolled up to read something)
  void _scrollIfNear() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;

      final position = _scroll.position;

      if (position.maxScrollExtent - position.pixels < 160) {
        _scroll.jumpTo(position.maxScrollExtent);
      }
    });
  }

  bool get _showTyping =>
      _sending && _messages.isNotEmpty && _messages.last.isUser;

  // ============================================================
  // ACTIONS
  // ============================================================

  Future<void> _send([String? preset]) async {
    if (_sending || _loadingChat) return;

    final typed = (preset ?? _input.text).trim();

    if (typed.isEmpty && !_hasPhoto) return;

    final question = typed.isEmpty
        ? 'Please look at this photo of my lettuce and tell me what you see.'
        : typed;

    final uploadBytes = _image;
    final uploadName = _imageName;
    final farm = _farmPhoto;

    // Show a photo in the chat only the first time it is used
    final showUpload = uploadBytes != null && !_imageShownInChat;
    final showFarm = farm != null && !_farmShownInChat;

    setState(() {
      _messages.add(
        _ChatMessage(
          isUser: true,
          text: question,
          image: showUpload ? uploadBytes : null,
          farmUrl: showFarm ? farm?.path : null,
          farmLabel: showFarm ? farm?.label : null,
        ),
      );

      if (uploadBytes != null) _imageShownInChat = true;
      if (farm != null) _farmShownInChat = true;

      _input.clear();
      _sending = true;
    });

    _scrollToBottom();

    final buffer = StringBuffer();
    bool started = false; // the first piece of the answer has arrived
    bool answered = false; // the whole answer has arrived and is saved
    int? savedChatId;

    try {
      await for (final event in _service.sendMessageStream(
        siteId: _siteId,
        shelfId: _shelfId,
        message: question,
        conversationId: _conversationId,
        layerImageId: farm?.imageId,
        imageBytes: uploadBytes,
        imageName: uploadName,
      )) {
        if (!mounted) return;

        final type = event['event'];

        if (type == 'delta') {
          buffer.write((event['text'] ?? '').toString());

          setState(() {
            final partial = _ChatMessage(
              isUser: false,
              text: buffer.toString(),
              isStreaming: true,
            );

            if (started) {
              _messages[_messages.length - 1] = partial;
            } else {
              _messages.add(partial);
              started = true;
            }
          });

          _scrollIfNear();
        } else if (type == 'done') {
          answered = true;
          savedChatId = event['conversation_id'] as int?;

          setState(() {
            _conversationId = savedChatId;
            _title = event['title']?.toString();

            if (started) {
              _messages[_messages.length - 1] = _ChatMessage(
                isUser: false,
                text: buffer.toString(),
              );
            }

            // The answer is complete. A better title may still follow.
            _sending = false;
          });

          _scrollToBottom();
        } else if (type == 'title') {
          // Ignore it if the user has moved to another chat meanwhile
          if (_conversationId == savedChatId) {
            setState(() {
              _title = event['title']?.toString();
            });
          }
        } else if (type == 'error') {
          throw Exception(
            (event['detail'] ?? 'The assistant could not answer right now.')
                .toString(),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;

      // A failure after the answer was saved (for example while waiting for
      // the title) is not an error for the user
      if (answered) return;

      setState(() {
        // Keep any partial answer, then show the error under it
        if (started) {
          _messages[_messages.length - 1] = _ChatMessage(
            isUser: false,
            text: buffer.toString(),
          );
        }

        _messages.add(
          _ChatMessage(
            isUser: false,
            isError: true,
            text: e.toString().replaceFirst('Exception: ', ''),
          ),
        );
      });
    } finally {
      if (mounted) {
        setState(() {
          _sending = false;
        });

        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom({bool jump = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;

      final end = _scroll.position.maxScrollExtent;

      if (jump) {
        _scroll.jumpTo(end);
      } else {
        _scroll.animateTo(
          end,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _clearAttachments() {
    _image = null;
    _imageName = null;
    _imageShownInChat = false;
    _farmPhoto = null;
    _farmShownInChat = false;
  }

  // Starts a fresh chat. The old one stays saved in History.
  void _newChat() {
    if (_sending) return;

    setState(() {
      _messages.clear();
      _conversationId = null;
      _title = null;
      _clearAttachments();
      _input.clear();
    });
  }

  _ChatMessage _fromServer(Map<String, dynamic> m) {
    final rawPhoto = m['photo'];

    final Map<String, dynamic>? photo = rawPhoto is Map
        ? Map<String, dynamic>.from(rawPhoto)
        : null;

    int? thumbMessageId;
    String? farmUrl;
    String? farmLabel;
    bool photoMissing = false;

    if (photo != null) {
      final kind = photo['kind'];
      final available = photo['available'] == true;

      if (kind == 'upload' && available) {
        thumbMessageId = m['id'] as int;
      } else if (kind == 'farm') {
        farmLabel = photo['label']?.toString();

        if (available) {
          farmUrl = photo['url']?.toString();
        }
      }

      photoMissing = !available;
    }

    return _ChatMessage(
      isUser: m['role'] == 'user',
      text: (m['text'] ?? '').toString(),
      thumbMessageId: thumbMessageId,
      farmUrl: farmUrl,
      farmLabel: farmLabel,
      photoMissing: photoMissing,
    );
  }

  Future<void> _openConversation(int id) async {
    setState(() {
      _loadingChat = true;
    });

    try {
      final data = await _service.getConversation(
        siteId: _siteId,
        shelfId: _shelfId,
        conversationId: id,
      );

      if (!mounted) return;

      final loaded = (data['messages'] as List)
          .map((m) => _fromServer(Map<String, dynamic>.from(m as Map)))
          .toList();

      setState(() {
        _messages
          ..clear()
          ..addAll(loaded);
        _conversationId = id;
        _title = data['title']?.toString();
        _clearAttachments();
        _loadingChat = false;
      });

      _scrollToBottom(jump: true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loadingChat = false;
      });

      _toast(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _toast(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  // Camera is offered on phones and the web; desktop only has the gallery
  bool get _cameraAvailable =>
      kIsWeb ||
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final file = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        imageQuality: 85,
      );

      if (file == null) return;

      final bytes = await file.readAsBytes();

      if (!mounted) return;

      setState(() {
        _clearAttachments();
        _image = bytes;
        _imageName = file.name;
      });
    } catch (e) {
      if (!mounted) return;

      _toast('Could not open the photo picker.');
    }
  }

  Future<void> _pickFarmPhoto() async {
    final picked = await showModalBottomSheet<_FarmPhoto>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) {
        return _FarmPhotoSheet(
          layerService: LayerService(),
          siteId: _siteId,
          shelfId: _shelfId,
        );
      },
    );

    if (picked == null || !mounted) return;

    setState(() {
      _clearAttachments();
      _farmPhoto = picked;
    });
  }

  void _chooseImageSource() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _sourceTile(
                  sheetContext,
                  Icons.spa_outlined,
                  'Farm photo',
                  'A photo taken by one of your cameras',
                  _pickFarmPhoto,
                ),
                _sourceTile(
                  sheetContext,
                  Icons.photo_library_outlined,
                  'Choose from gallery',
                  'A photo from this device',
                  () => _pickImage(ImageSource.gallery),
                ),
                if (_cameraAvailable)
                  _sourceTile(
                    sheetContext,
                    Icons.photo_camera_outlined,
                    'Take a photo',
                    'Use the camera now',
                    () => _pickImage(ImageSource.camera),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sourceTile(
    BuildContext sheetContext,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: GrowthStyle.iconChip(
        icon,
        GrowthColors.accentStrong,
        GrowthColors.accentSoft,
        size: 42,
      ),
      title: Text(
        title,
        style: GrowthStyle.text(size: 14.5, weight: FontWeight.w700),
      ),
      subtitle: Text(
        subtitle,
        style: GrowthStyle.text(
          size: 12,
          weight: FontWeight.w400,
          color: GrowthColors.muted,
        ),
      ),
      onTap: () {
        Navigator.pop(sheetContext);
        onTap();
      },
    );
  }

  void _showHistory() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) {
        return _HistorySheet(
          service: _service,
          siteId: _siteId,
          shelfId: _shelfId,
          currentId: _conversationId,
          onOpen: (id) {
            Navigator.pop(sheetContext);
            _openConversation(id);
          },
          onDeleted: (id) {
            // Deleting the chat that is open starts a fresh one
            if (id == _conversationId) _newChat();
          },
        );
      },
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    // Tell the Shelf Detail title row whether "New chat" can be used now
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      widget.controller?._update(_messages.isNotEmpty && !_sending);
    });

    final body = Container(color: GrowthColors.page, child: _buildContent());

    if (widget.embedded) return body;

    return Scaffold(
      backgroundColor: GrowthColors.page,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: GrowthColors.ink),
        title: Text(
          _title ?? 'AI Assistant',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GrowthStyle.text(size: 17, weight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'Chat history',
            onPressed: _showHistory,
            icon: const Icon(Icons.history_rounded),
          ),
          IconButton(
            tooltip: 'New chat',
            onPressed: (_messages.isEmpty || _sending) ? null : _newChat,
            icon: const Icon(Icons.add_comment_outlined),
          ),
        ],
      ),
      body: body,
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        Expanded(child: _buildBody()),
        if (_hasPhoto) _buildAttachmentChip(),
        _buildInputBar(),
      ],
    );
  }

  Widget _buildBody() {
    if (_loadingChat) {
      return const Center(
        child: CircularProgressIndicator(color: GrowthColors.accent),
      );
    }

    return _messages.isEmpty ? _buildEmptyState() : _buildMessageList();
  }

  // ── Empty state with example questions
  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF52C48F), Color(0xFF86DDB6)],
                  ),
                ),
                child: const Icon(
                  Icons.smart_toy_rounded,
                  size: 36,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'How can I help?',
                style: GrowthStyle.text(
                  size: 20,
                  weight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 22),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final text in _suggestions)
                    ActionChip(
                      label: Text(
                        text,
                        style: GrowthStyle.text(
                          size: 12.5,
                          weight: FontWeight.w600,
                          color: GrowthColors.body,
                        ),
                      ),
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: GrowthColors.line),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      onPressed: () => _send(text),
                    ),
                  ActionChip(
                    avatar: const Icon(
                      Icons.spa_outlined,
                      size: 16,
                      color: GrowthColors.accentStrong,
                    ),
                    label: Text(
                      'Analyze a farm photo',
                      style: GrowthStyle.text(
                        size: 12.5,
                        weight: FontWeight.w700,
                        color: GrowthColors.accentStrong,
                      ),
                    ),
                    backgroundColor: GrowthColors.accentSoft,
                    side: const BorderSide(color: GrowthColors.accentMid),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    onPressed: _pickFarmPhoto,
                  ),
                  ActionChip(
                    avatar: const Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 16,
                      color: GrowthColors.accentStrong,
                    ),
                    label: Text(
                      'Upload a photo',
                      style: GrowthStyle.text(
                        size: 12.5,
                        weight: FontWeight.w700,
                        color: GrowthColors.accentStrong,
                      ),
                    ),
                    backgroundColor: GrowthColors.accentSoft,
                    side: const BorderSide(color: GrowthColors.accentMid),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    onPressed: () => _pickImage(ImageSource.gallery),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── The conversation
  Widget _buildMessageList() {
    return SelectionArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: ListView.builder(
            controller: _scroll,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            itemCount: _messages.length + (_showTyping ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _messages.length) return _buildTypingBubble();

              final message = _messages[index];

              return message.isUser
                  ? _buildUserBubble(message)
                  : _buildAssistantBubble(message);
            },
          ),
        ),
      ),
    );
  }

  double _bubbleMaxWidth(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return (width * 0.82).clamp(220.0, 600.0).toDouble();
  }

  Future<Uint8List> _thumb(int messageId) {
    return _thumbCache.putIfAbsent(
      messageId,
      () => _service.getMessageImage(
        siteId: _siteId,
        shelfId: _shelfId,
        messageId: messageId,
      ),
    );
  }

  Widget _photoPlaceholder(IconData? icon) {
    return Container(
      color: GrowthColors.accentSoft,
      alignment: Alignment.center,
      child: icon == null
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: GrowthColors.accent,
              ),
            )
          : Icon(icon, color: GrowthColors.muted),
    );
  }

  // The photo inside a user's bubble (or null when the message has none)
  Widget? _bubblePhoto(_ChatMessage m) {
    Widget? picture;

    if (m.image != null) {
      picture = Image.memory(m.image!, fit: BoxFit.cover);
    } else if (m.thumbMessageId != null) {
      picture = FutureBuilder<Uint8List>(
        future: _thumb(m.thumbMessageId!),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Image.memory(snapshot.data!, fit: BoxFit.cover);
          }

          return _photoPlaceholder(
            snapshot.hasError ? Icons.broken_image_outlined : null,
          );
        },
      );
    } else if (m.farmUrl != null) {
      picture = Image.network(
        LayerService.imageUrl(m.farmUrl!),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            _photoPlaceholder(Icons.broken_image_outlined),
      );
    } else if (m.photoMissing) {
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.25),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          'Photo no longer available',
          style: GrowthStyle.text(
            size: 11.5,
            weight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      );
    } else {
      return null;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 220,
          height: 160,
          child: Stack(
            fit: StackFit.expand,
            children: [
              picture,
              if (m.farmLabel != null)
                Positioned(
                  left: 8,
                  bottom: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      m.farmLabel!,
                      style: GrowthStyle.text(
                        size: 11,
                        weight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserBubble(_ChatMessage message) {
    final photo = _bubblePhoto(message);

    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: _bubbleMaxWidth(context)),
        child: Container(
          margin: const EdgeInsets.only(bottom: 14, left: 40),
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            color: GrowthColors.accent,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (photo != null) photo,
              Text(
                message.text,
                style: GrowthStyle.text(
                  size: 14,
                  weight: FontWeight.w500,
                  color: Colors.white,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _assistantAvatar() {
    return Container(
      width: 32,
      height: 32,
      margin: const EdgeInsets.only(right: 8, top: 2),
      decoration: const BoxDecoration(
        color: GrowthColors.accentSoft,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: const Icon(
        Icons.smart_toy_rounded,
        size: 17,
        color: GrowthColors.accentStrong,
      ),
    );
  }

  Widget _buildAssistantBubble(_ChatMessage message) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _assistantAvatar(),
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: _bubbleMaxWidth(context)),
              child: Container(
                margin: const EdgeInsets.only(bottom: 14, right: 24),
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                decoration: BoxDecoration(
                  color: message.isError ? GrowthColors.redSoft : Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(18),
                    bottomLeft: Radius.circular(18),
                    bottomRight: Radius.circular(18),
                  ),
                  border: Border.all(
                    color: message.isError
                        ? const Color(0xFFF4B9BE)
                        : GrowthColors.line,
                  ),
                ),
                child: _assistantBubbleContent(message),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _assistantBubbleContent(_ChatMessage message) {
    if (message.isError) {
      // Only the newest error can be retried
      final canRetry = identical(message, _messages.last) && !_sending;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 18,
                color: GrowthColors.red,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message.text,
                  style: GrowthStyle.text(
                    size: 13.5,
                    weight: FontWeight.w500,
                    color: GrowthColors.red,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          if (canRetry) ...[
            const SizedBox(height: 6),
            TextButton.icon(
              onPressed: _retry,
              icon: const Icon(Icons.refresh_rounded, size: 17),
              label: Text(
                'Retry',
                style: GrowthStyle.text(size: 12.5, weight: FontWeight.w700),
              ),
              style: TextButton.styleFrom(
                foregroundColor: GrowthColors.red,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                minimumSize: const Size(0, 30),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _formattedText(message.text),
        // The Copy button appears when the answer is complete
        if (!message.isStreaming)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => _copy(message.text),
              icon: const Icon(Icons.copy_rounded, size: 15),
              label: Text(
                'Copy',
                style: GrowthStyle.text(size: 12, weight: FontWeight.w600),
              ),
              style: TextButton.styleFrom(
                foregroundColor: GrowthColors.muted,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                minimumSize: const Size(0, 30),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTypingBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _assistantAvatar(),
          Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: GrowthColors.line),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: GrowthColors.accent,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Thinking...',
                  style: GrowthStyle.text(
                    size: 13,
                    weight: FontWeight.w500,
                    color: GrowthColors.muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // The assistant writes plain text with "- " bullets and **bold**.
  // This shows those nicely without needing a markdown package.
  // ------------------------------------------------------------
  Widget _formattedText(String text) {
    final base = GrowthStyle.text(
      size: 14,
      weight: FontWeight.w400,
      color: GrowthColors.ink,
      height: 1.5,
    );

    final children = <Widget>[];

    for (final rawLine in text.split('\n')) {
      final line = rawLine.replaceAll('`', '').trimRight();
      final trimmed = line.trimLeft();

      if (trimmed.isEmpty) {
        children.add(const SizedBox(height: 6));
        continue;
      }

      // Headings (# ...) become a bold line
      if (trimmed.startsWith('#')) {
        final heading = trimmed.replaceFirst(RegExp(r'^#+\s*'), '');
        children.add(
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 2),
            child: Text(
              heading.replaceAll('**', ''),
              style: base.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
        );
        continue;
      }

      final bullet = RegExp(r'^[-*\u2022]\s+(.*)$').firstMatch(trimmed);
      final numbered = RegExp(r'^(\d+[.)])\s+(.*)$').firstMatch(trimmed);

      if (bullet != null || numbered != null) {
        final marker = bullet != null ? '\u2022' : numbered!.group(1)!;
        final content = bullet != null ? bullet.group(1)! : numbered!.group(2)!;

        children.add(
          Padding(
            padding: const EdgeInsets.only(top: 3, left: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 22,
                  child: Text(
                    marker,
                    style: base.copyWith(
                      color: GrowthColors.accentStrong,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Expanded(
                  child: Text.rich(TextSpan(children: _spans(content, base))),
                ),
              ],
            ),
          ),
        );
        continue;
      }

      children.add(
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text.rich(TextSpan(children: _spans(line, base))),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }

  // **bold** text between double asterisks
  List<InlineSpan> _spans(String text, TextStyle base) {
    final parts = text.split('**');

    return [
      for (int i = 0; i < parts.length; i++)
        TextSpan(
          text: parts[i],
          style: i.isOdd ? base.copyWith(fontWeight: FontWeight.w800) : base,
        ),
    ];
  }

  // ── The attached photo, shown above the input
  Widget _buildAttachmentChip() {
    final Widget thumbnail;
    final String title;

    if (_farmPhoto != null) {
      thumbnail = Image.network(
        LayerService.imageUrl(_farmPhoto!.path),
        width: 44,
        height: 44,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: 44,
          height: 44,
          color: GrowthColors.line,
          child: const Icon(Icons.image_not_supported_outlined, size: 18),
        ),
      );
      title = 'Farm photo \u00B7 ${_farmPhoto!.label}';
    } else {
      thumbnail = Image.memory(
        _image!,
        width: 44,
        height: 44,
        fit: BoxFit.cover,
      );
      title = 'Photo attached';
    }

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: GrowthColors.accentSoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: thumbnail,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GrowthStyle.text(
                          size: 12.5,
                          weight: FontWeight.w700,
                          color: GrowthColors.accentStrong,
                        ),
                      ),
                      Text(
                        'Used for your questions until you remove it',
                        style: GrowthStyle.text(
                          size: 11,
                          weight: FontWeight.w400,
                          color: GrowthColors.body,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Remove photo',
                  onPressed: () => setState(_clearAttachments),
                  icon: const Icon(
                    Icons.close_rounded,
                    size: 20,
                    color: GrowthColors.body,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Text field, attach and send buttons
  Widget _buildInputBar() {
    final canSend =
        !_sending &&
        !_loadingChat &&
        (_input.text.trim().isNotEmpty || _hasPhoto);

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: GrowthColors.line)),
      ),
      child: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Material(
                      color: GrowthColors.page,
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: (_sending || _loadingChat)
                            ? null
                            : _chooseImageSource,
                        child: const SizedBox(
                          width: 44,
                          height: 44,
                          child: Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 22,
                            color: GrowthColors.accentStrong,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        constraints: const BoxConstraints(maxHeight: 120),
                        decoration: BoxDecoration(
                          color: GrowthColors.page,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Focus(
                          onKeyEvent: _onInputKey,
                          child: TextField(
                            controller: _input,
                            minLines: 1,
                            maxLines: 4,
                            textInputAction: TextInputAction.newline,
                            onChanged: (_) => setState(() {}),
                            style: GrowthStyle.text(
                              size: 14,
                              weight: FontWeight.w400,
                            ),
                            decoration: InputDecoration(
                              hintText: _hasPhoto
                                  ? 'Ask about this photo...'
                                  : 'Message the assistant...',
                              hintStyle: GrowthStyle.text(
                                size: 14,
                                weight: FontWeight.w400,
                                color: GrowthColors.muted,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Material(
                      color: canSend ? GrowthColors.accent : GrowthColors.line,
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: canSend ? () => _send() : null,
                        child: const SizedBox(
                          width: 44,
                          height: 44,
                          child: Icon(
                            Icons.arrow_upward_rounded,
                            size: 22,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  _desktopEnterToSend
                      ? 'Enter to send  \u00B7  Shift+Enter for a new line  \u00B7  AI can make mistakes.'
                      : 'AI can make mistakes. Check important decisions.',
                  style: GrowthStyle.text(
                    size: 10.5,
                    weight: FontWeight.w400,
                    color: GrowthColors.muted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// HISTORY SHEET: the user's saved chats for this shelf
// ─────────────────────────────────────────────────────────────

class _HistorySheet extends StatefulWidget {
  final AssistantService service;
  final int siteId;
  final int shelfId;
  final int? currentId;
  final void Function(int id) onOpen;
  final void Function(int id) onDeleted;

  const _HistorySheet({
    required this.service,
    required this.siteId,
    required this.shelfId,
    required this.currentId,
    required this.onOpen,
    required this.onDeleted,
  });

  @override
  State<_HistorySheet> createState() => _HistorySheetState();
}

class _HistorySheetState extends State<_HistorySheet> {
  List<Map<String, dynamic>> _chats = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final chats = await widget.service.listConversations(
        siteId: widget.siteId,
        shelfId: widget.shelfId,
      );

      if (!mounted) return;

      setState(() {
        _chats = chats;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _confirmDelete(Map<String, dynamic> chat) async {
    final id = chat['id'] as int;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(
            'Delete this chat?',
            style: GrowthStyle.text(size: 16, weight: FontWeight.w800),
          ),
          content: Text(
            '"${chat['title']}" and all its messages will be removed.',
            style: GrowthStyle.text(
              size: 13.5,
              weight: FontWeight.w400,
              color: GrowthColors.body,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(
                'Cancel',
                style: GrowthStyle.text(
                  size: 13.5,
                  weight: FontWeight.w600,
                  color: GrowthColors.muted,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: GrowthColors.red,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(
                'Delete',
                style: GrowthStyle.text(
                  size: 13.5,
                  weight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    try {
      await widget.service.deleteConversation(
        siteId: widget.siteId,
        shelfId: widget.shelfId,
        conversationId: id,
      );

      if (!mounted) return;

      setState(() {
        _chats.removeWhere((c) => c['id'] == id);
      });

      widget.onDeleted(id);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.7;

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Chat history',
                style: GrowthStyle.text(
                  size: 18,
                  weight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 12),
              Flexible(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: CircularProgressIndicator(color: GrowthColors.accent),
        ),
      );
    }

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: GrowthStyle.text(
                size: 13.5,
                weight: FontWeight.w400,
                color: GrowthColors.body,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _load,
              style: GrowthStyle.outlinedButton,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_chats.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            GrowthStyle.iconChip(
              Icons.history_rounded,
              GrowthColors.accentStrong,
              GrowthColors.accentSoft,
              size: 60,
            ),
            const SizedBox(height: 14),
            Text(
              'No saved chats yet',
              style: GrowthStyle.text(size: 14.5, weight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              'Your conversations will appear here.',
              style: GrowthStyle.text(
                size: 12.5,
                weight: FontWeight.w400,
                color: GrowthColors.muted,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      itemCount: _chats.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final chat = _chats[index];
        final isCurrent = chat['id'] == widget.currentId;
        final count = chat['message_count'] ?? 0;

        return Material(
          color: isCurrent ? GrowthColors.accentSoft : GrowthColors.page,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => widget.onOpen(chat['id'] as int),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 4, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          chat['title']?.toString() ?? 'Chat',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GrowthStyle.text(
                            size: 13.5,
                            weight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '$count messages  \u00B7  ${_timeAgo(chat['updated_at'])}',
                          style: GrowthStyle.text(
                            size: 11.5,
                            weight: FontWeight.w400,
                            color: GrowthColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Delete chat',
                    onPressed: () => _confirmDelete(chat),
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      size: 20,
                      color: GrowthColors.muted,
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

// ─────────────────────────────────────────────────────────────
// FARM PHOTO SHEET: pick a layer, then a day, from the cameras' photos
// ─────────────────────────────────────────────────────────────

class _FarmPhotoSheet extends StatefulWidget {
  final LayerService layerService;
  final int siteId;
  final int shelfId;

  const _FarmPhotoSheet({
    required this.layerService,
    required this.siteId,
    required this.shelfId,
  });

  @override
  State<_FarmPhotoSheet> createState() => _FarmPhotoSheetState();
}

class _FarmPhotoSheetState extends State<_FarmPhotoSheet> {
  List<Map<String, dynamic>> _layers = [];
  bool _loading = true;
  String? _error;

  // Step 2: the photos of one layer
  Map<String, dynamic>? _layer;
  List<_FarmPhoto> _photos = [];
  bool _loadingPhotos = false;

  @override
  void initState() {
    super.initState();
    _loadLayers();
  }

  Future<void> _loadLayers() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final layers = await widget.layerService.getShelfLayers(
        siteId: widget.siteId,
        shelfId: widget.shelfId,
      );

      if (!mounted) return;

      setState(() {
        _layers = layers;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _openLayer(Map<String, dynamic> layer) async {
    setState(() {
      _layer = layer;
      _photos = [];
      _loadingPhotos = true;
    });

    final name = layer['display_name']?.toString() ?? 'Layer';

    try {
      final detail = await widget.layerService.getLayerDetail(
        siteId: widget.siteId,
        shelfId: widget.shelfId,
        layerId: layer['layer_id'] as int,
      );

      if (!mounted) return;

      final days = (detail['days'] as List?) ?? const [];
      final photos = <_FarmPhoto>[];

      // Newest first
      for (final d in days.reversed) {
        final day = Map<String, dynamic>.from(d as Map);

        if (day['image'] == null) continue;

        final image = Map<String, dynamic>.from(day['image'] as Map);

        photos.add(
          _FarmPhoto(
            imageId: image['id'] as int,
            path: image['image_url'].toString(),
            label: '$name \u00B7 Day ${day['day']}',
          ),
        );
      }

      // A layer without a growing cycle: offer its latest photo
      if (photos.isEmpty && layer['latest_image'] != null) {
        final image = Map<String, dynamic>.from(layer['latest_image'] as Map);

        photos.add(
          _FarmPhoto(
            imageId: image['id'] as int,
            path: image['image_url'].toString(),
            label: '$name \u00B7 Latest photo',
          ),
        );
      }

      setState(() {
        _photos = photos;
        _loadingPhotos = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loadingPhotos = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.75;

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
          child: _layer == null ? _buildLayerStep() : _buildPhotoStep(),
        ),
      ),
    );
  }

  Widget _heading(String title, String subtitle, {VoidCallback? onBack}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          if (onBack != null)
            IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GrowthStyle.text(
                    size: 18,
                    weight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  subtitle,
                  style: GrowthStyle.text(
                    size: 12.5,
                    weight: FontWeight.w400,
                    color: GrowthColors.muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Step 1: the layers
  Widget _buildLayerStep() {
    Widget content;

    if (_loading) {
      content = const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: CircularProgressIndicator(color: GrowthColors.accent),
        ),
      );
    } else if (_error != null) {
      content = Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: GrowthStyle.text(
                size: 13.5,
                weight: FontWeight.w400,
                color: GrowthColors.body,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _loadLayers,
              style: GrowthStyle.outlinedButton,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    } else {
      content = GridView.builder(
        shrinkWrap: true,
        itemCount: _layers.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.15,
        ),
        itemBuilder: (context, index) => _layerTile(_layers[index]),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _heading('Choose a layer', 'Then pick the day of the photo'),
        Flexible(child: content),
      ],
    );
  }

  Widget _layerTile(Map<String, dynamic> layer) {
    final image = layer['latest_image'] == null
        ? null
        : Map<String, dynamic>.from(layer['latest_image'] as Map);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: image == null ? null : () => _openLayer(layer),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: GrowthColors.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SizedBox(
                  width: double.infinity,
                  child: image == null
                      ? Container(
                          color: GrowthColors.page,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.no_photography_outlined,
                            color: GrowthColors.muted,
                          ),
                        )
                      : Image.network(
                          LayerService.imageUrl(image['image_url'].toString()),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                color: GrowthColors.page,
                                child: const Icon(
                                  Icons.broken_image_outlined,
                                  color: GrowthColors.muted,
                                ),
                              ),
                        ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      layer['display_name']?.toString() ?? 'Layer',
                      style: GrowthStyle.text(
                        size: 13,
                        weight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      image == null
                          ? 'No photo yet'
                          : _shortDateTime(image['captured_at']),
                      style: GrowthStyle.text(
                        size: 11,
                        weight: FontWeight.w400,
                        color: GrowthColors.muted,
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
  }

  // Step 2: the photos of the chosen layer
  Widget _buildPhotoStep() {
    final name = _layer?['display_name']?.toString() ?? 'Layer';

    Widget content;

    if (_loadingPhotos) {
      content = const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: CircularProgressIndicator(color: GrowthColors.accent),
        ),
      );
    } else if (_photos.isEmpty) {
      content = Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Text(
            _error ?? 'No photos for this layer yet.',
            textAlign: TextAlign.center,
            style: GrowthStyle.text(
              size: 13.5,
              weight: FontWeight.w400,
              color: GrowthColors.muted,
            ),
          ),
        ),
      );
    } else {
      content = ListView.separated(
        shrinkWrap: true,
        itemCount: _photos.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final photo = _photos[index];

          return Material(
            color: GrowthColors.page,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => Navigator.pop(context, photo),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        LayerService.imageUrl(photo.path),
                        width: 72,
                        height: 54,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 72,
                          height: 54,
                          color: GrowthColors.line,
                          child: const Icon(
                            Icons.broken_image_outlined,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        photo.label,
                        style: GrowthStyle.text(
                          size: 13.5,
                          weight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (index == 0)
                      GrowthStyle.pill(
                        'Latest',
                        GrowthColors.accentStrong,
                        GrowthColors.accentSoft,
                      ),
                    const SizedBox(width: 6),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _heading(
          name,
          'Choose the photo to analyse',
          onBack: () => setState(() {
            _layer = null;
            _error = null;
          }),
        ),
        Flexible(child: content),
      ],
    );
  }
}
