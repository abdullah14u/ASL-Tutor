import 'package:flutter_riverpod/flutter_riverpod.dart';

class CurrentSignIndex extends Notifier<int> {
  @override
  int build() => 0;

  void nextSign() {
    state++;
  }

  void setSign(int index) {
    state = index;
  }
}

final currentSignIndexProvider = NotifierProvider<CurrentSignIndex, int>(() => CurrentSignIndex());


class StreakCount extends Notifier<int> {
  @override
  int build() => 0;

  void increment() {
    state++;
  }

  void reset() {
    state = 0;
  }
}

final streakCountProvider = NotifierProvider<StreakCount, int>(() => StreakCount());


class AccuracyScore extends Notifier<double> {
  @override
  double build() => 0.0;

  void updateScore(double newScore) {
    // Keep a running average or just the latest depending on gamification needs
    state = newScore;
  }
}

final accuracyScoreProvider = NotifierProvider<AccuracyScore, double>(() => AccuracyScore());


class IsSignCorrect extends Notifier<bool> {
  @override
  bool build() => false;

  void setCorrect(bool isCorrect) {
    state = isCorrect;
  }
}

final isSignCorrectProvider = NotifierProvider<IsSignCorrect, bool>(() => IsSignCorrect());


class IsDarkMode extends Notifier<bool> {
  @override
  bool build() => true;

  void toggle() {
    state = !state;
  }
}

final isDarkModeProvider = NotifierProvider<IsDarkMode, bool>(() => IsDarkMode());
