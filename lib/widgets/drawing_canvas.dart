import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import 'dart:convert';

class DrawingCanvas extends StatefulWidget {
  final String? initialDrawing;
  final Function(String) onDrawingChanged;
  final double width;
  final double height;

  const DrawingCanvas({
    super.key,
    this.initialDrawing,
    required this.onDrawingChanged,
    this.width = 400,
    this.height = 300,
  });

  @override
  State<DrawingCanvas> createState() => _DrawingCanvasState();
}

class _DrawingCanvasState extends State<DrawingCanvas> {
  final GlobalKey _canvasKey = GlobalKey();
  final List<DrawingPath> _paths = [];
  final List<DrawingPath> _undoHistory = [];
  
  DrawingTool _selectedTool = DrawingTool.pen;
  Color _selectedColor = Colors.black;
  double _strokeWidth = 2.0;
  bool _isDrawing = false;
  double _scale = 1.0;
  Offset _offset = Offset.zero;
  bool _isPanning = false;
  late TransformationController _transformationController;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    if (widget.initialDrawing != null && widget.initialDrawing!.isNotEmpty) {
      _loadDrawing(widget.initialDrawing!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            _buildToolbar(),
            const SizedBox(height: 12),
            Expanded(child: _buildCanvas()),
          ],
        );
      },
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 600;
          
          return Column(
            children: [
              // Herramientas principales
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildToolButton(DrawingTool.pen, Icons.edit, 'Lápiz'),
                  _buildToolButton(DrawingTool.brush, Icons.brush, 'Pincel'),
                  _buildToolButton(DrawingTool.highlighter, Icons.highlight, 'Resaltador'),
                  _buildToolButton(DrawingTool.eraser, Icons.cleaning_services, 'Borrador'),
                  const SizedBox(width: 8),
                  // Acciones
                  _buildActionButton(Icons.undo, 'Deshacer', _canUndo(), _undo),
                  _buildActionButton(Icons.redo, 'Rehacer', _canRedo(), _redo),
                  _buildActionButton(Icons.clear, 'Limpiar', _paths.isNotEmpty, _clear),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Controles de trazo y color - Layout adaptativo
              if (isCompact) ...[
                // Layout vertical para pantallas pequeñas
                _buildStrokeControls(),
                const SizedBox(height: 8),
                _buildColorControls(),
              ] else ...[
                // Layout horizontal para pantallas grandes
                Row(
                  children: [
                    Expanded(flex: 2, child: _buildStrokeControls()),
                    const SizedBox(width: 16),
                    Expanded(flex: 3, child: _buildColorControls()),
                  ],
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildToolButton(DrawingTool tool, IconData icon, String label) {
    final isSelected = _selectedTool == tool;
    return Tooltip(
      message: label,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTool = tool;
          });
        },
        child: Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF4CAF50) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? const Color(0xFF4CAF50) : Colors.grey[300]!,
            ),
          ),
          child: Icon(
            icon,
            size: 20,
            color: isSelected ? Colors.white : Colors.grey[700],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, bool enabled, VoidCallback onTap) {
    return Tooltip(
      message: label,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: enabled ? Colors.white : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Icon(
            icon,
            size: 20,
            color: enabled ? Colors.grey[700] : Colors.grey[400],
          ),
        ),
      ),
    );
  }

  Widget _buildStrokeControls() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.line_weight, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<double>(
                value: _strokeWidth,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _strokeWidth = value;
                    });
                  }
                },
                items: [
                  _buildStrokeOption(1.0, 'Muy fino'),
                  _buildStrokeOption(2.0, 'Fino'),
                  _buildStrokeOption(4.0, 'Normal'),
                  _buildStrokeOption(6.0, 'Grueso'),
                  _buildStrokeOption(8.0, 'Muy grueso'),
                  _buildStrokeOption(12.0, 'Extra grueso'),
                  _buildStrokeOption(16.0, 'Súper grueso'),
                  _buildStrokeOption(20.0, 'Máximo'),
                ],
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
                icon: Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                isDense: true,
              ),
            ),
          ),
        ),
      ],
    );
  }

  DropdownMenuItem<double> _buildStrokeOption(double value, String label) {
    return DropdownMenuItem<double>(
      value: value,
      child: Row(
        children: [
          Container(
            width: 30,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Container(
                width: 24,
                height: value.clamp(1, 8),
                decoration: BoxDecoration(
                  color: Colors.grey[700],
                  borderRadius: BorderRadius.circular(value / 2),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildColorControls() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Color:',
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700]),
        ),
        const SizedBox(width: 8),
        _buildColorPicker(),
        const SizedBox(width: 8),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Colors.black,
                Colors.red,
                Colors.blue,
                Colors.green,
                Colors.orange,
                Colors.purple,
                Colors.pink,
                Colors.teal,
              ].map((color) => Padding(
                padding: const EdgeInsets.only(right: 4),
                child: _buildColorOption(color),
              )).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildColorPicker() {
    return GestureDetector(
      onTap: _showColorPicker,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: _selectedColor,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey[400]!, width: 2),
        ),
      ),
    );
  }

  Widget _buildColorOption(Color color) {
    final isSelected = _selectedColor == color;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedColor = color;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 4),
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.grey[800]! : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
      ),
    );
  }

  Widget _buildCanvas() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final canvasWidth = constraints.maxWidth;
        final canvasHeight = constraints.maxHeight;
        
        return Container(
          width: canvasWidth,
          height: canvasHeight,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              children: [
                // Canvas principal con zoom y pan
                InteractiveViewer(
                  transformationController: _transformationController,
                  boundaryMargin: const EdgeInsets.all(20),
                  minScale: 0.5,
                  maxScale: 5.0,
                  onInteractionStart: (details) {
                    if (details.pointerCount > 1) {
                      setState(() {
                        _isPanning = true;
                      });
                    }
                  },
                  onInteractionEnd: (details) {
                    setState(() {
                      _isPanning = false;
                    });
                  },
                  child: Container(
                    width: canvasWidth,
                    height: canvasHeight,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: RepaintBoundary(
                      key: _canvasKey,
                      child: GestureDetector(
                        onPanStart: _isPanning ? null : _onPanStart,
                        onPanUpdate: _isPanning ? null : _onPanUpdate,
                        onPanEnd: _isPanning ? null : _onPanEnd,
                        child: CustomPaint(
                          painter: DrawingPainter(_paths),
                          size: Size(canvasWidth, canvasHeight),
                          child: Container(),
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Controles de zoom superpuestos
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: _buildZoomControls(),
                ),
                
                // Indicador de modo
                if (_isPanning)
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.pan_tool, size: 16, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            'Modo navegación',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
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
      },
    );
  }

  Widget _buildZoomControls() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildZoomButton(Icons.add, () => _zoomIn()),
          Container(
            height: 1,
            width: 30,
            color: Colors.grey[300],
          ),
          _buildZoomButton(Icons.remove, () => _zoomOut()),
          Container(
            height: 1,
            width: 30,
            color: Colors.grey[300],
          ),
          _buildZoomButton(Icons.center_focus_strong, () => _resetZoom()),
        ],
      ),
    );
  }

  Widget _buildZoomButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Icon(
          icon,
          size: 20,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  void _zoomIn() {
    final matrix = Matrix4.copy(_transformationController.value);
    matrix.scale(1.2);
    _transformationController.value = matrix;
  }

  void _zoomOut() {
    final matrix = Matrix4.copy(_transformationController.value);
    matrix.scale(0.8);
    _transformationController.value = matrix;
  }

  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
  }

  void _onPanStart(DragStartDetails details) {
    if (_isPanning) return;
    
    // Convertir la posición de la pantalla a posición del canvas
    final localPosition = _getTransformedPosition(details.localPosition);
    
    setState(() {
      _isDrawing = true;
      _undoHistory.clear();
      
      _paths.add(DrawingPath(
        points: [localPosition],
        color: _selectedColor,
        strokeWidth: _strokeWidth,
        tool: _selectedTool,
      ));
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!_isDrawing || _isPanning) return;
    
    final localPosition = _getTransformedPosition(details.localPosition);
    
    setState(() {
      if (_paths.isNotEmpty) {
        _paths.last.points.add(localPosition);
      }
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_isPanning) return;
    
    setState(() {
      _isDrawing = false;
    });
    
    _saveDrawing();
  }

  Offset _getTransformedPosition(Offset screenPosition) {
    final matrix = _transformationController.value;
    final transform = matrix.storage;
    
    // Aplicar transformación inversa manualmente
    final scaleX = 1.0 / transform[0];
    final scaleY = 1.0 / transform[5];
    final translateX = -transform[12] * scaleX;
    final translateY = -transform[13] * scaleY;
    
    return Offset(
      (screenPosition.dx * scaleX) + translateX,
      (screenPosition.dy * scaleY) + translateY,
    );
  }

  void _undo() {
    if (_paths.isNotEmpty) {
      setState(() {
        _undoHistory.add(_paths.removeLast());
      });
      _saveDrawing();
    }
  }

  void _redo() {
    if (_undoHistory.isNotEmpty) {
      setState(() {
        _paths.add(_undoHistory.removeLast());
      });
      _saveDrawing();
    }
  }

  void _clear() {
    setState(() {
      _undoHistory.addAll(_paths);
      _paths.clear();
    });
    _saveDrawing();
  }

  bool _canUndo() => _paths.isNotEmpty;
  bool _canRedo() => _undoHistory.isNotEmpty;

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Seleccionar Color',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: BlockPicker(
            pickerColor: _selectedColor,
            onColorChanged: (color) {
              setState(() {
                _selectedColor = color;
              });
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  void _saveDrawing() {
    final drawingData = _encodeDrawing();
    widget.onDrawingChanged(drawingData);
  }

  String _encodeDrawing() {
    try {
      if (_paths.isEmpty) return '';
      
      final pathsData = _paths.map((path) => {
        'points': path.points.map((p) => {'x': p.dx, 'y': p.dy}).toList(),
        'color': path.color.value,
        'strokeWidth': path.strokeWidth,
        'tool': path.tool.name,
      }).toList();
      
      final drawingJson = {
        'version': 1,
        'paths': pathsData,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      
      final encoded = jsonEncode(drawingJson);
      print('Drawing encoded: ${encoded.substring(0, math.min(100, encoded.length))}...'); // Debug
      return encoded;
    } catch (e) {
      print('Error encoding drawing: $e');
      return '';
    }
  }

  void _loadDrawing(String drawingData) {
    try {
      if (drawingData.isEmpty) {
        print('No drawing data to load');
        return;
      }
      
      print('Loading drawing data: ${drawingData.substring(0, math.min(100, drawingData.length))}...');
      
      final Map<String, dynamic> drawingJson = jsonDecode(drawingData);
      final List<dynamic> pathsData = drawingJson['paths'] ?? [];
      
      setState(() {
        _paths.clear();
        _undoHistory.clear();
        
        for (final pathData in pathsData) {
          final List<dynamic> pointsData = pathData['points'] ?? [];
          final points = pointsData.map((p) => Offset(p['x'].toDouble(), p['y'].toDouble())).toList();
          
          final tool = _stringToTool(pathData['tool']);
          
          _paths.add(DrawingPath(
            points: points,
            color: Color(pathData['color']),
            strokeWidth: pathData['strokeWidth'].toDouble(),
            tool: tool,
          ));
        }
      });
      
      print('Drawing loaded successfully with ${_paths.length} paths');
    } catch (e) {
      print('Error loading drawing: $e');
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

  Future<Uint8List?> exportAsImage() async {
    try {
      final boundary = _canvasKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary != null) {
        final image = await boundary.toImage();
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        return byteData?.buffer.asUint8List();
      }
    } catch (e) {
      print('Error exporting drawing as image: $e');
    }
    return null;
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }
}

class DrawingPainter extends CustomPainter {
  final List<DrawingPath> paths;

  DrawingPainter(this.paths);

  @override
  void paint(Canvas canvas, Size size) {
    // Fondo blanco para el borrador
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = Colors.white);
    
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
          // Usar color blanco en lugar de BlendMode.clear
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
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class DrawingPath {
  final List<Offset> points;
  final Color color;
  final double strokeWidth;
  final DrawingTool tool;

  DrawingPath({
    required this.points,
    required this.color,
    required this.strokeWidth,
    required this.tool,
  });
}

enum DrawingTool {
  pen,
  brush,
  highlighter,
  eraser,
}

// Widget simple de selección de colores
class BlockPicker extends StatelessWidget {
  final Color pickerColor;
  final Function(Color) onColorChanged;

  const BlockPicker({
    super.key,
    required this.pickerColor,
    required this.onColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = [
      Colors.black, Colors.white, Colors.grey,
      Colors.red, Colors.pink, Colors.purple,
      Colors.blue, Colors.cyan, Colors.teal,
      Colors.green, Colors.lime, Colors.yellow,
      Colors.orange, Colors.brown, Colors.indigo,
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: colors.map((color) {
        return GestureDetector(
          onTap: () => onColorChanged(color),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              border: Border.all(
                color: pickerColor == color ? Colors.blue : Colors.grey,
                width: pickerColor == color ? 3 : 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }).toList(),
    );
  }
} 