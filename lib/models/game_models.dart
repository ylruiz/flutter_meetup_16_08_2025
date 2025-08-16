class Answer {
  final String text;
  final bool isCorrect;
  const Answer({required this.text, required this.isCorrect});
}

class Question {
  /// Path to the audio asset or URL to play for this question
  final String audioPath;
  final List<Answer> answers;
  const Question({required this.audioPath, required this.answers});
}
