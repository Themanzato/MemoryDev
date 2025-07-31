import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/documentation_item.dart';
import '../drawing_canvas.dart';
import '../../screens/full_screen_drawing_screen.dart';

class NoteForm extends StatefulWidget {
  final Function(DocumentationItem) onSave;
  final DocumentationItem? initialNote;

  const NoteForm({
    super.key,
    required this.onSave,
    this.initialNote,
  });

  @override
  State<NoteForm> createState() => _NoteFormState();
}

class _NoteFormState extends State<NoteForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _drawingData = '';

  @override
  void initState() {
    super.initState();
    if (widget.initialNote != null) {
      _titleController.text = widget.initialNote!.title;
      _contentController.text = widget.initialNote!.content;
      
      print('=== LOADING NOTE ===');
      print('Note attachments: ${widget.initialNote!.attachments}');
      
      // Cargar datos del dibujo si existen
      if (widget.initialNote!.attachments != null) {
        for (String attachment in widget.initialNote!.attachments!) {
          print('Checking attachment: $attachment');
          if (attachment.startsWith('drawing:')) {
            _drawingData = attachment.substring('drawing:'.length);
            print('Found drawing data: ${_drawingData.length} characters');
            break;
          }
        }
      }
      
      print('Final _drawingData length: ${_drawingData.length}');
      print('=== END LOADING ===');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.note,
                    color: Color(0xFF4CAF50),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    widget.initialNote != null ? 'Editar Nota' : 'Nueva Nota',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Form
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: 'Título',
                          hintText: 'Escribe el título de tu nota...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.title),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa un título';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Contenido
                      TextFormField(
                        controller: _contentController,
                        maxLines: 6,
                        decoration: InputDecoration(
                          labelText: 'Descripción',
                          hintText: 'Escribe el contenido de tu nota...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.description),
                          alignLabelWithHint: true,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa una descripción';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Sección de dibujo
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.brush,
                                  color: const Color(0xFF4CAF50),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Dibujo (Opcional)',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            
                            if (_drawingData.isNotEmpty) ...[
                              // Vista previa del dibujo
                              Container(
                                height: 120,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.brush,
                                        size: 32,
                                        color: const Color(0xFF4CAF50),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Dibujo incluido',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: _openDrawingScreen,
                                      icon: const Icon(Icons.edit),
                                      label: Text(
                                        'Editar Dibujo',
                                        style: GoogleFonts.poppins(),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: const Color(0xFF4CAF50),
                                        side: const BorderSide(color: Color(0xFF4CAF50)),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: _removeDrawing,
                                      icon: const Icon(Icons.delete_outline),
                                      label: Text(
                                        'Eliminar',
                                        style: GoogleFonts.poppins(),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.red,
                                        side: const BorderSide(color: Colors.red),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ] else ...[
                              // Botón para agregar dibujo
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: _openDrawingScreen,
                                  icon: const Icon(Icons.add),
                                  label: Text(
                                    'Agregar Dibujo',
                                    style: GoogleFonts.poppins(),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF4CAF50),
                                    side: const BorderSide(color: Color(0xFF4CAF50)),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Botones de acción
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'Cancelar',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveNote,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'Guardar Nota',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _saveNote() {
    print('=== SAVING NOTE ===');
    if (_formKey.currentState!.validate()) {
      final attachments = <String>[];

      print('Drawing data length before save: ${_drawingData.length}');
      
      // Agregar datos del dibujo si existe
      if (_drawingData.isNotEmpty) {
        attachments.add('drawing:$_drawingData');
        print('Added drawing to attachments');
      } else {
        print('No drawing data to save');
      }

      print('Final attachments: $attachments');

      final note = DocumentationItem(
        id: widget.initialNote?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        content: _contentController.text,
        type: DocumentationType.note,
        createdAt: widget.initialNote?.createdAt ?? DateTime.now(),
        status: null,
        attachments: attachments,
      );
      
      print('Saving note with ${note.attachments?.length ?? 0} attachments');
      widget.onSave(note);
      Navigator.pop(context);
    }
    print('=== END SAVING ===');
  }

  void _openDrawingScreen() async {
    print('=== OPENING DRAWING SCREEN ===');
    print('Current drawing data length: ${_drawingData.length}');
    
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenDrawingScreen(
          initialDrawing: _drawingData.isNotEmpty ? _drawingData : null,
        ),
      ),
    );
    
    if (result != null) {
      print('Received result from drawing screen: ${result.length} characters');
      setState(() {
        _drawingData = result;
      });
      print('Updated _drawingData length: ${_drawingData.length}');
    } else {
      print('No result received from drawing screen');
    }
    print('=== END OPENING DRAWING SCREEN ===');
  }

  void _removeDrawing() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Eliminar Dibujo',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          '¿Estás seguro de que quieres eliminar el dibujo? Esta acción no se puede deshacer.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _drawingData = '';
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(
              'Eliminar',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
} 