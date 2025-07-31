import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/documentation_item.dart';

class DiagramForm extends StatefulWidget {
  final Function(DocumentationItem) onSave;

  const DiagramForm({
    super.key,
    required this.onSave,
  });

  @override
  State<DiagramForm> createState() => _DiagramFormState();
}

class _DiagramFormState extends State<DiagramForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _diagramType = 'Flujo de Proceso';
  String _templateSelected = '';
  
  final List<String> _diagramTypes = [
    'Mapa Mental',
    'Flujo de Proceso',
    'Organigrama',
    'Cronograma',
    'Lluvia de Ideas',
    'Diagrama de Venn',
    'Mapa Conceptual',
    'Esquema',
    'Infografía',
    'Wireframe',
    'Storyboard',
    'Otros',
  ];

  final Map<String, List<Map<String, dynamic>>> _templates = {
    'Mapa Mental': [
      {'name': 'Tema Central', 'elements': ['Idea Principal', 'Subtemas', 'Detalles']},
      {'name': 'Planificación', 'elements': ['Objetivo', 'Tareas', 'Recursos', 'Timeline']},
    ],
    'Flujo de Proceso': [
      {'name': 'Proceso Simple', 'elements': ['Inicio', 'Pasos', 'Decisiones', 'Fin']},
      {'name': 'Metodología', 'elements': ['Fase 1', 'Fase 2', 'Fase 3', 'Evaluación']},
    ],
    'Lluvia de Ideas': [
      {'name': 'Creativo', 'elements': ['Ideas Principales', 'Ideas Secundarias', 'Conexiones']},
      {'name': 'Problemática', 'elements': ['Problema', 'Causas', 'Soluciones', 'Acciones']},
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 700, maxHeight: 800),
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
                    color: const Color(0xFF2196F3).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.account_tree,
                    color: Color(0xFF2196F3),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Crear Diagrama',
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
                          labelText: 'Título del diagrama',
                          hintText: 'Ej: Arquitectura del sistema de usuarios',
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
                      
                      // Tipo de diagrama
                      DropdownButtonFormField<String>(
                        value: _diagramType,
                        decoration: InputDecoration(
                          labelText: 'Tipo de Diagrama',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.category),
                        ),
                        items: _diagramTypes.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _diagramType = value!;
                            _templateSelected = '';
                          });
                        },
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Templates disponibles
                      if (_templates.containsKey(_diagramType)) ...[
                        Text(
                          'Plantillas Disponibles',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 12),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1.5,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: _templates[_diagramType]!.length,
                          itemBuilder: (context, index) {
                            final template = _templates[_diagramType]![index];
                            final isSelected = _templateSelected == template['name'];
                            
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _templateSelected = template['name'];
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isSelected 
                                      ? const Color(0xFF2196F3).withOpacity(0.1)
                                      : Colors.grey[50],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected 
                                        ? const Color(0xFF2196F3)
                                        : Colors.grey[300]!,
                                    width: 2,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          _getDiagramIcon(_diagramType),
                                          color: isSelected 
                                              ? const Color(0xFF2196F3)
                                              : Colors.grey[600],
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            template['name'],
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: isSelected 
                                                  ? const Color(0xFF2196F3)
                                                  : Colors.grey[800],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Expanded(
                                      child: Text(
                                        'Incluye: ${template['elements'].join(', ')}',
                                        style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          color: Colors.grey[600],
                                        ),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                      ],
                      
                      // Herramientas de dibujo (simuladas)
                      Text(
                        'Herramientas de Diseño',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Paleta de formas
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Formas Disponibles',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: _getShapesForType(_diagramType).map((shape) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.grey[300]!),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        shape['icon'],
                                        size: 16,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        shape['name'],
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Área de dibujo simulada
                      Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Stack(
                          children: [
                            // Fondo de cuadrícula
                            CustomPaint(
                              size: const Size(double.infinity, 200),
                              painter: GridPainter(),
                            ),
                            // Elementos del diagrama (simulados)
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.touch_app,
                                    size: 32,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Área de Diseño',
                                    style: GoogleFonts.poppins(
                                      color: Colors.grey[500],
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    'Arrastra elementos aquí para crear tu diagrama',
                                    style: GoogleFonts.poppins(
                                      color: Colors.grey[400],
                                      fontSize: 12,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Descripción
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Descripción',
                          hintText: 'Describe el propósito y funcionamiento del diagrama...',
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
                  onPressed: _saveDiagram,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: Text(
                    'Guardar Diagrama',
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

  List<Map<String, dynamic>> _getShapesForType(String type) {
    switch (type) {
      case 'Flujo de Proceso':
        return [
          {'name': 'Inicio/Fin', 'icon': Icons.radio_button_checked},
          {'name': 'Proceso', 'icon': Icons.crop_square},
          {'name': 'Decisión', 'icon': Icons.change_history},
          {'name': 'Documento', 'icon': Icons.description},
          {'name': 'Conector', 'icon': Icons.arrow_forward},
        ];
      case 'Arquitectura de Sistema':
        return [
          {'name': 'Servidor', 'icon': Icons.dns},
          {'name': 'Base de Datos', 'icon': Icons.storage},
          {'name': 'Cliente', 'icon': Icons.computer},
          {'name': 'API', 'icon': Icons.api},
          {'name': 'Balanceador', 'icon': Icons.balance},
        ];
      case 'Base de Datos (ERD)':
        return [
          {'name': 'Entidad', 'icon': Icons.table_chart},
          {'name': 'Atributo', 'icon': Icons.circle_outlined},
          {'name': 'Relación', 'icon': Icons.link},
          {'name': 'Clave Primaria', 'icon': Icons.key},
          {'name': 'Clave Foránea', 'icon': Icons.vpn_key},
        ];
      default:
        return [
          {'name': 'Rectángulo', 'icon': Icons.crop_square},
          {'name': 'Círculo', 'icon': Icons.circle_outlined},
          {'name': 'Triángulo', 'icon': Icons.change_history},
          {'name': 'Línea', 'icon': Icons.remove},
          {'name': 'Texto', 'icon': Icons.text_fields},
        ];
    }
  }

  IconData _getDiagramIcon(String type) {
    switch (type) {
      case 'Flujo de Proceso':
        return Icons.account_tree;
      case 'Arquitectura de Sistema':
        return Icons.architecture;
      case 'Base de Datos (ERD)':
        return Icons.storage;
      case 'Casos de Uso':
        return Icons.person;
      case 'Secuencia':
        return Icons.timeline;
      case 'Wireframe':
        return Icons.web_asset;
      case 'Organigrama':
        return Icons.account_tree;
      case 'Red/Infraestructura':
        return Icons.hub;
      default:
        return Icons.account_tree;
    }
  }

  void _saveDiagram() {
    if (_formKey.currentState!.validate()) {
      final diagram = DocumentationItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        content: _descriptionController.text,
        type: DocumentationType.diagram,
        createdAt: DateTime.now(),
        status: 'Creado',
        attachments: [
          'diagram_type:$_diagramType',
          if (_templateSelected.isNotEmpty) 'template:$_templateSelected',
          'diagram_data:${_generateDiagramData()}', // Simulated diagram data
        ],
      );
      
      widget.onSave(diagram);
      Navigator.pop(context);
    }
  }

  String _generateDiagramData() {
    // Simular datos del diagrama basado en el template seleccionado
    if (_templateSelected.isNotEmpty && _templates[_diagramType] != null) {
      final template = _templates[_diagramType]!
          .firstWhere((t) => t['name'] == _templateSelected);
      return 'elements:${template['elements'].join(',')}';
    }
    return 'custom_diagram';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}

// Custom painter para la cuadrícula del área de diseño
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[200]!
      ..strokeWidth = 0.5;

    const gridSize = 20.0;

    // Líneas verticales
    for (double x = 0; x <= size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Líneas horizontales
    for (double y = 0; y <= size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 