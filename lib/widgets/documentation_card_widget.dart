import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/documentation_item.dart';
import './drawing_viewer.dart';
import 'dart:math' as math;

class DocumentationCardWidget extends StatelessWidget {
  final DocumentationItem item;
  final VoidCallback onTap;

  const DocumentationCardWidget({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header con tipo y fecha - responsivo
                    Row(
                      children: [
                        Flexible(
                          flex: 2,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getTypeColor(item.type).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getTypeIcon(item.type),
                                  size: 14,
                                  color: _getTypeColor(item.type),
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    _getTypeLabel(item.type),
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: _getTypeColor(item.type),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          flex: 1,
                          child: Text(
                            _formatDate(item.createdAt),
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: Colors.grey[500],
                            ),
                            textAlign: TextAlign.end,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Título - responsivo
                    Text(
                      item.title,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Contenido - responsivo
                    Text(
                      item.content,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    // Mostrar dibujo si existe
                    if (_hasDrawing(item)) ...[
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () => _showFullDrawing(context, _getDrawingData(item)!),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: 150,
                            maxWidth: constraints.maxWidth,
                          ),
                          child: DrawingViewer(
                            drawingData: _getDrawingData(item)!,
                            height: 150,
                            isPreview: true,
                          ),
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: 12),
                    
                    // Footer responsivo
                    _buildFooter(item),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showFullDrawing(BuildContext context, String drawingData) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.brush,
                      color: const Color(0xFF4CAF50),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Dibujo completo',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: DrawingViewer(
                  drawingData: drawingData,
                  isPreview: false,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTypeColor(DocumentationType type) {
    switch (type) {
      case DocumentationType.milestone:
        return const Color(0xFF6C63FF);
      case DocumentationType.note:
        return const Color(0xFF4CAF50);
      case DocumentationType.task:
        return const Color(0xFFFF6B6B);
      case DocumentationType.update:
        return const Color(0xFF00BFA6);
      case DocumentationType.file:
        return const Color(0xFF9C27B0);
      case DocumentationType.image:
        return const Color(0xFFFF9800);
      case DocumentationType.diagram:
        return const Color(0xFF2196F3);
    }
  }

  IconData _getTypeIcon(DocumentationType type) {
    switch (type) {
      case DocumentationType.milestone:
        return Icons.flag;
      case DocumentationType.note:
        return Icons.note;
      case DocumentationType.task:
        return Icons.check_circle;
      case DocumentationType.update:
        return Icons.update;
      case DocumentationType.file:
        return Icons.attach_file;
      case DocumentationType.image:
        return Icons.image;
      case DocumentationType.diagram:
        return Icons.account_tree;
    }
  }

  String _getTypeLabel(DocumentationType type) {
    switch (type) {
      case DocumentationType.milestone:
        return 'Meta';
      case DocumentationType.note:
        return 'Nota';
      case DocumentationType.task:
        return 'Tarea';
      case DocumentationType.update:
        return 'Actualización';
      case DocumentationType.file:
        return 'Archivo';
      case DocumentationType.image:
        return 'Imagen';
      case DocumentationType.diagram:
        return 'Diagrama';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  bool _hasDrawing(DocumentationItem item) {
    print('=== CHECKING FOR DRAWING ===');
    print('Item ID: ${item.id}');
    print('Item title: ${item.title}');
    print('All attachments: ${item.attachments}');
    
    if (item.attachments == null) {
      print('No attachments found');
      return false;
    }
    
    for (String attachment in item.attachments!) {
      print('Checking attachment: $attachment');
      if (attachment.startsWith('drawing:')) {
        print('DRAWING FOUND!');
        return true;
      }
    }
    
    print('No drawing attachment found');
    return false;
  }

  String? _getDrawingData(DocumentationItem item) {
    print('=== GETTING DRAWING DATA ===');
    
    if (item.attachments == null) return null;
    
    for (String attachment in item.attachments!) {
      if (attachment.startsWith('drawing:')) {
        final drawingData = attachment.substring('drawing:'.length);
        print('Found drawing data: ${drawingData.length} characters');
        print('Drawing preview: ${drawingData.substring(0, math.min(50, drawingData.length))}...');
        return drawingData;
      }
    }
    
    print('No drawing data found');
    return null;
  }

  Widget _buildFooter(DocumentationItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Solo mostrar status si existe
        if (item.status != null)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(item.status!).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                item.status!,
                style: GoogleFonts.poppins(
                  color: _getStatusColor(item.status!),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        
        // Para notas, no mostrar attachments (categoría, prioridad, etc.)
        // Solo mostrar attachments reales para otros tipos de documentos
        if (item.type != DocumentationType.note && 
            item.attachments != null && 
            item.attachments!.isNotEmpty)
          LayoutBuilder(
            builder: (context, constraints) {
              final realAttachments = item.attachments!
                  .where((attachment) => 
                      !attachment.startsWith('drawing:') &&
                      !attachment.startsWith('category:') &&
                      !attachment.startsWith('priority:') &&
                      !attachment.startsWith('markdown:'))
                  .toList();
              
              if (realAttachments.isEmpty) return const SizedBox.shrink();
              
              return Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  ...realAttachments.take(2).map((attachment) {
                    return Container(
                      constraints: BoxConstraints(
                        maxWidth: constraints.maxWidth * 0.4,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getAttachmentIcon(attachment),
                            size: 12,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              attachment.length > 15 
                                  ? '${attachment.substring(0, 12)}...' 
                                  : attachment,
                              style: GoogleFonts.poppins(
                                color: Colors.grey[600],
                                fontSize: 9,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  if (realAttachments.length > 2)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '+${realAttachments.length - 2}',
                        style: GoogleFonts.poppins(
                          color: Colors.grey[600],
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completado':
        return const Color(0xFF4CAF50);
      case 'en progreso':
        return const Color(0xFFFF9800);
      case 'pendiente':
        return const Color(0xFF9E9E9E);
      default:
        return const Color(0xFF6C63FF);
    }
  }

  IconData _getAttachmentIcon(String attachment) {
    final extension = attachment.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }
} 