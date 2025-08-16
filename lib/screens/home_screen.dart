import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../pages/phrase_book_screen.dart';
import '../pages/translate_page.dart';

final selectedIndexProvider = StateProvider<int>((ref) => 0);

@RoutePage()
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const List<Widget> _pages = <Widget>[
    TranslatePage(),
    PhraseBookPage(),
    Center(child: Text('Game content goes here')),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedIndexProvider);

    return Scaffold(
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
          BottomNavigationBarItem(icon: Icon(PhosphorIconsRegular.bookOpen), label: 'Phrase Book'),
          BottomNavigationBarItem(
            icon: Icon(PhosphorIconsRegular.questionMark),
            label: 'Quiz',
          ),
        ],
      ),
    );
  }
}
