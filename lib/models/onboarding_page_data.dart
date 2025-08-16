enum AnimationType { network, asset }

class OnboardingPageData {
  final String animation;
  final AnimationType animationType;
  final String title;
  final String description;

  OnboardingPageData({
    required this.animation,
    required this.animationType,
    required this.title,
    required this.description,
  });
}
