import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/project.dart';
import '../services/storage_service.dart';
import 'add_project_screen.dart';
import 'new_project_screen.dart';
import 'project_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Project> projects = [];
  bool _isLoading = true;
  late StorageService _storageService;

  @override
  void initState() {
    super.initState();
    _initializeStorage();
  }

  Future<void> _initializeStorage() async {
    try {
      _storageService = await StorageService.getInstance();
      await _loadProjects();
    } catch (e) {
      print('Error initializing storage: $e');
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al inicializar almacenamiento. Usando modo offline.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _loadProjects() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (_storageService.isReady) {
        final loadedProjects = await _storageService.loadProjects();
        setState(() {
          projects = loadedProjects;
          _isLoading = false;
        });
      } else {
        // Fallback: usar lista vacía si no hay almacenamiento
        setState(() {
          projects = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading projects: $e');
      setState(() {
        projects = [];
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar proyectos'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveProjects() async {
    try {
      if (_storageService.isReady) {
        await _storageService.saveProjects(projects);
      }
    } catch (e) {
      print('Error saving projects: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar proyectos'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _addProject(Project project) async {
    setState(() {
      projects.add(project);
    });
    await _saveProjects();
  }

  Future<void> _deleteProject(Project project) async {
    setState(() {
      projects.removeWhere((p) => p.id == project.id);
    });
    await _storageService.deleteProject(project.id);
    await _saveProjects();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'MemoryDev',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Inicializando almacenamiento...',
              style: GoogleFonts.poppins(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'MemoryDev',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProjects,
          ),
          // Indicador de estado de almacenamiento
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: Icon(
              _storageService.isReady ? Icons.cloud_done : Icons.cloud_off,
              color: _storageService.isReady ? Colors.green : Colors.red,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              // TODO: Implementar perfil de usuario
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadProjects,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeSection(),
                const SizedBox(height: 24),
                _buildQuickActions(),
                const SizedBox(height: 24),
                _buildProjectsSection(),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: ElevatedButton.icon(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NewProjectScreen(),
              ),
            );
            
            if (result != null && result is Project) {
              await _addProject(result);
            }
          },
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.add, color: Colors.white),
          ),
          label: Text(
            'Nuevo Proyecto',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6C63FF),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            shadowColor: const Color(0xFF6C63FF).withOpacity(0.3),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¡Hola! 👋',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF6C63FF),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Bienvenido a MemoryDev',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Organiza y documenta tus proyectos de desarrollo de manera eficiente',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.rocket_launch,
              size: 32,
              color: Color(0xFF6C63FF),
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
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.timeline,
                title: 'Línea de Tiempo',
                color: const Color(0xFF00BFA6),
                onTap: () {
                  // TODO: Implementar navegación a línea de tiempo
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionCard(
                icon: Icons.flag,
                title: 'Metas',
                color: const Color(0xFFFF6B6B),
                onTap: () {
                  // TODO: Implementar navegación a metas
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionCard(
                icon: Icons.storage,
                title: 'Storage Info',
                color: const Color(0xFF9C27B0),
                onTap: _showStorageInfo,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showStorageInfo() async {
    final storageInfo = await _storageService.getStorageInfo();
    
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Información de Almacenamiento',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: storageInfo.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  '${entry.key}: ${entry.value}',
                  style: GoogleFonts.poppins(fontSize: 12),
                ),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cerrar', style: GoogleFonts.poppins()),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildProjectsSection() {
    return Builder(
      builder: (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mis Proyectos',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (projects.isEmpty) _buildEmptyState(),
          if (projects.isNotEmpty)
            ...projects.map((project) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildProjectCard(
                    context: context,
                    index: projects.indexOf(project),
                    title: project.name,
                    description: project.description,
                    type: project.type,
                    progress: project.progress,
                    color: _getProjectColor(project.type),
                  ),
                )),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(
            Icons.folder_open,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No tienes proyectos aún',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Crea tu primer proyecto para comenzar a organizar tu desarrollo',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Color _getProjectColor(String type) {
    switch (type.toLowerCase()) {
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

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectCard({
    required BuildContext context,
    required int index,
    required String title,
    required String description,
    required String type,
    required double progress,
    required Color color,
  }) {
    return Dismissible(
      key: Key(projects[index].id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 32,
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              'Eliminar Proyecto',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            content: Text(
              '¿Estás seguro de que deseas eliminar "$title"? Esta acción no se puede deshacer.',
              style: GoogleFonts.poppins(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancelar', style: GoogleFonts.poppins()),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text(
                  'Eliminar',
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) async {
        await _deleteProject(projects[index]);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Proyecto "$title" eliminado',
                style: GoogleFonts.poppins(),
              ),
              action: SnackBarAction(
                label: 'Deshacer',
                onPressed: () {
                  // TODO: Implementar deshacer eliminación
                },
              ),
            ),
          );
        }
      },
      child: InkWell(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProjectDetailsScreen(
                project: projects[index],
              ),
            ),
          );
          // Recargar proyectos después de volver de los detalles
          await _loadProjects();
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.folder,
                      color: color,
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
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          description,
                          style: GoogleFonts.poppins(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: color.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                borderRadius: BorderRadius.circular(2),
              ),
              const SizedBox(height: 8),
              Text(
                '${(progress * 100).toInt()}% Completado',
                style: GoogleFonts.poppins(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 