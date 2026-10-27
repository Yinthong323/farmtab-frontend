// import 'package:flutter/material.dart';

// import '../../services/layer_service.dart';
// import 'layer_detail_page.dart';
// import 'shelf_detail_page.dart' show FarmTabTheme;

// class GrowthMonitoringPage extends StatefulWidget {
//   final Map<String, dynamic> shelf;
//   final Map<String, dynamic> organisation;
//   final bool embedded;

//   const GrowthMonitoringPage({
//     super.key,
//     required this.shelf,
//     required this.organisation,
//     this.embedded = true,
//   });

//   @override
//   State<GrowthMonitoringPage> createState() => _GrowthMonitoringPageState();
// }

// class _GrowthMonitoringPageState extends State<GrowthMonitoringPage> {
//   final LayerService _layerService = LayerService();

//   List<Map<String, dynamic>> _layers = [];

//   // Layers currently showing the pink overlay instead of the plain photo
//   final Set<int> _overlayLayers = {};
//   bool _isLoading = true;
//   String? _error;

//   // An image older than this is flagged, because a new photo is
//   // expected every day at 8:00 PM.
//   static const Duration _staleAfter = Duration(hours: 26);

//   @override
//   void initState() {
//     super.initState();
//     _loadLayers();
//   }

//   Future<void> _loadLayers() async {
//     setState(() {
//       _error = null;
//       if (_layers.isEmpty) _isLoading = true;
//     });

//     try {
//       final layers = await _layerService.getShelfLayers(
//         siteId: widget.shelf['site_id'],
//         shelfId: widget.shelf['id'],
//       );

//       if (!mounted) return;

//       setState(() {
//         _layers = layers;
//         _isLoading = false;
//       });
//     } catch (e) {
//       if (!mounted) return;

//       setState(() {
//         _isLoading = false;
//         _error = e.toString().replaceFirst('Exception: ', '');
//       });
//     }
//   }

//   // ============================================================
//   // BUILD
//   // ============================================================

//   @override
//   Widget build(BuildContext context) {
//     final content = RefreshIndicator(
//       color: FarmTabTheme.grove,
//       onRefresh: _loadLayers,
//       child: SingleChildScrollView(
//         physics: const AlwaysScrollableScrollPhysics(),
//         padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildHeader(),
//             const SizedBox(height: 16),
//             if (_isLoading)
//               _buildLoading()
//             else if (_error != null && _layers.isEmpty)
//               _buildError()
//             else if (_layers.isEmpty)
//               _buildEmpty()
//             else
//               _buildLayerGrid(),
//           ],
//         ),
//       ),
//     );

//     if (widget.embedded) return content;

//     return Scaffold(
//       backgroundColor: FarmTabTheme.white,
//       appBar: AppBar(title: const Text('Growth Monitoring')),
//       body: content,
//     );
//   }

//   Widget _buildHeader() {
//     return Row(
//       children: [
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Latest Layer Images',
//                 style: FarmTabTheme.font(
//                   size: 17,
//                   weight: FontWeight.w700,
//                   color: FarmTabTheme.textH,
//                   letterSpacing: -0.2,
//                 ),
//               ),
//               const SizedBox(height: 3),
//               Text(
//                 'Captured automatically every day at 8:00 PM',
//                 style: FarmTabTheme.font(
//                   size: 12.5,
//                   weight: FontWeight.w400,
//                   color: FarmTabTheme.textM,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         Material(
//           color: Colors.transparent,
//           child: InkWell(
//             borderRadius: BorderRadius.circular(10),
//             onTap: _loadLayers,
//             child: Container(
//               width: 38,
//               height: 38,
//               alignment: Alignment.center,
//               decoration: BoxDecoration(
//                 color: FarmTabTheme.mist,
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: const Icon(
//                 Icons.refresh_rounded,
//                 size: 19,
//                 color: FarmTabTheme.grove,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   // One column on phones, two columns on wider screens.
//   Widget _buildLayerGrid() {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final twoColumns = constraints.maxWidth >= 600;

//         if (!twoColumns) {
//           return Column(
//             children: [
//               for (final layer in _layers) ...[
//                 _buildLayerCard(layer),
//                 const SizedBox(height: 14),
//               ],
//             ],
//           );
//         }

//         final rows = <Widget>[];

//         for (int i = 0; i < _layers.length; i += 2) {
//           rows.add(
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Expanded(child: _buildLayerCard(_layers[i])),
//                 const SizedBox(width: 14),
//                 Expanded(
//                   child: i + 1 < _layers.length
//                       ? _buildLayerCard(_layers[i + 1])
//                       : const SizedBox(),
//                 ),
//               ],
//             ),
//           );
//           rows.add(const SizedBox(height: 14));
//         }

//         return Column(children: rows);
//       },
//     );
//   }

//   // ============================================================
//   // LAYER CARD
//   // ============================================================

//   Widget _buildLayerCard(Map<String, dynamic> layer) {
//     final name = layer['display_name']?.toString() ?? 'Layer';
//     final code = layer['code']?.toString() ?? '';

//     final image = layer['latest_image'] == null
//         ? null
//         : Map<String, dynamic>.from(layer['latest_image'] as Map);

//     final cycle = layer['active_cycle'] == null
//         ? null
//         : Map<String, dynamic>.from(layer['active_cycle'] as Map);

//     final layerId = layer['layer_id'] as int;

//     final canopy = image == null || image['canopy'] == null
//         ? null
//         : Map<String, dynamic>.from(image['canopy'] as Map);

//     final overlayUrl = canopy?['overlay_url']?.toString();
//     final hasOverlay = overlayUrl != null && overlayUrl.isNotEmpty;
//     final showOverlay = hasOverlay && _overlayLayers.contains(layerId);

//     return Container(
//       clipBehavior: Clip.antiAlias,
//       decoration: FarmTabTheme.cardDecoration,
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           // Tapping the card opens the Layer Detail page
//           onTap: () => _openLayerDetail(layer),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // ── Header: layer name, camera code, cycle status
//               Padding(
//                 padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
//                 child: Row(
//                   children: [
//                     Text(
//                       name,
//                       style: FarmTabTheme.font(
//                         size: 15,
//                         weight: FontWeight.w700,
//                         color: FarmTabTheme.textH,
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     _chip(code, FarmTabTheme.textM, const Color(0xFFF2F2F2)),
//                     const Spacer(),
//                     _buildCycleChip(cycle),
//                     if (cycle != null)
//                       PopupMenuButton<String>(
//                         padding: EdgeInsets.zero,
//                         icon: const Icon(
//                           Icons.more_vert_rounded,
//                           size: 20,
//                           color: FarmTabTheme.textM,
//                         ),
//                         onSelected: (value) {
//                           if (value == 'abort') {
//                             _confirmAbortCycle(layer, cycle);
//                           }
//                         },
//                         itemBuilder: (context) => [
//                           PopupMenuItem<String>(
//                             value: 'abort',
//                             child: Text(
//                               'Abort cycle',
//                               style: FarmTabTheme.font(
//                                 size: 13.5,
//                                 weight: FontWeight.w500,
//                                 color: FarmTabTheme.alertRed,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     const Icon(
//                       Icons.chevron_right_rounded,
//                       size: 22,
//                       color: FarmTabTheme.textM,
//                     ),
//                   ],
//                 ),
//               ),

//               // ── Image (4:3, same shape as the camera photos)
//               AspectRatio(
//                 aspectRatio: 4 / 3,
//                 child: image == null
//                     ? _buildNoImage(hasCycle: cycle != null)
//                     : Stack(
//                         fit: StackFit.expand,
//                         children: [
//                           _buildImage(
//                             name,
//                             image,
//                             (showOverlay && overlayUrl != null)
//                                 ? overlayUrl
//                                 : image['image_url'].toString(),
//                           ),

//                           // Photo / Canopy switch, top-right of the image
//                           if (hasOverlay)
//                             Positioned(
//                               top: 10,
//                               right: 10,
//                               child: Material(
//                                 color: Colors.black.withOpacity(0.55),
//                                 borderRadius: BorderRadius.circular(20),
//                                 child: InkWell(
//                                   borderRadius: BorderRadius.circular(20),
//                                   onTap: () {
//                                     setState(() {
//                                       if (showOverlay) {
//                                         _overlayLayers.remove(layerId);
//                                       } else {
//                                         _overlayLayers.add(layerId);
//                                       }
//                                     });
//                                   },
//                                   child: Padding(
//                                     padding: const EdgeInsets.symmetric(
//                                       horizontal: 11,
//                                       vertical: 7,
//                                     ),
//                                     child: Row(
//                                       mainAxisSize: MainAxisSize.min,
//                                       children: [
//                                         Icon(
//                                           showOverlay
//                                               ? Icons.photo_outlined
//                                               : Icons.layers_rounded,
//                                           size: 14,
//                                           color: Colors.white,
//                                         ),
//                                         const SizedBox(width: 6),
//                                         Text(
//                                           showOverlay ? 'Photo' : 'Canopy',
//                                           style: FarmTabTheme.font(
//                                             size: 11.5,
//                                             weight: FontWeight.w600,
//                                             color: Colors.white,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                         ],
//                       ),
//               ),

//               // ── Canopy measurement
//               if (image != null)
//                 Padding(
//                   padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
//                   child: _buildCanopyStats(canopy),
//                 ),

//               // ── Footer: capture time
//               Padding(
//                 padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
//                 child: _buildImageFooter(image, hasCycle: cycle != null),
//               ),

//               // ── Start button (no cycle) or cycle details (active cycle)
//               if (cycle == null)
//                 Padding(
//                   padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
//                   child: SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       onPressed: () => _showStartCycleDialog(layer),
//                       style: FarmTabTheme.primaryButton,
//                       child: Text(
//                         'Start Growing Cycle',
//                         style: FarmTabTheme.font(
//                           size: 13,
//                           weight: FontWeight.w600,
//                           color: FarmTabTheme.white,
//                         ),
//                       ),
//                     ),
//                   ),
//                 )
//               else
//                 Padding(
//                   padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       _buildCycleInfo(cycle),
//                       const SizedBox(height: 12),
//                       SizedBox(
//                         width: double.infinity,
//                         child: OutlinedButton(
//                           onPressed: () => _showHarvestDialog(layer, cycle),
//                           style: FarmTabTheme.outlinedButton,
//                           child: Text(
//                             'Harvest',
//                             style: FarmTabTheme.font(
//                               size: 13,
//                               weight: FontWeight.w600,
//                               color: FarmTabTheme.grove,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _openLayerDetail(Map<String, dynamic> layer) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) =>
//             LayerDetailPage(shelf: widget.shelf, layer: layer),
//       ),
//     ).then((_) {
//       // A harvest or new photo may have happened meanwhile
//       if (mounted) _loadLayers();
//     });
//   }

//   Widget _buildCycleInfo(Map<String, dynamic> cycle) {
//     final transplant = DateTime.tryParse(
//       cycle['transplant_date']?.toString() ?? '',
//     );
//     final plants = cycle['plant_count'];

//     return Row(
//       children: [
//         const Icon(Icons.eco_rounded, size: 14, color: FarmTabTheme.grove),
//         const SizedBox(width: 6),
//         Expanded(
//           child: Text(
//             'Transplanted ${transplant == null ? '--' : _formatDate(transplant)}'
//             '${plants == null ? '' : '  \u00B7  $plants plants'}',
//             style: FarmTabTheme.font(
//               size: 12.5,
//               weight: FontWeight.w500,
//               color: FarmTabTheme.textB,
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   String _formatDate(DateTime date) {
//     const months = [
//       'Jan',
//       'Feb',
//       'Mar',
//       'Apr',
//       'May',
//       'Jun',
//       'Jul',
//       'Aug',
//       'Sep',
//       'Oct',
//       'Nov',
//       'Dec',
//     ];

//     return '${date.day} ${months[date.month - 1]} ${date.year}';
//   }

//   // ============================================================
//   // START GROWING CYCLE
//   // ============================================================
//   // The dialog is its own widget (_StartCycleDialog, at the bottom of
//   // this file). It owns its text fields, so they are only disposed
//   // after the dialog has fully closed.

//   Future<void> _showStartCycleDialog(Map<String, dynamic> layer) async {
//     final layerId = layer['layer_id'] as int;
//     final layerName = layer['display_name']?.toString() ?? 'Layer';

//     final result = await showDialog<Map<String, dynamic>>(
//       context: context,
//       barrierDismissible: false,
//       builder: (dialogContext) {
//         return _StartCycleDialog(
//           layerName: layerName,
//           onStart: (transplantDate, plantCount, variety) {
//             return _layerService.startCycle(
//               siteId: widget.shelf['site_id'],
//               shelfId: widget.shelf['id'],
//               layerId: layerId,
//               transplantDate: transplantDate,
//               plantCount: plantCount,
//               variety: variety,
//             );
//           },
//         );
//       },
//     );

//     // null = the user cancelled
//     if (result == null || !mounted) return;

//     _onCycleStarted(layerName, result);
//   }

//   void _onCycleStarted(String layerName, Map<String, dynamic> result) {
//     final firstCapture = result['first_capture']?.toString();

//     String message;

//     switch (firstCapture) {
//       case 'requested':
//         message =
//             '$layerName cycle started. Taking the first photo now (about a minute).';
//         break;
//       case 'existing':
//         message =
//             '$layerName cycle started. Photos already taken were added to it.';
//         break;
//       default:
//         message =
//             '$layerName cycle started. The first photo is taken at 8:00 PM.';
//     }

//     ScaffoldMessenger.of(context)
//         .showSnackBar(SnackBar(content: Text(message)));

//     _loadLayers();

//     // The camera needs a moment to take and upload the photo
//     if (firstCapture == 'requested') {
//       Future.delayed(const Duration(seconds: 75), () {
//         if (mounted) _loadLayers();
//       });
//     }
//   }

//   // ============================================================
//   // HARVEST
//   // ============================================================

//   Future<void> _showHarvestDialog(
//     Map<String, dynamic> layer,
//     Map<String, dynamic> cycle,
//   ) async {
//     final layerId = layer['layer_id'] as int;
//     final layerName = layer['display_name']?.toString() ?? 'Layer';
//     final cycleId = cycle['id'] as int;

//     final siteId = widget.shelf['site_id'];
//     final shelfId = widget.shelf['id'];

//     final harvested = await showDialog<bool>(
//       context: context,
//       barrierDismissible: false,
//       builder: (dialogContext) {
//         return _HarvestDialog(
//           layerName: layerName,
//           onCheckPhoto: (requestId) {
//             return _layerService.getHarvestPhoto(
//               siteId: siteId,
//               shelfId: shelfId,
//               layerId: layerId,
//               cycleId: cycleId,
//               requestId: requestId,
//             );
//           },
//           onRequestCapture: () {
//             return _layerService.requestHarvestCapture(
//               siteId: siteId,
//               shelfId: shelfId,
//               layerId: layerId,
//               cycleId: cycleId,
//             );
//           },
//           onHarvest: (imageId, weightG, note) async {
//             await _layerService.harvestCycle(
//               siteId: siteId,
//               shelfId: shelfId,
//               layerId: layerId,
//               cycleId: cycleId,
//               imageId: imageId,
//               finalWeightG: weightG,
//               note: note,
//             );
//           },
//         );
//       },
//     );

//     if (harvested != true || !mounted) return;

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('$layerName harvested. The cycle has ended.')),
//     );

//     _loadLayers();
//   }

//   // ============================================================
//   // ABORT GROWING CYCLE
//   // ============================================================

//   Future<void> _confirmAbortCycle(
//     Map<String, dynamic> layer,
//     Map<String, dynamic> cycle,
//   ) async {
//     final layerId = layer['layer_id'] as int;
//     final layerName = layer['display_name']?.toString() ?? 'Layer';
//     final cycleId = cycle['id'] as int;

//     // null = cancelled, otherwise the reason (may be empty)
//     final reason = await showDialog<String>(
//       context: context,
//       builder: (dialogContext) {
//         return _AbortCycleDialog(layerName: layerName);
//       },
//     );

//     if (reason == null) return;

//     try {
//       await _layerService.abortCycle(
//         siteId: widget.shelf['site_id'],
//         shelfId: widget.shelf['id'],
//         layerId: layerId,
//         cycleId: cycleId,
//         reason: reason,
//       );

//       if (!mounted) return;

//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text('$layerName cycle aborted.')));

//       _loadLayers();
//     } catch (e) {
//       if (!mounted) return;

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
//       );
//     }
//   }

//   // ============================================================
//   // CANOPY STATS
//   // ============================================================

//   Widget _buildCanopyStats(Map<String, dynamic>? canopy) {
//     final status = canopy?['status']?.toString();
//     final pixels = canopy?['pixels'];
//     final cm2 = canopy?['cm2'];

//     if (status == null) {
//       return _canopyMessage(
//         Icons.hourglass_empty_rounded,
//         'Measuring canopy...',
//         FarmTabTheme.textM,
//       );
//     }

//     if (status == 'failed' || pixels == null) {
//       return _canopyMessage(
//         Icons.error_outline_rounded,
//         'Canopy could not be measured',
//         FarmTabTheme.alertRed,
//       );
//     }

//     final cm2Number = cm2 is num ? cm2.toDouble() : double.tryParse('$cm2');

//     return Row(
//       children: [
//         Expanded(
//           child: _statTile(
//             label: 'Canopy area (approx.)',
//             value: cm2Number == null
//                 ? '--'
//                 : '${cm2Number.toStringAsFixed(1)} cm\u00B2',
//           ),
//         ),
//         const SizedBox(width: 10),
//         Expanded(
//           child: _statTile(
//             label: 'Green pixels',
//             value: _formatThousands(pixels),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _statTile({required String label, required String value}) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//       decoration: BoxDecoration(
//         color: FarmTabTheme.mist.withOpacity(0.55),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             label,
//             style: FarmTabTheme.font(
//               size: 11,
//               weight: FontWeight.w500,
//               color: FarmTabTheme.grove,
//             ),
//           ),
//           const SizedBox(height: 3),
//           Text(
//             value,
//             style: FarmTabTheme.font(
//               size: 16,
//               weight: FontWeight.w700,
//               color: FarmTabTheme.textH,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _canopyMessage(IconData icon, String text, Color color) {
//     return Row(
//       children: [
//         Icon(icon, size: 15, color: color),
//         const SizedBox(width: 6),
//         Text(
//           text,
//           style: FarmTabTheme.font(
//             size: 12.5,
//             weight: FontWeight.w500,
//             color: color,
//           ),
//         ),
//       ],
//     );
//   }

//   String _formatThousands(dynamic value) {
//     final number = value is num ? value.toInt() : int.tryParse('$value');

//     if (number == null) return '--';

//     final text = number.toString();
//     final buffer = StringBuffer();

//     for (int i = 0; i < text.length; i++) {
//       if (i > 0 && (text.length - i) % 3 == 0) buffer.write(',');
//       buffer.write(text[i]);
//     }

//     return buffer.toString();
//   }

//   Widget _buildImage(
//     String layerName,
//     Map<String, dynamic> image,
//     String path,
//   ) {
//     final url = LayerService.imageUrl(path);

//     return GestureDetector(
//       onTap: () => _openFullImage(layerName, image, path),
//       child: Image.network(
//         url,
//         key: ValueKey(url),
//         fit: BoxFit.cover,
//         width: double.infinity,
//         loadingBuilder: (context, child, progress) {
//           if (progress == null) return child;

//           return Container(
//             color: const Color(0xFFF7F7F7),
//             alignment: Alignment.center,
//             child: const SizedBox(
//               width: 22,
//               height: 22,
//               child: CircularProgressIndicator(
//                 strokeWidth: 2.5,
//                 color: FarmTabTheme.grove,
//               ),
//             ),
//           );
//         },
//         errorBuilder: (context, error, stackTrace) {
//           return Container(
//             color: const Color(0xFFF7F7F7),
//             alignment: Alignment.center,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Icon(
//                   Icons.broken_image_outlined,
//                   size: 30,
//                   color: Color(0xFFB0B0B0),
//                 ),
//                 const SizedBox(height: 6),
//                 Text(
//                   'Unable to load image',
//                   style: FarmTabTheme.font(
//                     size: 12.5,
//                     weight: FontWeight.w400,
//                     color: FarmTabTheme.textM,
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildNoImage({bool hasCycle = false}) {
//     return Container(
//       color: const Color(0xFFF7F7F7),
//       alignment: Alignment.center,
//       padding: const EdgeInsets.symmetric(horizontal: 24),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(
//             hasCycle
//                 ? Icons.hourglass_empty_rounded
//                 : Icons.photo_camera_outlined,
//             size: 30,
//             color: hasCycle ? FarmTabTheme.fern : const Color(0xFFB0B0B0),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             hasCycle ? 'Waiting for the first photo' : 'No image yet',
//             textAlign: TextAlign.center,
//             style: FarmTabTheme.font(
//               size: 13.5,
//               weight: FontWeight.w600,
//               color: hasCycle ? FarmTabTheme.grove : FarmTabTheme.textM,
//             ),
//           ),
//           if (hasCycle) ...[
//             const SizedBox(height: 4),
//             Text(
//               'Cameras take a photo every day at 8:00 PM.',
//               textAlign: TextAlign.center,
//               style: FarmTabTheme.font(
//                 size: 12,
//                 weight: FontWeight.w400,
//                 color: FarmTabTheme.textM,
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }

//   Widget _buildImageFooter(
//     Map<String, dynamic>? image, {
//     bool hasCycle = false,
//   }) {
//     if (image == null) {
//       return Text(
//         hasCycle
//             ? 'This cycle has no photo yet'
//             : 'Waiting for the first capture',
//         style: FarmTabTheme.font(
//           size: 12.5,
//           weight: FontWeight.w400,
//           color: FarmTabTheme.textM,
//         ),
//       );
//     }

//     final capturedAt = DateTime.tryParse(image['captured_at']?.toString() ?? '')
//         ?.toLocal();

//     final isTest = image['capture_type']?.toString() == 'manual';

//     final isStale =
//         capturedAt != null &&
//         DateTime.now().difference(capturedAt) > _staleAfter;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             const Icon(
//               Icons.schedule_rounded,
//               size: 14,
//               color: FarmTabTheme.textM,
//             ),
//             const SizedBox(width: 6),
//             Expanded(
//               child: Text(
//                 capturedAt == null
//                     ? '--'
//                     : '${_formatDateTime(capturedAt)}  ·  ${_timeAgo(capturedAt)}',
//                 style: FarmTabTheme.font(
//                   size: 12.5,
//                   weight: FontWeight.w500,
//                   color: FarmTabTheme.textB,
//                 ),
//               ),
//             ),
//             if (isTest)
//               _chip(
//                 'Test',
//                 FarmTabTheme.skyBlue,
//                 FarmTabTheme.skyBlue.withOpacity(0.10),
//               ),
//           ],
//         ),
//         if (isStale) ...[
//           const SizedBox(height: 8),
//           Row(
//             children: [
//               const Icon(
//                 Icons.warning_amber_rounded,
//                 size: 15,
//                 color: FarmTabTheme.amber,
//               ),
//               const SizedBox(width: 6),
//               Expanded(
//                 child: Text(
//                   'No new image in the last day. Check this camera.',
//                   style: FarmTabTheme.font(
//                     size: 12,
//                     weight: FontWeight.w500,
//                     color: FarmTabTheme.amber,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ],
//     );
//   }

//   Widget _buildCycleChip(Map<String, dynamic>? cycle) {
//     if (cycle == null) {
//       return _chip('No cycle', FarmTabTheme.textM, const Color(0xFFF2F2F2));
//     }

//     final transplant = DateTime.tryParse(
//       cycle['transplant_date']?.toString() ?? '',
//     );

//     if (transplant == null) {
//       return _chip('Growing', FarmTabTheme.grove, FarmTabTheme.mist);
//     }

//     final today = DateTime.now();
//     final start = DateTime(transplant.year, transplant.month, transplant.day);
//     final current = DateTime(today.year, today.month, today.day);
//     final day = current.difference(start).inDays + 1;

//     return _chip(
//       'Day ${day < 1 ? 1 : day}',
//       FarmTabTheme.grove,
//       FarmTabTheme.mist,
//     );
//   }

//   Widget _chip(String text, Color textColor, Color background) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
//       decoration: BoxDecoration(
//         color: background,
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Text(
//         text,
//         style: FarmTabTheme.font(
//           size: 11,
//           weight: FontWeight.w700,
//           color: textColor,
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // FULL-SCREEN IMAGE (pinch to zoom)
//   // ============================================================

//   void _openFullImage(
//     String layerName,
//     Map<String, dynamic> image,
//     String path,
//   ) {
//     final url = LayerService.imageUrl(path);

//     final capturedAt = DateTime.tryParse(image['captured_at']?.toString() ?? '')
//         ?.toLocal();

//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => Scaffold(
//           backgroundColor: Colors.black,
//           appBar: AppBar(
//             backgroundColor: Colors.black,
//             foregroundColor: Colors.white,
//             title: Text(
//               capturedAt == null
//                   ? layerName
//                   : '$layerName  ·  ${_formatDateTime(capturedAt)}',
//               style: FarmTabTheme.font(
//                 size: 14.5,
//                 weight: FontWeight.w600,
//                 color: Colors.white,
//               ),
//             ),
//           ),
//           body: Center(
//             child: InteractiveViewer(
//               minScale: 1,
//               maxScale: 5,
//               child: Image.network(url, fit: BoxFit.contain),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // STATES
//   // ============================================================

//   Widget _buildLoading() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(vertical: 28),
//       decoration: FarmTabTheme.cardDecoration,
//       child: Column(
//         children: [
//           const SizedBox(
//             width: 22,
//             height: 22,
//             child: CircularProgressIndicator(
//               strokeWidth: 2.5,
//               color: FarmTabTheme.grove,
//             ),
//           ),
//           const SizedBox(height: 12),
//           Text(
//             'Loading layer images...',
//             style: FarmTabTheme.font(
//               size: 13.5,
//               weight: FontWeight.w400,
//               color: FarmTabTheme.textM,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildError() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(18),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(16),
//         color: const Color(0xFFF7F7F7),
//       ),
//       child: Column(
//         children: [
//           const Icon(
//             Icons.error_outline_rounded,
//             size: 30,
//             color: FarmTabTheme.alertRed,
//           ),
//           const SizedBox(height: 10),
//           Text(
//             _error ?? 'Unable to load layer images.',
//             textAlign: TextAlign.center,
//             style: FarmTabTheme.font(
//               size: 13.5,
//               weight: FontWeight.w400,
//               color: FarmTabTheme.textB,
//             ),
//           ),
//           const SizedBox(height: 12),
//           OutlinedButton(
//             onPressed: _loadLayers,
//             style: FarmTabTheme.outlinedButton,
//             child: Text(
//               'Retry',
//               style: FarmTabTheme.font(
//                 size: 13,
//                 weight: FontWeight.w600,
//                 color: FarmTabTheme.grove,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEmpty() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(16),
//         color: const Color(0xFFF7F7F7),
//       ),
//       child: Text(
//         'No camera layers are set up for this shelf yet.',
//         textAlign: TextAlign.center,
//         style: FarmTabTheme.font(
//           size: 13.5,
//           weight: FontWeight.w400,
//           color: FarmTabTheme.textM,
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // FORMATTING
//   // ============================================================

//   String _formatDateTime(DateTime dateTime) {
//     const months = [
//       'Jan',
//       'Feb',
//       'Mar',
//       'Apr',
//       'May',
//       'Jun',
//       'Jul',
//       'Aug',
//       'Sep',
//       'Oct',
//       'Nov',
//       'Dec',
//     ];

//     final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
//     final minute = dateTime.minute.toString().padLeft(2, '0');
//     final period = dateTime.hour >= 12 ? 'PM' : 'AM';

//     return '${dateTime.day} ${months[dateTime.month - 1]}, '
//         '$hour:$minute $period';
//   }

//   String _timeAgo(DateTime dateTime) {
//     final diff = DateTime.now().difference(dateTime);

//     if (diff.inMinutes < 1) return 'just now';
//     if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
//     if (diff.inHours < 24) return '${diff.inHours} h ago';

//     final days = diff.inDays;
//     return days == 1 ? '1 day ago' : '$days days ago';
//   }
// }

// // ============================================================
// // SHARED HELPERS FOR THE DIALOGS
// // ============================================================

// String _formatShortDate(DateTime date) {
//   const months = [
//     'Jan',
//     'Feb',
//     'Mar',
//     'Apr',
//     'May',
//     'Jun',
//     'Jul',
//     'Aug',
//     'Sep',
//     'Oct',
//     'Nov',
//     'Dec',
//   ];

//   return '${date.day} ${months[date.month - 1]} ${date.year}';
// }

// InputDecoration _layerFieldDecoration(String hint) {
//   return InputDecoration(
//     hintText: hint,
//     filled: true,
//     fillColor: const Color(0xFFF7F7F7),
//     contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
//     border: OutlineInputBorder(
//       borderRadius: BorderRadius.circular(10),
//       borderSide: BorderSide.none,
//     ),
//     enabledBorder: OutlineInputBorder(
//       borderRadius: BorderRadius.circular(10),
//       borderSide: BorderSide.none,
//     ),
//     focusedBorder: OutlineInputBorder(
//       borderRadius: BorderRadius.circular(10),
//       borderSide: const BorderSide(color: FarmTabTheme.fern, width: 1.5),
//     ),
//   );
// }

// // ============================================================
// // START CYCLE DIALOG
// // ============================================================

// class _StartCycleDialog extends StatefulWidget {
//   final String layerName;

//   // Sends the request to the backend and returns its result
//   final Future<Map<String, dynamic>> Function(
//     DateTime transplantDate,
//     int plantCount,
//     String variety,
//   )
//   onStart;

//   const _StartCycleDialog({required this.layerName, required this.onStart});

//   @override
//   State<_StartCycleDialog> createState() => _StartCycleDialogState();
// }

// class _StartCycleDialogState extends State<_StartCycleDialog> {
//   final TextEditingController _plantsController = TextEditingController();
//   final TextEditingController _varietyController = TextEditingController(
//     text: 'looseleaf lettuce',
//   );

//   late final DateTime _today;
//   late DateTime _transplantDate;
//   bool _isSaving = false;

//   @override
//   void initState() {
//     super.initState();

//     final now = DateTime.now();
//     _today = DateTime(now.year, now.month, now.day);
//     _transplantDate = _today;
//   }

//   // Runs only when the dialog is really removed from the screen,
//   // after its closing animation has finished.
//   @override
//   void dispose() {
//     _plantsController.dispose();
//     _varietyController.dispose();
//     super.dispose();
//   }

//   Future<void> _pickDate() async {
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: _transplantDate,
//       firstDate: _today.subtract(const Duration(days: 60)),
//       lastDate: _today,
//     );

//     if (picked != null && mounted) {
//       setState(() {
//         _transplantDate = picked;
//       });
//     }
//   }

//   Future<void> _submit() async {
//     final plants = int.tryParse(_plantsController.text.trim());

//     if (plants == null || plants < 1 || plants > 100) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please enter the number of plants (1 to 100).'),
//         ),
//       );
//       return;
//     }

//     setState(() {
//       _isSaving = true;
//     });

//     try {
//       final result = await widget.onStart(
//         _transplantDate,
//         plants,
//         _varietyController.text.trim(),
//       );

//       if (!mounted) return;

//       Navigator.pop(context, result);
//     } catch (e) {
//       if (!mounted) return;

//       setState(() {
//         _isSaving = false;
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
//       );
//     }
//   }

//   Widget _label(String text) {
//     return Text(
//       text,
//       style: FarmTabTheme.font(
//         size: 13,
//         weight: FontWeight.w600,
//         color: FarmTabTheme.textH,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       backgroundColor: FarmTabTheme.white,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       title: Text(
//         'Start Growing Cycle \u00B7 ${widget.layerName}',
//         style: FarmTabTheme.font(
//           size: 16,
//           weight: FontWeight.w700,
//           color: FarmTabTheme.textH,
//         ),
//       ),
//       content: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _label('Transplant Date (Day 1)'),
//             const SizedBox(height: 8),
//             InkWell(
//               borderRadius: BorderRadius.circular(10),
//               onTap: _isSaving ? null : _pickDate,
//               child: Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 14,
//                   vertical: 14,
//                 ),
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(10),
//                   border: Border.all(color: FarmTabTheme.border),
//                 ),
//                 child: Row(
//                   children: [
//                     const Icon(
//                       Icons.calendar_today_rounded,
//                       size: 18,
//                       color: FarmTabTheme.grove,
//                     ),
//                     const SizedBox(width: 10),
//                     Text(
//                       _formatShortDate(_transplantDate),
//                       style: FarmTabTheme.font(
//                         size: 14.5,
//                         weight: FontWeight.w500,
//                         color: FarmTabTheme.textH,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 6),
//             Text(
//               _transplantDate == _today
//                   ? 'Photos are taken automatically every day at 8:00 PM.'
//                   : 'Photos already taken since this date will join the cycle.',
//               style: FarmTabTheme.font(
//                 size: 11.5,
//                 weight: FontWeight.w400,
//                 color: FarmTabTheme.textM,
//               ),
//             ),
//             const SizedBox(height: 18),
//             _label('Number of Plants'),
//             const SizedBox(height: 8),
//             TextField(
//               controller: _plantsController,
//               keyboardType: TextInputType.number,
//               enabled: !_isSaving,
//               decoration: _layerFieldDecoration('e.g. 16'),
//             ),
//             const SizedBox(height: 18),
//             _label('Variety'),
//             const SizedBox(height: 8),
//             TextField(
//               controller: _varietyController,
//               enabled: !_isSaving,
//               decoration: _layerFieldDecoration('looseleaf lettuce'),
//             ),
//           ],
//         ),
//       ),
//       actions: [
//         TextButton(
//           onPressed: _isSaving ? null : () => Navigator.pop(context),
//           child: Text(
//             'Cancel',
//             style: FarmTabTheme.font(
//               size: 13.5,
//               weight: FontWeight.w600,
//               color: FarmTabTheme.textM,
//             ),
//           ),
//         ),
//         ElevatedButton(
//           style: FarmTabTheme.primaryButton,
//           onPressed: _isSaving ? null : _submit,
//           child: _isSaving
//               ? const SizedBox(
//                   width: 18,
//                   height: 18,
//                   child: CircularProgressIndicator(
//                     strokeWidth: 2,
//                     color: FarmTabTheme.white,
//                   ),
//                 )
//               : Text(
//                   'Start Cycle',
//                   style: FarmTabTheme.font(
//                     size: 13.5,
//                     weight: FontWeight.w600,
//                     color: FarmTabTheme.white,
//                   ),
//                 ),
//         ),
//       ],
//     );
//   }
// }

// // ============================================================
// // ABORT CYCLE DIALOG
// // ============================================================

// class _AbortCycleDialog extends StatefulWidget {
//   final String layerName;

//   const _AbortCycleDialog({required this.layerName});

//   @override
//   State<_AbortCycleDialog> createState() => _AbortCycleDialogState();
// }

// class _AbortCycleDialogState extends State<_AbortCycleDialog> {
//   final TextEditingController _reasonController = TextEditingController();

//   @override
//   void dispose() {
//     _reasonController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       backgroundColor: FarmTabTheme.white,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       title: Text(
//         'Abort ${widget.layerName} cycle?',
//         style: FarmTabTheme.font(
//           size: 16,
//           weight: FontWeight.w700,
//           color: FarmTabTheme.textH,
//         ),
//       ),
//       content: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Use this if the cycle was started by mistake or the batch '
//             'failed. Photos and records are kept, but this cycle will '
//             'not be used for training. To record a normal harvest, use '
//             'Harvest instead.',
//             style: FarmTabTheme.font(
//               size: 13,
//               weight: FontWeight.w400,
//               color: FarmTabTheme.textB,
//               height: 1.4,
//             ),
//           ),
//           const SizedBox(height: 14),
//           TextField(
//             controller: _reasonController,
//             decoration: _layerFieldDecoration('Reason (optional)'),
//           ),
//         ],
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.pop(context),
//           child: Text(
//             'Cancel',
//             style: FarmTabTheme.font(
//               size: 13.5,
//               weight: FontWeight.w600,
//               color: FarmTabTheme.textM,
//             ),
//           ),
//         ),
//         ElevatedButton(
//           style: ElevatedButton.styleFrom(
//             backgroundColor: FarmTabTheme.alertRed,
//             foregroundColor: FarmTabTheme.white,
//             elevation: 0,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(10),
//             ),
//           ),
//           onPressed: () =>
//               Navigator.pop(context, _reasonController.text.trim()),
//           child: Text(
//             'Abort Cycle',
//             style: FarmTabTheme.font(
//               size: 13.5,
//               weight: FontWeight.w600,
//               color: FarmTabTheme.white,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// // ============================================================
// // HARVEST DIALOG
// // ============================================================
// // Steps: find today's photo (or ask the camera for one) -> check the
// // photo and its canopy -> enter weight and note -> confirm.

// String _formatClock(DateTime dateTime) {
//   final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
//   final minute = dateTime.minute.toString().padLeft(2, '0');
//   final period = dateTime.hour >= 12 ? 'PM' : 'AM';

//   return '$hour:$minute $period';
// }

// class _HarvestDialog extends StatefulWidget {
//   final String layerName;

//   // requestId == null: look for a photo taken today.
//   // requestId != null: follow the "capture now" job.
//   final Future<Map<String, dynamic>> Function(int? requestId) onCheckPhoto;

//   // Asks the camera for a new photo; returns the request id.
//   final Future<int> Function() onRequestCapture;

//   // Ends the cycle. imageId == null means "harvest without a final photo".
//   final Future<void> Function(int? imageId, double? weightG, String? note)
//   onHarvest;

//   const _HarvestDialog({
//     required this.layerName,
//     required this.onCheckPhoto,
//     required this.onRequestCapture,
//     required this.onHarvest,
//   });

//   @override
//   State<_HarvestDialog> createState() => _HarvestDialogState();
// }

// class _HarvestDialogState extends State<_HarvestDialog> {
//   final TextEditingController _weightController = TextEditingController();
//   final TextEditingController _noteController = TextEditingController();

//   // loading, needs_capture, waiting, measuring, ready,
//   // measure_failed, expired, no_photo, error
//   String _state = 'loading';

//   Map<String, dynamic>? _image;
//   bool _showOverlay = false;
//   bool _isSaving = false;
//   String? _error;

//   @override
//   void initState() {
//     super.initState();
//     _checkToday();
//   }

//   // Runs only when the dialog is really removed from the screen
//   @override
//   void dispose() {
//     _weightController.dispose();
//     _noteController.dispose();
//     super.dispose();
//   }

//   String _plainError(Object e) => e.toString().replaceFirst('Exception: ', '');

//   void _applyResult(Map<String, dynamic> result) {
//     setState(() {
//       _state = result['state']?.toString() ?? 'error';
//       _image = result['image'] == null
//           ? null
//           : Map<String, dynamic>.from(result['image'] as Map);
//       _showOverlay = false;
//     });
//   }

//   Future<void> _checkToday() async {
//     setState(() {
//       _state = 'loading';
//       _error = null;
//     });

//     try {
//       final result = await widget.onCheckPhoto(null);

//       if (!mounted) return;

//       _applyResult(result);
//     } catch (e) {
//       if (!mounted) return;

//       setState(() {
//         _state = 'error';
//         _error = _plainError(e);
//       });
//     }
//   }

//   Future<void> _captureNow() async {
//     setState(() {
//       _state = 'waiting';
//       _image = null;
//     });

//     try {
//       final requestId = await widget.onRequestCapture();

//       if (!mounted) return;

//       await _pollForPhoto(requestId);
//     } catch (e) {
//       if (!mounted) return;

//       setState(() {
//         _state = 'error';
//         _error = _plainError(e);
//       });
//     }
//   }

//   // Asks the server every 4 seconds whether the photo has arrived
//   Future<void> _pollForPhoto(int requestId) async {
//     final deadline = DateTime.now().add(const Duration(minutes: 3));

//     while (mounted && DateTime.now().isBefore(deadline)) {
//       await Future.delayed(const Duration(seconds: 4));

//       if (!mounted) return;

//       try {
//         final result = await widget.onCheckPhoto(requestId);

//         if (!mounted) return;

//         final state = result['state']?.toString();

//         if (state == 'waiting' || state == 'measuring') {
//           setState(() {
//             _state = state ?? 'waiting';
//           });
//           continue;
//         }

//         _applyResult(result);
//         return;
//       } catch (_) {
//         // A short network problem: keep trying until the deadline
//       }
//     }

//     if (mounted) {
//       setState(() {
//         _state = 'expired';
//       });
//     }
//   }

//   Future<void> _submit() async {
//     final weight = double.tryParse(_weightController.text.trim());

//     if (weight == null || weight <= 0) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please enter the harvested weight in grams.'),
//         ),
//       );
//       return;
//     }

//     setState(() {
//       _isSaving = true;
//     });

//     try {
//       final imageId = _state == 'no_photo' ? null : _image?['id'] as int?;

//       await widget.onHarvest(imageId, weight, _noteController.text.trim());

//       if (!mounted) return;

//       Navigator.pop(context, true);
//     } catch (e) {
//       if (!mounted) return;

//       setState(() {
//         _isSaving = false;
//       });

//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text(_plainError(e))));
//     }
//   }

//   // ------------------------------------------------------------
//   // Small building blocks
//   // ------------------------------------------------------------

//   Widget _label(String text) {
//     return Text(
//       text,
//       style: FarmTabTheme.font(
//         size: 13,
//         weight: FontWeight.w600,
//         color: FarmTabTheme.textH,
//       ),
//     );
//   }

//   Widget _busy(String text) {
//     return Row(
//       children: [
//         const SizedBox(
//           width: 20,
//           height: 20,
//           child: CircularProgressIndicator(
//             strokeWidth: 2.5,
//             color: FarmTabTheme.grove,
//           ),
//         ),
//         const SizedBox(width: 14),
//         Expanded(
//           child: Text(
//             text,
//             style: FarmTabTheme.font(
//               size: 13.5,
//               weight: FontWeight.w400,
//               color: FarmTabTheme.textB,
//               height: 1.4,
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _message(IconData icon, String text, {Color? color}) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Icon(icon, size: 22, color: color ?? FarmTabTheme.fern),
//         const SizedBox(width: 12),
//         Expanded(
//           child: Text(
//             text,
//             style: FarmTabTheme.font(
//               size: 13.5,
//               weight: FontWeight.w400,
//               color: FarmTabTheme.textB,
//               height: 1.4,
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildPhotoPreview() {
//     final image = _image!;

//     final canopy = image['canopy'] == null
//         ? null
//         : Map<String, dynamic>.from(image['canopy'] as Map);

//     final overlay = canopy?['overlay_url']?.toString();
//     final hasOverlay = overlay != null && overlay.isNotEmpty;

//     final String path = (_showOverlay && overlay != null && overlay.isNotEmpty)
//         ? overlay
//         : image['image_url'].toString();

//     final url = LayerService.imageUrl(path);

//     final capturedAt = DateTime.tryParse(image['captured_at']?.toString() ?? '')
//         ?.toLocal();

//     final cm2 = canopy?['cm2'];
//     final pixels = canopy?['pixels'];

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         ClipRRect(
//           borderRadius: BorderRadius.circular(12),
//           child: AspectRatio(
//             aspectRatio: 4 / 3,
//             child: Image.network(
//               url,
//               key: ValueKey(url),
//               fit: BoxFit.cover,
//               errorBuilder: (context, error, stackTrace) {
//                 return Container(
//                   color: const Color(0xFFF7F7F7),
//                   alignment: Alignment.center,
//                   child: const Icon(
//                     Icons.broken_image_outlined,
//                     size: 30,
//                     color: Color(0xFFB0B0B0),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ),
//         const SizedBox(height: 8),
//         Row(
//           children: [
//             Expanded(
//               child: Text(
//                 capturedAt == null
//                     ? ''
//                     : 'Photo taken ${_formatShortDate(capturedAt)}, '
//                           '${_formatClock(capturedAt)}',
//                 style: FarmTabTheme.font(
//                   size: 12,
//                   weight: FontWeight.w500,
//                   color: FarmTabTheme.textM,
//                 ),
//               ),
//             ),
//             if (hasOverlay)
//               TextButton(
//                 onPressed: () {
//                   setState(() {
//                     _showOverlay = !_showOverlay;
//                   });
//                 },
//                 child: Text(
//                   _showOverlay ? 'Show photo' : 'Show canopy',
//                   style: FarmTabTheme.font(
//                     size: 12.5,
//                     weight: FontWeight.w600,
//                     color: FarmTabTheme.grove,
//                   ),
//                 ),
//               ),
//           ],
//         ),
//         if (pixels != null)
//           Text(
//             'Canopy: ${cm2 is num ? cm2.toStringAsFixed(1) : '--'} cm\u00B2 '
//             '(approx.)  \u00B7  $pixels green pixels',
//             style: FarmTabTheme.font(
//               size: 13,
//               weight: FontWeight.w600,
//               color: FarmTabTheme.textH,
//             ),
//           ),
//       ],
//     );
//   }

//   Widget _buildFields() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const SizedBox(height: 16),
//         _label('Total Harvested Weight (all plants)'),
//         const SizedBox(height: 8),
//         TextField(
//           controller: _weightController,
//           keyboardType: const TextInputType.numberWithOptions(decimal: true),
//           enabled: !_isSaving,
//           decoration: _layerFieldDecoration('e.g. 850')
//               .copyWith(suffixText: 'g'),
//         ),
//         const SizedBox(height: 16),
//         _label('Note (optional)'),
//         const SizedBox(height: 8),
//         TextField(
//           controller: _noteController,
//           enabled: !_isSaving,
//           decoration: _layerFieldDecoration('e.g. leaves fill the pot'),
//         ),
//       ],
//     );
//   }

//   Widget _buildBody() {
//     switch (_state) {
//       case 'loading':
//         return _busy("Checking today's photo...");

//       case 'waiting':
//         return _busy('Taking a photo now. This can take up to a minute...');

//       case 'measuring':
//         return _busy('Photo received. Measuring the canopy...');

//       case 'needs_capture':
//         return _message(
//           Icons.lightbulb_outline_rounded,
//           'No photo has been taken today for this layer. Switch the grow '
//           'lights on, then press Capture Now.',
//         );

//       case 'expired':
//         return _message(
//           Icons.cloud_off_rounded,
//           'The camera did not answer in time. Check that its Raspberry Pi '
//           'is on, then try again.',
//           color: FarmTabTheme.amber,
//         );

//       case 'measure_failed':
//         return _message(
//           Icons.error_outline_rounded,
//           'The photo could not be measured. Retake the photo.',
//           color: FarmTabTheme.alertRed,
//         );

//       case 'error':
//         return _message(
//           Icons.error_outline_rounded,
//           _error ?? 'Something went wrong.',
//           color: FarmTabTheme.alertRed,
//         );

//       case 'no_photo':
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _message(
//               Icons.warning_amber_rounded,
//               'Harvesting without a final photo. The final canopy will not '
//               'be recorded for this cycle.',
//               color: FarmTabTheme.amber,
//             ),
//             _buildFields(),
//           ],
//         );

//       default: // ready
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [if (_image != null) _buildPhotoPreview(), _buildFields()],
//         );
//     }
//   }

//   Widget _cancelButton() {
//     return TextButton(
//       onPressed: _isSaving ? null : () => Navigator.pop(context, false),
//       child: Text(
//         'Cancel',
//         style: FarmTabTheme.font(
//           size: 13.5,
//           weight: FontWeight.w600,
//           color: FarmTabTheme.textM,
//         ),
//       ),
//     );
//   }

//   Widget _textAction(String text, VoidCallback? onPressed) {
//     return TextButton(
//       onPressed: onPressed,
//       child: Text(
//         text,
//         style: FarmTabTheme.font(
//           size: 13.5,
//           weight: FontWeight.w600,
//           color: FarmTabTheme.grove,
//         ),
//       ),
//     );
//   }

//   Widget _primaryAction(String text, VoidCallback? onPressed) {
//     return ElevatedButton(
//       style: FarmTabTheme.primaryButton,
//       onPressed: onPressed,
//       child: Text(
//         text,
//         style: FarmTabTheme.font(
//           size: 13.5,
//           weight: FontWeight.w600,
//           color: FarmTabTheme.white,
//         ),
//       ),
//     );
//   }

//   List<Widget> _buildActions() {
//     switch (_state) {
//       case 'loading':
//       case 'waiting':
//       case 'measuring':
//         return [_cancelButton()];

//       case 'needs_capture':
//         return [
//           _cancelButton(),
//           _textAction('Harvest without photo', () {
//             setState(() {
//               _state = 'no_photo';
//               _image = null;
//             });
//           }),
//           _primaryAction('Capture Now', _captureNow),
//         ];

//       case 'expired':
//       case 'measure_failed':
//         return [
//           _cancelButton(),
//           _textAction('Harvest without photo', () {
//             setState(() {
//               _state = 'no_photo';
//               _image = null;
//             });
//           }),
//           _primaryAction(
//             _state == 'expired' ? 'Try Again' : 'Retake',
//             _captureNow,
//           ),
//         ];

//       case 'error':
//         return [_cancelButton(), _primaryAction('Try Again', _checkToday)];

//       case 'no_photo':
//         return [
//           _cancelButton(),
//           _primaryAction('Confirm Harvest', _isSaving ? null : _submit),
//         ];

//       default: // ready
//         return [
//           _cancelButton(),
//           _textAction('Retake', _isSaving ? null : _captureNow),
//           _primaryAction('Confirm Harvest', _isSaving ? null : _submit),
//         ];
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       backgroundColor: FarmTabTheme.white,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       title: Text(
//         'Harvest \u00B7 ${widget.layerName}',
//         style: FarmTabTheme.font(
//           size: 16,
//           weight: FontWeight.w700,
//           color: FarmTabTheme.textH,
//         ),
//       ),
//       content: SingleChildScrollView(child: _buildBody()),
//       actions: _buildActions(),
//     );
//   }
// }

import 'package:flutter/material.dart';

import '../../services/layer_service.dart';
import 'growth_style.dart';
import 'layer_detail_page.dart';
import 'shelf_detail_page.dart' show FarmTabTheme;

class GrowthMonitoringPage extends StatefulWidget {
  final Map<String, dynamic> shelf;
  final Map<String, dynamic> organisation;
  final bool embedded;

  const GrowthMonitoringPage({
    super.key,
    required this.shelf,
    required this.organisation,
    this.embedded = true,
  });

  @override
  State<GrowthMonitoringPage> createState() => _GrowthMonitoringPageState();
}

class _GrowthMonitoringPageState extends State<GrowthMonitoringPage> {
  final LayerService _layerService = LayerService();

  List<Map<String, dynamic>> _layers = [];

  // Layers currently showing the pink overlay instead of the plain photo
  final Set<int> _overlayLayers = {};
  bool _isLoading = true;
  String? _error;

  // An image older than this is flagged, because a new photo is
  // expected every day at 8:00 PM.
  static const Duration _staleAfter = Duration(hours: 26);

  @override
  void initState() {
    super.initState();
    _loadLayers();
  }

  Future<void> _loadLayers() async {
    setState(() {
      _error = null;
      if (_layers.isEmpty) _isLoading = true;
    });

    try {
      final layers = await _layerService.getShelfLayers(
        siteId: widget.shelf['site_id'],
        shelfId: widget.shelf['id'],
      );

      if (!mounted) return;

      setState(() {
        _layers = layers;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final content = Container(
      color: Colors.white,
      child: RefreshIndicator(
        color: GrowthColors.accent,
        onRefresh: _loadLayers,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              if (_isLoading)
                _buildLoading()
              else if (_error != null && _layers.isEmpty)
                _buildError()
              else if (_layers.isEmpty)
                _buildEmpty()
              else
                _buildLayerGrid(),
            ],
          ),
        ),
      ),
    );

    if (widget.embedded) return content;

    return Scaffold(
      backgroundColor: GrowthColors.page,
      appBar: AppBar(title: const Text('Growth Monitoring')),
      body: content,
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 3),
              Text(
                'A photo is taken automatically every day at 8:00 PM',
                style: GrowthStyle.text(
                  size: 12.5,
                  weight: FontWeight.w400,
                  color: GrowthColors.muted,
                ),
              ),
            ],
          ),
        ),
        Material(
          color: Colors.white,
          shape: const CircleBorder(side: BorderSide(color: GrowthColors.line)),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: _loadLayers,
            child: const SizedBox(
              width: 42,
              height: 42,
              child: Icon(
                Icons.refresh_rounded,
                size: 20,
                color: GrowthColors.accentStrong,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 1 column on a phone, 2 on a tablet, 3 on a wide computer window.
  Widget _buildLayerGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 1200 ? 3 : (width >= 600 ? 2 : 1);

        if (columns == 1) {
          return Column(
            children: [
              for (final layer in _layers) ...[
                _buildLayerCard(layer),
                const SizedBox(height: 14),
              ],
            ],
          );
        }

        final rows = <Widget>[];

        for (int i = 0; i < _layers.length; i += columns) {
          rows.add(
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int j = 0; j < columns; j++) ...[
                  if (j > 0) const SizedBox(width: 14),
                  Expanded(
                    child: i + j < _layers.length
                        ? _buildLayerCard(_layers[i + j])
                        : const SizedBox(),
                  ),
                ],
              ],
            ),
          );
          rows.add(const SizedBox(height: 14));
        }

        return Column(children: rows);
      },
    );
  }

  // ============================================================
  // LAYER CARD
  // ============================================================

  Widget _buildLayerCard(Map<String, dynamic> layer) {
    final name = layer['display_name']?.toString() ?? 'Layer';
    final code = layer['code']?.toString() ?? '';

    final image = layer['latest_image'] == null
        ? null
        : Map<String, dynamic>.from(layer['latest_image'] as Map);

    final cycle = layer['active_cycle'] == null
        ? null
        : Map<String, dynamic>.from(layer['active_cycle'] as Map);

    final layerId = layer['layer_id'] as int;

    final canopy = image == null || image['canopy'] == null
        ? null
        : Map<String, dynamic>.from(image['canopy'] as Map);

    final overlayUrl = canopy?['overlay_url']?.toString();
    final hasOverlay = overlayUrl != null && overlayUrl.isNotEmpty;
    final showOverlay = hasOverlay && _overlayLayers.contains(layerId);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color.fromARGB(255, 194, 236, 216),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E2B25).withOpacity(0.14),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          // Tapping the card opens the Layer Detail page
          onTap: () => _openLayerDetail(layer),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header: layer name, camera code, cycle status
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                child: Row(
                  children: [
                    Text(
                      name,
                      style: FarmTabTheme.font(
                        size: 15,
                        weight: FontWeight.w700,
                        color: GrowthColors.ink,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _chip(code, GrowthColors.body, GrowthColors.page),
                    const Spacer(),
                    _buildCycleChip(cycle),
                    if (cycle != null)
                      PopupMenuButton<String>(
                        padding: EdgeInsets.zero,
                        icon: const Icon(
                          Icons.more_vert_rounded,
                          size: 20,
                          color: GrowthColors.muted,
                        ),
                        onSelected: (value) {
                          if (value == 'abort') {
                            _confirmAbortCycle(layer, cycle);
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem<String>(
                            value: 'abort',
                            child: Text(
                              'Abort cycle',
                              style: FarmTabTheme.font(
                                size: 13.5,
                                weight: FontWeight.w500,
                                color: GrowthColors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 22,
                      color: GrowthColors.muted,
                    ),
                  ],
                ),
              ),

              // ── Image (4:3, same shape as the camera photos)
              AspectRatio(
                aspectRatio: 4 / 3,
                child: image == null
                    ? _buildNoImage(hasCycle: cycle != null)
                    : Stack(
                        fit: StackFit.expand,
                        children: [
                          _buildImage(
                            name,
                            image,
                            (showOverlay && overlayUrl != null)
                                ? overlayUrl
                                : image['image_url'].toString(),
                          ),

                          // Photo / Canopy switch, top-right of the image
                          if (hasOverlay)
                            Positioned(
                              top: 10,
                              right: 10,
                              child: Material(
                                color: Colors.black.withOpacity(0.55),
                                borderRadius: BorderRadius.circular(20),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: () {
                                    setState(() {
                                      if (showOverlay) {
                                        _overlayLayers.remove(layerId);
                                      } else {
                                        _overlayLayers.add(layerId);
                                      }
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 11,
                                      vertical: 7,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          showOverlay
                                              ? Icons.photo_outlined
                                              : Icons.layers_rounded,
                                          size: 14,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          showOverlay ? 'Photo' : 'Canopy',
                                          style: FarmTabTheme.font(
                                            size: 11.5,
                                            weight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
              ),

              // ── Canopy measurement
              if (image != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                  child: _buildCanopyStats(canopy),
                ),

              // ── Footer: capture time
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: _buildImageFooter(image, hasCycle: cycle != null),
              ),

              // ── Start button (no cycle) or cycle details (active cycle)
              if (cycle == null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _showStartCycleDialog(layer),
                      style: GrowthStyle.primaryButton,
                      child: Text(
                        'Start Growing Cycle',
                        style: FarmTabTheme.font(
                          size: 13,
                          weight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCycleInfo(cycle),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => _showHarvestDialog(layer, cycle),
                          style: GrowthStyle.outlinedButton,
                          child: Text(
                            'Harvest',
                            style: FarmTabTheme.font(
                              size: 13,
                              weight: FontWeight.w600,
                              color: GrowthColors.accentStrong,
                            ),
                          ),
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

  void _openLayerDetail(Map<String, dynamic> layer) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            LayerDetailPage(shelf: widget.shelf, layer: layer),
      ),
    ).then((_) {
      // A harvest or new photo may have happened meanwhile
      if (mounted) _loadLayers();
    });
  }

  Widget _buildCycleInfo(Map<String, dynamic> cycle) {
    final transplant = DateTime.tryParse(
      cycle['transplant_date']?.toString() ?? '',
    );
    final plants = cycle['plant_count'];

    return Row(
      children: [
        const Icon(
          Icons.eco_rounded,
          size: 14,
          color: GrowthColors.accentStrong,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            'Transplanted ${transplant == null ? '--' : _formatDate(transplant)}'
            '${plants == null ? '' : '  \u00B7  $plants plants'}',
            style: FarmTabTheme.font(
              size: 12.5,
              weight: FontWeight.w500,
              color: GrowthColors.body,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    const months = [
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

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  // ============================================================
  // START GROWING CYCLE
  // ============================================================
  // The dialog is its own widget (_StartCycleDialog, at the bottom of
  // this file). It owns its text fields, so they are only disposed
  // after the dialog has fully closed.

  Future<void> _showStartCycleDialog(Map<String, dynamic> layer) async {
    final layerId = layer['layer_id'] as int;
    final layerName = layer['display_name']?.toString() ?? 'Layer';

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return _StartCycleDialog(
          layerName: layerName,
          onStart: (transplantDate, plantCount, variety) {
            return _layerService.startCycle(
              siteId: widget.shelf['site_id'],
              shelfId: widget.shelf['id'],
              layerId: layerId,
              transplantDate: transplantDate,
              plantCount: plantCount,
              variety: variety,
            );
          },
        );
      },
    );

    // null = the user cancelled
    if (result == null || !mounted) return;

    _onCycleStarted(layerName, result);
  }

  void _onCycleStarted(String layerName, Map<String, dynamic> result) {
    final firstCapture = result['first_capture']?.toString();

    String message;

    switch (firstCapture) {
      case 'requested':
        message =
            '$layerName cycle started. Taking the first photo now (about a minute).';
        break;
      case 'existing':
        message =
            '$layerName cycle started. Photos already taken were added to it.';
        break;
      default:
        message =
            '$layerName cycle started. The first photo is taken at 8:00 PM.';
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));

    _loadLayers();

    // The camera needs a moment to take and upload the photo
    if (firstCapture == 'requested') {
      Future.delayed(const Duration(seconds: 75), () {
        if (mounted) _loadLayers();
      });
    }
  }

  // ============================================================
  // HARVEST
  // ============================================================

  Future<void> _showHarvestDialog(
    Map<String, dynamic> layer,
    Map<String, dynamic> cycle,
  ) async {
    final layerId = layer['layer_id'] as int;
    final layerName = layer['display_name']?.toString() ?? 'Layer';
    final cycleId = cycle['id'] as int;

    final siteId = widget.shelf['site_id'];
    final shelfId = widget.shelf['id'];

    final harvested = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return _HarvestDialog(
          layerName: layerName,
          onCheckPhoto: (requestId) {
            return _layerService.getHarvestPhoto(
              siteId: siteId,
              shelfId: shelfId,
              layerId: layerId,
              cycleId: cycleId,
              requestId: requestId,
            );
          },
          onRequestCapture: () {
            return _layerService.requestHarvestCapture(
              siteId: siteId,
              shelfId: shelfId,
              layerId: layerId,
              cycleId: cycleId,
            );
          },
          onHarvest: (imageId, weightG, note) async {
            await _layerService.harvestCycle(
              siteId: siteId,
              shelfId: shelfId,
              layerId: layerId,
              cycleId: cycleId,
              imageId: imageId,
              finalWeightG: weightG,
              note: note,
            );
          },
        );
      },
    );

    if (harvested != true || !mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$layerName harvested. The cycle has ended.')),
    );

    _loadLayers();
  }

  // ============================================================
  // ABORT GROWING CYCLE
  // ============================================================

  Future<void> _confirmAbortCycle(
    Map<String, dynamic> layer,
    Map<String, dynamic> cycle,
  ) async {
    final layerId = layer['layer_id'] as int;
    final layerName = layer['display_name']?.toString() ?? 'Layer';
    final cycleId = cycle['id'] as int;

    // null = cancelled, otherwise the reason (may be empty)
    final reason = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return _AbortCycleDialog(layerName: layerName);
      },
    );

    if (reason == null) return;

    try {
      await _layerService.abortCycle(
        siteId: widget.shelf['site_id'],
        shelfId: widget.shelf['id'],
        layerId: layerId,
        cycleId: cycleId,
        reason: reason,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('$layerName cycle aborted.')));

      _loadLayers();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  // ============================================================
  // CANOPY STATS
  // ============================================================

  Widget _buildCanopyStats(Map<String, dynamic>? canopy) {
    final status = canopy?['status']?.toString();
    final pixels = canopy?['pixels'];
    final cm2 = canopy?['cm2'];

    if (status == null) {
      return _canopyMessage(
        Icons.hourglass_empty_rounded,
        'Measuring canopy...',
        GrowthColors.muted,
      );
    }

    if (status == 'failed' || pixels == null) {
      return _canopyMessage(
        Icons.error_outline_rounded,
        'Canopy could not be measured',
        GrowthColors.red,
      );
    }

    final cm2Number = cm2 is num ? cm2.toDouble() : double.tryParse('$cm2');

    // Green pixels on the left, canopy area on the right
    return Row(
      children: [
        Expanded(
          child: _statTile(
            icon: Icons.grain_rounded,
            color: GrowthColors.teal,
            background: GrowthColors.tealSoft,
            label: 'Green pixels',
            value: _formatThousands(pixels),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statTile(
            icon: Icons.crop_free_rounded,
            color: GrowthColors.accentStrong,
            background: GrowthColors.accentSoft,
            label: 'Canopy area(~)',
            value: cm2Number == null
                ? '--'
                : '${cm2Number.toStringAsFixed(1)} cm\u00B2',
          ),
        ),
      ],
    );
  }

  Widget _statTile({
    required IconData icon,
    required Color color,
    required Color background,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: background.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.55), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 17, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GrowthStyle.text(
                    size: 10.5,
                    weight: FontWeight.w600,
                    color: GrowthColors.body,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GrowthStyle.text(
                    size: 15,
                    weight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _canopyMessage(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 6),
        Text(
          text,
          style: FarmTabTheme.font(
            size: 12.5,
            weight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }

  String _formatThousands(dynamic value) {
    final number = value is num ? value.toInt() : int.tryParse('$value');

    if (number == null) return '--';

    final text = number.toString();
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      if (i > 0 && (text.length - i) % 3 == 0) buffer.write(',');
      buffer.write(text[i]);
    }

    return buffer.toString();
  }

  Widget _buildImage(
    String layerName,
    Map<String, dynamic> image,
    String path,
  ) {
    final url = LayerService.imageUrl(path);

    return GestureDetector(
      onTap: () => _openFullImage(layerName, image, path),
      child: Image.network(
        url,
        key: ValueKey(url),
        fit: BoxFit.cover,
        width: double.infinity,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;

          return Container(
            color: const Color(0xFFF7F7F7),
            alignment: Alignment.center,
            child: const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: GrowthColors.accentStrong,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: const Color(0xFFF7F7F7),
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.broken_image_outlined,
                  size: 30,
                  color: Color(0xFFB0B0B0),
                ),
                const SizedBox(height: 6),
                Text(
                  'Unable to load image',
                  style: FarmTabTheme.font(
                    size: 12.5,
                    weight: FontWeight.w400,
                    color: GrowthColors.muted,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNoImage({bool hasCycle = false}) {
    return Container(
      color: const Color(0xFFF7F7F7),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasCycle
                ? Icons.hourglass_empty_rounded
                : Icons.photo_camera_outlined,
            size: 30,
            color: hasCycle ? GrowthColors.accent : const Color(0xFFB0B0B0),
          ),
          const SizedBox(height: 8),
          Text(
            hasCycle ? 'Waiting for the first photo' : 'No image yet',
            textAlign: TextAlign.center,
            style: FarmTabTheme.font(
              size: 13.5,
              weight: FontWeight.w600,
              color: hasCycle ? GrowthColors.accentStrong : GrowthColors.muted,
            ),
          ),
          if (hasCycle) ...[
            const SizedBox(height: 4),
            Text(
              'Cameras take a photo every day at 8:00 PM.',
              textAlign: TextAlign.center,
              style: FarmTabTheme.font(
                size: 12,
                weight: FontWeight.w400,
                color: GrowthColors.muted,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildImageFooter(
    Map<String, dynamic>? image, {
    bool hasCycle = false,
  }) {
    if (image == null) {
      return Text(
        hasCycle
            ? 'This cycle has no photo yet'
            : 'Waiting for the first capture',
        style: FarmTabTheme.font(
          size: 12.5,
          weight: FontWeight.w400,
          color: GrowthColors.muted,
        ),
      );
    }

    final capturedAt = DateTime.tryParse(image['captured_at']?.toString() ?? '')
        ?.toLocal();

    final isTest = image['capture_type']?.toString() == 'manual';

    final isStale =
        capturedAt != null &&
        DateTime.now().difference(capturedAt) > _staleAfter;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.schedule_rounded,
              size: 14,
              color: GrowthColors.muted,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                capturedAt == null
                    ? '--'
                    : '${_formatDateTime(capturedAt)}  ·  ${_timeAgo(capturedAt)}',
                style: FarmTabTheme.font(
                  size: 12.5,
                  weight: FontWeight.w500,
                  color: GrowthColors.body,
                ),
              ),
            ),
            if (isTest)
              _chip(
                'Test',
                GrowthColors.blue,
                GrowthColors.blue.withOpacity(0.10),
              ),
          ],
        ),
        if (isStale) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                size: 15,
                color: GrowthColors.amber,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'No new image in the last day. Check this camera.',
                  style: FarmTabTheme.font(
                    size: 12,
                    weight: FontWeight.w500,
                    color: GrowthColors.amber,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildCycleChip(Map<String, dynamic>? cycle) {
    if (cycle == null) {
      return _chip('No cycle', GrowthColors.muted, const Color(0xFFF2F2F2));
    }

    final transplant = DateTime.tryParse(
      cycle['transplant_date']?.toString() ?? '',
    );

    if (transplant == null) {
      return _chip(
        'Growing',
        GrowthColors.accentStrong,
        GrowthColors.accentSoft,
      );
    }

    final today = DateTime.now();
    final start = DateTime(transplant.year, transplant.month, transplant.day);
    final current = DateTime(today.year, today.month, today.day);
    final day = current.difference(start).inDays + 1;

    return _chip(
      'Day ${day < 1 ? 1 : day}',
      GrowthColors.accentStrong,
      GrowthColors.accentSoft,
    );
  }

  Widget _chip(String text, Color textColor, Color background) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: FarmTabTheme.font(
          size: 11,
          weight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }

  // ============================================================
  // FULL-SCREEN IMAGE (pinch to zoom)
  // ============================================================

  void _openFullImage(
    String layerName,
    Map<String, dynamic> image,
    String path,
  ) {
    final url = LayerService.imageUrl(path);

    final capturedAt = DateTime.tryParse(image['captured_at']?.toString() ?? '')
        ?.toLocal();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            title: Text(
              capturedAt == null
                  ? layerName
                  : '$layerName  ·  ${_formatDateTime(capturedAt)}',
              style: FarmTabTheme.font(
                size: 14.5,
                weight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          body: Center(
            child: InteractiveViewer(
              minScale: 1,
              maxScale: 5,
              child: Image.network(url, fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // STATES
  // ============================================================

  Widget _buildLoading() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: GrowthStyle.card(),
      child: Column(
        children: [
          const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: GrowthColors.accentStrong,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Loading layer images...',
            style: FarmTabTheme.font(
              size: 13.5,
              weight: FontWeight.w400,
              color: GrowthColors.muted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFFF7F7F7),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 30,
            color: GrowthColors.red,
          ),
          const SizedBox(height: 10),
          Text(
            _error ?? 'Unable to load layer images.',
            textAlign: TextAlign.center,
            style: FarmTabTheme.font(
              size: 13.5,
              weight: FontWeight.w400,
              color: GrowthColors.body,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: _loadLayers,
            style: GrowthStyle.outlinedButton,
            child: Text(
              'Retry',
              style: FarmTabTheme.font(
                size: 13,
                weight: FontWeight.w600,
                color: GrowthColors.accentStrong,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFFF7F7F7),
      ),
      child: Text(
        'No camera layers are set up for this shelf yet.',
        textAlign: TextAlign.center,
        style: FarmTabTheme.font(
          size: 13.5,
          weight: FontWeight.w400,
          color: GrowthColors.muted,
        ),
      ),
    );
  }

  // ============================================================
  // FORMATTING
  // ============================================================

  String _formatDateTime(DateTime dateTime) {
    const months = [
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

    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';

    return '${dateTime.day} ${months[dateTime.month - 1]}, '
        '$hour:$minute $period';
  }

  String _timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);

    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} h ago';

    final days = diff.inDays;
    return days == 1 ? '1 day ago' : '$days days ago';
  }
}

// ============================================================
// SHARED HELPERS FOR THE DIALOGS
// ============================================================

String _formatShortDate(DateTime date) {
  const months = [
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

  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

InputDecoration _layerFieldDecoration(String hint) {
  return InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: const Color(0xFFF7F7F7),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: GrowthColors.accent, width: 1.5),
    ),
  );
}

// ============================================================
// START CYCLE DIALOG
// ============================================================

class _StartCycleDialog extends StatefulWidget {
  final String layerName;

  // Sends the request to the backend and returns its result
  final Future<Map<String, dynamic>> Function(
    DateTime transplantDate,
    int plantCount,
    String variety,
  )
  onStart;

  const _StartCycleDialog({required this.layerName, required this.onStart});

  @override
  State<_StartCycleDialog> createState() => _StartCycleDialogState();
}

class _StartCycleDialogState extends State<_StartCycleDialog> {
  final TextEditingController _plantsController = TextEditingController();
  final TextEditingController _varietyController = TextEditingController(
    text: 'looseleaf lettuce',
  );

  late final DateTime _today;
  late DateTime _transplantDate;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    _today = DateTime(now.year, now.month, now.day);
    _transplantDate = _today;
  }

  // Runs only when the dialog is really removed from the screen,
  // after its closing animation has finished.
  @override
  void dispose() {
    _plantsController.dispose();
    _varietyController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _transplantDate,
      firstDate: _today.subtract(const Duration(days: 60)),
      lastDate: _today,
    );

    if (picked != null && mounted) {
      setState(() {
        _transplantDate = picked;
      });
    }
  }

  Future<void> _submit() async {
    final plants = int.tryParse(_plantsController.text.trim());

    if (plants == null || plants < 1 || plants > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the number of plants (1 to 100).'),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final result = await widget.onStart(
        _transplantDate,
        plants,
        _varietyController.text.trim(),
      );

      if (!mounted) return;

      Navigator.pop(context, result);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Widget _label(String text) {
    return Text(
      text,
      style: FarmTabTheme.font(
        size: 13,
        weight: FontWeight.w600,
        color: GrowthColors.ink,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'Start Growing Cycle \u00B7 ${widget.layerName}',
        style: FarmTabTheme.font(
          size: 16,
          weight: FontWeight.w700,
          color: GrowthColors.ink,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label('Transplant Date (Day 1)'),
            const SizedBox(height: 8),
            InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: _isSaving ? null : _pickDate,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: FarmTabTheme.border),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 18,
                      color: GrowthColors.accentStrong,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _formatShortDate(_transplantDate),
                      style: FarmTabTheme.font(
                        size: 14.5,
                        weight: FontWeight.w500,
                        color: GrowthColors.ink,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _transplantDate == _today
                  ? 'Photos are taken automatically every day at 8:00 PM.'
                  : 'Photos already taken since this date will join the cycle.',
              style: FarmTabTheme.font(
                size: 11.5,
                weight: FontWeight.w400,
                color: GrowthColors.muted,
              ),
            ),
            const SizedBox(height: 18),
            _label('Number of Plants'),
            const SizedBox(height: 8),
            TextField(
              controller: _plantsController,
              keyboardType: TextInputType.number,
              enabled: !_isSaving,
              decoration: _layerFieldDecoration('e.g. 16'),
            ),
            const SizedBox(height: 18),
            _label('Variety'),
            const SizedBox(height: 8),
            TextField(
              controller: _varietyController,
              enabled: !_isSaving,
              decoration: _layerFieldDecoration('looseleaf lettuce'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: FarmTabTheme.font(
              size: 13.5,
              weight: FontWeight.w600,
              color: GrowthColors.muted,
            ),
          ),
        ),
        ElevatedButton(
          style: GrowthStyle.primaryButton,
          onPressed: _isSaving ? null : _submit,
          child: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  'Start Cycle',
                  style: FarmTabTheme.font(
                    size: 13.5,
                    weight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
        ),
      ],
    );
  }
}

// ============================================================
// ABORT CYCLE DIALOG
// ============================================================

class _AbortCycleDialog extends StatefulWidget {
  final String layerName;

  const _AbortCycleDialog({required this.layerName});

  @override
  State<_AbortCycleDialog> createState() => _AbortCycleDialogState();
}

class _AbortCycleDialogState extends State<_AbortCycleDialog> {
  final TextEditingController _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'Abort ${widget.layerName} cycle?',
        style: FarmTabTheme.font(
          size: 16,
          weight: FontWeight.w700,
          color: GrowthColors.ink,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Use this if the cycle was started by mistake or the batch '
            'failed. Photos and records are kept, but this cycle will '
            'not be used for training. To record a normal harvest, use '
            'Harvest instead.',
            style: FarmTabTheme.font(
              size: 13,
              weight: FontWeight.w400,
              color: GrowthColors.body,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _reasonController,
            decoration: _layerFieldDecoration('Reason (optional)'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: FarmTabTheme.font(
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
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () =>
              Navigator.pop(context, _reasonController.text.trim()),
          child: Text(
            'Abort Cycle',
            style: FarmTabTheme.font(
              size: 13.5,
              weight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// HARVEST DIALOG
// ============================================================
// Steps: find today's photo (or ask the camera for one) -> check the
// photo and its canopy -> enter weight and note -> confirm.

String _formatClock(DateTime dateTime) {
  final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
  final minute = dateTime.minute.toString().padLeft(2, '0');
  final period = dateTime.hour >= 12 ? 'PM' : 'AM';

  return '$hour:$minute $period';
}

class _HarvestDialog extends StatefulWidget {
  final String layerName;

  // requestId == null: look for a photo taken today.
  // requestId != null: follow the "capture now" job.
  final Future<Map<String, dynamic>> Function(int? requestId) onCheckPhoto;

  // Asks the camera for a new photo; returns the request id.
  final Future<int> Function() onRequestCapture;

  // Ends the cycle. imageId == null means "harvest without a final photo".
  final Future<void> Function(int? imageId, double? weightG, String? note)
  onHarvest;

  const _HarvestDialog({
    required this.layerName,
    required this.onCheckPhoto,
    required this.onRequestCapture,
    required this.onHarvest,
  });

  @override
  State<_HarvestDialog> createState() => _HarvestDialogState();
}

class _HarvestDialogState extends State<_HarvestDialog> {
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  // loading, needs_capture, waiting, measuring, ready,
  // measure_failed, expired, no_photo, error
  String _state = 'loading';

  Map<String, dynamic>? _image;
  bool _showOverlay = false;
  bool _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _checkToday();
  }

  // Runs only when the dialog is really removed from the screen
  @override
  void dispose() {
    _weightController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  String _plainError(Object e) => e.toString().replaceFirst('Exception: ', '');

  void _applyResult(Map<String, dynamic> result) {
    setState(() {
      _state = result['state']?.toString() ?? 'error';
      _image = result['image'] == null
          ? null
          : Map<String, dynamic>.from(result['image'] as Map);
      _showOverlay = false;
    });
  }

  Future<void> _checkToday() async {
    setState(() {
      _state = 'loading';
      _error = null;
    });

    try {
      final result = await widget.onCheckPhoto(null);

      if (!mounted) return;

      _applyResult(result);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _state = 'error';
        _error = _plainError(e);
      });
    }
  }

  Future<void> _captureNow() async {
    setState(() {
      _state = 'waiting';
      _image = null;
    });

    try {
      final requestId = await widget.onRequestCapture();

      if (!mounted) return;

      await _pollForPhoto(requestId);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _state = 'error';
        _error = _plainError(e);
      });
    }
  }

  // Asks the server every 4 seconds whether the photo has arrived
  Future<void> _pollForPhoto(int requestId) async {
    final deadline = DateTime.now().add(const Duration(minutes: 3));

    while (mounted && DateTime.now().isBefore(deadline)) {
      await Future.delayed(const Duration(seconds: 4));

      if (!mounted) return;

      try {
        final result = await widget.onCheckPhoto(requestId);

        if (!mounted) return;

        final state = result['state']?.toString();

        if (state == 'waiting' || state == 'measuring') {
          setState(() {
            _state = state ?? 'waiting';
          });
          continue;
        }

        _applyResult(result);
        return;
      } catch (_) {
        // A short network problem: keep trying until the deadline
      }
    }

    if (mounted) {
      setState(() {
        _state = 'expired';
      });
    }
  }

  Future<void> _submit() async {
    final weight = double.tryParse(_weightController.text.trim());

    if (weight == null || weight <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the harvested weight in grams.'),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final imageId = _state == 'no_photo' ? null : _image?['id'] as int?;

      await widget.onHarvest(imageId, weight, _noteController.text.trim());

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(_plainError(e))));
    }
  }

  // ------------------------------------------------------------
  // Small building blocks
  // ------------------------------------------------------------

  Widget _label(String text) {
    return Text(
      text,
      style: FarmTabTheme.font(
        size: 13,
        weight: FontWeight.w600,
        color: GrowthColors.ink,
      ),
    );
  }

  Widget _busy(String text) {
    return Row(
      children: [
        const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: GrowthColors.accentStrong,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            text,
            style: FarmTabTheme.font(
              size: 13.5,
              weight: FontWeight.w400,
              color: GrowthColors.body,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _message(IconData icon, String text, {Color? color}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22, color: color ?? GrowthColors.accent),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: FarmTabTheme.font(
              size: 13.5,
              weight: FontWeight.w400,
              color: GrowthColors.body,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoPreview() {
    final image = _image!;

    final canopy = image['canopy'] == null
        ? null
        : Map<String, dynamic>.from(image['canopy'] as Map);

    final overlay = canopy?['overlay_url']?.toString();
    final hasOverlay = overlay != null && overlay.isNotEmpty;

    final String path = (_showOverlay && overlay != null && overlay.isNotEmpty)
        ? overlay
        : image['image_url'].toString();

    final url = LayerService.imageUrl(path);

    final capturedAt = DateTime.tryParse(image['captured_at']?.toString() ?? '')
        ?.toLocal();

    final cm2 = canopy?['cm2'];
    final pixels = canopy?['pixels'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AspectRatio(
            aspectRatio: 4 / 3,
            child: Image.network(
              url,
              key: ValueKey(url),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: const Color(0xFFF7F7F7),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.broken_image_outlined,
                    size: 30,
                    color: Color(0xFFB0B0B0),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Text(
                capturedAt == null
                    ? ''
                    : 'Photo taken ${_formatShortDate(capturedAt)}, '
                          '${_formatClock(capturedAt)}',
                style: FarmTabTheme.font(
                  size: 12,
                  weight: FontWeight.w500,
                  color: GrowthColors.muted,
                ),
              ),
            ),
            if (hasOverlay)
              TextButton(
                onPressed: () {
                  setState(() {
                    _showOverlay = !_showOverlay;
                  });
                },
                child: Text(
                  _showOverlay ? 'Show photo' : 'Show canopy',
                  style: FarmTabTheme.font(
                    size: 12.5,
                    weight: FontWeight.w600,
                    color: GrowthColors.accentStrong,
                  ),
                ),
              ),
          ],
        ),
        if (pixels != null)
          Text(
            'Canopy: ${cm2 is num ? cm2.toStringAsFixed(1) : '--'} cm\u00B2 '
            '(approx.)  \u00B7  $pixels green pixels',
            style: FarmTabTheme.font(
              size: 13,
              weight: FontWeight.w600,
              color: GrowthColors.ink,
            ),
          ),
      ],
    );
  }

  Widget _buildFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        _label('Total Harvested Weight (all plants)'),
        const SizedBox(height: 8),
        TextField(
          controller: _weightController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          enabled: !_isSaving,
          decoration: _layerFieldDecoration('e.g. 850')
              .copyWith(suffixText: 'g'),
        ),
        const SizedBox(height: 16),
        _label('Note (optional)'),
        const SizedBox(height: 8),
        TextField(
          controller: _noteController,
          enabled: !_isSaving,
          decoration: _layerFieldDecoration('e.g. leaves fill the pot'),
        ),
      ],
    );
  }

  Widget _buildBody() {
    switch (_state) {
      case 'loading':
        return _busy("Checking today's photo...");

      case 'waiting':
        return _busy('Taking a photo now. This can take up to a minute...');

      case 'measuring':
        return _busy('Photo received. Measuring the canopy...');

      case 'needs_capture':
        return _message(
          Icons.lightbulb_outline_rounded,
          'No photo has been taken today for this layer. Switch the grow '
          'lights on, then press Capture Now.',
        );

      case 'expired':
        return _message(
          Icons.cloud_off_rounded,
          'The camera did not answer in time. Check that its Raspberry Pi '
          'is on, then try again.',
          color: GrowthColors.amber,
        );

      case 'measure_failed':
        return _message(
          Icons.error_outline_rounded,
          'The photo could not be measured. Retake the photo.',
          color: GrowthColors.red,
        );

      case 'error':
        return _message(
          Icons.error_outline_rounded,
          _error ?? 'Something went wrong.',
          color: GrowthColors.red,
        );

      case 'no_photo':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _message(
              Icons.warning_amber_rounded,
              'Harvesting without a final photo. The final canopy will not '
              'be recorded for this cycle.',
              color: GrowthColors.amber,
            ),
            _buildFields(),
          ],
        );

      default: // ready
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [if (_image != null) _buildPhotoPreview(), _buildFields()],
        );
    }
  }

  Widget _cancelButton() {
    return TextButton(
      onPressed: _isSaving ? null : () => Navigator.pop(context, false),
      child: Text(
        'Cancel',
        style: FarmTabTheme.font(
          size: 13.5,
          weight: FontWeight.w600,
          color: GrowthColors.muted,
        ),
      ),
    );
  }

  Widget _textAction(String text, VoidCallback? onPressed) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: FarmTabTheme.font(
          size: 13.5,
          weight: FontWeight.w600,
          color: GrowthColors.accentStrong,
        ),
      ),
    );
  }

  Widget _primaryAction(String text, VoidCallback? onPressed) {
    return ElevatedButton(
      style: GrowthStyle.primaryButton,
      onPressed: onPressed,
      child: Text(
        text,
        style: FarmTabTheme.font(
          size: 13.5,
          weight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  List<Widget> _buildActions() {
    switch (_state) {
      case 'loading':
      case 'waiting':
      case 'measuring':
        return [_cancelButton()];

      case 'needs_capture':
        return [
          _cancelButton(),
          _textAction('Harvest without photo', () {
            setState(() {
              _state = 'no_photo';
              _image = null;
            });
          }),
          _primaryAction('Capture Now', _captureNow),
        ];

      case 'expired':
      case 'measure_failed':
        return [
          _cancelButton(),
          _textAction('Harvest without photo', () {
            setState(() {
              _state = 'no_photo';
              _image = null;
            });
          }),
          _primaryAction(
            _state == 'expired' ? 'Try Again' : 'Retake',
            _captureNow,
          ),
        ];

      case 'error':
        return [_cancelButton(), _primaryAction('Try Again', _checkToday)];

      case 'no_photo':
        return [
          _cancelButton(),
          _primaryAction('Confirm Harvest', _isSaving ? null : _submit),
        ];

      default: // ready
        return [
          _cancelButton(),
          _textAction('Retake', _isSaving ? null : _captureNow),
          _primaryAction('Confirm Harvest', _isSaving ? null : _submit),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'Harvest \u00B7 ${widget.layerName}',
        style: FarmTabTheme.font(
          size: 16,
          weight: FontWeight.w700,
          color: GrowthColors.ink,
        ),
      ),
      content: SingleChildScrollView(child: _buildBody()),
      actions: _buildActions(),
    );
  }
}
