import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

final selectedIndexProvider = StateProvider<int>((ref) => 0);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const List<Widget> _pages = <Widget>[
    Center(child: Text('Translate content goes here')),
    Center(child: Text('Prompts content goes here')),
    Center(child: Text('Game content goes here')),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedIndexProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: _pages[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) =>
            ref.read(selectedIndexProvider.notifier).state = index,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(PhosphorIconsRegular.chatText, size: 32.0),
            label: 'Translator',
          ),
          BottomNavigationBarItem(
            icon: Icon(PhosphorIconsRegular.bookOpen, size: 32.0),
            label: 'Phrase book',
          ),
          BottomNavigationBarItem(
            icon: Icon(PhosphorIconsRegular.questionMark, size: 32.0),
            label: 'Quiz',
          ),
        ],
      ),
    );
  }
}
