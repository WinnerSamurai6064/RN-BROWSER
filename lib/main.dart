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
        colorScheme: ColorScheme.fromSeed(seedColor: RnColors.lemon, brightness: Brightness.dark),
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
                      style: FilledButton.styleFrom(backgroundColor: RnColors.lemon, foregroundColor: Colors.black, shape: const StadiumBorder()),
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
        Positioned.fill(child: Container(decoration: const BoxDecoration(gradient: RadialGradient(center: Alignment.topRight, radius: 1.1, colors: [Color(0x443CFF68), Color(0x00000000)])))),
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
    return Container(width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, color: color.withOpacity(.13), boxShadow: [BoxShadow(color: color.withOpacity(.22), blurRadius: 80, spreadRadius: 16)]));
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
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                Text('Secure spaces for shared phones', style: TextStyle(fontSize: 37, height: .98, fontWeight: FontWeight.w900)),
                SizedBox(height: 14),
                Text('My Space and Guest Space keep sessions separated with secure defaults.', style: TextStyle(color: Colors.white70, fontSize: 15, height: 1.35)),
                SizedBox(height: 15),
                Wrap(spacing: 9, runSpacing: 9, children: [FeaturePill(label: '2 Spaces'), FeaturePill(label: 'Secure'), FeaturePill(label: 'No forced login'), FeaturePill(label: 'Glass UI')]),
              ]),
            )
          ],
        ),
      ),
    );
  }
}

class BrowserScreen extends StatefulWidget {
  const BrowserScreen({super.key, required this.profile, required this.onProfileChanged});
  final String profile;
  final ValueChanged<String> onProfileChanged;

  @override
  State<BrowserScreen> createState() => _BrowserScreenState();
}

class _BrowserScreenState extends State<BrowserScreen> {
  final TextEditingController address = TextEditingController(text: 'https://duckduckgo.com');
  final List<String> history = ['https://duckduckgo.com'];
  int pointer = 0;
  bool menuOpen = false;

  String get url => history[pointer];
  bool get canBack => pointer > 0;
  bool get canForward => pointer < history.length - 1;

  @override
  void dispose() {
    address.dispose();
    super.dispose();
  }

  void openAddress() {
    final raw = address.text.trim();
    if (raw.isEmpty) return;
    final next = raw.startsWith('http://') || raw.startsWith('https://') ? raw : 'https://duckduckgo.com/?q=${Uri.encodeComponent(raw)}';
    setState(() {
      if (pointer < history.length - 1) history.removeRange(pointer + 1, history.length);
      history.add(next);
      pointer = history.length - 1;
      address.text = next;
    });
  }

  void goBack() => setState(() { if (canBack) { pointer--; address.text = url; } });
  void goForward() => setState(() { if (canForward) { pointer++; address.text = url; } });
  void goHome() => setState(() { history.add('https://duckduckgo.com'); pointer = history.length - 1; address.text = url; });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RnColors.black,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                  child: BrowserTopBar(profile: widget.profile, onProfileChanged: widget.onProfileChanged, address: address, onSubmit: openAddress, onMenu: () => setState(() => menuOpen = true)),
                ),
                Expanded(child: BrowserPreview(url: url, profile: widget.profile)),
              ],
            ),
          ),
          Positioned(left: 18, right: 18, bottom: 98, child: BrowserControls(canBack: canBack, canForward: canForward, onBack: goBack, onForward: goForward, onHome: goHome, onRefresh: openAddress)),
          if (menuOpen) SlideMenu(onClose: () => setState(() => menuOpen = false)),
        ],
      ),
    );
  }
}

class BrowserTopBar extends StatelessWidget {
  const BrowserTopBar({super.key, required this.profile, required this.onProfileChanged, required this.address, required this.onSubmit, required this.onMenu});
  final String profile;
  final ValueChanged<String> onProfileChanged;
  final TextEditingController address;
  final VoidCallback onSubmit;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(children: [
        ProfileChip(label: 'My Space', selected: profile == 'My Space', onTap: () => onProfileChanged('My Space')),
        const SizedBox(width: 8),
        ProfileChip(label: 'Guest Space', selected: profile == 'Guest Space', onTap: () => onProfileChanged('Guest Space')),
      ]),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(
          child: GlassPanel(
            radius: 999,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: TextField(
              controller: address,
              onSubmitted: (_) => onSubmit(),
              textInputAction: TextInputAction.go,
              decoration: const InputDecoration(border: InputBorder.none, prefixIcon: Icon(Icons.lock_rounded, color: RnColors.lemon), hintText: 'Search or enter address'),
            ),
          ),
        ),
        const SizedBox(width: 10),
        GlassPanel(radius: 18, padding: EdgeInsets.zero, child: IconButton(onPressed: onMenu, icon: const Icon(Icons.menu_rounded, color: RnColors.lemon))),
      ]),
    ]);
  }
}

class BrowserPreview extends StatelessWidget {
  const BrowserPreview({super.key, required this.url, required this.profile});
  final String url;
  final String profile;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 178),
      child: GlassPanel(
        radius: 28,
        padding: const EdgeInsets.all(18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [const Icon(Icons.public_rounded, color: RnColors.lemon), const SizedBox(width: 8), Expanded(child: Text(url, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800)))]),
          const SizedBox(height: 18),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), gradient: const LinearGradient(colors: [Color(0xFF101910), Color(0xFF070A07)]), border: Border.all(color: RnColors.border)),
              padding: const EdgeInsets.all(18),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(profile, style: const TextStyle(color: RnColors.lemon, fontWeight: FontWeight.w900)),
                const SizedBox(height: 12),
                const Text('RN beta browser canvas', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
                const SizedBox(height: 12),
                const Text('This shell is ready for WebView wiring. It already includes liquid glass styling, profiles, URL input, settings toggles, menu, and Android-style navigation controls.', style: TextStyle(color: Colors.white70, height: 1.4)),
                const Spacer(),
                const Wrap(spacing: 10, runSpacing: 10, children: [FeaturePill(label: 'Location Shield'), FeaturePill(label: 'Files'), FeaturePill(label: 'Mic Control'), FeaturePill(label: 'Zoom Rules')]),
              ]),
            ),
          )
        ]),
      ),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.profile, required this.onProfileChanged});
  final String profile;
  final ValueChanged<String> onProfileChanged;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool mic = false;
  bool files = true;
  bool region = false;
  bool pinchAllowList = true;
  bool clearOnExit = true;
  double zoom = 100;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RnColors.black,
      body: SafeArea(
        child: ListView(padding: const EdgeInsets.fromLTRB(18, 18, 18, 112), children: [
          const Text('Settings', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          Row(children: [ProfileChip(label: 'My Space', selected: widget.profile == 'My Space', onTap: () => widget.onProfileChanged('My Space')), const SizedBox(width: 8), ProfileChip(label: 'Guest Space', selected: widget.profile == 'Guest Space', onTap: () => widget.onProfileChanged('Guest Space'))]),
          const SizedBox(height: 16),
          ToggleCard(title: 'Access to mic', subtitle: 'Let selected websites request microphone access.', value: mic, onChanged: (v) => setState(() => mic = v)),
          ToggleCard(title: 'Access gallery/files', subtitle: 'Allow uploads from Android gallery or file picker.', value: files, onChanged: (v) => setState(() => files = v)),
          ToggleCard(title: 'Region mode', subtitle: 'Use browser region mode instead of real location by default.', value: region, onChanged: (v) => setState(() => region = v)),
          ToggleCard(title: 'Pinch zoom allowlist', subtitle: 'Pinch to zoom only on selected websites.', value: pinchAllowList, onChanged: (v) => setState(() => pinchAllowList = v)),
          ToggleCard(title: 'Clear on exit', subtitle: 'Clear temporary browsing data when leaving a space.', value: clearOnExit, onChanged: (v) => setState(() => clearOnExit = v)),
          const SizedBox(height: 12),
          GlassPanel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Region zoom', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            Text('${zoom.round()}%', style: const TextStyle(color: Colors.white70)),
            Slider(min: 50, max: 150, value: zoom, activeColor: RnColors.lemon, onChanged: (v) => setState(() => zoom = v)),
          ])),
        ]),
      ),
    );
  }
}

class ToggleCard extends StatelessWidget {
  const ToggleCard({super.key, required this.title, required this.subtitle, required this.value, required this.onChanged});
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.only(bottom: 12), child: GlassPanel(child: SwitchListTile(value: value, onChanged: onChanged, activeColor: RnColors.lemon, title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)), subtitle: Text(subtitle))));
  }
}

class ProfileChip extends StatelessWidget {
  const ProfileChip({super.key, required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(999), child: Container(padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9), decoration: BoxDecoration(color: selected ? RnColors.lemon : Colors.white10, borderRadius: BorderRadius.circular(999), border: Border.all(color: selected ? RnColors.lemon : Colors.white24)), child: Text(label, style: TextStyle(color: selected ? Colors.black : Colors.white, fontWeight: FontWeight.w900))));
  }
}

class BrowserControls extends StatelessWidget {
  const BrowserControls({super.key, required this.canBack, required this.canForward, required this.onBack, required this.onForward, required this.onHome, required this.onRefresh});
  final bool canBack;
  final bool canForward;
  final VoidCallback onBack;
  final VoidCallback onForward;
  final VoidCallback onHome;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(radius: 28, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
      IconButton(onPressed: canBack ? onBack : null, icon: const Icon(Icons.arrow_back_rounded)),
      IconButton(onPressed: canForward ? onForward : null, icon: const Icon(Icons.arrow_forward_rounded)),
      IconButton(onPressed: onHome, icon: const Icon(Icons.home_rounded, color: RnColors.lemon)),
      IconButton(onPressed: onRefresh, icon: const Icon(Icons.refresh_rounded)),
    ]));
  }
}

class SlideMenu extends StatelessWidget {
  const SlideMenu({super.key, required this.onClose});
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(children: [
        GestureDetector(onTap: onClose, child: Container(color: Colors.black54)),
        Align(
          alignment: Alignment.centerRight,
          child: SafeArea(
            child: Container(
              width: MediaQuery.of(context).size.width * .78,
              margin: const EdgeInsets.only(right: 12, bottom: 95),
              child: GlassPanel(radius: 32, child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [const Text('RN MENU', style: TextStyle(color: RnColors.lemon, fontWeight: FontWeight.w900, fontSize: 20)), const Spacer(), IconButton(onPressed: onClose, icon: const Icon(Icons.close_rounded, color: RnColors.cyan))]),
                const Divider(color: Colors.white12),
                const MenuRow(icon: Icons.add_rounded, label: 'New Tab'),
                const MenuRow(icon: Icons.star_border_rounded, label: 'Bookmarks'),
                const MenuRow(icon: Icons.history_rounded, label: 'History'),
                const MenuRow(icon: Icons.download_rounded, label: 'Downloads'),
                const MenuRow(icon: Icons.favorite_border_rounded, label: 'Favorites'),
                const Divider(color: Colors.white12),
                const MenuRow(icon: Icons.visibility_off_rounded, label: 'Incognito Mode'),
                const MenuRow(icon: Icons.desktop_windows_rounded, label: 'Desktop Site'),
                const MenuRow(icon: Icons.tune_rounded, label: 'Customize'),
              ])),
            ),
          ),
        ),
      ]),
    );
  }
}

class MenuRow extends StatelessWidget {
  const MenuRow({super.key, required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Row(children: [Icon(icon, color: RnColors.lemon), const SizedBox(width: 14), Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800))), const Icon(Icons.chevron_right_rounded)]));
  }
}

class RnGlassNav extends StatelessWidget {
  const RnGlassNav({super.key, required this.index, required this.onChanged});
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 20),
      child: GlassPanel(radius: 34, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        NavButton(icon: Icons.home_rounded, selected: index == 0, onTap: () => onChanged(0)),
        NavButton(icon: Icons.public_rounded, selected: index == 1, onTap: () => onChanged(1)),
        NavButton(icon: Icons.tune_rounded, selected: index == 2, onTap: () => onChanged(2)),
      ])),
    );
  }
}

class NavButton extends StatelessWidget {
  const NavButton({super.key, required this.icon, required this.selected, required this.onTap});
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(22), child: AnimatedContainer(duration: const Duration(milliseconds: 180), padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: selected ? RnColors.lemon.withOpacity(.18) : Colors.transparent, borderRadius: BorderRadius.circular(22), border: Border.all(color: selected ? RnColors.lemon : Colors.transparent)), child: Icon(icon, color: selected ? RnColors.lemon : Colors.white70, size: 28)));
  }
}

class FeaturePill extends StatelessWidget {
  const FeaturePill({super.key, required this.label});
  final String label;
  @override
  Widget build(BuildContext context) => GlassPanel(radius: 999, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)));
}
