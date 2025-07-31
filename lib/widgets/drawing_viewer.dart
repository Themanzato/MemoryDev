import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import '../widgets/drawing_canvas.dart'; // Para acceder a DrawingPath y DrawingTool
import 'dart:math' as math;

class DrawingViewer extends StatelessWidget {
  final String drawingData;
  final double? width;
  final double? height;
  final bool isPreview;

  const DrawingViewer({
    super.key,
    required this.drawingData,
    this.width,
    this.height,
    this.isPreview = true,
  });

  List<DrawingPath> _parseDrawingData() {
    try {
      final Map<String, dynamic> drawingJson = jsonDecode(drawingData);
      final List<dynamic> pathsData = drawingJson['paths'] ?? [];
      
      return pathsData.map((pathData) {
        final List<dynamic> pointsData = pathData['points'] ?? [];
        final points = pointsData.map((p) => Offset(p['x'].toDouble(), p['y'].toDouble())).toList();
        
        return DrawingPath(
          points: points,
          color: Color(pathData['color']),
          strokeWidth: pathData['strokeWidth'].toDouble(),
          tool: _stringToTool(pathData['tool']),
        );
      }).toList();
    } catch (e) {
      print('Error parsing drawing data: $e');
      return [];
    }
  }

  DrawingTool _stringToTool(String toolString) {
    switch (toolString) {
      case 'pen':
        return DrawingTool.pen;
      case 'brush':
        return DrawingTool.brush;
      case 'highlighter':
        return DrawingTool.highlighter;
      case 'eraser':
        return DrawingTool.eraser;
      default:
        return DrawingTool.pen;
    }
  }

  @override
  Widget build(BuildContext context) {
    final paths = _parseDrawingData();
    
    return Container(
      width: width ?? double.infinity,
      height: height ?? (isPreview ? 200 : 300),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // Renderizar el dibujo escalado para que quepa completo
            if (paths.isNotEmpty)
              Container(
                width: double.infinity,
                height: double.infinity,
                child: CustomPaint(
                  painter: ScaledDrawingPainter(paths),
                  size: Size.infinite,
                ),
              )
            else
              // Placeholder si no hay dibujo
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.brush,
                        size: isPreview ? 32 : 48,
                        color: Colors.grey[400],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Dibujo vacío',
                      style: GoogleFonts.poppins(
                        fontSize: isPreview ? 14 : 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            
            // Badge indicador
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.draw,
                      size: 12,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Dibujo',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Nuevo painter que escala automáticamente
class ScaledDrawingPainter extends CustomPainter {
  final List<DrawingPath> paths;

  ScaledDrawingPainter(this.paths);

  @override
  void paint(Canvas canvas, Size size) {
    if (paths.isEmpty) return;

    // Calcular los límites del dibujo
    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = double.negativeInfinity;
    double maxY = double.negativeInfinity;

    for (final path in paths) {
      for (final point in path.points) {
        minX = math.min(minX, point.dx);
        minY = math.min(minY, point.dy);
        maxX = math.max(maxX, point.dx);
        maxY = math.max(maxY, point.dy);
      }
    }

    // Si no hay puntos válidos, no dibujar nada
    if (minX == double.infinity) return;

    // Calcular dimensiones del dibujo
    final drawingWidth = maxX - minX;
    final drawingHeight = maxY - minY;

    // Calcular escala para que quepa en el contenedor con margen
    const margin = 20.0;
    final scaleX = (size.width - margin * 2) / drawingWidth;
    final scaleY = (size.height - margin * 2) / drawingHeight;
    final scale = math.min(scaleX, scaleY);

    // Calcular offset para centrar
    final scaledWidth = drawingWidth * scale;
    final scaledHeight = drawingHeight * scale;
    final offsetX = (size.width - scaledWidth) / 2 - minX * scale;
    final offsetY = (size.height - scaledHeight) / 2 - minY * scale;

    // Aplicar transformación
    canvas.save();
    canvas.translate(offsetX, offsetY);
    canvas.scale(scale);

    // Dibujar fondo blanco
    final backgroundPaint = Paint()..color = Colors.white;
    canvas.drawRect(
      Rect.fromLTWH(minX, minY, drawingWidth, drawingHeight),
      backgroundPaint,
    );

    // Dibujar todos los paths
    for (final path in paths) {
      final paint = Paint()
        ..color = path.color
        ..strokeWidth = path.strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      switch (path.tool) {
        case DrawingTool.pen:
          paint.style = PaintingStyle.stroke;
          break;
        case DrawingTool.brush:
          paint.style = PaintingStyle.stroke;
          paint.strokeWidth = path.strokeWidth * 1.5;
          break;
        case DrawingTool.highlighter:
          paint.style = PaintingStyle.stroke;
          paint.color = path.color.withOpacity(0.4);
          paint.strokeWidth = path.strokeWidth * 2;
          break;
        case DrawingTool.eraser:
          paint.style = PaintingStyle.stroke;
          paint.color = Colors.white;
          paint.strokeWidth = path.strokeWidth * 2;
          break;
      }

      if (path.points.length > 1) {
        final pathToDraw = Path();
        pathToDraw.moveTo(path.points.first.dx, path.points.first.dy);
        
        for (int i = 1; i < path.points.length; i++) {
          pathToDraw.lineTo(path.points[i].dx, path.points[i].dy);
        }
        
        canvas.drawPath(pathToDraw, paint);
      } else if (path.points.isNotEmpty) {
        canvas.drawCircle(path.points.first, path.strokeWidth / 2, paint);
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
} 