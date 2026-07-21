/// Network Inspector Overlay for LDFlutter Networking Layer
library;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'network_inspector.dart';
import 'network_log_entry.dart';
import 'shake_detector.dart';

/// Color palette for the network inspector UI, independent of the host
/// app's own theme. Toggle via [NetworkInspector.toggleBrightness].
class _InspectorColors {
  final Color background;
  final Color surface;
  final Color border;
  final Color handle;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;

  const _InspectorColors({
    required this.background,
    required this.surface,
    required this.border,
    required this.handle,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
  });

  static const dark = _InspectorColors(
    background: Color(0xFF161616),
    surface: Color(0xFF1E1E1E),
    border: Colors.white12,
    handle: Colors.white24,
    textPrimary: Colors.white,
    textSecondary: Colors.white70,
    textTertiary: Colors.white38,
  );

  static const light = _InspectorColors(
    background: Colors.white,
    surface: Color(0xFFF2F2F2),
    border: Colors.black12,
    handle: Colors.black26,
    textPrimary: Colors.black87,
    textSecondary: Colors.black54,
    textTertiary: Colors.black38,
  );

  static _InspectorColors of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;
}

/// Wraps [child] and shows an in-app network log viewer, as a bottom sheet,
/// whenever the device is shaken. Attach once, high in the widget tree (e.g.
/// `MaterialApp`'s `builder`). Pass `enabled: false` (e.g. in production) to
/// skip listening for shakes entirely.
class NetworkInspectorOverlay extends StatefulWidget {
  final Widget child;
  final bool enabled;

  const NetworkInspectorOverlay({
    super.key,
    required this.child,
    this.enabled = true,
  });

  @override
  State<NetworkInspectorOverlay> createState() =>
      _NetworkInspectorOverlayState();
}

class _NetworkInspectorOverlayState extends State<NetworkInspectorOverlay> {
  bool _visible = false;
  ShakeDetector? _shakeDetector;

  @override
  void initState() {
    super.initState();
    if (widget.enabled) {
      _shakeDetector = ShakeDetector(
        onShake: () => setState(() => _visible = true),
      )..startListening();
    }
  }

  @override
  void dispose() {
    _shakeDetector?.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_visible)
          _NetworkLogSheet(onClose: () => setState(() => _visible = false)),
      ],
    );
  }
}

/// A bottom sheet shell (scrim + slide-up panel) hosting its own [Navigator]
/// so the log list and log detail push/pop like real screens, independent of
/// the host app's own navigation stack.
class _NetworkLogSheet extends StatefulWidget {
  final VoidCallback onClose;

  const _NetworkLogSheet({required this.onClose});

  @override
  State<_NetworkLogSheet> createState() => _NetworkLogSheetState();
}

class _NetworkLogSheetState extends State<_NetworkLogSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 240),
  )..forward();

  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  Future<void> _dismiss() async {
    await _controller.reverse();
    if (mounted) widget.onClose();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sheetHeight = MediaQuery.of(context).size.height * 0.92;
    final curved = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: _dismiss,
                child: Container(
                  color: Colors.black.withValues(alpha: 0.55 * _controller.value),
                ),
              ),
            ),
            Positioned.fill(
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(curved),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(height: sheetHeight, child: child),
                ),
              ),
            ),
          ],
        );
      },
      child: _SheetChrome(navigatorKey: _navigatorKey, onDismiss: _dismiss),
    );
  }
}

class _SheetChrome extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final VoidCallback onDismiss;

  const _SheetChrome({required this.navigatorKey, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Brightness>(
      valueListenable: NetworkInspector.instance.brightness,
      builder: (context, brightness, _) {
        return Theme(
          data: brightness == Brightness.dark
              ? ThemeData.dark(useMaterial3: true)
              : ThemeData.light(useMaterial3: true),
          child: Builder(
            builder: (context) {
              final colors = _InspectorColors.of(context);
              return ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Material(
                  color: colors.background,
                  // The sheet already sits clear of the notch/status bar (it's
                  // bottom-anchored at < 100% height), but without this the
                  // nested Scaffold's AppBar still pads itself for the
                  // full-screen top inset it inherits via MediaQuery.
                  child: MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    child: SafeArea(
                      top: false,
                      child: Column(
                        children: [
                          GestureDetector(
                            onVerticalDragEnd: (details) {
                              if ((details.primaryVelocity ?? 0) > 300) onDismiss();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              alignment: Alignment.center,
                              color: Colors.transparent,
                              child: Container(
                                width: 36,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: colors.handle,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            // Isolated from the host app's own Navigator so
                            // this debug Navigator doesn't fight over the
                            // ambient HeroController.
                            child: HeroControllerScope.none(
                              child: Navigator(
                                key: navigatorKey,
                                onGenerateRoute: (settings) => MaterialPageRoute(
                                  settings: settings,
                                  builder: (_) => NetworkLogListPage(onClose: onDismiss),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

/// The network log list screen. Public so it can also be pushed standalone
/// (e.g. from a host app's own debug menu route) instead of via the shake
/// gesture.
class NetworkLogListPage extends StatefulWidget {
  final VoidCallback? onClose;

  const NetworkLogListPage({super.key, this.onClose});

  @override
  State<NetworkLogListPage> createState() => _NetworkLogListPageState();
}

class _NetworkLogListPageState extends State<NetworkLogListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<NetworkLogEntry> _filter(List<NetworkLogEntry> entries) {
    if (_query.isEmpty) return entries;
    return entries.where((entry) {
      return entry.url.toString().toLowerCase().contains(_query) ||
          entry.method.toLowerCase().contains(_query) ||
          (entry.statusCode?.toString() ?? '').contains(_query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colors = _InspectorColors.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: ValueListenableBuilder<List<NetworkLogEntry>>(
          valueListenable: NetworkInspector.instance.logs,
          builder: (context, entries, _) => Text(
            'Network Logs (${entries.length})',
            style: TextStyle(color: colors.textPrimary, fontSize: 17),
          ),
        ),
        actions: [
          ValueListenableBuilder<Brightness>(
            valueListenable: NetworkInspector.instance.brightness,
            builder: (context, brightness, _) => IconButton(
              tooltip: 'Toggle theme',
              icon: Icon(
                brightness == Brightness.dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                color: colors.textSecondary,
              ),
              onPressed: NetworkInspector.instance.toggleBrightness,
            ),
          ),
          IconButton(
            tooltip: 'Clear',
            icon: Icon(Icons.delete_outline, color: colors.textSecondary),
            onPressed: NetworkInspector.instance.clear,
          ),
          if (widget.onClose != null)
            IconButton(
              tooltip: 'Close',
              icon: Icon(Icons.close, color: colors.textSecondary),
              onPressed: widget.onClose,
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: _SearchField(controller: _searchController),
          ),
          Expanded(
            child: ValueListenableBuilder<List<NetworkLogEntry>>(
              valueListenable: NetworkInspector.instance.logs,
              builder: (context, entries, _) {
                if (entries.isEmpty) {
                  return Center(
                    child: Text(
                      'No requests yet\nShake again after making a request',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colors.textTertiary),
                    ),
                  );
                }

                final filtered = _filter(entries);
                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      'No matching requests',
                      style: TextStyle(color: colors.textTertiary),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => Divider(color: colors.border, height: 1),
                  itemBuilder: (context, index) {
                    final entry = filtered[index];
                    return _LogListTile(
                      entry: entry,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => NetworkLogDetailPage(entry: entry),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;

  const _SearchField({required this.controller});

  @override
  Widget build(BuildContext context) {
    final colors = _InspectorColors.of(context);
    final brightness = Theme.of(context).brightness;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.border),
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(color: colors.textPrimary, fontSize: 14),
        cursorColor: colors.textPrimary,
        keyboardAppearance: brightness,
        decoration: InputDecoration(
          isDense: true,
          filled: false,
          hintText: 'Search by URL, method, or status',
          hintStyle: TextStyle(color: colors.textTertiary, fontSize: 14),
          prefixIcon: Icon(Icons.search, color: colors.textTertiary, size: 20),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) {
              if (value.text.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: Icon(Icons.clear, color: colors.textTertiary, size: 18),
                onPressed: controller.clear,
              );
            },
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}

class _LogListTile extends StatelessWidget {
  final NetworkLogEntry entry;
  final VoidCallback onTap;

  const _LogListTile({required this.entry, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = _InspectorColors.of(context);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _MethodBadge(method: entry.method),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.url.path.isEmpty ? '/' : entry.url.path,
                    style: TextStyle(color: colors.textPrimary, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    entry.url.host,
                    style: TextStyle(color: colors.textTertiary, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _StatusBadge(entry: entry),
                const SizedBox(height: 4),
                Text(
                  entry.duration != null ? '${entry.duration!.inMilliseconds}ms' : '···',
                  style: TextStyle(color: colors.textTertiary, fontSize: 11),
                ),
              ],
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, color: colors.textTertiary, size: 20),
          ],
        ),
      ),
    );
  }
}

/// The request/response detail screen for a single [NetworkLogEntry]. Public
/// for the same standalone-usage reason as [NetworkLogListPage].
class NetworkLogDetailPage extends StatelessWidget {
  final NetworkLogEntry entry;

  const NetworkLogDetailPage({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final colors = _InspectorColors.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: colors.textSecondary),
        title: Text(
          entry.method,
          style: TextStyle(color: colors.textPrimary, fontSize: 17),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              _MethodBadge(method: entry.method),
              const SizedBox(width: 8),
              _StatusBadge(entry: entry),
              const Spacer(),
              if (entry.duration != null)
                Text(
                  '${entry.duration!.inMilliseconds} ms',
                  style: TextStyle(color: colors.textSecondary, fontSize: 13),
                ),
            ],
          ),
          const SizedBox(height: 16),
          _Section(title: 'URL', content: entry.url.toString()),
          if (entry.error != null)
            _Section(title: 'Error', content: '${entry.error}', isError: true),
          _Section(title: 'Request Headers', content: _formatHeaders(entry.requestHeaders)),
          _Section(title: 'Request Body', content: _formatBody(entry.requestBody)),
          _Section(
            title: 'Response Headers',
            content: _formatHeaders(entry.responseHeaders ?? {}),
          ),
          _Section(title: 'Response Body', content: _formatBody(entry.responseBody)),
        ],
      ),
    );
  }

  String _formatHeaders(Map<String, String> headers) {
    if (headers.isEmpty) return '-';
    return headers.entries.map((e) => '${e.key}: ${e.value}').join('\n');
  }

  String _formatBody(Uint8List? body) {
    if (body == null || body.isEmpty) return '-';
    try {
      final decoded = utf8.decode(body);
      try {
        final jsonBody = json.decode(decoded);
        return const JsonEncoder.withIndent('  ').convert(jsonBody);
      } catch (_) {
        return decoded;
      }
    } catch (_) {
      return '<${body.length} bytes>';
    }
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String content;
  final bool isError;

  const _Section({
    required this.title,
    required this.content,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    if (content == '-') return const SizedBox.shrink();

    final colors = _InspectorColors.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: isError ? Colors.redAccent : colors.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(4),
                onTap: () => Clipboard.setData(ClipboardData(text: content)),
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: Icon(Icons.copy, size: 15, color: colors.textTertiary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          SelectableText(
            content,
            style: TextStyle(
              color: isError ? Colors.redAccent : colors.textPrimary,
              fontFamily: 'monospace',
              fontSize: 12.5,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _MethodBadge extends StatelessWidget {
  final String method;

  const _MethodBadge({required this.method});

  Color get _color {
    switch (method.toUpperCase()) {
      case 'GET':
        return Colors.blueAccent;
      case 'POST':
        return Colors.greenAccent;
      case 'PUT':
      case 'PATCH':
        return Colors.orangeAccent;
      case 'DELETE':
        return Colors.redAccent;
      default:
        return Colors.purpleAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        method.toUpperCase(),
        style: TextStyle(color: _color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final NetworkLogEntry entry;

  const _StatusBadge({required this.entry});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    if (entry.isPending) {
      color = Colors.grey;
      label = '···';
    } else if (entry.error != null) {
      color = Colors.redAccent;
      label = 'ERR';
    } else if (entry.statusCode! >= 200 && entry.statusCode! < 300) {
      color = Colors.greenAccent;
      label = '${entry.statusCode}';
    } else {
      color = Colors.orangeAccent;
      label = '${entry.statusCode}';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}
