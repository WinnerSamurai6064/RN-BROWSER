import 'dart:ui';

import 'package:flutter/material.dart';

void main() {
  runApp(const RnBrowserApp());
}

class RnBrowserApp extends StatelessWidget {
  const RnBrowserApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RN Browser',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: RnColors.black,
        colorScheme: ColorScheme.fromSeed(
          seedColor: RnColors.lemon,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const RnShell(),
    );
  }
}

class RnColors {
  static const black = Color(0xFF050705);
  static const panel = Color(0xCC10160F);
  static const panelStrong = Color(0xEE111A10);
  static const lemon = Color(0xFFC7FF3A);
  static const cyan = Color(0xFF50F6D7);
  static const pink = Color(0xFFFF4FD2);
  static const border = Color(0x553CFF68);
}

class RnShell extends StatefulWidget {
  const RnShell({super.key});

  @override
  State<RnShell> createState() => _RnShellState();
}

class _RnShellState extends State<RnShell> {
  int index = 0;
  String profile = 'My Space';

  @override
  Widget build(BuildContext context) {
    final pages = [
      StartScreen(onStart: () => setState(() => index = 1)),
      BrowserScreen(profile: profile, onProfileChanged: (v) => setState(() => profile = v)),
      SettingsScreen(profile: profile, onProfileChanged: (v) => setState(() => profile = v)),
    ];

    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: RnGlassNav(index: index, onChanged: (v) => setState(() => index = v)),
    );
  }
}

class GlassPanel extends StatelessWidget {
  const GlassPanel({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.radius = 26});

  final Widget child;
  final EdgeInsets padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: RnColors.panel,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: RnColors.border, width: 1.2),
            boxShadow: const [BoxShadow(color: Color(0x331DFF75), blurRadius: 22, spreadRadius: 1)],
          ),
          child: child,
        ),
      ),
    );
  }
}

class StartScreen extends StatelessWidget {
  const StartScreen({super.key, required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RnColors.black,
      body: Stack(
        children: [
          const StartBackdrop(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 112),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const BrandRow(),
                  const SizedBox(height: 18),
                  const Expanded(child: HeroCard()),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 62,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: RnColors.lemon,
                        foregroundColor: Colors.black,
                        shape: const StadiumBorder(),
                      ),
                      onPressed: onStart,
                      child: const Text('Start Secure Browsing', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.sync_lock_rounded, size: 18),
                      label: const Text('Login / Sync'),
                      style: TextButton.styleFrom(foregroundColor: RnColors.lemon),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StartBackdrop extends StatelessWidget {
  const StartBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(center: Alignment.topRight, radius: 1.1, colors: [Color(0x443CFF68), Color(0x00000000)]),
            ),
          ),
        ),
        Positioned(top: 95, right: -60, child: GlowBlob(size: 240, color: RnColors.lemon)),
        Positioned(bottom: 130, left: -80, child: GlowBlob(size: 220, color: RnColors.cyan)),
      ],
    );
  }
}

class GlowBlob extends StatelessWidget {
  const GlowBlob({super.key, required this.size, required this.color});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color.withOpacity(.13), boxShadow: [BoxShadow(color: color.withOpacity(.22), blurRadius: 80, spreadRadius: 16)]),
    );
  }
}

class BrandRow extends StatelessWidget {
  const BrandRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const GlassPanel(radius: 18, padding: EdgeInsets.all(12), child: Icon(Icons.shield_rounded, color: RnColors.lemon)),
        const SizedBox(width: 12),
        const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('RN', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
          Text('Liquid privacy browser', style: TextStyle(color: Colors.white60, fontSize: 12)),
        ]),
        const Spacer(),
        GlassPanel(radius: 999, padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8), child: const Text('Beta 0.5', style: TextStyle(color: RnColors.lemon, fontWeight: FontWeight.w900))),
      ],
    );
  }
}

class HeroCard extends StatelessWidget {
  const HeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      radius: 34,
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(34),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network('https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=1200&q=80', fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: const Color(0xFF0D150D))),
            Container(decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x22000000), Color(0xEE050705)]))),
            Positioned(
              left: 22,
              right: 22,
              bottom: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Secure spaces for shared phones', style: TextStyle(fontSize: 37, height: .98, fontWeight: FontWeight.w900)),
                  SizedBox(height: 14),
                  Text('My Space and Guest Space keep sessions separated with secure defaults.', style: TextStyle(color: Colors.white70, fontSize: 15, height: 1.35)),
                  SizedBox(height: 15),
                  Wrap(spacing: 9, runSpacing: 9, children: [FeaturePill(label: '2 Spaces'), FeaturePill(label: 'Secure'), FeaturePill(label: 'No forced login'), FeaturePill(label: 'Glass UI')]),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class FeaturePill extends StatelessWidget {
  const FeaturePill({super.key, required this.label});
  final String label;
  @override
  Widget build(BuildContext context) => GlassPanel(radius: 999, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)));
}
