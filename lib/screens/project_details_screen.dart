import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/project.dart';
import '../models/documentation_item.dart';
import '../widgets/timeline_widget.dart';
import '../widgets/documentation_card_widget.dart';
import '../widgets/documentation_forms/note_form.dart';
import '../widgets/documentation_forms/task_form.dart';
import '../widgets/documentation_forms/milestone_form.dart';
import '../widgets/documentation_forms/diagram_form.dart';
import '../widgets/documentation_forms/file_form.dart';
import '../services/storage_service.dart';
import '../widgets/drawing_viewer.dart';

class ProjectDetailsScreen extends StatefulWidget {
  final Project project;

  const ProjectDetailsScreen({
    super.key,
    required this.project,
  });

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  final List<DocumentationItem> _documentation = [];
  bool _showTimeline = true;
  String _taskFilter = 'Todas';
  String _taskView = 'Lista';
  DateTime _selectedDate = DateTime.now();
  late StorageService _storageService;
  bool _isLoading = true;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeStorage();
  }

  Future<void> _initializeStorage() async {
    try {
      _storageService = await StorageService.getInstance();
      await _loadDocumentation();
    } catch (e) {
      print('Error initializing storage: $e');
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al inicializar almacenamiento. Algunos datos podrían no guardarse.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _loadDocumentation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (_storageService.isReady) {
        final loadedDocs = await _storageService.loadDocumentation(widget.project.id);
        setState(() {
          _documentation.clear();
          _documentation.addAll(loadedDocs);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading documentation: $e');
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar documentación'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveDocumentation() async {
    try {
      if (_storageService.isReady) {
        await _storageService.saveDocumentationItems(widget.project.id, _documentation);
      }
    } catch (e) {
      print('Error saving documentation: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar cambios'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          widget.project.name,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(_showTimeline ? Icons.grid_view : Icons.timeline),
            onPressed: () {
              setState(() {
                _showTimeline = !_showTimeline;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showOptionsMenu(context),
          ),
        ],
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey[800],
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Column(
        children: [
          // Navigation tabs
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildCustomTab(0, 'Resumen', Icons.apps),
                  _buildCustomTab(1, 'Timeline', Icons.timeline),
                  _buildCustomTab(2, 'Notas', Icons.sticky_note_2),
                  _buildCustomTab(3, 'Tareas', Icons.task_alt),
                  _buildCustomTab(4, 'Logros', Icons.emoji_events),
                  _buildCustomTab(5, 'Stats', Icons.bar_chart),
                ],
              ),
            ),
          ),
          // Content basado en índice seleccionado
          Expanded(
            child: _buildSelectedTabContent(),
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: _getProjectColor().withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () => _showAddDocumentationDialog(context),
          icon: const Icon(Icons.add, size: 20),
          label: Text(
            'Nuevo',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          backgroundColor: _getProjectColor(),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedTabContent() {
    switch (_currentTabIndex) {
      case 0: return _buildOverviewTab();
      case 1: return _buildTimelineTab();
      case 2: return _buildDocumentationTab();
      case 3: return _buildTasksTab();
      case 4: return _buildAchievementsTab();
      case 5: return _buildStatsTab();
      default: return _buildOverviewTab();
    }
  }

  Widget _buildCustomTab(int index, String title, IconData icon) {
    final isSelected = _currentTabIndex == index;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentTabIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6C63FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : Colors.grey[600],
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernTab({
    required IconData icon,
    required IconData selectedIcon,
    required String text,
  }) {
    // Eliminar este método ya que usamos _buildCustomTab
    return Container();
  }

  Widget _buildOverviewTab() {
    final recentItems = _documentation.take(3).toList();
    
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProjectSummaryCard(),
            const SizedBox(height: 24),
            _buildQuickStats(),
            const SizedBox(height: 24),
            _buildRecentActivity(recentItems),
            const SizedBox(height: 24),
            _buildQuickActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getProjectColor().withOpacity(0.8),
            _getProjectColor(),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _getProjectColor().withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getProjectIcon(),
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.project.name,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      widget.project.type,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            widget.project.description,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progreso',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              Text(
                '${(widget.project.progress * 100).toInt()}%',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: widget.project.progress,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            borderRadius: BorderRadius.circular(4),
            minHeight: 8,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Elementos',
            _documentation.length.toString(),
            Icons.inventory,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Completados',
            _documentation.where((item) => item.status == 'Completado').length.toString(),
            Icons.check_circle,
            Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'En Progreso',
            _documentation.where((item) => item.status == 'En Progreso').length.toString(),
            Icons.access_time,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
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
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(List<DocumentationItem> recentItems) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Actividad Reciente',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (_documentation.isEmpty)
            // Solo mostrar el inicio del proyecto cuando no hay documentación
            _buildActivityItem(
              'Inicio del proyecto',
              'El proyecto "${widget.project.name}" ha sido creado',
              widget.project.createdAt,
              Icons.rocket_launch,
              const Color(0xFF4CAF50),
            )
          else
            // Mostrar documentación real cuando existe
            ...recentItems.map((item) => _buildActivityItem(
              item.title,
              item.content,
              item.createdAt,
              _getTypeIcon(item.type),
              _getTypeColor(item.type),
            )),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String title, String content, DateTime date, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: GoogleFonts.poppins(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(date),
                  style: GoogleFonts.poppins(
                    color: Colors.grey[500],
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Acciones Rápidas',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                'Agregar Nota',
                Icons.note_add,
                Colors.blue,
                () => _showAddDocumentationDialog(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionCard(
                'Nuevo Hito',
                Icons.flag,
                Colors.purple,
                () => _showAddDocumentationDialog(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                'Subir Archivo',
                Icons.upload_file,
                Colors.green,
                () => _showAddDocumentationDialog(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionCard(
                'Actualización',
                Icons.update,
                Colors.orange,
                () => _showAddDocumentationDialog(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.poppins(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TimelineWidget(
              project: widget.project,
              documentation: _documentation,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentationTab() {
    final notes = _documentation.where((doc) => doc.type == DocumentationType.note).toList();
    
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (notes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.note_add,
                size: 64,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No hay notas aún',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Crea tu primera nota para comenzar a documentar',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _showNoteForm,
              icon: const Icon(Icons.add),
              label: Text(
                'Crear Primera Nota',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return DocumentationCardWidget(
          item: note,
          onTap: () => _showNoteDetails(note),
        );
      },
    );
  }

  void _showNoteDetails(DocumentationItem note) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.note,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            note.title,
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          Text(
                            'Creado el ${note.createdAt.day}/${note.createdAt.month}/${note.createdAt.year}',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Contenido de texto
                      Text(
                        note.content,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.grey[700],
                          height: 1.6,
                        ),
                      ),
                      
                      // Mostrar dibujo si existe
                      if (_hasDrawing(note)) ...[
                        const SizedBox(height: 24),
                        Text(
                          'Dibujo adjunto:',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 12),
                        DrawingViewer(
                          drawingData: _getDrawingData(note)!,
                          isPreview: false,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              
              // Actions
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.grey[200]!),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _showDeleteNoteDialog(note);
                        },
                        icon: const Icon(Icons.delete_outline),
                        label: Text(
                          'Eliminar',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: BorderSide(color: Colors.red.withOpacity(0.3)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _showEditNoteDialog(note);
                        },
                        icon: const Icon(Icons.edit),
                        label: Text(
                          'Editar',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
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

  // Agregar estos métodos auxiliares para detectar dibujos
  bool _hasDrawing(DocumentationItem item) {
    return item.attachments?.any((attachment) => attachment.startsWith('drawing:')) ?? false;
  }

  String? _getDrawingData(DocumentationItem item) {
    if (item.attachments == null) return null;
    
    for (String attachment in item.attachments!) {
      if (attachment.startsWith('drawing:')) {
        return attachment.substring('drawing:'.length);
      }
    }
    return null;
  }

  void _showEditNoteDialog(DocumentationItem note) {
    showDialog(
      context: context,
      builder: (context) => NoteForm(
        initialNote: note, // Asegurémonos de usar initialNote
        onSave: (updatedNote) {
          setState(() {
            final index = _documentation.indexWhere((doc) => doc.id == note.id);
            if (index != -1) {
              _documentation[index] = updatedNote;
            }
          });
        },
      ),
    );
  }

  void _showDeleteNoteDialog(DocumentationItem note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.warning_outlined, color: Colors.red),
            ),
            const SizedBox(width: 12),
            Text(
              'Eliminar Nota',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          '¿Estás seguro de que deseas eliminar "${note.title}"? Esta acción no se puede deshacer.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: GoogleFonts.poppins(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              setState(() {
                _documentation.removeWhere((doc) => doc.id == note.id);
              });
              await _saveDocumentation();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Eliminar',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showNoteForm() {
    showDialog(
      context: context,
      builder: (context) => NoteForm(
        onSave: (note) {
          _addDocumentationItem(note);
        },
      ),
    );
  }

  void _showMilestoneForm() {
    showDialog(
      context: context,
      builder: (context) => MilestoneForm(
        onSave: (item) {
          _addDocumentationItem(item);
        },
      ),
    );
  }

  void _showTaskForm() {
    showDialog(
      context: context,
      builder: (context) => TaskForm(
        onSave: (item) {
          _addDocumentationItem(item);
        },
      ),
    );
  }

  void _showFileForm() {
    showDialog(
      context: context,
      builder: (context) => FileForm(
        onSave: (item) {
          _addDocumentationItem(item);
        },
      ),
    );
  }

  void _showImageForm() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF9800).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.image,
                      color: Color(0xFFFF9800),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Agregar Imagen',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Título de la imagen',
                  hintText: 'Ej: Captura de pantalla del diseño',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Descripción (opcional)',
                  hintText: 'Describe el contenido de la imagen',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 2,
              ),
              
              const SizedBox(height: 20),
              
              Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey[300]!,
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_a_photo,
                      size: 40,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Seleccionar imagen',
                      style: GoogleFonts.poppins(
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      '(Funcionalidad en desarrollo)',
                      style: GoogleFonts.poppins(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancelar',
                        style: GoogleFonts.poppins(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (titleController.text.isNotEmpty) {
                          final imageItem = DocumentationItem(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            title: titleController.text,
                            content: descriptionController.text.isEmpty 
                                ? 'Sin descripción' 
                                : descriptionController.text,
                            type: DocumentationType.image,
                            createdAt: DateTime.now(),
                            status: 'Agregada',
                            attachments: ['sample_image_${DateTime.now().millisecondsSinceEpoch}.jpg'],
                          );
                          _addDocumentationItem(imageItem);
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF9800),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Agregar',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDiagramForm() {
    showDialog(
      context: context,
      builder: (context) => DiagramForm(
        onSave: (item) {
          _addDocumentationItem(item);
        },
      ),
    );
  }

  void _showAddDocumentationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 400,
            maxHeight: 500,
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    Icons.add_circle_outline,
                    color: _getProjectColor(),
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Agregar Documentación',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
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
              
              const SizedBox(height: 16),
              
              Text(
                'Selecciona el tipo de documentación:',
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Grid de opciones
              Expanded(
                child: GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  childAspectRatio: 1.1,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: [
                    _buildDocumentationTypeCard(
                      'Nota',
                      Icons.note,
                      const Color(0xFF4CAF50),
                      DocumentationType.note,
                    ),
                    _buildDocumentationTypeCard(
                      'Tarea',
                      Icons.check_circle,
                      const Color(0xFFFF6B6B),
                      DocumentationType.task,
                    ),
                    _buildDocumentationTypeCard(
                      'Hito',
                      Icons.flag,
                      const Color(0xFF6C63FF),
                      DocumentationType.milestone,
                    ),
                    _buildDocumentationTypeCard(
                      'Diagrama',
                      Icons.account_tree,
                      const Color(0xFF2196F3),
                      DocumentationType.diagram,
                    ),
                    _buildDocumentationTypeCard(
                      'Archivo',
                      Icons.attach_file,
                      const Color(0xFF9C27B0),
                      DocumentationType.file,
                    ),
                    _buildDocumentationTypeCard(
                      'Imagen',
                      Icons.image,
                      const Color(0xFFFF9800),
                      DocumentationType.image,
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

  Widget _buildDocumentationTypeCard(
    String title,
    IconData icon,
    Color color,
    DocumentationType type,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pop(context); // Cerrar el diálogo de selección
          _showSpecificForm(type); // Mostrar el formulario específico
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: color,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSpecificForm(DocumentationType type) {
    switch (type) {
      case DocumentationType.note:
        showDialog(
          context: context,
          builder: (context) => NoteForm(
            onSave: (item) {
              _addDocumentationItem(item);
            },
          ),
        );
        break;
      case DocumentationType.task:
        showDialog(
          context: context,
          builder: (context) => TaskForm(
            onSave: (item) {
              _addDocumentationItem(item);
            },
          ),
        );
        break;
      case DocumentationType.milestone:
        showDialog(
          context: context,
          builder: (context) => MilestoneForm(
            onSave: (item) {
              _addDocumentationItem(item);
            },
          ),
        );
        break;
      case DocumentationType.diagram:
        showDialog(
          context: context,
          builder: (context) => DiagramForm(
            onSave: (item) {
              _addDocumentationItem(item);
            },
          ),
        );
        break;
      case DocumentationType.file:
        showDialog(
          context: context,
          builder: (context) => FileForm(
            onSave: (item) {
              _addDocumentationItem(item);
            },
          ),
        );
        break;
      case DocumentationType.image:
        _showImageForm();
        break;
      case DocumentationType.update:
        // Implementar formulario de actualización
        break;
    }
  }

  void _addDocumentationItem(DocumentationItem item) async {
    setState(() {
      _documentation.add(item);
      _documentation.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    });
    
    await _saveDocumentation();
    
    // Mostrar snackbar de confirmación
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              _getTypeIcon(item.type),
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${_getTypeName(item.type)} "${item.title}" agregado exitosamente',
                style: GoogleFonts.poppins(),
              ),
            ),
          ],
        ),
        backgroundColor: _getTypeColor(item.type),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Ver',
          textColor: Colors.white,
          onPressed: () {
            // Cambiar a la pestaña de timeline para ver el elemento
            setState(() {
              _currentTabIndex = 1;
            });
          },
        ),
      ),
    );
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: Text(
                'Editar Proyecto',
                style: GoogleFonts.poppins(),
              ),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implementar edición
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: Text(
                'Compartir',
                style: GoogleFonts.poppins(),
              ),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implementar compartir
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: Text(
                'Exportar PDF',
                style: GoogleFonts.poppins(),
              ),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implementar exportar
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _getProjectColor() {
    switch (widget.project.type.toLowerCase()) {
      case 'proyecto académico':
        return const Color(0xFF6C63FF);
      case 'proyecto personal':
        return const Color(0xFF4CAF50);
      case 'proyecto profesional':
        return const Color(0xFF00BFA6);
      case 'proyecto creativo':
        return const Color(0xFFFF6B6B);
      case 'proyecto de investigación':
        return const Color(0xFF9C27B0);
      case 'proyecto de negocio':
        return const Color(0xFFFF9800);
      case 'proyecto tecnológico':
        return const Color(0xFF2196F3);
      case 'proyecto social':
        return const Color(0xFF607D8B);
      case 'proyecto de salud':
        return const Color(0xFFE91E63);
      default:
        return const Color(0xFF795548);
    }
  }

  IconData _getProjectIcon() {
    switch (widget.project.type.toLowerCase()) {
      case 'proyecto académico':
        return Icons.school;
      case 'proyecto personal':
        return Icons.person;
      case 'proyecto profesional':
        return Icons.work;
      case 'proyecto creativo':
        return Icons.palette;
      case 'proyecto de investigación':
        return Icons.science;
      case 'proyecto de negocio':
        return Icons.business;
      case 'proyecto tecnológico':
        return Icons.computer;
      case 'proyecto social':
        return Icons.groups;
      case 'proyecto de salud':
        return Icons.health_and_safety;
      default:
        return Icons.folder;
    }
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

  String _getTypeName(DocumentationType type) {
    switch (type) {
      case DocumentationType.milestone:
        return 'Hito';
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

  String _getTypeDisplayName(DocumentationType type) {
    switch (type) {
      case DocumentationType.milestone:
        return 'Hito';
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

  @override
  void dispose() {
    // Sin TabController que limpiar
    super.dispose();
  }

  Widget _buildStatsTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estadísticas del Proyecto',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            // Estadísticas básicas
            _buildStatsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    final totalDocs = _documentation.length;
    final notes = _documentation.where((d) => d.type == DocumentationType.note).length;
    final tasks = _documentation.where((d) => d.type == DocumentationType.task).length;
    final milestones = _documentation.where((d) => d.type == DocumentationType.milestone).length;

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
        children: [
          _buildStatItem('Total de elementos', totalDocs.toString(), Icons.folder, Colors.blue),
          const SizedBox(height: 16),
          _buildStatItem('Notas', notes.toString(), Icons.note, Colors.green),
          const SizedBox(height: 16),
          _buildStatItem('Tareas', tasks.toString(), Icons.check_circle, Colors.red),
          const SizedBox(height: 16),
          _buildStatItem('Hitos', milestones.toString(), Icons.flag, Colors.purple),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildTasksTab() {
    final tasks = _documentation.where((item) => item.type == DocumentationType.task).toList();
    
    return Column(
      children: [
        _buildTasksHeader(tasks),
        Expanded(
          child: _taskView == 'Lista' ? _buildTasksList(tasks) : _buildTasksCalendar(tasks),
        ),
      ],
    );
  }

  Widget _buildTasksHeader(List<DocumentationItem> tasks) {
    final allTasks = tasks.length;
    final pendingTasks = tasks.where((t) => t.status == 'Pendiente').length;
    final completedTasks = tasks.where((t) => t.status == 'Completado').length;

    return Column(
      children: [
        // Selector de vista pequeño y separado
        Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildCompactViewButton('Lista', Icons.list_alt),
                    _buildCompactViewButton('Calendario', Icons.calendar_today),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Filtros de tareas (solo mostrar en vista de lista)
        if (_taskView == 'Lista')
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFFF6B6B).withOpacity(0.1),
                  const Color(0xFFFF6B6B).withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFFF6B6B).withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                _buildTaskFilterChip('Todas', allTasks, const Color(0xFF6C63FF)),
                const SizedBox(width: 12),
                _buildTaskFilterChip('Pendientes', pendingTasks, Colors.orange),
                const SizedBox(width: 12),
                _buildTaskFilterChip('Completas', completedTasks, Colors.green),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildCompactViewButton(String view, IconData icon) {
    final isSelected = _taskView == view;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          setState(() {
            _taskView = view;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFF6B6B) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : Colors.grey[600],
              ),
              const SizedBox(width: 6),
              Text(
                view,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskFilterChip(String label, int count, Color color) {
    final isSelected = _taskFilter == label;
    
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            setState(() {
              _taskFilter = label;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            decoration: BoxDecoration(
              color: isSelected ? color : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? color : Colors.grey[300]!,
                width: 1.5,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              children: [
                Text(
                  count.toString(),
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTasksList(List<DocumentationItem> tasks) {
    // Aplicar filtro
    List<DocumentationItem> filteredTasks;
    switch (_taskFilter) {
      case 'Pendientes':
        filteredTasks = tasks.where((t) => t.status == 'Pendiente').toList();
        break;
      case 'Completas':  // Cambiar aquí para que coincida
        filteredTasks = tasks.where((t) => t.status == 'Completado').toList();
        break;
      default: // 'Todas'
        filteredTasks = tasks;
        break;
    }

    if (filteredTasks.isEmpty) {
      return _buildEmptyFilteredTasksState();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filteredTasks.length,
      itemBuilder: (context, index) {
        return _buildTaskCard(filteredTasks[index]);
      },
    );
  }

  Widget _buildEmptyFilteredTasksState() {
    String message;
    String subtitle;
    IconData icon;
    
    switch (_taskFilter) {
      case 'Pendientes':
        message = 'No hay tareas pendientes';
        subtitle = '¡Excelente! Has completado todas tus tareas pendientes';
        icon = Icons.check_circle_outline;
        break;
      case 'Completas':  // Cambiar aquí también
        message = 'No hay tareas completadas';
        subtitle = 'Las tareas completadas aparecerán aquí';
        icon = Icons.task_alt;
        break;
      default:
        message = 'No hay tareas aún';
        subtitle = 'Comienza agregando tareas para organizar tu trabajo';
        icon = Icons.add_task;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(32),
      margin: const EdgeInsets.all(16),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.grey[600],
            ),
          ),
          if (_taskFilter == 'Todas') ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showTaskForm(),
              icon: const Icon(Icons.add),
              label: Text(
                'Agregar Tarea',
                style: GoogleFonts.poppins(),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B6B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTaskCard(DocumentationItem task) {
    final priorityColor = _getPriorityColor(task.progress?.toString() ?? 'Media');
    final statusColor = _getStatusColor(task.status ?? 'Pendiente');
    final isCompleted = task.status == 'Completado';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: priorityColor, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showModernTaskDetails(task),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Checkbox de estado
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isCompleted ? statusColor : Colors.transparent,
                        border: Border.all(
                          color: isCompleted ? statusColor : Colors.grey[400]!,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () => _toggleTaskCompletion(task),
                          child: isCompleted
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 18,
                                )
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Título y estado
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isCompleted ? Colors.grey[500] : Colors.grey[800],
                              decoration: isCompleted ? TextDecoration.lineThrough : null,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              // Estado
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  task.status ?? 'Pendiente',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: statusColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Prioridad
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: priorityColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  task.progress?.toString() ?? 'Media',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: priorityColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Menú de acciones
                    _buildTaskActionMenu(task),
                  ],
                ),
                if (task.content.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.only(left: 44),
                    child: Text(
                      task.content,
                      style: GoogleFonts.poppins(
                        color: Colors.grey[600],
                        fontSize: 14,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
                if (task.dueDate != null) ...[
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.only(left: 44),
                    child: Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 16,
                          color: _isOverdue(task.dueDate!)
                              ? Colors.red
                              : Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Vence: ${task.dueDate!.day}/${task.dueDate!.month}/${task.dueDate!.year}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: _isOverdue(task.dueDate!)
                                ? Colors.red
                                : Colors.grey[500],
                            fontWeight: _isOverdue(task.dueDate!)
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                        if (_isOverdue(task.dueDate!)) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Atrasada',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskActionMenu(DocumentationItem task) {
    return PopupMenuButton<String>(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.more_horiz,
          color: Colors.grey[600],
          size: 18,
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 8,
      onSelected: (value) {
        switch (value) {
          case 'edit':
            _showModernEditTaskDialog(task);
            break;
          case 'duplicate':
            _duplicateTask(task);
            break;
          case 'delete':
            _showModernDeleteTaskDialog(task);
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.edit_outlined,
                  size: 16,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Editar',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'duplicate',
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.copy_outlined,
                  size: 16,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Duplicar',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.delete_outline,
                  size: 16,
                  color: Colors.red,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Eliminar',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showModernTaskDetails(DocumentationItem task) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 30,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header con gradiente
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getPriorityColor(task.progress?.toString() ?? 'Media'),
                      _getPriorityColor(task.progress?.toString() ?? 'Media').withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.task_alt,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Detalles de Tarea',
                            style: GoogleFonts.poppins(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            task.title,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Contenido
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Estado y Prioridad
                    Row(
                      children: [
                        Expanded(
                          child: _buildDetailChip(
                            'Estado',
                            task.status ?? 'Pendiente',
                            _getStatusColor(task.status ?? 'Pendiente'),
                            Icons.flag_outlined,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDetailChip(
                            'Prioridad',
                            task.progress?.toString() ?? 'Media',
                            _getPriorityColor(task.progress?.toString() ?? 'Media'),
                            Icons.priority_high,
                          ),
                        ),
                      ],
                    ),
                    if (task.dueDate != null) ...[
                      const SizedBox(height: 16),
                      _buildDetailChip(
                        'Fecha límite',
                        '${task.dueDate!.day}/${task.dueDate!.month}/${task.dueDate!.year}',
                        _isOverdue(task.dueDate!) ? Colors.red : Colors.blue,
                        Icons.schedule,
                      ),
                    ],
                    if (task.content.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Text(
                        'Descripción',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Text(
                          task.content,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[700],
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    Text(
                      'Creado: ${task.createdAt.day}/${task.createdAt.month}/${task.createdAt.year} a las ${task.createdAt.hour}:${task.createdAt.minute.toString().padLeft(2, '0')}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              // Botones de acción
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.grey[200]!),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          Navigator.pop(context);
                          _showModernDeleteTaskDialog(task);
                        },
                        icon: const Icon(Icons.delete_outline, size: 18),
                        label: Text(
                          'Eliminar',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: BorderSide(color: Colors.red.withOpacity(0.3)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          Navigator.pop(context);
                          _showModernEditTaskDialog(task);
                        },
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: Text(
                          'Editar',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _getPriorityColor(task.progress?.toString() ?? 'Media'),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
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

  Widget _buildDetailChip(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: color.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showModernDeleteTaskDialog(DocumentationItem task) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '¿Eliminar tarea?',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Esta acción eliminará permanentemente "${task.title}" y no se puede deshacer.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              // Botones
              Container(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Row(
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
                        onPressed: () async {
                          setState(() {
                            _documentation.removeWhere((doc) => doc.id == task.id);
                          });
                          await _saveDocumentation();
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Tarea eliminada',
                                style: GoogleFonts.poppins(),
                              ),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          'Eliminar',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
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

  void _showModernEditTaskDialog(DocumentationItem task) {
    showDialog(
      context: context,
      builder: (context) => TaskForm(
        initialTask: task, // Usar initialTask en lugar de solo onSave
        onSave: (updatedTask) {
          setState(() {
            final index = _documentation.indexWhere((doc) => doc.id == task.id);
            if (index != -1) {
              _documentation[index] = updatedTask;
            }
          });
        },
      ),
    );
  }

  void _toggleTaskCompletion(DocumentationItem task) {
    final newStatus = task.status == 'Completado' ? 'Pendiente' : 'Completado';
    _updateTaskStatus(task, newStatus);
  }

  void _duplicateTask(DocumentationItem task) {
    final duplicatedTask = DocumentationItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: '${task.title} (Copia)',
      content: task.content,
      type: task.type,
      createdAt: DateTime.now(),
      status: 'Pendiente',
      progress: task.progress,
      attachments: task.attachments,
      dueDate: task.dueDate,
    );
    
    setState(() {
      _documentation.add(duplicatedTask);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Tarea duplicada',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _updateTaskStatus(DocumentationItem task, String newStatus) {
    setState(() {
      final index = _documentation.indexWhere((doc) => doc.id == task.id);
      if (index != -1) {
        _documentation[index] = DocumentationItem(
          id: task.id,
          title: task.title,
          content: task.content,
          type: task.type,
          createdAt: task.createdAt,
          status: newStatus,
          progress: task.progress,
          attachments: task.attachments,
          dueDate: task.dueDate,
        );
      }
    });
  }

  bool _isOverdue(DateTime dueDate) {
    return dueDate.isBefore(DateTime.now()) && 
           !_isSameDay(dueDate, DateTime.now());
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && 
           date1.month == date2.month && 
           date1.day == date2.day;
  }

  Widget _buildTasksCalendar(List<DocumentationItem> tasks) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // En pantallas pequeñas mostrar en columna, en grandes en fila
          if (constraints.maxWidth < 800) {
            return Column(
              children: [
                _buildCompactCalendarView(tasks),
                const SizedBox(height: 16),
                _buildDayTasksList(tasks),
              ],
            );
          } else {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: _buildCompactCalendarView(tasks),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 3,
                  child: _buildDayTasksList(tasks),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildCompactCalendarView(List<DocumentationItem> tasks) {
    final currentMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
    final daysInMonth = DateTime(_selectedDate.year, _selectedDate.month + 1, 0).day;
    final firstDayWeekday = currentMonth.weekday;

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
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header del calendario
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1, 1);
                  });
                },
                icon: const Icon(Icons.chevron_left, size: 24),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.grey[100],
                  minimumSize: const Size(40, 40),
                  padding: EdgeInsets.zero,
                ),
              ),
              Column(
                children: [
                  Text(
                    _getMonthName(_selectedDate.month),
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  Text(
                    _selectedDate.year.toString(),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1, 1);
                  });
                },
                icon: const Icon(Icons.chevron_right, size: 24),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.grey[100],
                  minimumSize: const Size(40, 40),
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Días de la semana
          Row(
            children: ['L', 'M', 'X', 'J', 'V', 'S', 'D']
                .map((day) => Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          day,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          
          const SizedBox(height: 12),
          
          // Grid del calendario
          ...List.generate(6, (weekIndex) {
            final weekDays = List.generate(7, (dayIndex) {
              final dayNumber = weekIndex * 7 + dayIndex + 1 - firstDayWeekday + 1;
              
              if (dayNumber < 1 || dayNumber > daysInMonth) {
                return const Expanded(child: SizedBox(height: 45));
              }
              
              final date = DateTime(_selectedDate.year, _selectedDate.month, dayNumber);
              final isSelected = _isSameDay(date, _selectedDate);
              final isToday = _isSameDay(date, DateTime.now());
              final dayTasks = _getTasksForDate(tasks, date);
              final hasTasks = dayTasks.isNotEmpty;
              
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDate = date;
                    });
                  },
                  child: Container(
                    height: 45,
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? const Color(0xFFFF6B6B)
                          : isToday 
                              ? const Color(0xFFFF6B6B).withOpacity(0.1)
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: hasTasks && !isSelected
                          ? Border.all(color: const Color(0xFFFF6B6B).withOpacity(0.5), width: 1)
                          : null,
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Text(
                            dayNumber.toString(),
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                              color: isSelected 
                                  ? Colors.white
                                  : isToday 
                                      ? const Color(0xFFFF6B6B)
                                      : Colors.grey[800],
                            ),
                          ),
                        ),
                        if (hasTasks && !isSelected)
                          Positioned(
                            right: 4,
                            top: 4,
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFF6B6B),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            });
            
            // Solo mostrar la fila si tiene al menos un día válido
            if (weekDays.any((widget) => widget.child != null)) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(children: weekDays),
              );
            }
            return const SizedBox.shrink();
          }),
          
          const SizedBox(height: 20),
          
          // Leyenda
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF6B6B),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Con tareas',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B6B).withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFFF6B6B), width: 1),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Hoy',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDayTasksList(List<DocumentationItem> tasks) {
    final dayTasks = _getTasksForDate(tasks, _selectedDate);
    
    return Container(
      constraints: const BoxConstraints(minHeight: 300, maxHeight: 500),
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
          // Header con fecha seleccionada
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B6B).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.event,
                  color: const Color(0xFFFF6B6B),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${_selectedDate.day} de ${_getMonthName(_selectedDate.month)}, ${_selectedDate.year}',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFFF6B6B),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B6B),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${dayTasks.length}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Lista de tareas scrolleable
          Expanded(
            child: dayTasks.isEmpty
                ? _buildEmptyDayState()
                : ListView.builder(
                    itemCount: dayTasks.length,
                    itemBuilder: (context, index) {
                      return _buildCalendarTaskCard(dayTasks[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyDayState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.event_available,
            size: 32,
            color: Colors.grey[400],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Sin tareas programadas',
          style: GoogleFonts.poppins(
            color: Colors.grey[600],
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Este día está libre de tareas',
          style: GoogleFonts.poppins(
            color: Colors.grey[400],
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 16),
        TextButton.icon(
          onPressed: () => _showTaskForm(),
          icon: Icon(
            Icons.add,
            size: 16,
            color: const Color(0xFFFF6B6B),
          ),
          label: Text(
            'Agregar tarea',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: const Color(0xFFFF6B6B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarTaskCard(DocumentationItem task) {
    final priorityColor = _getPriorityColor(task.progress?.toString() ?? 'Media');
    final isCompleted = task.status == 'Completado';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: priorityColor, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con checkbox y prioridad
          Row(
            children: [
              GestureDetector(
                onTap: () => _toggleTaskCompletion(task),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isCompleted ? Colors.green : Colors.transparent,
                    border: Border.all(
                      color: isCompleted ? Colors.green : Colors.grey[400]!,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: isCompleted
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  task.title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                    color: isCompleted ? Colors.grey[500] : Colors.grey[800],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: priorityColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  task.progress?.toString() ?? 'Media',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: priorityColor,
                  ),
                ),
              ),
            ],
          ),
          
          // Descripción si existe
          if (task.content.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                task.content,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                  height: 1.3,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
          
          // Footer con estado y fecha de vencimiento
          const SizedBox(height: 8),
          Row(
            children: [
              // Estado
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _getStatusColor(task.status ?? 'Pendiente').withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  task.status ?? 'Pendiente',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: _getStatusColor(task.status ?? 'Pendiente'),
                  ),
                ),
              ),
              const Spacer(),
              // Hora si existe
              if (task.dueDate != null)
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 12,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${task.dueDate!.hour.toString().padLeft(2, '0')}:${task.dueDate!.minute.toString().padLeft(2, '0')}',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completado':
        return Colors.green;
      case 'en progreso':
        return Colors.blue;
      case 'bloqueado':
        return Colors.red;
      case 'pendiente':
      default:
        return Colors.orange;
    }
  }

  List<DocumentationItem> _getTasksForDate(List<DocumentationItem> tasks, DateTime date) {
    return tasks.where((task) {
      if (task.dueDate == null) return false;
      return _isSameDay(task.dueDate!, date);
    }).toList();
  }

  Widget _buildEmptyTasksState() {
    return Container(
      padding: const EdgeInsets.all(32),
      margin: const EdgeInsets.all(16),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.task_alt,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No hay tareas aún',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Comienza agregando tareas para organizar tu trabajo',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showTaskForm(),
            icon: const Icon(Icons.add),
            label: Text(
              'Agregar Tarea',
              style: GoogleFonts.poppins(),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _getProjectColor(),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'crítica':
        return Colors.red;
      case 'alta':
        return Colors.orange;
      case 'media':
        return Colors.blue;
      case 'baja':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return months[month - 1];
  }

  Widget _buildMilestonesTab() {
    return _buildAchievementsTab(); // Redirigir al nuevo método
  }

  Widget _buildFilesTab() {
    final files = _documentation.where((item) => item.type == DocumentationType.file).toList();
    
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (files.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.attach_file, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('No hay archivos', style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey[600])),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: files.length,
      itemBuilder: (context, index) {
        return DocumentationCardWidget(
          item: files[index],
          onTap: () {},
        );
      },
    );
  }

  Widget _buildAchievementsTab() {
    final achievements = _documentation.where((item) => item.type == DocumentationType.milestone).toList();
    
    return Column(
      children: [
        _buildAchievementsHeader(achievements),
        Expanded(
          child: _buildAchievementsList(achievements),
        ),
      ],
    );
  }

  Widget _buildAchievementsHeader(List<DocumentationItem> achievements) {
    final totalAchievements = achievements.length;
    final criticalAchievements = achievements.where((a) => a.progress?.toString() == 'Crítica').length;
    final highAchievements = achievements.where((a) => a.progress?.toString() == 'Alta').length;
    final mediumAchievements = achievements.where((a) => a.progress?.toString() == 'Media').length;

    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6C63FF).withOpacity(0.1),
            const Color(0xFF6C63FF).withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF6C63FF).withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.emoji_events,
                  color: Color(0xFF6C63FF),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Logros del Proyecto',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    Text(
                      'Registra los hitos importantes y momentos clave',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAchievementForm(),
                icon: const Icon(Icons.add, size: 16),
                label: Text(
                  'Agregar',
                  style: GoogleFonts.poppins(fontSize: 12),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Estadísticas de logros
          Row(
            children: [
              _buildAchievementStat('Total', totalAchievements, const Color(0xFF6C63FF)),
              const SizedBox(width: 12),
              _buildAchievementStat('Críticos', criticalAchievements, Colors.red),
              const SizedBox(width: 12),
              _buildAchievementStat('Importantes', highAchievements, Colors.orange),
              const SizedBox(width: 12),
              _buildAchievementStat('Normales', mediumAchievements, Colors.blue),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementStat(String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementsList(List<DocumentationItem> achievements) {
    if (achievements.isEmpty) {
      return _buildEmptyAchievementsState();
    }

    // Ordenar por fecha (más recientes primero)
    achievements.sort((a, b) {
      if (a.createdAt == null && b.createdAt == null) return 0;
      if (a.createdAt == null) return 1;
      if (b.createdAt == null) return -1;
      return b.createdAt!.compareTo(a.createdAt!);
    });

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        return _buildAchievementCard(achievements[index]);
      },
    );
  }

  Widget _buildAchievementCard(DocumentationItem achievement) {
    final importanceColor = _getImportanceColor(achievement.progress?.toString() ?? 'Media');
    final timeAgo = _getTimeAgo(achievement.createdAt ?? DateTime.now());
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
        children: [
          // Header con importancia y fecha
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: importanceColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: importanceColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getAchievementIcon(achievement.progress?.toString() ?? 'Media'),
                    color: importanceColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        achievement.title,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: importanceColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              achievement.progress?.toString() ?? 'Media',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.access_time,
                            size: 12,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            timeAgo,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditAchievementDialog(achievement);
                    } else if (value == 'delete') {
                      _showDeleteAchievementDialog(achievement);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          const Icon(Icons.edit, size: 16),
                          const SizedBox(width: 8),
                          Text('Editar', style: GoogleFonts.poppins(fontSize: 12)),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(Icons.delete, size: 16, color: Colors.red),
                          const SizedBox(width: 8),
                          Text('Eliminar', style: GoogleFonts.poppins(fontSize: 12, color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Contenido del logro
          if (achievement.content.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                achievement.content,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
            ),
          
          // Footer con fecha exacta
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: Colors.grey[500],
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDate(achievement.createdAt ?? DateTime.now()),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C63FF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.emoji_events,
                        size: 12,
                        color: const Color(0xFF6C63FF),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Logro',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF6C63FF),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getImportanceColor(String importance) {
    switch (importance.toLowerCase()) {
      case 'crítica':
        return Colors.red;
      case 'alta':
        return Colors.orange;
      case 'media':
        return Colors.blue;
      case 'baja':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  IconData _getAchievementIcon(String importance) {
    switch (importance.toLowerCase()) {
      case 'crítica':
        return Icons.star;
      case 'alta':
        return Icons.emoji_events;
      case 'media':
        return Icons.flag;
      case 'baja':
        return Icons.check_circle;
      default:
        return Icons.flag;
    }
  }

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return 'Hace ${difference.inDays} día${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'Hace ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'Hace ${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'Ahora mismo';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildEmptyAchievementsState() {
    return Container(
      padding: const EdgeInsets.all(32),
      margin: const EdgeInsets.all(16),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.emoji_events,
              size: 48,
              color: const Color(0xFF6C63FF),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '¡Aún no hay logros!',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Registra los hitos importantes y momentos clave de tu proyecto',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAchievementForm(),
            icon: const Icon(Icons.add),
            label: Text(
              'Registrar Primer Logro',
              style: GoogleFonts.poppins(),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAchievementForm() {
    showDialog(
      context: context,
      builder: (context) => MilestoneForm(
        onSave: (achievement) {
          _addDocumentationItem(achievement);
        },
      ),
    );
  }

  void _showEditAchievementDialog(DocumentationItem achievement) {
    showDialog(
      context: context,
      builder: (context) => MilestoneForm(
        initialMilestone: achievement, // Cambiar por el nombre correcto del parámetro
        onSave: (updatedAchievement) {
          setState(() {
            final index = _documentation.indexWhere((doc) => doc.id == achievement.id);
            if (index != -1) {
              _documentation[index] = updatedAchievement;
            }
          });
        },
      ),
    );
  }

  void _showDeleteAchievementDialog(DocumentationItem achievement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.warning_outlined, color: Colors.red),
            ),
            const SizedBox(width: 12),
            Text(
              'Eliminar Logro',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          '¿Estás seguro de que deseas eliminar "${achievement.title}"? Esta acción no se puede deshacer.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: GoogleFonts.poppins(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              setState(() {
                _documentation.removeWhere((doc) => doc.id == achievement.id);
              });
              await _saveDocumentation();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Eliminar',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 