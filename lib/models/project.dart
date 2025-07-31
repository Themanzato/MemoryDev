import 'documentation_item.dart';

class Project {
  final String id;
  final String name;
  final String description;
  final String type;
  final double progress;
  final String estimatedDuration;
  final String methodology;
  final bool allowImages;
  final bool allowFiles;
  final bool allowDiagrams;
  final DateTime createdAt;
  final List<DocumentationItem> documentation;

  Project({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.progress,
    required this.estimatedDuration,
    required this.methodology,
    required this.allowImages,
    required this.allowFiles,
    required this.allowDiagrams,
    DateTime? createdAt,
    List<DocumentationItem>? documentation,
  }) : createdAt = createdAt ?? DateTime.now(), 
       documentation = documentation ?? [];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type,
      'progress': progress,
      'estimatedDuration': estimatedDuration,
      'methodology': methodology,
      'allowImages': allowImages,
      'allowFiles': allowFiles,
      'allowDiagrams': allowDiagrams,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      type: map['type'] ?? '',
      progress: (map['progress'] ?? 0.0).toDouble(),
      estimatedDuration: map['estimatedDuration'] ?? '',
      methodology: map['methodology'] ?? '',
      allowImages: map['allowImages'] ?? false,
      allowFiles: map['allowFiles'] ?? false,
      allowDiagrams: map['allowDiagrams'] ?? false,
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Project copyWith({
    String? id,
    String? name,
    String? description,
    String? type,
    double? progress,
    String? estimatedDuration,
    String? methodology,
    bool? allowImages,
    bool? allowFiles,
    bool? allowDiagrams,
    DateTime? createdAt,
    List<DocumentationItem>? documentation,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      progress: progress ?? this.progress,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      methodology: methodology ?? this.methodology,
      allowImages: allowImages ?? this.allowImages,
      allowFiles: allowFiles ?? this.allowFiles,
      allowDiagrams: allowDiagrams ?? this.allowDiagrams,
      createdAt: createdAt ?? this.createdAt,
      documentation: documentation ?? this.documentation,
    );
  }
} 