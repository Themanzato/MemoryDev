import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/documentation_item.dart';

class FileForm extends StatefulWidget {
  final Function(DocumentationItem) onSave;

  const FileForm({
    super.key,
    required this.onSave,
  });

  @override
  State<FileForm> createState() => _FileFormState();
}

class _FileFormState extends State<FileForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<String> _selectedFiles = [];
  String _fileCategory = 'Documentos';

  final List<String> _fileCategories = [
    'Documentos',
    'Imágenes',
    'Presentaciones',
    'Hojas de Cálculo',
    'PDFs',
    'Audio',
    'Video',
    'Diseño',
    'Investigación',
    'Referencias',
    'Recursos',
    'Plantillas',
  ];

  // Simulamos tipos de archivos comunes
  final List<Map<String, dynamic>> _availableFiles = [
    {'name': 'requirements.pdf', 'type': 'pdf', 'size': '2.3 MB'},
    {'name': 'database_schema.sql', 'type': 'sql', 'size': '156 KB'},
    {'name': 'api_documentation.docx', 'type': 'docx', 'size': '845 KB'},
    {'name': 'wireframes.fig', 'type': 'fig', 'size': '12.7 MB'},
    {'name': 'logo.png', 'type': 'png', 'size': '89 KB'},
    {'name': 'config.json', 'type': 'json', 'size': '3.2 KB'},
    {'name': 'main.dart', 'type': 'dart', 'size': '15.6 KB'},
    {'name': 'styles.css', 'type': 'css', 'size': '8.9 KB'},
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
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
                    color: const Color(0xFF9C27B0).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.attach_file,
                    color: Color(0xFF9C27B0),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Adjuntar Archivos',
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
                          labelText: 'Título del conjunto de archivos',
                          hintText: 'Ej: Documentación técnica v1.0',
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
                      
                      // Categoría
                      DropdownButtonFormField<String>(
                        value: _fileCategory,
                        decoration: InputDecoration(
                          labelText: 'Categoría',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.folder),
                        ),
                        items: _fileCategories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _fileCategory = value!;
                          });
                        },
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Descripción
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Descripción',
                          hintText: 'Describe el propósito de estos archivos...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignLabelWithHint: true,
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor agrega una descripción';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Selección de archivos
                      Text(
                        'Seleccionar Archivos',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Botón para "simular" subida de archivos
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey[300]!,
                            style: BorderStyle.solid,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.cloud_upload_outlined,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Arrastra archivos aquí o haz click para seleccionar',
                              style: GoogleFonts.poppins(
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: _showFileSelector,
                              icon: const Icon(Icons.folder_open),
                              label: Text(
                                'Seleccionar Archivos',
                                style: GoogleFonts.poppins(),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF9C27B0),
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Archivos seleccionados
                      if (_selectedFiles.isNotEmpty) ...[
                        Text(
                          'Archivos Seleccionados (${_selectedFiles.length})',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...(_selectedFiles.map((fileName) {
                          final file = _availableFiles.firstWhere(
                            (f) => f['name'] == fileName,
                            orElse: () => {'name': fileName, 'type': 'unknown', 'size': '0 KB'},
                          );
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _getFileIcon(file['type']),
                                  color: _getFileColor(file['type']),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        file['name'],
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        file['size'],
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _selectedFiles.remove(fileName);
                                    });
                                  },
                                  icon: const Icon(Icons.remove_circle_outline),
                                  color: Colors.red,
                                ),
                              ],
                            ),
                          );
                        }).toList()),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Botones
            Row(
              children: [
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancelar',
                    style: GoogleFonts.poppins(
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _selectedFiles.isNotEmpty ? _saveFiles : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9C27B0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: Text(
                    'Adjuntar Archivos',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
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

  void _showFileSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Seleccionar Archivos',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView.builder(
            itemCount: _availableFiles.length,
            itemBuilder: (context, index) {
              final file = _availableFiles[index];
              final isSelected = _selectedFiles.contains(file['name']);
              
              return CheckboxListTile(
                title: Text(
                  file['name'],
                  style: GoogleFonts.poppins(),
                ),
                subtitle: Text(
                  file['size'],
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                secondary: Icon(
                  _getFileIcon(file['type']),
                  color: _getFileColor(file['type']),
                ),
                value: isSelected,
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _selectedFiles.add(file['name']);
                    } else {
                      _selectedFiles.remove(file['name']);
                    }
                  });
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cerrar',
              style: GoogleFonts.poppins(),
            ),
          ),
        ],
      ),
    );
  }

  void _saveFiles() {
    if (_formKey.currentState!.validate() && _selectedFiles.isNotEmpty) {
      final fileItem = DocumentationItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        content: _descriptionController.text,
        type: DocumentationType.file,
        createdAt: DateTime.now(),
        status: 'Adjuntado',
        attachments: _selectedFiles,
      );
      
      widget.onSave(fileItem);
      Navigator.pop(context);
    }
  }

  IconData _getFileIcon(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'docx':
      case 'doc':
        return Icons.description;
      case 'png':
      case 'jpg':
      case 'jpeg':
        return Icons.image;
      case 'sql':
        return Icons.storage;
      case 'dart':
      case 'js':
      case 'py':
        return Icons.code;
      case 'css':
      case 'html':
        return Icons.web;
      case 'json':
      case 'xml':
        return Icons.data_object;
      case 'fig':
        return Icons.design_services;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getFileColor(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return Colors.red;
      case 'docx':
      case 'doc':
        return Colors.blue;
      case 'png':
      case 'jpg':
      case 'jpeg':
        return Colors.green;
      case 'sql':
        return Colors.orange;
      case 'dart':
        return Colors.blue;
      case 'js':
        return Colors.yellow[700]!;
      case 'py':
        return Colors.green;
      case 'css':
        return Colors.blue;
      case 'html':
        return Colors.orange;
      case 'json':
      case 'xml':
        return Colors.purple;
      case 'fig':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
} 