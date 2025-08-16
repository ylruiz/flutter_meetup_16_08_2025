import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_meetup_16_08_2025/models/onboarding_page_data.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../data/pages_list.dart';
import '../paths.dart';

/// local provider for current page index
final onboardingPageProvider = StateProvider<int>((ref) => 0);

@RoutePage()
class OnboardingScreen extends HookConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = usePageController();
    final router = context.router;

    final currentPage = ref.watch(onboardingPageProvider);
    final isLastPage = currentPage == pages.length - 1;

    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: controller,
                itemCount: pages.length,
                onPageChanged: (index) =>
                    ref.read(onboardingPageProvider.notifier).state = index,
                itemBuilder: (context, index) {
                  final page = pages[index];
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: page.animationType == AnimationType.network
                            ? Lottie.network(page.animation, repeat: true)
                            : LottieBuilder.asset(page.animation),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        page.title,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        page.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                    ],
                  );
                },
              ),
            ),
            SmoothPageIndicator(
              controller: controller,
              count: pages.length,
              effect: ExpandingDotsEffect(
                activeDotColor: Theme.of(context).primaryColor,
                dotHeight: 8,
                dotWidth: 8,
              ),
            ),
            const SizedBox(height: 24),
            isLastPage
                ? ElevatedButton(
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('isOnboardingCompleted', true);
                      router.replacePath(Paths.home);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text("Get Started"),
                  )
                : TextButton(
                    onPressed: () => controller.nextPage(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                    ),
                    child: const Text("Next"),
                  ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
