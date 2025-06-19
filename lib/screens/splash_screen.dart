import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'home_screen.dart'; // Assure-toi que ce chemin est correct

/// Extension on Offset to add a normalize method.
/// This calculates a vector with the same direction but a magnitude of 1.
extension OffsetExtension on Offset {
  Offset normalize() {
    final magnitude = sqrt(dx * dx + dy * dy);
    if (magnitude == 0) {
      return Offset.zero; // Avoid division by zero
    }
    return Offset(dx / magnitude, dy / magnitude);
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoAnimationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _rotationAnimation; // Animation for rotation
  late Animation<Offset> _slideAnimation;

  late AnimationController _finalTextAnimationController;
  late Animation<double> _finalTextScaleAnimation;
  late Animation<double> _finalTextRotationAnimation;
  late Animation<double> _finalTextFadeAnimation;

  late AnimationController _lightningController;
  late Animation<double> _lightningFadeAnimation;

  int _currentLogoIndex = 0;
  bool _showFinalText = false;

  final List<String> _logoPaths = [
    // 'assets/images/logo1.png',
    // 'assets/images/logo2.png',
    'assets/images/logo3.png',
    'assets/images/logo4.png',
    'assets/images/logo2.png', // Le logo 2 sera affiché à la fin
  ];

  @override
  void initState() {
    super.initState();

    // Controller et animations pour les logos
    _logoAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = Tween<double>(
      begin: 2.5,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
    ));

    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
    ));

    // MODIFICATION ICI pour la rotation des logos - reste la même, sera appliquée à chaque logo
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.5 * pi, // Ajuste la vitesse/angle selon ton goût
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeInOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
    ));

    // Controller and animations for the final text and logo
    _finalTextAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _finalTextScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _finalTextAnimationController, curve: Curves.easeOut),
    );

    // MODIFICATION ICI pour la rotation du texte final (et du logo qui l'accompagne)
    _finalTextRotationAnimation = Tween<double>(
      begin: -0.2 * pi,
      end: 0.0,
    ).animate(
      CurvedAnimation(parent: _finalTextAnimationController, curve: Curves.elasticOut),
    );

    _finalTextFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _finalTextAnimationController, curve: Curves.easeIn),
    );

    // Controller for the lightning effect
    _lightningController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );

    _lightningFadeAnimation = Tween<double>(begin: 0.0, end: 0.8).animate(
      CurvedAnimation(parent: _lightningController, curve: Curves.easeIn),
    );

    _startSplashSequence();
  }

  void _triggerLightning() async {
    _lightningController.reset();
    await _lightningController.forward();
    await Future.delayed(const Duration(milliseconds: 50));
    await _lightningController.reverse();
  }

  void _startSplashSequence() async {
    // Logo animation sequence
    for (int i = 0; i < _logoPaths.length; i++) {
      setState(() {
        _currentLogoIndex = i;
      });
      _logoAnimationController.reset();
      await _logoAnimationController.forward(); // Commence l'animation (incluant la rotation)
      await Future.delayed(const Duration(milliseconds: 500));
      _triggerLightning();
      await _logoAnimationController.reverse();
      await Future.delayed(const Duration(milliseconds: 200));
      if (i == _logoPaths.length - 2) { // Avant-dernier logo (l'avant-dernier 'logo2')
        break; // S'arrête après l'animation de l'avant-dernier logo
      }
    }

    // Affiche le logo 2 et le texte final
    setState(() {
      _currentLogoIndex = _logoPaths.length - 1; // Affiche le dernier 'logo2'
      _showFinalText = true;
    });
    _finalTextAnimationController.forward();
    _triggerLightning();
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    _finalTextAnimationController.dispose();
    _lightningController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBackground(
        lightningAnimation: _lightningFadeAnimation,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Display the animated logo
              FadeTransition(
                opacity: _showFinalText ? _finalTextFadeAnimation : _fadeAnimation,
                child: SlideTransition(
                  position: _showFinalText ? Tween<Offset>(begin: Offset.zero, end: Offset.zero).animate(_finalTextAnimationController) : _slideAnimation,
                  child: RotationTransition(
                    turns: _showFinalText ? _finalTextRotationAnimation : _rotationAnimation,
                    child: ScaleTransition(
                      scale: _showFinalText ? _finalTextScaleAnimation : _scaleAnimation,
                      child: Image.asset(
                        _logoPaths[_currentLogoIndex],
                        width: _showFinalText ? 200 : 180,
                        height: _showFinalText ? 200 : 180,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // Display final text only when _showFinalText is true
              if (_showFinalText)
                FadeTransition(
                  opacity: _finalTextFadeAnimation,
                  child: ScaleTransition(
                    scale: _finalTextScaleAnimation,
                    child: RotationTransition(
                      turns: _finalTextRotationAnimation,
                      child: const Text(
                        'Les 48 Lois du Pouvoir VF',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 32,
                          color: Color.fromARGB(255, 1, 15, 138),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          shadows: [
                            Shadow(
                              blurRadius: 10.0,
                              color: Color.fromARGB(255, 255, 255, 255),
                              offset: Offset(0, 0),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              if (!_showFinalText)
                const CircularProgressIndicator(
                  color: Color.fromARGB(255, 154, 1, 168),
                  strokeWidth: 7,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget with animated background and lightning effect
class AnimatedBackground extends StatefulWidget {
  final Widget child;
  final Animation<double> lightningAnimation;
  const AnimatedBackground({required this.child, required this.lightningAnimation, super.key});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with TickerProviderStateMixin {
  late AnimationController _bgController;
  late AnimationController _moleculeController;

  final List<Molecule> _molecules = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    _moleculeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _createMolecules(20);

    _moleculeController.addListener(() {
      setState(() {
        for (var mol in _molecules) {
          mol.update(_moleculeController.value);
        }
      });
    });
  }

  void _createMolecules(int count) {
    for (int i = 0; i < count; i++) {
      _molecules.add(
        Molecule(
          position: Offset(_random.nextDouble() * 1.0, _random.nextDouble() * 1.0),
          radius: _random.nextDouble() * 15 + 5,
          speed: _random.nextDouble() * 0.005 + 0.001,
          color: Color.fromRGBO( // Génère une couleur RGB aléatoire
            _random.nextInt(256),
            _random.nextInt(256),
            _random.nextInt(256),
            _random.nextDouble() * 0.3 + 0.1, // Transparence
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _bgController.dispose();
    _moleculeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bgController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.lerp(
                  const Color.fromARGB(255, 2, 2, 2),
                  const Color.fromARGB(255, 33, 1, 197),
                  _bgController.value,
                )!,
                Color.lerp(
                  const Color.fromARGB(255, 6, 24, 192),
                  const Color.fromARGB(255, 255, 255, 255),
                  _bgController.value,
                )!,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Opacity(
                opacity: widget.lightningAnimation.value,
                child: Container(
                  color: Colors.white,
                ),
              ),
              CustomPaint(
                painter: MoleculePainter(molecules: _molecules),
                child: Container(),
              ),
              widget.child,
            ],
          ),
        );
      },
    );
  }
}

class Molecule {
  Offset position;
  double radius;
  double speed;
  Color color;
  Offset direction;

  Molecule({
    required this.position,
    required this.radius,
    required this.speed,
    required this.color,
  }) : direction = Offset(Random().nextDouble() * 2 - 1, Random().nextDouble() * 2 - 1).normalize();

  void update(double animationValue) {
    position = position + direction * speed;

    if (position.dx < 0 || position.dx > 1) {
      direction = Offset(-direction.dx, direction.dy);
      position = Offset(position.dx.clamp(0.0, 1.0), position.dy);
    }
    if (position.dy < 0 || position.dy > 1) {
      direction = Offset(direction.dx, -direction.dy);
      position = Offset(position.dx, position.dy.clamp(0.0, 1.0));
    }
  }
}

class MoleculePainter extends CustomPainter {
  final List<Molecule> molecules;

  MoleculePainter({required this.molecules});

  @override
  void paint(Canvas canvas, Size size) {
    for (var mol in molecules) {
      final paint = Paint()..color = mol.color;
      final actualPosition = Offset(mol.position.dx * size.width, mol.position.dy * size.height);
      canvas.drawCircle(actualPosition, mol.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}