import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/documentation_item.dart';

class TaskForm extends StatefulWidget {
  final Function(DocumentationItem) onSave;
  final DocumentationItem? initialTask;

  const TaskForm({
    super.key,
    required this.onSave,
    this.initialTask,
  });

  @override
  State<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _priority = 'Media';
  String _status = 'Pendiente';
  DateTime? _dueDate;
  double _progress = 0.0;
  int _estimatedHours = 1;
  final List<String> _subtasks = [];
  final List<String> _tags = [];

  final List<String> _priorities = ['Baja', 'Media', 'Alta', 'Crítica'];
  final List<String> _statusOptions = ['Pendiente', 'Completado'];
  final List<String> _availableTags = [
    'Urgente', 'Importante', 'Investigación', 'Escritura', 'Diseño', 
    'Reunión', 'Comunicación', 'Análisis', 'Planificación', 'Revisión',
    'Creatividad', 'Técnico', 'Administrativo', 'Presentación', 'Estudio'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialTask != null) {
      _titleController.text = widget.initialTask!.title;
      _descriptionController.text = widget.initialTask!.content;
      _status = widget.initialTask!.status ?? 'Pendiente';
      _priority = widget.initialTask!.progress?.toString() ?? 'Media';
      _dueDate = widget.initialTask!.dueDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
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
                    color: const Color(0xFFFF6B6B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Color(0xFFFF6B6B),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    widget.initialTask != null ? 'Editar Tarea' : 'Nueva Tarea',
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
                          labelText: 'Título de la tarea',
                          hintText: 'Ej: Implementar autenticación de usuarios',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.task),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa un título';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Descripción
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Descripción',
                          hintText: 'Describe los detalles de la tarea...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.description),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa una descripción';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Fecha límite (obligatoria)
                      TextFormField(
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Fecha límite *',
                          hintText: _dueDate != null 
                              ? '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}'
                              : 'Seleccionar fecha límite',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.calendar_today),
                          suffixIcon: _dueDate != null 
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () => setState(() => _dueDate = null),
                                )
                              : null,
                        ),
                        validator: (value) {
                          if (_dueDate == null) {
                            return 'La fecha límite es obligatoria';
                          }
                          return null;
                        },
                        onTap: () => _selectDueDate(context),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Prioridad y Estado en columna para mejor responsividad
                      Column(
                        children: [
                          DropdownButtonFormField<String>(
                            value: _priorities.contains(_priority) ? _priority : 'Media',
                            decoration: InputDecoration(
                              labelText: 'Prioridad',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: Icon(
                                Icons.priority_high,
                                color: _getPriorityColor(_priority),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                            items: _priorities.map((priority) {
                              return DropdownMenuItem(
                                value: priority,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: _getPriorityColor(priority),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      priority,
                                      style: GoogleFonts.poppins(),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _priority = value!;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _statusOptions.contains(_status) ? _status : 'Pendiente',
                            decoration: InputDecoration(
                              labelText: 'Estado',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: Icon(
                                _status == 'Completado' ? Icons.check_circle : Icons.radio_button_unchecked,
                                color: _getStatusColor(_status),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                            items: _statusOptions.map((status) {
                              return DropdownMenuItem(
                                value: status,
                                child: Row(
                                  children: [
                                    Icon(
                                      status == 'Completado' ? Icons.check_circle : Icons.radio_button_unchecked,
                                      color: _getStatusColor(status),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      status,
                                      style: GoogleFonts.poppins(),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _status = value!;
                              });
                            },
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Etiquetas (opcional)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Etiquetas',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (_tags.isNotEmpty) ...[
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: _tags.map((tag) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFF6B6B).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                            color: const Color(0xFFFF6B6B).withOpacity(0.3),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              tag,
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                color: const Color(0xFFFF6B6B),
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  _tags.remove(tag);
                                                });
                                              },
                                              child: const Icon(
                                                Icons.close,
                                                size: 16,
                                                color: Color(0xFFFF6B6B),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                  const SizedBox(height: 8),
                                ],
                                TextButton.icon(
                                  onPressed: _showTagSelector,
                                  icon: const Icon(Icons.add, size: 18),
                                  label: Text(
                                    'Agregar etiqueta',
                                    style: GoogleFonts.poppins(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
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
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveTask,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B6B),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      widget.initialTask != null ? 'Actualizar' : 'Crear Tarea',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
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

  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  void _showTagSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Seleccionar Etiquetas',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: _availableTags.length,
            itemBuilder: (context, index) {
              final tag = _availableTags[index];
              final isSelected = _tags.contains(tag);
              
              return ListTile(
                leading: Icon(
                  isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                  color: isSelected ? const Color(0xFFFF6B6B) : Colors.grey,
                ),
                title: Text(tag, style: GoogleFonts.poppins()),
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _tags.remove(tag);
                    } else {
                      _tags.add(tag);
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

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      final task = DocumentationItem(
        id: widget.initialTask?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        content: _descriptionController.text,
        type: DocumentationType.task,
        createdAt: widget.initialTask?.createdAt ?? DateTime.now(),
        status: _status,
        progress: _priority,
        attachments: _tags,
        dueDate: _dueDate,
      );
      widget.onSave(task);
      Navigator.pop(context);
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'Crítica':
        return Colors.red;
      case 'Alta':
        return Colors.orange;
      case 'Media':
        return Colors.blue;
      case 'Baja':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Completado':
        return Colors.green;
      case 'Pendiente':
        return Colors.grey;
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