import '../models/onboarding_page_data.dart';

final pages = [
  OnboardingPageData(
    animation: 'assets/animations/hello.json',
    animationType: AnimationType.asset,
    title: "Welcome!",
    description: "Discover new phrases and categories with ease.",
  ),
  OnboardingPageData(
    animation: 'https://assets3.lottiefiles.com/packages/lf20_touohxv0.json',
    animationType: AnimationType.network,
    title: "Learn Faster",
    description: "Use audio and visuals to remember phrases quickly.",
  ),
  OnboardingPageData(
    animation: 'assets/animations/stopwatch_timer.json',
    animationType: AnimationType.asset,
    title: "Get Started",
    description: "Start exploring the phrasebook now!",
  ),
];
