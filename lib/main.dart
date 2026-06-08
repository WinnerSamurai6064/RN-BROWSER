import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final savedSettings = await RnBrowserSettings.load();
  final savedProfile = await RnProfileStore.load();
  runApp(RnBrowserApp(initialSettings: savedSettings, initialProfile: savedProfile));
}

class RnBrowserApp extends StatelessWidget {
  const RnBrowserApp({super.key, required this.initialSettings, required this.initialProfile});

  final RnBrowserSettings initialSettings;
  final String initialProfile;

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
      home: RnShell(initialSettings: initialSettings, initialProfile: initialProfile),
    );
  }
}

class RnColors {
  static const black = Color(0xFF000402);
  static const panel = Color(0xDD071509);
  static const lemon = Color(0xFFC7FF2E);
  static const cyan = Color(0xFF50F6D7);
  static const pink = Color(0xFFFF4FD2);
  static const border = Color(0x6631D957);
  static const muted = Color(0xFFB8C4B5);
}

class RnProfileStore {
  const RnProfileStore._();

  static const key = 'rn.activeProfile';

  static Future<String> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(key);
    if (saved == 'Guest Space') return 'Guest Space';
    return 'My Space';
  }

  static Future<void> save(String profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, profile == 'Guest Space' ? 'Guest Space' : 'My Space');
  }
}

class RnBrowserSettings {
  const RnBrowserSettings({
    this.mic = false,
    this.camera = false,
    this.files = true,
    this.regionMode = false,
    this.pinchAllowList = true,
    this.clearOnExit = true,
    this.desktopSite = false,
    this.darkWebPages = false,
    this.zoom = 100,
  });

  final bool mic;
  final bool camera;
  final bool files;
  final bool regionMode;
  final bool pinchAllowList;
  final bool clearOnExit;
  final bool desktopSite;
  final bool darkWebPages;
  final double zoom;

  static const _prefix = 'rn.settings.';

  static Future<RnBrowserSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    return RnBrowserSettings(
      mic: prefs.getBool('${_prefix}mic') ?? false,
      camera: prefs.getBool('${_prefix}camera') ?? false,
      files: prefs.getBool('${_prefix}files') ?? true,
      regionMode: prefs.getBool('${_prefix}regionMode') ?? false,
      pinchAllowList: prefs.getBool('${_prefix}pinchAllowList') ?? true,
      clearOnExit: prefs.getBool('${_prefix}clearOnExit') ?? true,
      desktopSite: prefs.getBool('${_prefix}desktopSite') ?? false,
      darkWebPages: prefs.getBool('${_prefix}darkWebPages') ?? false,
      zoom: prefs.getDouble('${_prefix}zoom') ?? 100,
    );
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('${_prefix}mic', mic);
    await prefs.setBool('${_prefix}camera', camera);
    await prefs.setBool('${_prefix}files', files);
    await prefs.setBool('${_prefix}regionMode', regionMode);
    await prefs.setBool('${_prefix}pinchAllowList', pinchAllowList);
    await prefs.setBool('${_prefix}clearOnExit', clearOnExit);
    await prefs.setBool('${_prefix}desktopSite', desktopSite);
    await prefs.setBool('${_prefix}darkWebPages', darkWebPages);
    await prefs.setDouble('${_prefix}zoom', zoom);
  }

  RnBrowserSettings copyWith({
    bool? mic,
    bool? camera,
    bool? files,
    bool? regionMode,
    bool? pinchAllowList,
    bool? clearOnExit,
    bool? desktopSite,
    bool? darkWebPages,
    double? zoom,
  }) {
    return RnBrowserSettings(
      mic: mic ?? this.mic,
      camera: camera ?? this.camera,
      files: files ?? this.files,
      regionMode: regionMode ?? this.regionMode,
      pinchAllowList: pinchAllowList ?? this.pinchAllowList,
      clearOnExit: clearOnExit ?? this.clearOnExit,
      desktopSite: desktopSite ?? this.desktopSite,
      darkWebPages: darkWebPages ?? this.darkWebPages,
      zoom: zoom ?? this.zoom,
    );
  }
}

enum RnPage { start, browser, settings }

class RnShell extends StatefulWidget {
  const RnShell({super.key, required this.initialSettings, required this.initialProfile});

  final RnBrowserSettings initialSettings;
  final String initialProfile;

  @override
  State<RnShell> createState() => _RnShellState();
}

class _RnShellState extends State<RnShell> {
  late String profile;
  late RnBrowserSettings settings;
  RnPage page = RnPage.start;

  @override
  void initState() {
    super.initState();
    profile = widget.initialProfile;
    settings = widget.initialSettings;
  }

  Future<void> changeProfile(String next) async {
    if (next == profile) return;
    setState(() => profile = next);
    await RnProfileStore.save(next);
    if (settings.clearOnExit) {
      await CookieManager.instance().deleteAllCookies();
      await WebStorageManager.instance().deleteAllData();
    }
  }

  Future<void> updateSettings(RnBrowserSettings next) async {
    setState(() => settings = next);
    await next.save();
  }

  @override
  Widget build(BuildContext context) {
    if (page == RnPage.start) {
      return StartScreen(onStart: () => setState(() => page = RnPage.browser));
    }
    if (page == RnPage.settings) {
      return SettingsScreen(profile: profile, settings: settings, onProfileChanged: changeProfile, onSettingsChanged: updateSettings, onBack: () => setState(() => page = RnPage.browser));
    }
    return BrowserScreen(profile: profile, settings: settings, onProfileChanged: changeProfile, onOpenSettings: () => setState(() => page = RnPage.settings));
  }
}

class StartScreen extends StatelessWidget {
  const StartScreen({super.key, required this.onStart});
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RnColors.black,
      body: Stack(children: [
        const StartBackdrop(),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const BrandRow(),
              const SizedBox(height: 28),
              const Text('Welcome to RN', style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, height: .98)),
              const SizedBox(height: 18),
              const Text('RN provides a secure and private browsing experience built around isolated browser spaces. Each space keeps its own cookies, sessions, and privacy settings, making it safer to share one phone without mixing accounts, activity, or browsing data.', style: TextStyle(color: RnColors.muted, height: 1.45, fontSize: 15.5)),
              const SizedBox(height: 22),
              const Wrap(spacing: 9, runSpacing: 10, children: [
                FeaturePill(label: '2 Spaces'),
                FeaturePill(label: 'Isolated Cookies'),
                FeaturePill(label: 'Private Sessions'),
                FeaturePill(label: 'No Forced Login'),
                FeaturePill(label: 'Security Controls'),
              ]),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 62,
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: RnColors.lemon, foregroundColor: Colors.black, shape: const StadiumBorder()),
                  onPressed: onStart,
                  child: const Text('Start Secure Browsing', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17)),
                ),
              ),
              const SizedBox(height: 14),
              Center(child: TextButton.icon(onPressed: () {}, icon: const Icon(Icons.sync_lock_rounded, size: 18), label: const Text('Login / Sync'), style: TextButton.styleFrom(foregroundColor: RnColors.lemon))),
              const Center(child: Text('Optional. RN works without an account.', style: TextStyle(color: RnColors.muted, fontSize: 12.5))),
              const SizedBox(height: 22),
              const Center(child: Text('RN by TEKDEV', style: TextStyle(color: RnColors.lemon, fontWeight: FontWeight.w800, letterSpacing: .4))),
            ]),
          ),
        ),
      ]),
    );
  }
}

class BrandRow extends StatelessWidget {
  const BrandRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      const GlassPanel(radius: 18, padding: EdgeInsets.all(12), child: Icon(Icons.shield_rounded, color: RnColors.lemon)),
      const SizedBox(width: 12),
      const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('RN', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
        Text('Privacy-first browser', style: TextStyle(color: RnColors.muted, fontSize: 13)),
      ]),
      const Spacer(),
      GlassPanel(radius: 999, padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9), child: const Text('Beta 0.6', style: TextStyle(color: RnColors.lemon, fontWeight: FontWeight.w900))),
    ]);
  }
}

class StartBackdrop extends StatelessWidget {
  const StartBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned.fill(child: Container(decoration: const BoxDecoration(gradient: RadialGradient(center: Alignment.topRight, radius: 1.2, colors: [Color(0x3325FF52), Color(0x00000000)])))),
      Positioned(bottom: -50, left: -70, child: GlowBlob(size: 260, color: RnColors.cyan)),
      Positioned(top: 120, right: -95, child: GlowBlob(size: 260, color: RnColors.lemon)),
    ]);
  }
}

class BrowserScreen extends StatefulWidget {
  const BrowserScreen({super.key, required this.profile, required this.settings, required this.onProfileChanged, required this.onOpenSettings});
  final String profile;
  final RnBrowserSettings settings;
  final ValueChanged<String> onProfileChanged;
  final VoidCallback onOpenSettings;

  @override
  State<BrowserScreen> createState() => _BrowserScreenState();
}

class _BrowserScreenState extends State<BrowserScreen> {
  final TextEditingController address = TextEditingController(text: 'https://duckduckgo.com');
  InAppWebViewController? controller;
  String url = 'https://duckduckgo.com';
  double progress = 1;
  bool canBack = false;
  bool canForward = false;
  bool menuOpen = false;

  @override
  void dispose() {
    address.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant BrowserScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.settings != widget.settings) applyWebSettings();
  }

  Future<void> openAddress() async {
    final raw = address.text.trim();
    if (raw.isEmpty) return;
    final next = raw.startsWith('http://') || raw.startsWith('https://') ? raw : 'https://duckduckgo.com/?q=${Uri.encodeComponent(raw)}';
    address.text = next;
    await controller?.loadUrl(urlRequest: URLRequest(url: WebUri(next)));
  }

  Future<void> updateNav() async {
    final c = controller;
    if (c == null) return;
    final back = await c.canGoBack();
    final forward = await c.canGoForward();
    final current = await c.getUrl();
    if (!mounted) return;
    setState(() {
      canBack = back;
      canForward = forward;
      if (current != null) {
        url = current.toString();
        address.text = url;
      }
    });
  }

  bool get zoomAllowed {
    if (!widget.settings.pinchAllowList) return true;
    final host = Uri.tryParse(url)?.host ?? '';
    return host.contains('wikipedia.org') || host.contains('github.com') || host.contains('docs.flutter.dev');
  }

  Future<void> applyWebSettings() async {
    final c = controller;
    if (c == null) return;
    await c.setSettings(settings: InAppWebViewSettings(
      supportZoom: zoomAllowed,
      builtInZoomControls: zoomAllowed,
      displayZoomControls: false,
      geolocationEnabled: widget.settings.regionMode,
      thirdPartyCookiesEnabled: false,
      mediaPlaybackRequiresUserGesture: true,
      userAgent: widget.settings.desktopSite ? 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 Chrome/124 Safari/537.36 RNBrowser/0.6' : null,
    ));
    final scale = widget.settings.zoom / 100;
    await c.evaluateJavascript(source: "try{document.documentElement.style.zoom='$scale';document.body.style.zoom='$scale';}catch(e){};");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RnColors.black,
      body: Stack(children: [
        SafeArea(
          bottom: false,
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
              child: BrowserTopBar(profile: widget.profile, onProfileChanged: widget.onProfileChanged, address: address, onSubmit: openAddress, onMenu: () => setState(() => menuOpen = true)),
            ),
            if (progress < 1) LinearProgressIndicator(value: progress, minHeight: 2, color: RnColors.lemon, backgroundColor: Colors.white10),
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                child: InAppWebView(
                  initialUrlRequest: URLRequest(url: WebUri(url)),
                  initialSettings: InAppWebViewSettings(
                    javaScriptEnabled: true,
                    useShouldOverrideUrlLoading: true,
                    supportZoom: zoomAllowed,
                    builtInZoomControls: zoomAllowed,
                    displayZoomControls: false,
                    geolocationEnabled: widget.settings.regionMode,
                    thirdPartyCookiesEnabled: false,
                    mediaPlaybackRequiresUserGesture: true,
                  ),
                  onWebViewCreated: (c) => controller = c,
                  onLoadStart: (_, current) {
                    if (current == null) return;
                    setState(() {
                      url = current.toString();
                      address.text = url;
                    });
                  },
                  onLoadStop: (_, __) async {
                    await updateNav();
                    await applyWebSettings();
                  },
                  onProgressChanged: (_, value) => setState(() => progress = value / 100),
                  onPermissionRequest: (_, request) async {
                    final allowed = <PermissionResourceType>[];
                    for (final resource in request.resources) {
                      if (resource == PermissionResourceType.MICROPHONE && widget.settings.mic) allowed.add(resource);
                      if (resource == PermissionResourceType.CAMERA && widget.settings.camera) allowed.add(resource);
                    }
                    return PermissionResponse(resources: allowed, action: allowed.isEmpty ? PermissionResponseAction.DENY : PermissionResponseAction.GRANT);
                  },
                  onGeolocationPermissionsShowPrompt: (_, origin) async {
                    return GeolocationPermissionShowPromptResponse(origin: origin, allow: widget.settings.regionMode, retain: false);
                  },
                ),
              ),
            ),
          ]),
        ),
        Positioned(left: 18, right: 18, bottom: 24, child: BrowserControls(canBack: canBack, canForward: canForward, onBack: () => controller?.goBack(), onForward: () => controller?.goForward(), onHome: () => controller?.loadUrl(urlRequest: URLRequest(url: WebUri('https://duckduckgo.com'))), onRefresh: () => controller?.reload())),
        if (menuOpen) SlideMenu(onClose: () => setState(() => menuOpen = false), onNewTab: () { setState(() => menuOpen = false); controller?.loadUrl(urlRequest: URLRequest(url: WebUri('https://duckduckgo.com'))); }, onSettings: () { setState(() => menuOpen = false); widget.onOpenSettings(); }),
      ]),
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
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        ProfileChip(label: 'My Space', selected: profile == 'My Space', onTap: () => onProfileChanged('My Space')),
        const SizedBox(width: 10),
        ProfileChip(label: 'Guest Space', selected: profile == 'Guest Space', onTap: () => onProfileChanged('Guest Space')),
      ]),
      const SizedBox(height: 14),
      Row(children: [
        Expanded(child: GlassPanel(radius: 26, padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 5), child: TextField(controller: address, onSubmitted: (_) => onSubmit(), textInputAction: TextInputAction.go, decoration: const InputDecoration(border: InputBorder.none, prefixIcon: Icon(Icons.lock_rounded, color: RnColors.lemon), hintText: 'Search or enter address')))),
        const SizedBox(width: 12),
        GlassPanel(radius: 18, padding: EdgeInsets.zero, child: IconButton(onPressed: onMenu, icon: const Icon(Icons.menu_rounded, color: RnColors.lemon))),
      ]),
    ]);
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.profile, required this.settings, required this.onProfileChanged, required this.onSettingsChanged, required this.onBack});
  final String profile;
  final RnBrowserSettings settings;
  final ValueChanged<String> onProfileChanged;
  final ValueChanged<RnBrowserSettings> onSettingsChanged;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final website = ['Microphone Access', 'Camera Access', 'Gallery and File Access', 'Location Access', 'Notifications', 'Clipboard Access', 'Pop-ups and Redirects', 'Downloads'];
    final privacy = ['Block third-party cookies', 'Block tracking scripts', 'Block fingerprinting attempts', 'Clear cookies on exit', 'Do Not Track request', 'Hide referrer where possible', 'Private DNS mode'];
    final sessions = ['Separate cookies per space', 'Separate local storage per space', 'Separate cache per space', 'Prevent account merging', 'Clear Guest Space on exit'];
    final behavior = ['Region Mode', 'Pinch Zoom Allowlist', 'Desktop Site Mode', 'JavaScript Control', 'Open links inside RN', 'Default search engine', 'Homepage', 'Location Shield', 'Network Persona'];

    return Scaffold(
      backgroundColor: RnColors.black,
      body: SafeArea(
        child: ListView(padding: const EdgeInsets.fromLTRB(18, 14, 18, 26), children: [
          Row(children: [IconButton(onPressed: onBack, icon: const Icon(Icons.arrow_back_rounded)), const SizedBox(width: 8), const Text('Settings', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900))]),
          const SizedBox(height: 10),
          Row(children: [ProfileChip(label: 'My Space', selected: profile == 'My Space', onTap: () => onProfileChanged('My Space')), const SizedBox(width: 10), ProfileChip(label: 'Guest Space', selected: profile == 'Guest Space', onTap: () => onProfileChanged('Guest Space'))]),
          const SizedBox(height: 20),
          SettingsList(title: 'Website Permissions', items: website),
          SettingsList(title: 'Privacy Controls', items: privacy),
          SettingsList(title: 'Session Isolation', items: sessions),
          SettingsList(title: 'Browser Behavior', items: behavior),
          GlassPanel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Region zoom', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            Text('${settings.zoom.round()}%', style: const TextStyle(color: RnColors.muted)),
            Slider(min: 50, max: 150, value: settings.zoom, activeColor: RnColors.lemon, onChanged: (v) => onSettingsChanged(settings.copyWith(zoom: v))),
          ])),
          const SizedBox(height: 16),
          const AboutCard(),
          const FooterLinks(),
        ]),
      ),
    );
  }
}

class SettingsList extends StatelessWidget {
  const SettingsList({super.key, required this.title, required this.items});
  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.only(bottom: 18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(color: RnColors.lemon, fontSize: 18, fontWeight: FontWeight.w900)),
      const SizedBox(height: 10),
      ...items.map((item) => Padding(padding: const EdgeInsets.only(bottom: 10), child: GlassPanel(padding: const EdgeInsets.all(16), child: Row(children: [Expanded(child: Text(item, style: const TextStyle(fontWeight: FontWeight.w800))), const Icon(Icons.chevron_right_rounded)])))),
    ]));
  }
}

class AboutCard extends StatelessWidget {
  const AboutCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassPanel(child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('About RN', style: TextStyle(color: RnColors.lemon, fontSize: 19, fontWeight: FontWeight.w900)),
      SizedBox(height: 10),
      Text('RN Browser', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
      Text('Beta 0.6', style: TextStyle(color: RnColors.muted)),
      SizedBox(height: 12),
      Text('RN is a privacy-first browser by TEKDEV. It is designed to keep browsing sessions isolated, protect shared-phone users, and give people stronger control over cookies, permissions, and website access.', style: TextStyle(color: RnColors.muted, height: 1.4)),
      SizedBox(height: 14),
      Text('RN by TEKDEV', style: TextStyle(color: RnColors.lemon, fontWeight: FontWeight.w900)),
    ]));
  }
}

class FooterLinks extends StatelessWidget {
  const FooterLinks({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(children: [
      SizedBox(height: 12),
      FooterLink(label: 'Privacy Policy'),
      FooterLink(label: 'Terms'),
      FooterLink(label: 'Contact TEKDEV'),
      FooterLink(label: 'Check for updates'),
      SizedBox(height: 8),
      Text('RN by TEKDEV', style: TextStyle(color: RnColors.muted, fontWeight: FontWeight.w700)),
    ]);
  }
}

class FooterLink extends StatelessWidget {
  const FooterLink({super.key, required this.label});
  final String label;
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 8), child: GlassPanel(padding: const EdgeInsets.all(16), child: Row(children: [Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800))), const Icon(Icons.chevron_right_rounded)])));
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
    return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(999), child: Container(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11), decoration: BoxDecoration(color: selected ? RnColors.lemon : Colors.white10, borderRadius: BorderRadius.circular(999), border: Border.all(color: selected ? RnColors.lemon : Colors.white24)), child: Text(label, style: TextStyle(color: selected ? Colors.black : Colors.white, fontWeight: FontWeight.w900))));
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
    return GlassPanel(radius: 34, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
      IconButton(onPressed: canBack ? onBack : null, icon: const Icon(Icons.arrow_back_rounded)),
      IconButton(onPressed: canForward ? onForward : null, icon: const Icon(Icons.arrow_forward_rounded)),
      IconButton(onPressed: onHome, icon: const Icon(Icons.public_rounded, color: RnColors.lemon, size: 30)),
      IconButton(onPressed: onRefresh, icon: const Icon(Icons.refresh_rounded)),
    ]));
  }
}

class SlideMenu extends StatelessWidget {
  const SlideMenu({super.key, required this.onClose, required this.onNewTab, required this.onSettings});
  final VoidCallback onClose;
  final VoidCallback onNewTab;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(child: Stack(children: [
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
              MenuRow(icon: Icons.add_rounded, label: 'New Tab', onTap: onNewTab),
              const MenuRow(icon: Icons.star_border_rounded, label: 'Bookmarks'),
              const MenuRow(icon: Icons.history_rounded, label: 'History'),
              const MenuRow(icon: Icons.download_rounded, label: 'Downloads'),
              const MenuRow(icon: Icons.favorite_border_rounded, label: 'Favorites'),
              MenuRow(icon: Icons.tune_rounded, label: 'Settings', onTap: onSettings),
            ])),
          ),
        ),
      ),
    ]));
  }
}

class MenuRow extends StatelessWidget {
  const MenuRow({super.key, required this.icon, required this.label, this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(14), child: Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Row(children: [Icon(icon, color: RnColors.lemon), const SizedBox(width: 14), Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800))), const Icon(Icons.chevron_right_rounded)])));
  }
}

class GlassPanel extends StatelessWidget {
  const GlassPanel({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.radius = 26});
  final Widget child;
  final EdgeInsets padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(borderRadius: BorderRadius.circular(radius), child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18), child: Container(padding: padding, decoration: BoxDecoration(color: RnColors.panel, borderRadius: BorderRadius.circular(radius), border: Border.all(color: RnColors.border, width: 1.2), boxShadow: const [BoxShadow(color: Color(0x331DFF75), blurRadius: 22, spreadRadius: 1)]), child: child)));
  }
}

class FeaturePill extends StatelessWidget {
  const FeaturePill({super.key, required this.label});
  final String label;
  @override
  Widget build(BuildContext context) => GlassPanel(radius: 999, padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9), child: Text(label, style: const TextStyle(fontWeight: FontWeight.w900)));
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
