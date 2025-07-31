import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/project.dart';

class NewProjectScreen extends StatefulWidget {
  const NewProjectScreen({super.key});

  @override
  State<NewProjectScreen> createState() => _NewProjectScreenState();
}

class _NewProjectScreenState extends State<NewProjectScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedType = 'Aplicación Web';
  String _selectedPriority = 'Media';
  String _estimatedDuration = '1 mes';
  String _selectedMethodology = 'Ninguna';
  bool _allowImages = false;
  bool _allowFiles = false;
  bool _allowDiagrams = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<Map<String, dynamic>> _projectTypes = [
    {'label': 'Proyecto Académico', 'icon': Icons.school, 'color': const Color(0xFF6C63FF)},
    {'label': 'Proyecto Personal', 'icon': Icons.person, 'color': const Color(0xFF4CAF50)},
    {'label': 'Proyecto Profesional', 'icon': Icons.work, 'color': const Color(0xFF00BFA6)},
    {'label': 'Proyecto Creativo', 'icon': Icons.palette, 'color': const Color(0xFFFF6B6B)},
    {'label': 'Proyecto de Investigación', 'icon': Icons.science, 'color': const Color(0xFF9C27B0)},
    {'label': 'Proyecto de Negocio', 'icon': Icons.business, 'color': const Color(0xFFFF9800)},
    {'label': 'Proyecto Tecnológico', 'icon': Icons.computer, 'color': const Color(0xFF2196F3)},
    {'label': 'Proyecto Social', 'icon': Icons.groups, 'color': const Color(0xFF607D8B)},
    {'label': 'Proyecto de Salud', 'icon': Icons.health_and_safety, 'color': const Color(0xFFE91E63)},
    {'label': 'Otro', 'icon': Icons.folder, 'color': const Color(0xFF795548)},
  ];

  final List<Map<String, dynamic>> _priorities = [
    {'label': 'Baja', 'color': Colors.green, 'icon': Icons.keyboard_arrow_down},
    {'label': 'Media', 'color': Colors.blue, 'icon': Icons.remove},
    {'label': 'Alta', 'color': Colors.orange, 'icon': Icons.keyboard_arrow_up},
    {'label': 'Crítica', 'color': Colors.red, 'icon': Icons.priority_high},
  ];
  
  final List<Map<String, dynamic>> _durations = [
    {'label': '2 semanas', 'value': '2 semanas', 'color': Colors.green, 'icon': Icons.flash_on},
    {'label': '1 mes', 'value': '1 mes', 'color': Colors.blue, 'icon': Icons.calendar_today},
    {'label': '3 meses', 'value': '3 meses', 'color': Colors.orange, 'icon': Icons.calendar_view_month},
    {'label': '6 meses', 'value': '6 meses', 'color': Colors.purple, 'icon': Icons.date_range},
    {'label': '1 año', 'value': '1 año', 'color': Colors.red, 'icon': Icons.schedule},
    {'label': 'Más de 1 año', 'value': 'Más de 1 año', 'color': Colors.grey[700], 'icon': Icons.hourglass_full},
  ];

  final List<Map<String, dynamic>> _methodologies = [
    {'label': 'Ninguna', 'icon': Icons.block, 'color': Colors.grey},
    {'label': 'Scrum', 'icon': Icons.group_work, 'color': const Color(0xFF4CAF50)},
    {'label': 'Kanban', 'icon': Icons.view_column, 'color': const Color(0xFF2196F3)},
    {'label': 'GTD (Getting Things Done)', 'icon': Icons.checklist, 'color': const Color(0xFF9C27B0)},
    {'label': 'Pomodoro', 'icon': Icons.timer, 'color': const Color(0xFFFF9800)},
    {'label': 'Método Tradicional', 'icon': Icons.waterfall_chart, 'color': const Color(0xFF00BCD4)},
    {'label': 'Design Thinking', 'icon': Icons.lightbulb, 'color': const Color(0xFFFF6B6B)},
    {'label': 'Lean Startup', 'icon': Icons.trending_up, 'color': const Color(0xFF4CAF50)},
    {'label': 'Personalizado', 'icon': Icons.tune, 'color': const Color(0xFF607D8B)},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
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
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Form(
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
                
                // Tipo de proyecto
                _buildProjectTypeSection(),
                
                const SizedBox(height: 32),
                
                // Prioridad
                _buildPrioritySection(),
                
                const SizedBox(height: 32),
                
                // Duración estimada
                _buildDurationSection(),
                
                const SizedBox(height: 32),
                
                // Metodología
                _buildMethodologySection(),
                
                const SizedBox(height: 32),
                
                // Opciones avanzadas
                _buildAdvancedOptionsSection(),
                
                const SizedBox(height: 40),
                
                // Botones de acción
                _buildActionButtons(),
              ],
            ),
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
            blurRadius: 20,
            offset: const Offset(0, 10),
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
                  '¡Crea tu proyecto!',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Configura los detalles de tu nuevo proyecto',
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
            label: 'Nombre del Proyecto',
            hint: 'Ej: Sitio Web Corporativo',
            icon: Icons.title,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa un nombre';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _descriptionController,
            label: 'Descripción',
            hint: 'Describe brevemente tu proyecto',
            icon: Icons.description,
            maxLines: 3,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa una descripción';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProjectTypeSection() {
    return _buildSection(
      title: 'Tipo de Proyecto',
      icon: Icons.category,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 2.5,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: _projectTypes.length,
        itemBuilder: (context, index) {
          final type = _projectTypes[index];
          final isSelected = _selectedType == type['label'];
          
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedType = type['label'];
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected 
                    ? type['color'].withOpacity(0.1)
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected 
                      ? type['color']
                      : Colors.grey[300]!,
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: type['color'].withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ] : null,
              ),
              child: Row(
                children: [
                  Icon(
                    type['icon'],
                    color: isSelected ? type['color'] : Colors.grey[600],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      type['label'],
                      style: GoogleFonts.poppins(
                        color: isSelected ? type['color'] : Colors.grey[700],
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPrioritySection() {
    return _buildSection(
      title: 'Prioridad',
      icon: Icons.priority_high,
      child: Row(
        children: _priorities.map((priority) {
          final isSelected = _selectedPriority == priority['label'];
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedPriority = priority['label'];
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
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
                    const SizedBox(height: 8),
                    Text(
                      priority['label'],
                      style: GoogleFonts.poppins(
                        color: isSelected ? priority['color'] : Colors.grey[700],
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDurationSection() {
    return _buildSection(
      title: 'Duración Estimada',
      icon: Icons.schedule,
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: _durations.map((duration) {
          final isSelected = _estimatedDuration == duration['value'];
          return GestureDetector(
            onTap: () {
              setState(() {
                _estimatedDuration = duration['value'];
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected 
                    ? duration['color'].withOpacity(0.1)
                    : Colors.white,
                borderRadius: BorderRadius.circular(25),
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
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    duration['icon'],
                    color: isSelected ? duration['color'] : Colors.grey[600],
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    duration['label'],
                    style: GoogleFonts.poppins(
                      color: isSelected ? duration['color'] : Colors.grey[700],
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMethodologySection() {
    return _buildSection(
      title: 'Metodología',
      icon: Icons.settings,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1.2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: _methodologies.length,
        itemBuilder: (context, index) {
          final methodology = _methodologies[index];
          final isSelected = _selectedMethodology == methodology['label'];
          
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedMethodology = methodology['label'];
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected 
                    ? methodology['color'].withOpacity(0.1)
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected 
                      ? methodology['color']
                      : Colors.grey[300]!,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    methodology['icon'],
                    color: isSelected ? methodology['color'] : Colors.grey[600],
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    methodology['label'],
                    style: GoogleFonts.poppins(
                      color: isSelected ? methodology['color'] : Colors.grey[700],
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      fontSize: 11,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAdvancedOptionsSection() {
    return _buildSection(
      title: 'Recursos del Proyecto',
      icon: Icons.settings,
      child: Column(
        children: [
          _buildSwitchOption(
            label: 'Permitir adjuntar imágenes',
            icon: Icons.image,
            subtitle: 'Fotos, capturas, diagramas visuales',
            value: _allowImages,
            onChanged: (val) => setState(() => _allowImages = val),
          ),
          const SizedBox(height: 12),
          _buildSwitchOption(
            label: 'Permitir adjuntar archivos',
            icon: Icons.attach_file,
            subtitle: 'Documentos, PDFs, presentaciones',
            value: _allowFiles,
            onChanged: (val) => setState(() => _allowFiles = val),
          ),
          const SizedBox(height: 12),
          _buildSwitchOption(
            label: 'Permitir crear diagramas',
            icon: Icons.account_tree,
            subtitle: 'Mapas mentales, flujos de proceso',
            value: _allowDiagrams,
            onChanged: (val) => setState(() => _allowDiagrams = val),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
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
                  fontWeight: FontWeight.bold,
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
    required String? Function(String?) validator,
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
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        labelStyle: GoogleFonts.poppins(color: Colors.grey[700]),
        hintStyle: GoogleFonts.poppins(color: Colors.grey[500]),
      ),
      style: GoogleFonts.poppins(),
      maxLines: maxLines,
      validator: validator,
    );
  }

  Widget _buildSwitchOption({
    required String label,
    required IconData icon,
    String? subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: value ? const Color(0xFF6C63FF).withOpacity(0.05) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value ? const Color(0xFF6C63FF).withOpacity(0.3) : Colors.grey[300]!,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: value ? const Color(0xFF6C63FF) : Colors.grey[600],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    color: value ? const Color(0xFF6C63FF) : Colors.grey[800],
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF6C63FF),
          ),
        ],
      ),
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
            onPressed: _submitForm,
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

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final project = Project(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        description: _descriptionController.text,
        type: _selectedType,
        progress: 0.0,
        estimatedDuration: _estimatedDuration,
        methodology: _selectedMethodology,
        allowImages: _allowImages,
        allowFiles: _allowFiles,
        allowDiagrams: _allowDiagrams,
      );

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

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
} 