enum DocumentationType {
  milestone,    // Hitos importantes
  note,         // Notas generales
  task,         // Tareas completadas
  update,       // Actualizaciones de progreso
  file,         // Archivos adjuntos
  image,        // Imágenes
  diagram       // Diagramas
}

class DocumentationItem {
  final String id;
  final String title;
  final String content;
  final DocumentationType type;
  final DateTime createdAt;
  final String? status;
  final dynamic progress;
  final List<String>? attachments;
  final DateTime? dueDate;

  DocumentationItem({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    required this.createdAt,
    this.status,
    this.progress,
    this.attachments,
    this.dueDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'type': type.toString(),
      'createdAt': createdAt.toIso8601String(),
      'status': status,
      'progress': progress?.toString(),
      'attachments': attachments,
      'dueDate': dueDate?.toIso8601String(),
    };
  }

  factory DocumentationItem.fromMap(Map<String, dynamic> map) {
    return DocumentationItem(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      type: DocumentationType.values.firstWhere(
        (e) => e.toString() == map['type'],
        orElse: () => DocumentationType.note,
      ),
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      status: map['status'],
      progress: map['progress'],
      attachments: map['attachments'] != null 
          ? List<String>.from(map['attachments']) 
          : null,
      dueDate: map['dueDate'] != null 
          ? DateTime.parse(map['dueDate']) 
          : null,
    );
  }

  DocumentationItem copyWith({
    String? id,
    String? title,
    String? content,
    DocumentationType? type,
    DateTime? createdAt,
    String? status,
    dynamic progress,
    List<String>? attachments,
    DateTime? dueDate,
  }) {
    return DocumentationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      attachments: attachments ?? this.attachments,
      dueDate: dueDate ?? this.dueDate,
    );
  }
} 