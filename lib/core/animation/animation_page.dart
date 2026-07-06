import 'dart:ui';

import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:demo_app/core/theme/app_colors.dart';

class AnimationsShowcaseScreen extends StatefulWidget {
  const AnimationsShowcaseScreen({Key? key}) : super(key: key);

  @override
  State<AnimationsShowcaseScreen> createState() => _AnimationsShowcaseScreenState();
}

class _AnimationsShowcaseScreenState extends State<AnimationsShowcaseScreen>
    with TickerProviderStateMixin {
  // Animation Controllers
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _rotateController;
  late AnimationController _slideController;
  late AnimationController _bounceController;
  late AnimationController _flipController;
  late AnimationController _shakeController;
  late AnimationController _pulseController;
  late AnimationController _colorController;
  late AnimationController _sizeController;
  late AnimationController _opacityScaleController;
  late AnimationController _elasticController;
  late AnimationController _waveController;
  late AnimationController _glowController;
  late AnimationController _spinController;
  late AnimationController _swingController;
  late AnimationController _zoomController;
  late AnimationController _wiggleController;
  late AnimationController _breatheController;
  late AnimationController _rippleController;
  late AnimationController _morphController;
  late AnimationController _blurController;
  late AnimationController _cardFlipController;
  late AnimationController _slideUpController;
  late AnimationController _slideDownController;

  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _bounceAnimation;
  late Animation<double> _flipAnimation;
  late Animation<double> _shakeAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<Color?> _colorAnimation;
  late Animation<double> _sizeAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _elasticAnimation;
  late Animation<double> _waveAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _spinAnimation;
  late Animation<double> _swingAnimation;
  late Animation<double> _zoomAnimation;
  late Animation<double> _wiggleAnimation;
  late Animation<double> _breatheAnimation;
  late Animation<double> _rippleAnimation;
  late Animation<BorderRadius?> _morphAnimation;
  late Animation<double> _blurAnimation;
  late Animation<double> _cardFlipAnimation;
  late Animation<Offset> _slideUpAnimation;
  late Animation<Offset> _slideDownAnimation;

  @override
  void initState() {
    super.initState();

    // 1. Fade Animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    // 2. Scale Animation
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    // 3. Rotate Animation
    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _rotateAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _rotateController, curve: Curves.easeInOut),
    );

    // 4. Slide Animation
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    // 5. Bounce Animation
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _bounceAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.bounceOut),
    );

    // 6. Flip Animation
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0.0, end: math.pi).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );

    // 7. Shake Animation
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    // 8. Pulse Animation
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // 9. Color Animation
    _colorController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _colorAnimation = ColorTween(
      begin: Colors.blue,
      end: Colors.red,
    ).animate(_colorController);

    // 10. Size Animation
    _sizeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _sizeAnimation = Tween<double>(begin: 100.0, end: 200.0).animate(
      CurvedAnimation(parent: _sizeController, curve: Curves.easeInOut),
    );

    // 11. Opacity + Scale Animation
    _opacityScaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _opacityAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _opacityScaleController, curve: Curves.easeIn),
    );

    // 12. Elastic Animation
    _elasticController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _elasticAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _elasticController, curve: Curves.elasticInOut),
    );

    // 13. Wave Animation
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _waveAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_waveController);

    // 14. Glow Animation
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _glowAnimation = Tween<double>(begin: 0.0, end: 30.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // 15. Spin Animation (Continuous)
    _spinController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _spinAnimation = Tween<double>(begin: 0.0, end: 4 * math.pi).animate(_spinController);

    // 16. Swing Animation
    _swingController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _swingAnimation = Tween<double>(begin: -0.2, end: 0.2).animate(
      CurvedAnimation(parent: _swingController, curve: Curves.easeInOut),
    );

    // 17. Zoom Animation
    _zoomController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _zoomAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _zoomController, curve: Curves.easeOut),
    );

    // 18. Wiggle Animation
    _wiggleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _wiggleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_wiggleController);

    // 19. Breathe Animation
    _breatheController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _breatheAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _breatheController, curve: Curves.easeInOut),
    );

    // 20. Ripple Animation
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_rippleController);

    // 21. Morph Animation
    _morphController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _morphAnimation = BorderRadiusTween(
      begin: BorderRadius.circular(12),
      end: BorderRadius.circular(75),
    ).animate(_morphController);

    // 22. Blur Animation
    _blurController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _blurAnimation = Tween<double>(begin: 0.0, end: 10.0).animate(_blurController);

    // 23. Card Flip Animation
    _cardFlipController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _cardFlipAnimation = Tween<double>(begin: 0.0, end: math.pi).animate(
      CurvedAnimation(parent: _cardFlipController, curve: Curves.easeInOut),
    );

    // 24. Slide Up Animation
    _slideUpController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _slideUpAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideUpController, curve: Curves.easeOut));

    // 25. Slide Down Animation
    _slideDownController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _slideDownAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideDownController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _rotateController.dispose();
    _slideController.dispose();
    _bounceController.dispose();
    _flipController.dispose();
    _shakeController.dispose();
    _pulseController.dispose();
    _colorController.dispose();
    _sizeController.dispose();
    _opacityScaleController.dispose();
    _elasticController.dispose();
    _waveController.dispose();
    _glowController.dispose();
    _spinController.dispose();
    _swingController.dispose();
    _zoomController.dispose();
    _wiggleController.dispose();
    _breatheController.dispose();
    _rippleController.dispose();
    _morphController.dispose();
    _blurController.dispose();
    _cardFlipController.dispose();
    _slideUpController.dispose();
    _slideDownController.dispose();
    super.dispose();
  }

  void _playFadeAnimation() => _fadeController.forward(from: 0.0);
  void _playScaleAnimation() => _scaleController.forward(from: 0.0);
  void _playRotateAnimation() => _rotateController.forward(from: 0.0);
  void _playSlideAnimation() => _slideController.forward(from: 0.0);
  void _playBounceAnimation() => _bounceController.forward(from: 0.0);
  void _playFlipAnimation() => _flipController.forward(from: 0.0);

  void _playShakeAnimation() {
    _shakeController.forward(from: 0.0).then((_) => _shakeController.reverse());
  }

  void _playPulseAnimation() {
    _pulseController.forward().then((_) => _pulseController.reverse());
  }

  void _playColorAnimation() {
    if (_colorController.status == AnimationStatus.completed) {
      _colorController.reverse();
    } else {
      _colorController.forward();
    }
  }

  void _playSizeAnimation() {
    if (_sizeController.status == AnimationStatus.completed) {
      _sizeController.reverse();
    } else {
      _sizeController.forward();
    }
  }

  void _playOpacityScaleAnimation() => _opacityScaleController.forward(from: 0.0);
  void _playElasticAnimation() => _elasticController.forward(from: 0.0);

  void _playWaveAnimation() {
    _waveController.repeat();
    Future.delayed(const Duration(seconds: 4), () {
      _waveController.stop();
      _waveController.reset();
    });
  }

  void _playGlowAnimation() {
    _glowController.forward().then((_) => _glowController.reverse());
  }

  void _playSpinAnimation() => _spinController.forward(from: 0.0);

  void _playSwingAnimation() {
    _swingController.forward().then((_) => _swingController.reverse());
  }

  void _playZoomAnimation() {
    _zoomController.forward().then((_) => _zoomController.reverse());
  }

  void _playWiggleAnimation() {
    _wiggleController.forward(from: 0.0);
  }

  void _playBreatheAnimation() {
    _breatheController.repeat(reverse: true);
    Future.delayed(const Duration(seconds: 4), () {
      _breatheController.stop();
      _breatheController.reset();
    });
  }

  void _playRippleAnimation() => _rippleController.forward(from: 0.0);

  void _playMorphAnimation() {
    if (_morphController.status == AnimationStatus.completed) {
      _morphController.reverse();
    } else {
      _morphController.forward();
    }
  }

  void _playBlurAnimation() {
    if (_blurController.status == AnimationStatus.completed) {
      _blurController.reverse();
    } else {
      _blurController.forward();
    }
  }

  void _playCardFlipAnimation() => _cardFlipController.forward(from: 0.0);
  void _playSlideUpAnimation() => _slideUpController.forward(from: 0.0);
  void _playSlideDownAnimation() => _slideDownController.forward(from: 0.0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(onPressed: (){
                  Navigator.pop(context);
                }, child: Text("Back")),
              ],
            ),
            // 1. FADE ANIMATION
            _buildAnimationCard(
              title: '1. Fade Animation',
              description: 'Smoothly fades in from transparent to opaque',
              useCase: '✓ Page transitions\n✓ Loading states\n✓ Dialog appearances\n✓ Toast notifications',
              animation: FadeTransition(
                opacity: _fadeAnimation,
                child: _buildAnimatedBox('Fade'),
              ),
              onPressed: _playFadeAnimation,
            ),

            // 2. SCALE ANIMATION
            _buildAnimationCard(
              title: '2. Scale Animation',
              description: 'Scales from small to full size with elastic effect',
              useCase: '✓ Button press feedback\n✓ Item selection\n✓ Pop-up modals\n✓ Add to cart animation',
              animation: ScaleTransition(
                scale: _scaleAnimation,
                child: _buildAnimatedBox('Scale'),
              ),
              onPressed: _playScaleAnimation,
            ),

            // 3. ROTATE ANIMATION
            _buildAnimationCard(
              title: '3. Rotate Animation',
              description: 'Rotates 360 degrees (2π radians)',
              useCase: '✓ Refresh indicators\n✓ Loading spinners\n✓ Icon state changes\n✓ Image carousel transitions',
              animation: AnimatedBuilder(
                animation: _rotateAnimation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _rotateAnimation.value,
                    child: _buildAnimatedBox('Rotate'),
                  );
                },
              ),
              onPressed: _playRotateAnimation,
            ),

            // 4. SLIDE ANIMATION
            _buildAnimationCard(
              title: '4. Slide Animation (Left)',
              description: 'Slides in from left to center',
              useCase: '✓ Side drawer navigation\n✓ List item entry\n✓ Notification banners\n✓ Form field reveals',
              animation: SlideTransition(
                position: _slideAnimation,
                child: _buildAnimatedBox('Slide'),
              ),
              onPressed: _playSlideAnimation,
            ),

            // 5. BOUNCE ANIMATION
            _buildAnimationCard(
              title: '5. Bounce Animation',
              description: 'Bounces in with bounceOut curve',
              useCase: '✓ Success confirmations\n✓ Badge notifications\n✓ New message alerts\n✓ Achievement unlocks',
              animation: ScaleTransition(
                scale: _bounceAnimation,
                child: _buildAnimatedBox('Bounce'),
              ),
              onPressed: _playBounceAnimation,
            ),

            // 6. FLIP ANIMATION
            _buildAnimationCard(
              title: '6. Flip Animation (3D)',
              description: 'Flips around Y-axis in 3D space',
              useCase: '✓ Card reveal (front/back)\n✓ Product image flip\n✓ Quiz answer reveal\n✓ Memory game cards',
              animation: AnimatedBuilder(
                animation: _flipAnimation,
                builder: (context, child) {
                  return Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(_flipAnimation.value),
                    child: _buildAnimatedBox('Flip'),
                  );
                },
              ),
              onPressed: _playFlipAnimation,
            ),

            // 7. SHAKE ANIMATION
            _buildAnimationCard(
              title: '7. Shake Animation',
              description: 'Shakes horizontally back and forth',
              useCase: '✓ Form validation errors\n✓ Wrong password feedback\n✓ Attention grabber\n✓ Delete confirmation',
              animation: AnimatedBuilder(
                animation: _shakeAnimation,
                builder: (context, child) {
                  final offset = math.sin(_shakeAnimation.value * math.pi * 4) * 20;
                  return Transform.translate(
                    offset: Offset(offset, 0),
                    child: _buildAnimatedBox('Shake'),
                  );
                },
              ),
              onPressed: _playShakeAnimation,
            ),

            // 8. PULSE ANIMATION
            _buildAnimationCard(
              title: '8. Pulse Animation',
              description: 'Pulses by scaling up and down',
              useCase: '✓ Live indicators\n✓ Recording status\n✓ Active call icon\n✓ Heart/Like button',
              animation: ScaleTransition(
                scale: _pulseAnimation,
                child: _buildAnimatedBox('Pulse'),
              ),
              onPressed: _playPulseAnimation,
            ),

            // 9. COLOR ANIMATION
            _buildAnimationCard(
              title: '9. Color Animation',
              description: 'Transitions from blue to red and back',
              useCase: '✓ Theme switching\n✓ Status changes (inactive/active)\n✓ Progress indicators\n✓ Mood/rating selectors',
              animation: AnimatedBuilder(
                animation: _colorAnimation,
                builder: (context, child) {
                  return Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: _colorAnimation.value,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Color',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
              onPressed: _playColorAnimation,
            ),

            // 10. SIZE ANIMATION
            _buildAnimationCard(
              title: '10. Size Animation',
              description: 'Changes size from 100x100 to 200x200',
              useCase: '✓ Expand/collapse panels\n✓ Image zoom preview\n✓ Widget resize on focus\n✓ Responsive layouts',
              animation: AnimatedBuilder(
                animation: _sizeAnimation,
                builder: (context, child) {
                  return Container(
                    width: _sizeAnimation.value,
                    height: _sizeAnimation.value,
                    decoration: BoxDecoration(
                      color: Colors.purple,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Size',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
              onPressed: _playSizeAnimation,
            ),

            // 11. OPACITY + SCALE COMBINED
            _buildAnimationCard(
              title: '11. Opacity + Scale Combined',
              description: 'Fades in while scaling up simultaneously',
              useCase: '✓ Modal/Dialog entry\n✓ Onboarding screens\n✓ Feature highlights\n✓ Splash screen elements',
              animation: AnimatedBuilder(
                animation: _opacityScaleController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _opacityAnimation.value,
                    child: Transform.scale(
                      scale: _opacityAnimation.value,
                      child: _buildAnimatedBox('Combo'),
                    ),
                  );
                },
              ),
              onPressed: _playOpacityScaleAnimation,
            ),

            // 12. ELASTIC ANIMATION
            _buildAnimationCard(
              title: '12. Elastic Animation',
              description: 'Bounces with elastic curve effect',
              useCase: '✓ Button feedback\n✓ Playful interactions\n✓ Game elements\n✓ Reward animations',
              animation: ScaleTransition(
                scale: _elasticAnimation,
                child: _buildAnimatedBox('Elastic'),
              ),
              onPressed: _playElasticAnimation,
            ),

            // 13. WAVE ANIMATION
            _buildAnimationCard(
              title: '13. Wave Animation',
              description: 'Creates smooth wave motion',
              useCase: '✓ Audio visualizers\n✓ Water/ocean effects\n✓ Loading animations\n✓ Background effects',
              animation: AnimatedBuilder(
                animation: _waveAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, math.sin(_waveAnimation.value * 4 * math.pi) * 20),
                    child: _buildAnimatedBox('Wave'),
                  );
                },
              ),
              onPressed: _playWaveAnimation,
            ),

            // 14. GLOW ANIMATION
            _buildAnimationCard(
              title: '14. Glow Animation',
              description: 'Pulsating glow effect around object',
              useCase: '✓ Highlight featured items\n✓ Active selection\n✓ Power-up effects\n✓ Premium badges',
              animation: AnimatedBuilder(
                animation: _glowAnimation,
                builder: (context, child) {
                  return Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withOpacity(0.6),
                          blurRadius: _glowAnimation.value,
                          spreadRadius: _glowAnimation.value / 3,
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Glow',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
              onPressed: _playGlowAnimation,
            ),

            // 15. SPIN ANIMATION
            _buildAnimationCard(
              title: '15. Spin Animation (2 Rotations)',
              description: 'Continuous spinning motion',
              useCase: '✓ Loading indicators\n✓ Processing status\n✓ Settings gear icon\n✓ Sync animations',
              animation: AnimatedBuilder(
                animation: _spinAnimation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _spinAnimation.value,
                    child: _buildAnimatedBox('Spin', icon: Icons.sync),
                  );
                },
              ),
              onPressed: _playSpinAnimation,
            ),

            // 16. SWING ANIMATION
            _buildAnimationCard(
              title: '16. Swing Animation',
              description: 'Swings like a pendulum',
              useCase: '✓ Notification bells\n✓ Hanging tags\n✓ Delete/archive actions\n✓ Playful UI elements',
              animation: AnimatedBuilder(
                animation: _swingAnimation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _swingAnimation.value,
                    child: _buildAnimatedBox('Swing', icon: Icons.notifications),
                  );
                },
              ),
              onPressed: _playSwingAnimation,
            ),

            // 17. ZOOM ANIMATION
            _buildAnimationCard(
              title: '17. Zoom Animation',
              description: 'Quick zoom in and out',
              useCase: '✓ Image preview\n✓ Focus attention\n✓ Like/favorite button\n✓ Product quick view',
              animation: ScaleTransition(
                scale: _zoomAnimation,
                child: _buildAnimatedBox('Zoom'),
              ),
              onPressed: _playZoomAnimation,
            ),

            // 18. WIGGLE ANIMATION
            _buildAnimationCard(
              title: '18. Wiggle Animation',
              description: 'Rotates back and forth quickly',
              useCase: '✓ Delete mode (iOS style)\n✓ Edit mode indicators\n✓ Grab attention\n✓ Incorrect input',
              animation: AnimatedBuilder(
                animation: _wiggleAnimation,
                builder: (context, child) {
                  final angle = math.sin(_wiggleAnimation.value * math.pi * 8) * 0.1;
                  return Transform.rotate(
                    angle: angle,
                    child: _buildAnimatedBox('Wiggle'),
                  );
                },
              ),
              onPressed: _playWiggleAnimation,
            ),

            // 19. BREATHE ANIMATION
            _buildAnimationCard(
              title: '19. Breathe Animation',
              description: 'Subtle pulsing scale (breathing effect)',
              useCase: '✓ Meditation apps\n✓ Microphone active\n✓ Live streaming\n✓ Subtle status indicators',
              animation: ScaleTransition(
                scale: _breatheAnimation,
                child: _buildAnimatedBox('Breathe', icon: Icons.mic),
              ),
              onPressed: _playBreatheAnimation,
            ),

            // 20. RIPPLE ANIMATION
            _buildAnimationCard(
              title: '20. Ripple Animation',
              description: 'Expanding circle ripple effect',
              useCase: '✓ Touch feedback\n✓ Sonar/radar effects\n✓ Location pings\n✓ Water drop effects',
              animation: AnimatedBuilder(
                animation: _rippleAnimation,
                builder: (context, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 150 * _rippleAnimation.value,
                        height: 150 * _rippleAnimation.value,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.blue.withOpacity(1 - _rippleAnimation.value),
                            width: 2,
                          ),
                        ),
                      ),
                      _buildAnimatedBox('Ripple', width: 80, height: 80),
                    ],
                  );
                },
              ),
              onPressed: _playRippleAnimation,
            ),

            // 21. MORPH ANIMATION
            _buildAnimationCard(
              title: '21. Morph Animation',
              description: 'Shape morphs from square to circle',
              useCase: '✓ Shape transitions\n✓ Profile avatar changes\n✓ Button state changes\n✓ Design morphing',
              animation: AnimatedBuilder(
                animation: _morphAnimation,
                builder: (context, child) {
                  return Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.teal, Colors.teal.shade700],
                      ),
                      borderRadius: _morphAnimation.value,
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Morph',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
              onPressed: _playMorphAnimation,
            ),

            // 22. BLUR ANIMATION
            _buildAnimationCard(
              title: '22. Blur Animation',
              description: 'Blurs and unblurs the content',
              useCase: '✓ Focus/unfocus states\n✓ Background blur\n✓ Loading states\n✓ Privacy/spoiler content',
              animation: AnimatedBuilder(
                animation: _blurAnimation,
                builder: (context, child) {
                  return ImageFiltered(
                    imageFilter: ImageFilter.blur(
                      sigmaX: _blurAnimation.value,
                      sigmaY: _blurAnimation.value,
                    ),
                    child: _buildAnimatedBox('Blur'),
                  );
                },
              ),
              onPressed: _playBlurAnimation,
            ),

            // 23. CARD FLIP ANIMATION
            _buildAnimationCard(
              title: '23. Card Flip (with content)',
              description: 'Flips card to reveal back content',
              useCase: '✓ Credit card displays\n✓ Flashcards\n✓ Product details\n✓ Two-sided info cards',
              animation: AnimatedBuilder(
                animation: _cardFlipAnimation,
                builder: (context, child) {
                  final isFront = _cardFlipAnimation.value < math.pi / 2;
                  return Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(_cardFlipAnimation.value),
                    child: isFront
                        ? _buildCardSide('FRONT', Colors.indigo, Icons.credit_card)
                        : Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.rotationY(math.pi),
                      child: _buildCardSide('BACK', Colors.deepOrange, Icons.lock),
                    ),
                  );
                },
              ),
              onPressed: _playCardFlipAnimation,
            ),

            // 24. SLIDE UP ANIMATION
            _buildAnimationCard(
              title: '24. Slide Up Animation',
              description: 'Slides in from bottom to center',
              useCase: '✓ Bottom sheets\n✓ Snackbars\n✓ Modal dialogs\n✓ Keyboard appearance',
              animation: SlideTransition(
                position: _slideUpAnimation,
                child: _buildAnimatedBox('Slide Up'),
              ),
              onPressed: _playSlideUpAnimation,
            ),

            // 25. SLIDE DOWN ANIMATION
            _buildAnimationCard(
              title: '25. Slide Down Animation',
              description: 'Slides in from top to center',
              useCase: '✓ Notification banners\n✓ Top alerts\n✓ Dropdown menus\n✓ App bar reveal',
              animation: SlideTransition(
                position: _slideDownAnimation,
                child: _buildAnimatedBox('Slide Down'),
              ),
              onPressed: _playSlideDownAnimation,
            ),

            const SizedBox(height: 20),

            // IMPLICIT ANIMATIONS SECTION
            _buildImplicitAnimationsSection(),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimationCard({
    required String title,
    required String description,
    required String useCase,
    required Widget animation,
    required VoidCallback onPressed,
  }) {
    return Card(
      elevation: 4,
      color: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style:  TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb_outline, size: 16, color: Colors.blue.shade700),
                      const SizedBox(width: 6),
                      Text(
                        'Where to use:',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    useCase,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.text,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Container(
                height: 180,
                alignment: Alignment.center,
                child: animation,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onPressed,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Play Animation'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedBox(String text, {IconData? icon, double width = 150, double height = 150}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue, Colors.blue.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 32, color: Colors.white),
            const SizedBox(height: 8),
          ],
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardSide(String text, Color color, IconData icon) {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color!.withBlue(3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: Colors.white),
          const SizedBox(height: 8),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImplicitAnimationsSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '26. Implicit Animations',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'AnimatedContainer, AnimatedOpacity, etc.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Text(
                '✓ Settings panels\n✓ Expandable cards\n✓ Dynamic layouts\n✓ State-based UI changes',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[800],
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const ImplicitAnimationsDemo(),
          ],
        ),
      ),
    );
  }
}

// Implicit Animations Demo remains the same
class ImplicitAnimationsDemo extends StatefulWidget {
  const ImplicitAnimationsDemo({Key? key}) : super(key: key);

  @override
  State<ImplicitAnimationsDemo> createState() => _ImplicitAnimationsDemoState();
}

class _ImplicitAnimationsDemoState extends State<ImplicitAnimationsDemo> {
  bool _isExpanded = false;
  double _opacity = 1.0;
  Alignment _alignment = Alignment.centerLeft;

  void _toggleAnimations() {
    setState(() {
      _isExpanded = !_isExpanded;
      _opacity = _isExpanded ? 0.3 : 1.0;
      _alignment = _isExpanded ? Alignment.centerRight : Alignment.centerLeft;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [




        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          width: _isExpanded ? 300 : 150,
          height: _isExpanded ? 200 : 150,
          decoration: BoxDecoration(
            color: _isExpanded ? Colors.orange : Colors.green,
            borderRadius: BorderRadius.circular(_isExpanded ? 20 : 12),
          ),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 500),
            opacity: _opacity,
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 500),
              alignment: _alignment,
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Implicit',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _toggleAnimations,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Toggle Implicit Animations'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}