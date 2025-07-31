import '../models/project.dart';
import '../models/documentation_item.dart';

class StorageService {
  static StorageService? _instance;
  
  StorageService._();
  
  static Future<StorageService> getInstance() async {
    _instance ??= StorageService._();
    return _instance!;
  }
  
  Future<void> saveProjects(List<Project> projects) async {
    // No hacer nada - solo para desarrollo
    print('Storage disabled - projects not saved');
  }
  
  Future<List<Project>> loadProjects() async {
    return [];
  }
  
  Future<void> saveDocumentation(String projectId, List<DocumentationItem> documentation) async {
    print('Storage disabled - documentation not saved');
  }
  
  Future<List<DocumentationItem>> loadDocumentation(String projectId) async {
    return [];
  }
  
  Future<void> deleteDocumentation(String projectId) async {}
  Future<void> deleteProject(String projectId) async {}
  Future<void> clearAll() async {}
  
  bool get isReady => true;
} 