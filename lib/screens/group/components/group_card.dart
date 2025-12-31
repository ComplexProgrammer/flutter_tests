import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tests/constants.dart';
import 'package:flutter_tests/models/group.dart';
import 'package:flutter_tests/screens/book/book_screen.dart';

class GroupCard extends StatefulWidget {
  final Group group;

  const GroupCard({super.key, required this.group});

  @override
  State<GroupCard> createState() => _GroupCardState();
}

class _GroupCardState extends State<GroupCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: kAnimationDurationFast,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) => Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          ),
          child: OpenContainer(
            closedElevation: 0,
            openElevation: 0,
            closedColor: Colors.transparent,
            openColor: Colors.transparent,
            transitionDuration: const Duration(milliseconds: 500),
            closedBuilder: (context, action) => _buildGroupCard(context),
            openBuilder: (context, action) => BookScreen(group: widget.group),
          ),
        ),
      ),
    );
  }

  Widget _buildGroupCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(kCardBorderRadius),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 10),
            blurRadius: 30,
            spreadRadius: -5,
            color: kPrimaryColor.withOpacity(_isPressed ? 0.3 : 0.15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(kCardBorderRadius),
        child: Stack(
          children: [
            // Main content
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 2,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Image
                      (widget.group.image != null &&
                              widget.group.image!.isNotEmpty)
                          ? Image.network(
                              "$baseUrl/media/${widget.group.image}",
                              fit: BoxFit.contain,
                            )
                          : Image.asset(
                              'assets/images/img.png',
                              fit: BoxFit.contain,
                            ),
                      // Gradient overlay
                      Container(
                        decoration: const BoxDecoration(
                          gradient: kDarkOverlayGradient,
                        ),
                      ),
                    ],
                  ),
                ),
                // Glassmorphism title container
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(
                        color: kPrimaryColor.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Accent indicator
                      Container(
                        width: 4,
                        height: 24,
                        decoration: BoxDecoration(
                          gradient: kPremiumGradient,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.group.name_uz_uz ?? '',
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: kTextColor,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      // Arrow icon
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: kPrimaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          size: 18,
                          color: kPrimaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Hover effect overlay
            if (_isPressed)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: kPrimaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(kCardBorderRadius),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
