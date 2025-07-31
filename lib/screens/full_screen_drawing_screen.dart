import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/drawing_canvas.dart';
import 'dart:math' as math;

class FullScreenDrawingScreen extends StatefulWidget {
  final String? initialDrawing;

  const FullScreenDrawingScreen({
    super.key,
    this.initialDrawing,
  });

  @override
  State<FullScreenDrawingScreen> createState() => _FullScreenDrawingScreenState();
}

class _FullScreenDrawingScreenState extends State<FullScreenDrawingScreen> {
  String _currentDrawing = '';
  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    _currentDrawing = widget.initialDrawing ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: _buildAppBar(),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Container(
                margin: EdgeInsets.all(constraints.maxWidth < 600 ? 4 : 8),
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
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Column(
                    children: [
                      _buildHeader(),
                      Expanded(
                        child: _buildCanvasArea(constraints),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'Canvas de Dibujo',
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      backgroundColor: Colors.white,
      foregroundColor: Colors.grey[800],
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.arrow_back, size: 18),
        ),
        onPressed: () => _handleBack(),
      ),
      actions: [
        // Botón de ayuda
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.help_outline,
              size: 18,
              color: Colors.blue[600],
            ),
          ),
          onPressed: _showHelp,
        ),
        // Botón de guardar - adaptativo
        Container(
          margin: const EdgeInsets.only(right: 8),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isSmall = MediaQuery.of(context).size.width < 400;
              
              if (isSmall) {
                // Solo icono en pantallas pequeñas
                return IconButton(
                  onPressed: _hasUnsavedChanges ? _saveAndExit : null,
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _hasUnsavedChanges 
                          ? const Color(0xFF4CAF50) 
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.save,
                      size: 18,
                      color: _hasUnsavedChanges ? Colors.white : Colors.grey[500],
                    ),
                  ),
                );
              } else {
                // Botón con texto en pantallas más grandes
                return ElevatedButton.icon(
                  onPressed: _hasUnsavedChanges ? _saveAndExit : null,
                  icon: const Icon(Icons.save, size: 16),
                  label: Text(
                    'Guardar',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 500;
          
          if (isCompact) {
            // Layout compacto para pantallas pequeñas
            return Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        Icons.brush,
                        color: const Color(0xFF4CAF50),
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Área de Dibujo',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                  ],
                ),
                if (_hasUnsavedChanges) ...[
                  const SizedBox(height: 8),
                  _buildUnsavedBadge(),
                ],
              ],
            );
          } else {
            // Layout normal para pantallas más grandes
            return Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.brush,
                    color: const Color(0xFF4CAF50),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Área de Dibujo',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.grey[800],
                        ),
                      ),
                      Text(
                        'Usa las herramientas para crear tu dibujo',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (_hasUnsavedChanges) _buildUnsavedBadge(),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildUnsavedBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.edit,
            size: 12,
            color: Colors.orange[700],
          ),
          const SizedBox(width: 4),
          Text(
            'Sin guardar',
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Colors.orange[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCanvasArea(BoxConstraints constraints) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: DrawingCanvas(
        initialDrawing: _currentDrawing.isNotEmpty ? _currentDrawing : null,
        onDrawingChanged: (drawingData) {
          print('Drawing data changed: ${drawingData.length} characters'); // Debug
          setState(() {
            _currentDrawing = drawingData;
            _hasUnsavedChanges = true;
          });
        },
        width: constraints.maxWidth - 16,
        height: constraints.maxHeight - 16,
      ),
    );
  }

  void _saveAndExit() {
    print('Saving drawing data: ${_currentDrawing.substring(0, math.min(100, _currentDrawing.length))}...'); // Debug
    Navigator.pop(context, _currentDrawing);
  }

  Future<bool> _onWillPop() async {
    if (_hasUnsavedChanges) {
      return await _showUnsavedChangesDialog() ?? false;
    }
    return true;
  }

  void _handleBack() async {
    if (_hasUnsavedChanges) {
      final shouldExit = await _showUnsavedChangesDialog();
      if (shouldExit == true) {
        Navigator.pop(context);
      }
    } else {
      Navigator.pop(context);
    }
  }

  Future<bool?> _showUnsavedChangesDialog() {
    return showDialog<bool>(
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
                color: Colors.orange[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.warning_outlined,
                color: Colors.orange[600],
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Cambios sin guardar',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          '¿Quieres guardar los cambios en tu dibujo antes de salir?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Salir sin guardar',
              style: GoogleFonts.poppins(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, false);
              _saveAndExit();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Guardar y salir',
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

  void _showHelp() {
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
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.help_outline,
                color: Colors.blue[600],
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Ayuda de Dibujo',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHelpItem(Icons.edit, 'Lápiz', 'Trazos precisos y delgados'),
              _buildHelpItem(Icons.brush, 'Pincel', 'Trazos más gruesos y suaves'),
              _buildHelpItem(Icons.highlight, 'Resaltador', 'Trazos semitransparentes'),
              _buildHelpItem(Icons.cleaning_services, 'Borrador', 'Elimina partes del dibujo'),
              const SizedBox(height: 16),
              Text(
                'Consejos:',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '• Usa deshacer/rehacer para corregir errores\n'
                '• Ajusta el grosor según lo que necesites\n'
                '• El resaltador es ideal para enfatizar texto\n'
                '• Guarda regularmente para no perder cambios',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Entendido',
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

  Widget _buildHelpItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Colors.grey[800],
                  ),
                ),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 