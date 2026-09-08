import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const DropReadyApp());
}

class Drop {
  Drop({
    required this.name,
    required this.releaseAt,
    required this.url,
    required this.sizes,
  });

  final String name;
  final DateTime releaseAt;
  final String url;
  final List<String> sizes;
  final Map<String, bool> checklist = {
    'Login ready': false,
    'Address confirmed': false,
    'Payment method ready': false,
    'Internet checked': false,
    'Battery / alerts ready': false,
  };

  int get readyCount => checklist.values.where((item) => item).length;
}

class DropReadyApp extends StatelessWidget {
  const DropReadyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Drop Ready',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.light(
          primary: Colors.black,
          onPrimary: Colors.white,
          surface: Colors.white,
          onSurface: Colors.black,
        ),
        scaffoldBackgroundColor: const Color(0xFFF6F6F6),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int pageIndex = 0;

  final List<Drop> drops = [
    Drop(
      name: 'YOUR NEXT DROP',
      releaseAt: DateTime.now().add(const Duration(days: 1, hours: 2)),
      url: 'https://www.nike.com/',
      sizes: ['US 9', 'US 8.5', 'US 9.5'],
    ),
  ];

  List<String> history = [];

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardPage(
        drops: drops,
        onOpen: () => setState(() => pageIndex = 1),
      ),
      DropDayPage(
        drop: drops.first,
        onSaveResult: (result) {
          setState(() {
            history.insert(0, '${drops.first.name} — $result');
            pageIndex = 2;
          });
        },
      ),
      HistoryPage(history: history),
      const SettingsPage(),
    ];

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            backgroundColor: Colors.black,
            selectedIndex: pageIndex,
            onDestinationSelected: (value) {
              setState(() => pageIndex = value);
            },
            labelType: NavigationRailLabelType.all,
            indicatorColor: Colors.white,
            selectedIconTheme: const IconThemeData(color: Colors.black),
            unselectedIconTheme: const IconThemeData(color: Colors.white70),
            selectedLabelTextStyle: const TextStyle(color: Colors.white),
            unselectedLabelTextStyle: const TextStyle(color: Colors.white70),
            leading: const Padding(
              padding: EdgeInsets.symmetric(vertical: 28),
              child: Text(
                'DR',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.shopping_bag_outlined),
                selectedIcon: Icon(Icons.shopping_bag),
                label: Text('Drop Day'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.history_outlined),
                selectedIcon: Icon(Icons.history),
                label: Text('History'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: Text('Settings'),
              ),
            ],
          ),
          Expanded(child: pages[pageIndex]),
        ],
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({
    super.key,
    required this.drops,
    required this.onOpen,
  });

  final List<Drop> drops;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final drop = drops.first;

    return PageLayout(
      title: 'DROP READY',
      subtitle: 'Prepare early. Confirm manually. Move fast.',
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(36),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'NEXT DROP',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    drop.name,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 26),
                  Countdown(target: drop.releaseAt, large: true),
                  const Divider(height: 48),
                  const Text(
                    'SIZE PLAN',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: drop.sizes
                        .asMap()
                        .entries
                        .map(
                          (entry) => Chip(
                            label: Text('${entry.key + 1}. ${entry.value}'),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 22),
                  Text('READINESS ${drop.readyCount}/5'),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: onOpen,
                    child: const Text('OPEN DROP DAY MODE'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DropDayPage extends StatefulWidget {
  const DropDayPage({
    super.key,
    required this.drop,
    required this.onSaveResult,
  });

  final Drop drop;
  final ValueChanged<String> onSaveResult;

  @override
  State<DropDayPage> createState() => _DropDayPageState();
}

class _DropDayPageState extends State<DropDayPage> {
  int selectedSize = 0;

  Future<void> openProductPage() async {
    final url = Uri.parse(widget.drop.url);
    final opened = await launchUrl(url, mode: LaunchMode.externalApplication);

    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ไม่สามารถเปิดหน้าสินค้าได้')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final drop = widget.drop;

    return PageLayout(
      title: 'DROP DAY',
      subtitle: drop.name,
      child: ListView(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                children: [
                  const Text(
                    'RELEASE IN',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Countdown(target: drop.releaseAt, large: true),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: openProductPage,
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('OPEN PRODUCT PAGE'),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'คุณเป็นผู้เลือกไซซ์ เพิ่มตะกร้า และยืนยันการชำระเงินด้วยตัวเอง',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SIZE PRIORITY',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: List.generate(
                      drop.sizes.length,
                      (index) => ChoiceChip(
                        label: Text('${index + 1}. ${drop.sizes[index]}'),
                        selected: selectedSize == index,
                        onSelected: (_) {
                          setState(() => selectedSize = index);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'READINESS CHECKLIST ${drop.readyCount}/5',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...drop.checklist.entries.map(
                    (item) => CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(item.key),
                      value: item.value,
                      onChanged: (value) {
                        setState(() => drop.checklist[item.key] = value ?? false);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton(
                onPressed: () => widget.onSaveResult(
                  'สำเร็จ — ${drop.sizes[selectedSize]}',
                ),
                child: const Text('บันทึก: สำเร็จ'),
              ),
              OutlinedButton(
                onPressed: () => widget.onSaveResult('ไม่สำเร็จ'),
                child: const Text('บันทึก: ไม่สำเร็จ'),
              ),
              OutlinedButton(
                onPressed: () => widget.onSaveResult('ยกเลิก'),
                child: const Text('บันทึก: ยกเลิก'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key, required this.history});

  final List<String> history;

  @override
  Widget build(BuildContext context) {
    return PageLayout(
      title: 'HISTORY',
      subtitle: 'Results from completed drop attempts',
      child: history.isEmpty
          ? const Center(child: Text('ยังไม่มีประวัติการเข้าร่วม'))
          : ListView.separated(
              itemCount: history.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, index) => Card(
                child: ListTile(
                  leading: const Icon(Icons.check_circle_outline),
                  title: Text(history[index]),
                ),
              ),
            ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PageLayout(
      title: 'SETTINGS',
      subtitle: 'Application information',
      child: Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(28),
            child: Text(
              'DROP READY 1.0.0\n\n'
              'แอปนี้ช่วยเตรียมแผนสำหรับวันดรอปและเปิดหน้าสินค้าในเบราว์เซอร์เท่านั้น\n'
              'ไม่เก็บรหัสผ่าน เลขบัตร หรือ CVV และไม่ทำการสั่งซื้อแทนผู้ใช้',
            ),
          ),
        ),
      ),
    );
  }
}

class PageLayout extends StatelessWidget {
  const PageLayout({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 5),
            Text(subtitle),
            const SizedBox(height: 26),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

class Countdown extends StatefulWidget {
  const Countdown({
    super.key,
    required this.target,
    this.large = false,
  });

  final DateTime target;
  final bool large;

  @override
  State<Countdown> createState() => _CountdownState();
}

class _CountdownState extends State<Countdown> {
  Timer? timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final duration = widget.target.difference(DateTime.now());
    final text = duration.isNegative ? 'LIVE NOW' : formatDuration(duration);

    return Text(
      text,
      style: TextStyle(
        fontSize: widget.large ? 50 : 16,
        fontWeight: FontWeight.w900,
        letterSpacing: 1,
      ),
    );
  }
}

String formatDuration(Duration duration) {
  final days = duration.inDays;
  final hours = duration.inHours.remainder(24).toString().padLeft(2, '0');
  final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');

  return days > 0 ? '${days}D $hours:$minutes:$seconds' : '$hours:$minutes:$seconds';
}
