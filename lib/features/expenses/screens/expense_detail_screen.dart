import 'dart:io'; // Added for File operations

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wanzo/features/expenses/bloc/expense_bloc.dart';
import 'package:wanzo/features/expenses/models/expense.dart';
import 'package:wanzo/core/shared_widgets/wanzo_app_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart'; // Added for sharing
import 'package:path_provider/path_provider.dart'; // Added for temp directory
import 'package:flutter_cache_manager/flutter_cache_manager.dart'; // Added for cache access
import 'package:http/http.dart' as http; // Added for manual download

// Import for PhotoView
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ExpenseDetailScreen extends StatefulWidget {
  final String expenseId;

  const ExpenseDetailScreen({super.key, required this.expenseId});

  @override
  State<ExpenseDetailScreen> createState() => _ExpenseDetailScreenState();
}

class _ExpenseDetailScreenState extends State<ExpenseDetailScreen> {
  bool _isSharing = false; // To track sharing state and show loading indicator

  @override
  void initState() {
    super.initState();
    context.read<ExpenseBloc>().add(LoadExpenseById(widget.expenseId));
  }

  Future<File> _getFileForSharing(String url) async {
    // Try to get the file from cache
    final fileInfo = await DefaultCacheManager().getFileFromCache(url);
    
    if (fileInfo != null && await fileInfo.file.exists()) {
      return fileInfo.file;
    } else {
      // If not in cache or file doesn't exist, download it
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final tempDir = await getTemporaryDirectory();
        // Extract filename from URL or generate one
        String fileName = 'shared_image.jpg'; // Default filename
        try {
          final uri = Uri.parse(url);
          if (uri.pathSegments.isNotEmpty) {
            String lastSegment = uri.pathSegments.last;
            if (lastSegment.isNotEmpty && lastSegment.contains('.')) {
              fileName = lastSegment;
            } else if (lastSegment.isNotEmpty) {
              fileName = '$lastSegment.jpg'; // Add default extension
            }
          }
        } catch (_) {
          // If URI parsing fails or path is unusual, stick to default
        }
        
        final File file = File('${tempDir.path}/$fileName');
        await file.writeAsBytes(response.bodyBytes);
        
        if (await file.exists()){
            return file;
        } else {
            throw Exception("Le fichier téléchargé n'existe pas après l'écriture.");
        }
      } else {
        throw Exception('Échec du téléchargement de l\'image (status: ${response.statusCode})');
      }
    }
  }

  Future<void> _shareAttachment(BuildContext context, String url) async {
    if (_isSharing) return; // Prevent multiple share attempts

    setState(() {
      _isSharing = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Préparation du partage...'), duration: Duration(seconds: 2)), // Shorter duration
    );

    try {
      final File imageToShare = await _getFileForSharing(url);
      final xFile = XFile(imageToShare.path);
      await Share.shareXFiles([xFile], text: 'Pièce jointe de dépense: ${widget.expenseId}');
    } catch (e) {
      if (mounted) { // Check if mounted before showing SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de partage: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) { // Check if the widget is still in the tree
        setState(() {
          _isSharing = false;
        });
      }
    }
  }

  void _openFullScreenImageViewer(BuildContext context, final List<String> imageUrls, final int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.black,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: PhotoViewGallery.builder(
            itemCount: imageUrls.length,
            builder: (context, index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: CachedNetworkImageProvider(imageUrls[index]),
                initialScale: PhotoViewComputedScale.contained,
                heroAttributes: PhotoViewHeroAttributes(tag: imageUrls[index]),
                minScale: PhotoViewComputedScale.contained * 0.8,
                maxScale: PhotoViewComputedScale.covered * 2,
              );
            },
            scrollPhysics: const BouncingScrollPhysics(),
            backgroundDecoration: const BoxDecoration(color: Colors.black),
            pageController: PageController(initialPage: initialIndex),
            loadingBuilder: (context, event) {
              double? progress;
              if (event != null && event.expectedTotalBytes != null) {
                progress = event.cumulativeBytesLoaded / event.expectedTotalBytes!;
              }
              return Center(
                child: SizedBox(
                  width: 20.0,
                  height: 20.0,
                  child: CircularProgressIndicator(
                    value: progress,
                  ),
                ),
              );
            },
            onPageChanged: (index) {
              // Optional: handle page change if needed
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA');

    return Scaffold(
      appBar: WanzoAppBar(
        title: 'Détails de la Dépense',
        onBackPressed: () { // Use onBackPressed for the back button
          if (context.canPop()) {
            context.pop();
          } else {
            // Handle case where there's nothing to pop (e.g., deep link)
            // You might want to navigate to a default screen
            context.go('/operations'); // Example: Navigate to operations screen
          }
        },
      ),
      body: Stack( // Wrap with Stack to show loading indicator over content
        children: [
          BlocBuilder<ExpenseBloc, ExpenseState>(
            builder: (context, state) {
              if (state is ExpenseLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ExpenseLoaded) {
                final expense = state.expense;
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _buildDetailRow(context, 'Motif:', expense.motif),
                      _buildDetailRow(context, 'Montant:', currencyFormat.format(expense.amount)),
                      _buildDetailRow(context, 'Date:', DateFormat('dd/MM/yyyy').format(expense.date)),
                      _buildDetailRow(context, 'Méthode de Paiement:', expense.paymentMethod ?? 'N/A'), // Handle nullable paymentMethod
                      _buildDetailRow(context, 'Catégorie:', expense.category.displayName),
                      
                      const SizedBox(height: 16),
                      Text('Pièces Jointes:', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)), // Added fontWeight
                      const SizedBox(height: 8),
                      _buildAttachments(context, expense.attachmentUrls ?? []), // Pass empty list if null
                      
                      // TODO: Add Edit/Delete buttons if necessary
                    ],
                  ),
                );
              } else if (state is ExpenseError) {
                return Center(child: Text('Erreur: ${state.message}'));
              }
              return const Center(child: Text('Veuillez charger une dépense.'));
            },
          ),
          if (_isSharing) // Show loading indicator
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 10),
                    Text('Partage en cours...', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label ', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value, style: Theme.of(context).textTheme.bodyMedium)),
        ],
      ),
    );
  }

  Widget _buildAttachments(BuildContext context, List<String> attachmentUrls) { // Changed to List<String>
    if (attachmentUrls.isEmpty) {
      return const Padding( // Added padding for consistency
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Text('Aucune pièce jointe.', style: TextStyle(fontStyle: FontStyle.italic)),
      );
    }
    return SizedBox(
      height: 160, // Increased height for better touch targets and visual
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: attachmentUrls.length,
        itemBuilder: (context, index) {
          final url = attachmentUrls[index];
          return Padding(
            padding: const EdgeInsets.only(right: 10.0), // Increased padding
            child: GestureDetector(
              onTap: () {
                // Open full screen viewer
                _openFullScreenImageViewer(context, attachmentUrls, index);
              },
              child: Hero( // Added Hero widget for smooth transition
                tag: url, // Unique tag for Hero animation
                child: Card(
                  elevation: 3, // Slightly increased elevation
                  shape: RoundedRectangleBorder( // Added rounded corners
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  clipBehavior: Clip.antiAlias, // Ensures content respects border radius
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CachedNetworkImage(
                        imageUrl: url,
                        width: 110, // Increased width
                        height: 160, // Matched container height
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container( // Improved placeholder
                          width: 110,
                          height: 160,
                          color: Colors.grey[200],
                          child: const Center(child: CircularProgressIndicator(strokeWidth: 2.0)),
                        ),
                        errorWidget: (context, url, error) {
                          // Keep existing errorWidget logic for simulated/broken images
                          if (url.startsWith('uploads/')) { 
                             return Container(
                              width: 110,
                              height: 160,
                              color: Colors.grey[300],
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.broken_image, color: Colors.grey[600], size: 40),
                                    const SizedBox(height: 4),
                                    Text('Simulé', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                                  ],
                                ),
                              ),
                            );
                          }
                          return Container(
                            width: 110,
                            height: 160,
                            color: Colors.grey[300],
                            child: Center(
                              child: Icon(Icons.error, color: Colors.red[400]),
                            ),
                          );
                        },
                      ),
                      Container( // Share button overlay
                        margin: const EdgeInsets.all(4.0),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.share, color: Colors.white, size: 18),
                          onPressed: () { // Removed the unused 'event' parameter
                            _shareAttachment(context, url);
                          },
                          tooltip: 'Partager',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
