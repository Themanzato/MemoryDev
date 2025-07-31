import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/project.dart';
import '../models/documentation_item.dart';

class StorageService {
  static StorageService? _instance;
  Directory? _appDir;
  
  StorageService._();
  
  static Future<StorageService> getInstance() async {
    if (_instance == null) {
      _instance = StorageService._();
      await _instance!._initDirectory();
    }
    return _instance!;
  }
  
  Future<void> _initDirectory() async {
    try {
      _appDir = await getApplicationDocumentsDirectory();
      
      // Crear directorio para datos de la app si no existe
      final appDataDir = Directory('${_appDir!.path}/memorydev_data');
      if (!await appDataDir.exists()) {
        await appDataDir.create(recursive: true);
      }
      _appDir = appDataDir;
      
      print('Storage initialized at: ${_appDir!.path}');
    } catch (e) {
      print('Error initializing directory: $e');
      rethrow;
    }
  }
  
  // Archivo para proyectos
  File get _projectsFile => File('${_appDir!.path}/projects.json');
  
  // Archivo para documentación de un proyecto específico
  File _getDocumentationFile(String projectId) => File('${_appDir!.path}/docs_$projectId.json');
  
  // Guardar lista de proyectos
  Future<void> saveProjects(List<Project> projects) async {
    try {
      final projectsJson = projects.map((project) => project.toMap()).toList();
      final jsonString = const JsonEncoder.withIndent('  ').convert(projectsJson);
      
      await _projectsFile.writeAsString(jsonString);
      print('Projects saved: ${projects.length} projects');
    } catch (e) {
      print('Error saving projects: $e');
      rethrow;
    }
  }
  
  // Cargar lista de proyectos
  Future<List<Project>> loadProjects() async {
    try {
      if (!await _projectsFile.exists()) {
        print('Projects file does not exist, returning empty list');
        return [];
      }
      
      final jsonString = await _projectsFile.readAsString();
      if (jsonString.isEmpty) {
        return [];
      }
      
      final projectsJson = jsonDecode(jsonString) as List;
      final projects = projectsJson.map((json) => Project.fromMap(json as Map<String, dynamic>)).toList();
      
      print('Projects loaded: ${projects.length} projects');
      return projects;
    } catch (e) {
      print('Error loading projects: $e');
      return [];
    }
  }
  
  // Guardar documentación de un proyecto específico
  Future<void> saveDocumentationItems(String projectId, List<DocumentationItem> items) async {
    try {
      print('=== SAVING DOCUMENTATION ITEMS ===');
      print('Project ID: $projectId');
      print('Number of items: ${items.length}');
      
      final file = File('${_appDir!.path}/docs_$projectId.json');
      
      final itemsJson = items.map((item) {
        print('Saving item: ${item.title}');
        print('Item attachments: ${item.attachments}');
        return item.toMap();
      }).toList();
      
      final jsonString = const JsonEncoder.withIndent('  ').convert(itemsJson);
      await file.writeAsString(jsonString);
      
      print('Documentation items saved successfully');
      print('=== END SAVING ===');
    } catch (e) {
      print('Error saving documentation items: $e');
    }
  }
  
  // Cargar documentación de un proyecto específico
  Future<List<DocumentationItem>> loadDocumentation(String projectId) async {
    try {
      final docFile = _getDocumentationFile(projectId);
      
      if (!await docFile.exists()) {
        print('Documentation file for project $projectId does not exist');
        return [];
      }
      
      final jsonString = await docFile.readAsString();
      if (jsonString.isEmpty) {
        return [];
      }
      
      final documentationJson = jsonDecode(jsonString) as List;
      final documentation = documentationJson.map((json) => DocumentationItem.fromMap(json as Map<String, dynamic>)).toList();
      
      print('Documentation loaded for project $projectId: ${documentation.length} items');
      return documentation;
    } catch (e) {
      print('Error loading documentation for project $projectId: $e');
      return [];
    }
  }
  
  // Eliminar documentación de un proyecto
  Future<void> deleteDocumentation(String projectId) async {
    try {
      final docFile = _getDocumentationFile(projectId);
      if (await docFile.exists()) {
        await docFile.delete();
        print('Documentation deleted for project $projectId');
      }
    } catch (e) {
      print('Error deleting documentation: $e');
      rethrow;
    }
  }
  
  // Eliminar proyecto y su documentación
  Future<void> deleteProject(String projectId) async {
    try {
      await deleteDocumentation(projectId);
      print('Project $projectId and its documentation deleted');
    } catch (e) {
      print('Error deleting project: $e');
      rethrow;
    }
  }
  
  // Limpiar todos los datos
  Future<void> clearAll() async {
    try {
      if (_appDir != null && await _appDir!.exists()) {
        // Eliminar todos los archivos en el directorio de datos
        final files = _appDir!.listSync();
        for (final file in files) {
          if (file is File) {
            await file.delete();
          }
        }
        print('All data cleared');
      }
    } catch (e) {
      print('Error clearing all data: $e');
      rethrow;
    }
  }
  
  // Verificar si el almacenamiento está listo
  bool get isReady => _appDir != null;
  
  // Obtener información de almacenamiento para debugging
  Future<Map<String, dynamic>> getStorageInfo() async {
    try {
      final info = <String, dynamic>{};
      info['storage_path'] = _appDir?.path ?? 'Not initialized';
      info['projects_file_exists'] = await _projectsFile.exists();
      
      if (await _projectsFile.exists()) {
        final stat = await _projectsFile.stat();
        info['projects_file_size'] = stat.size;
        info['projects_file_modified'] = stat.modified.toIso8601String();
      }
      
      // Contar archivos de documentación
      if (_appDir != null && await _appDir!.exists()) {
        final files = _appDir!.listSync();
        final docFiles = files.where((f) => f.path.contains('docs_')).length;
        info['documentation_files'] = docFiles;
      }
      
      return info;
    } catch (e) {
      return {'error': e.toString()};
    }
  }
  
  // Crear backup de todos los datos
  Future<String?> createBackup() async {
    try {
      final backupData = <String, dynamic>{};
      
      // Agregar proyectos
      final projects = await loadProjects();
      backupData['projects'] = projects.map((p) => p.toMap()).toList();
      
      // Agregar documentación de cada proyecto
      final documentation = <String, dynamic>{};
      for (final project in projects) {
        final docs = await loadDocumentation(project.id);
        if (docs.isNotEmpty) {
          documentation[project.id] = docs.map((d) => d.toMap()).toList();
        }
      }
      backupData['documentation'] = documentation;
      backupData['backup_date'] = DateTime.now().toIso8601String();
      backupData['app_version'] = '1.0.0';
      
      final backupJson = const JsonEncoder.withIndent('  ').convert(backupData);
      
      // Guardar backup en directorio de descargas
      final downloadsDir = await getExternalStorageDirectory();
      if (downloadsDir != null) {
        final backupFile = File('${downloadsDir.path}/memorydev_backup_${DateTime.now().millisecondsSinceEpoch}.json');
        await backupFile.writeAsString(backupJson);
        return backupFile.path;
      }
      
      return null;
    } catch (e) {
      print('Error creating backup: $e');
      return null;
    }
  }
  
  // Agregar este método para compatibilidad:
  Future<void> saveDocumentation(String projectId, List<DocumentationItem> documentation) async {
    return saveDocumentationItems(projectId, documentation);
  }
} 