import 'dart:math';
import 'package:flutter/material.dart';
import 'login_page.dart';

class TagItem {
  final String text;
  final Color color;
  final double left;
  final double top;
  final double rotate;
  final double width;
  final double height;
  final bool isAnimated;

  const TagItem(
    this.text,
    this.color, {
    required this.left,
    required this.top,
    required this.rotate,
    required this.width,
    required this.height,
    this.isAnimated = false,
  });
}

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with TickerProviderStateMixin {
  // Update warna-warna utama
  final Color primaryColor = const Color(0xFF6B57D2); // Ungu tua
  final Color backgroundColor = Colors.white;
  final Color surfaceColor = const Color(0xFFF5F5F5); // Abu-abu sangat muda
  final Color accentColor = const Color(0xFF8F7DE0); // Ungu muda
  final Color textColor = const Color(0xFF2D3142); // Hitam kebiruan
  final Color secondaryTextColor = const Color(0xFF9BA0B3); // Abu-abu

  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late AnimationController _loadingController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _loadingAnimation;

  bool _isLoading = false;
  final List<Color> _loadingColors = [
    const Color(0xFF6B57D2), // Ungu tua
    const Color(0xFF8F7DE0), // Ungu muda
    const Color(0xFFA594E8), // Ungu lebih muda
    const Color(0xFFBBACEF), // Ungu paling muda
  ];

  final List<IconData> fallingIcons = [
    Icons.pregnant_woman,
    Icons.child_care,
    Icons.favorite,
    Icons.medical_services,
    Icons.local_hospital,
    Icons.health_and_safety,
    Icons.healing,
    Icons.monitor_heart,
    Icons.medication,
    Icons.baby_changing_station,
  ];

  final List<FallingIcon> _fallingIcons = [];
  final Random random = Random();

  final List<TagItem> tags = [
    const TagItem(
      'Kesehatan Ibu',
      Color(0xFF6B57D2),
      left: 40,
      top: 180,
      rotate: -0.2,
      width: 160,
      height: 45,
      isAnimated: true,
    ),
    const TagItem(
      'Kehamilan',
      Color(0xFF8F7DE0),
      left: 220,
      top: 140,
      rotate: 0.1,
      width: 180,
      height: 45,
      isAnimated: true,
    ),
    const TagItem(
      'Nutrisi',
      Color(0xFF6B57D2),
      left: 30,
      top: 240,
      rotate: 0.15,
      width: 140,
      height: 45,
      isAnimated: true,
    ),
    const TagItem(
      'Edukasi',
      Color(0xFF8F7DE0),
      left: 190,
      top: 220,
      rotate: -0.1,
      width: 130,
      height: 45,
      isAnimated: true,
    ),
    const TagItem(
      'Konsultasi',
      Color(0xFF6B57D2),
      left: 50,
      top: 300,
      rotate: 0.1,
      width: 120,
      height: 45,
      isAnimated: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startLoadingSequence();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_fallingIcons.isEmpty) {
      _startFallingIcons();
    }
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _rotateAnimation = Tween<double>(
      begin: 0,
      end: 2 * pi,
    ).animate(CurvedAnimation(
      parent: _rotateController,
      curve: Curves.linear,
    ));

    _loadingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _loadingController,
      curve: Curves.easeInOut,
    ));

    _fadeController.forward();
  }

  void _startFallingIcons() {
    final screenWidth = MediaQuery.of(context).size.width;
    for (int i = 0; i < 20; i++) {
      _fallingIcons.add(FallingIcon(
        icon: fallingIcons[random.nextInt(fallingIcons.length)],
        startPos: random.nextDouble() * screenWidth,
        speed: 1 + random.nextDouble() * 3,
        size: 15 + random.nextDouble() * 25,
        delay: random.nextDouble() * 5,
        rotationSpeed: random.nextDouble() * 0.1,
      ));
    }
  }

  void _startLoadingSequence() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _isLoading = true);
        _loadingController.repeat();

        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const LoginPage(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              transitionDuration: const Duration(milliseconds: 800),
            ),
          );
        });
      }
    });
  }

  Widget _buildLogo() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            RotationTransition(
              turns: _rotateAnimation,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.pregnant_woman, // Ikon kehamilan
                  size: 28,
                  color: primaryColor,
                ),
              ),
            ),
            const SizedBox(width: 15),
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [primaryColor, accentColor],
              ).createShader(bounds),
              child: Text(
                'Hadomi Inan',
                style: TextStyle(
                  color: textColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [primaryColor, accentColor],
              stops: const [0.2, 0.8],
            ).createShader(bounds),
            child: Text(
              'Kesehatan Ibu & Anak',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: textColor,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            'Mendampingi Perjalanan\nKehamilan Anda',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              color: textColor.withOpacity(0.9),
              height: 1.5,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        width: _isLoading ? 100 : 0,
        height: _isLoading ? 100 : 0,
        child: RotationTransition(
          turns: _loadingAnimation,
          child: CustomPaint(
            painter: LoadingPainter(
              colors: _loadingColors,
              strokeWidth: 4,
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                strokeWidth: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white,
                  const Color(0xFFF5F5F5),
                  primaryColor.withOpacity(0.05),
                ],
              ),
            ),
          ),
          ..._fallingIcons.map((fallingIcon) => FallingIconAnimation(
                fallingIcon: fallingIcon,
                color: accentColor,
              )),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildLogo(),
                    const Spacer(),
                    _buildContent(),
                    const SizedBox(height: 30),
                    _buildLoading(),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ),
          ...tags.map((tag) => AnimatedTagWrapper(tag)).toList(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    _rotateController.dispose();
    _loadingController.dispose();
    super.dispose();
  }
}

class LoadingPainter extends CustomPainter {
  final List<Color> colors;
  final double strokeWidth;

  LoadingPainter({
    required this.colors,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double radius = min(centerX, centerY) - strokeWidth;

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < colors.length; i++) {
      final double startAngle = (i * pi / 2) + (pi / 6);
      final double sweepAngle = pi / 3;

      paint.color = colors[i];
      canvas.drawArc(
        Rect.fromCircle(center: Offset(centerX, centerY), radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(LoadingPainter oldDelegate) => true;
}

class AnimatedTagWrapper extends StatefulWidget {
  final TagItem tag;

  const AnimatedTagWrapper(this.tag, {Key? key}) : super(key: key);

  @override
  State<AnimatedTagWrapper> createState() => _AnimatedTagWrapperState();
}

class _AnimatedTagWrapperState extends State<AnimatedTagWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    ));

    _rotateAnimation = Tween<double>(
      begin: widget.tag.rotate - 0.2,
      end: widget.tag.rotate,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.4, 1.0, curve: Curves.easeInOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(-0.5, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    ));

    if (widget.tag.isAnimated) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.tag.left,
      top: widget.tag.top,
      child: SlideTransition(
        position: _slideAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Transform.rotate(
            angle: _rotateAnimation.value,
            child: Container(
              width: widget.tag.width,
              height: widget.tag.height,
              decoration: BoxDecoration(
                color: widget.tag.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: widget.tag.color.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  widget.tag.text,
                  style: TextStyle(
                    color: widget.tag.color,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FallingIcon {
  final IconData icon;
  final double startPos;
  final double speed;
  final double size;
  final double delay;
  final double rotationSpeed;
  double currentPos = 0;
  double rotation = 0;

  FallingIcon({
    required this.icon,
    required this.startPos,
    required this.speed,
    required this.size,
    required this.delay,
    required this.rotationSpeed,
  });
}

class FallingIconAnimation extends StatefulWidget {
  final FallingIcon fallingIcon;
  final Color color;

  const FallingIconAnimation({
    Key? key,
    required this.fallingIcon,
    required this.color,
  }) : super(key: key);

  @override
  State<FallingIconAnimation> createState() => _FallingIconAnimationState();
}

class _FallingIconAnimationState extends State<FallingIconAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    Future.delayed(Duration(seconds: widget.fallingIcon.delay.toInt()), () {
      if (mounted) {
        _startAnimation();
      }
    });
  }

  void _startAnimation() {
    if (mounted) {
      _controller.addListener(() {
        setState(() {
          widget.fallingIcon.currentPos += widget.fallingIcon.speed;
          widget.fallingIcon.rotation += widget.fallingIcon.rotationSpeed;

          if (widget.fallingIcon.currentPos >
              MediaQuery.of(context).size.height) {
            widget.fallingIcon.currentPos = 0;
          }
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.fallingIcon.startPos,
      top: widget.fallingIcon.currentPos,
      child: Transform.rotate(
        angle: widget.fallingIcon.rotation,
        child: Icon(
          widget.fallingIcon.icon,
          size: widget.fallingIcon.size,
          color: widget.color.withOpacity(0.2),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
