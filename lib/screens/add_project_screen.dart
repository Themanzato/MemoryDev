import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AddProjectScreen extends StatefulWidget {
  const AddProjectScreen({super.key});

  @override
  State<AddProjectScreen> createState() => _AddProjectScreenState();
}

class _AddProjectScreenState extends State<AddProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedType = 'Web';
  String _estimatedDuration = '1 mes';
  String _priority = 'Media';

  final List<String> _projectTypes = [
    'Web',
    'Móvil',
    'Desktop',
    'Videojuego',
    'API/Backend',
    'Base de Datos',
    'Otro',
  ];

  final List<Map<String, dynamic>> _durations = [
    {
      'label': '2 semanas',
      'value': '2 semanas',
      'icon': Icons.flash_on,
      'color': Colors.green,
      'description': 'Proyecto rápido'
    },
    {
      'label': '1 mes',
      'value': '1 mes',
      'icon': Icons.calendar_today,
      'color': Colors.blue,
      'description': 'Proyecto corto'
    },
    {
      'label': '3 meses',
      'value': '3 meses',
      'icon': Icons.calendar_view_month,
      'color': Colors.orange,
      'description': 'Proyecto mediano'
    },
    {
      'label': '6 meses',
      'value': '6 meses',
      'icon': Icons.date_range,
      'color': Colors.purple,
      'description': 'Proyecto largo'
    },
    {
      'label': '1 año',
      'value': '1 año',
      'icon': Icons.schedule,
      'color': Colors.red,
      'description': 'Proyecto extenso'
    },
    {
      'label': 'Más de 1 año',
      'value': 'Más de 1 año',
      'icon': Icons.hourglass_full,
      'color': Colors.grey[700]!,
      'description': 'Proyecto a largo plazo'
    },
  ];

  final List<Map<String, dynamic>> _priorities = [
    {'label': 'Baja', 'color': Colors.green, 'icon': Icons.keyboard_arrow_down},
    {'label': 'Media', 'color': Colors.blue, 'icon': Icons.remove},
    {'label': 'Alta', 'color': Colors.orange, 'icon': Icons.keyboard_arrow_up},
    {'label': 'Crítica', 'color': Colors.red, 'icon': Icons.priority_high},
  ];

  @override
  Widget build(BuildContext context) {
    print('Usando AddProjectScreen actualizado - SIN FECHAS');
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Nuevo Proyecto',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey[800],
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header principal
              _buildHeader(),
              
              const SizedBox(height: 32),
              
              // Información básica
              _buildBasicInfoSection(),
              
              const SizedBox(height: 32),
              
              // Duración estimada
              _buildDurationSection(),
              
              const SizedBox(height: 32),
              
              // Prioridad
              _buildPrioritySection(),
              
              const SizedBox(height: 32),
              
              // Descripción
              _buildDescriptionSection(),
              
              const SizedBox(height: 40),
              
              // Botones de acción
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6C63FF),
            const Color(0xFF6C63FF).withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.rocket_launch,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¡Crea tu Proyecto!',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Define los detalles y comienza a documentar',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return _buildSection(
      title: 'Información Básica',
      icon: Icons.info_outline,
      child: Column(
        children: [
          _buildTextField(
            controller: _nameController,
            label: 'Nombre del proyecto',
            hint: 'Ej: Sistema de gestión de inventarios',
            icon: Icons.title,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa el nombre del proyecto';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 20),
          
          _buildTypeDropdown(),
        ],
      ),
    );
  }

  Widget _buildDurationSection() {
    return _buildSection(
      title: 'Duración Estimada',
      icon: Icons.access_time,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¿Cuánto tiempo crees que tardará en completarse?',
            style: GoogleFonts.poppins(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _durations.length,
            itemBuilder: (context, index) {
              final duration = _durations[index];
              final isSelected = _estimatedDuration == duration['value'];
              
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _estimatedDuration = duration['value'];
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? duration['color'].withOpacity(0.1)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected 
                            ? duration['color']
                            : Colors.grey[300]!,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected ? [
                        BoxShadow(
                          color: duration['color'].withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ] : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          duration['icon'],
                          color: isSelected ? duration['color'] : Colors.grey[600],
                          size: 20,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          duration['label'],
                          style: GoogleFonts.poppins(
                            color: isSelected ? duration['color'] : Colors.grey[800],
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPrioritySection() {
    return _buildSection(
      title: 'Prioridad del Proyecto',
      icon: Icons.flag,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selecciona la importancia de este proyecto',
            style: GoogleFonts.poppins(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: _priorities.map((priority) {
              final isSelected = _priority == priority['label'];
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _priority = priority['label'];
                        });
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? priority['color'].withOpacity(0.1)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected 
                                ? priority['color']
                                : Colors.grey[300]!,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              priority['icon'],
                              color: isSelected ? priority['color'] : Colors.grey[600],
                              size: 24,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              priority['label'],
                              style: GoogleFonts.poppins(
                                color: isSelected ? priority['color'] : Colors.grey[800],
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return _buildSection(
      title: 'Descripción del Proyecto',
      icon: Icons.description,
      child: _buildTextField(
        controller: _descriptionController,
        label: 'Descripción detallada',
        hint: 'Describe los objetivos, características principales, tecnologías que planeas usar, etc.',
        icon: Icons.text_fields,
        maxLines: 6,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor ingresa una descripción del proyecto';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF6C63FF),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF6C63FF)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        alignLabelWithHint: maxLines > 1,
      ),
      maxLines: maxLines,
      validator: validator,
      style: GoogleFonts.poppins(),
    );
  }

  Widget _buildTypeDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedType,
      decoration: InputDecoration(
        labelText: 'Tipo de proyecto',
        prefixIcon: Icon(_getTypeIcon(_selectedType), color: const Color(0xFF6C63FF)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      items: _projectTypes.map((type) {
        return DropdownMenuItem(
          value: type,
          child: Row(
            children: [
              Icon(
                _getTypeIcon(type),
                size: 20,
                color: _getTypeColor(type),
              ),
              const SizedBox(width: 12),
              Text(
                type,
                style: GoogleFonts.poppins(),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedType = value!;
        });
      },
      style: GoogleFonts.poppins(),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(color: Colors.grey[400]!),
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
          flex: 2,
          child: ElevatedButton(
            onPressed: _saveProject,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.rocket_launch, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Crear Proyecto',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _saveProject() {
    if (_formKey.currentState!.validate()) {
      final project = {
        'name': _nameController.text,
        'description': _descriptionController.text,
        'type': _selectedType,
        'priority': _priority,
        'estimatedDuration': _estimatedDuration,
        'createdAt': DateTime.now(),
        'progress': 0.0,
      };

      Navigator.pop(context, project);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Proyecto "${_nameController.text}" creado exitosamente',
                  style: GoogleFonts.poppins(),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'web':
        return Icons.web;
      case 'móvil':
        return Icons.phone_android;
      case 'desktop':
        return Icons.desktop_windows;
      case 'videojuego':
        return Icons.sports_esports;
      case 'api/backend':
        return Icons.storage;
      case 'base de datos':
        return Icons.storage;
      default:
        return Icons.folder;
    }
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'web':
        return const Color(0xFF6C63FF);
      case 'móvil':
        return const Color(0xFF4CAF50);
      case 'desktop':
        return const Color(0xFF00BFA6);
      case 'videojuego':
        return const Color(0xFFFF6B6B);
      case 'api/backend':
        return const Color(0xFF9C27B0);
      case 'base de datos':
        return const Color(0xFFFF9800);
      default:
        return const Color(0xFF6C63FF);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
} 