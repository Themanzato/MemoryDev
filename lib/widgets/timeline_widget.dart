import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/project.dart';
import '../models/documentation_item.dart';

class TimelineWidget extends StatelessWidget {
  final Project project;
  final List<DocumentationItem> documentation;

  const TimelineWidget({
    super.key,
    required this.project,
    required this.documentation,
  });

  @override
  Widget build(BuildContext context) {
    // Crear eventos combinando el inicio del proyecto con la documentación
    final events = <Map<String, dynamic>>[];
    
    // Agregar evento de inicio del proyecto
    events.add({
      'title': 'Inicio del proyecto',
      'description': 'El proyecto "${project.name}" ha sido creado',
      'date': project.createdAt,
      'type': 'start',
      'icon': Icons.rocket_launch,
      'color': const Color(0xFF4CAF50),
    });

    // Agregar eventos de documentación
    for (final doc in documentation) {
      events.add({
        'title': doc.title,
        'description': doc.content,
        'date': doc.createdAt,
        'type': doc.type.toString(),
        'icon': _getTypeIcon(doc.type),
        'color': _getTypeColor(doc.type),
      });
    }

    // Ordenar eventos por fecha (más reciente primero)
    events.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          Row(
            children: [
              Icon(
                Icons.timeline,
                color: const Color(0xFF6C63FF),
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Timeline del Proyecto',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (events.isEmpty)
            _buildEmptyState()
          else
            Column(
              children: events.asMap().entries.map((entry) {
                final index = entry.key;
                final event = entry.value;
                final isLast = index == events.length - 1;
                return _buildTimelineItem(event, isLast);
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(Map<String, dynamic> event, bool isLast) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: event['color'],
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: event['color'].withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  event['icon'],
                  color: Colors.white,
                  size: 20,
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 60,
                  color: Colors.grey[300],
                  margin: const EdgeInsets.symmetric(vertical: 8),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event['title'],
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event['description'],
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatDate(event['date']),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.timeline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No hay eventos en el timeline',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Los eventos del proyecto aparecerán aquí',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
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

  String _formatDate(DateTime date) {
    final months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    
    return '${date.day} ${months[date.month - 1]} ${date.year} - ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
} 