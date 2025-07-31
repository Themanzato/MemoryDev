import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _animationController;

  final List<OnboardingItem> _items = [
    OnboardingItem(
      title: 'Documenta tus Proyectos',
      description: 'Registra y organiza toda la información de tus proyectos de desarrollo',
      animation: 'assets/animations/document.json',
      color: const Color(0xFF6C63FF),
    ),
    OnboardingItem(
      title: 'Línea de Tiempo Visual',
      description: 'Visualiza el progreso de tu proyecto con una línea de tiempo interactiva',
      animation: 'assets/animations/timeline.json',
      color: const Color(0xFF00BFA6),
    ),
    OnboardingItem(
      title: 'Metas y Objetivos',
      description: 'Establece y realiza seguimiento de tus objetivos de proyecto',
      animation: 'assets/animations/goals.json',
      color: const Color(0xFFFF6B6B),
    ),
    OnboardingItem(
      title: 'Exporta tu Documentación',
      description: 'Genera PDFs con toda la información de tu proyecto',
      animation: 'assets/animations/export.json',
      color: const Color(0xFF4CAF50),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _items.length,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
              _animationController.reset();
              _animationController.forward();
            },
            itemBuilder: (context, index) {
              return _buildPage(_items[index]);
            },
          ),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _items.length,
                    (index) => _buildDot(index),
                  ),
                ),
                const SizedBox(height: 30),
                if (_currentPage == _items.length - 1)
                  _buildButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(OnboardingItem item) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            item.color.withOpacity(0.1),
            _currentPage == _items.length - 1 
                ? const Color(0xFFF5F5F5)  // Gris muy claro para el fondo
                : Colors.white,
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: _currentPage == _items.length - 1 
                  ? const Color(0xFFF0F0F0)  // Gris más oscuro para el contenedor de la animación
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Lottie.asset(
              item.animation,
              controller: _animationController,
              repeat: true,
              animate: true,
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.width * 0.8,
            ),
          ),
          const SizedBox(height: 40),
          Text(
            item.title,
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: item.color,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            item.description,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 5),
      width: _currentPage == index ? 20 : 10,
      height: 10,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: _currentPage == index ? _items[_currentPage].color : Colors.grey[300],
      ),
    );
  }

  Widget _buildButton() {
    return Container(
      width: 200,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: LinearGradient(
          colors: [
            _items[_currentPage].color,
            _items[_currentPage].color.withOpacity(0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: _items[_currentPage].color.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(25),
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const MyHomePage(title: 'MemoryDev'),
              ),
            );
          },
          child: Center(
            child: Text(
              'Comenzar',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class OnboardingItem {
  final String title;
  final String description;
  final String animation;
  final Color color;

  OnboardingItem({
    required this.title,
    required this.description,
    required this.animation,
    required this.color,
  });
} 