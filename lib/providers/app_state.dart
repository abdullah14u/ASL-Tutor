import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_state.g.dart';

@riverpod
class CurrentSignIndex extends _$CurrentSignIndex {
  @override
  int build() => 0;

  void nextSign() {
    state++;
  }

  void setSign(int index) {
    state = index;
  }
}

@riverpod
class StreakCount extends _$StreakCount {
  @override
  int build() => 0;

  void increment() {
    state++;
  }

  void reset() {
    state = 0;
  }
}

@riverpod
class AccuracyScore extends _$AccuracyScore {
  @override
  double build() => 0.0;

  void updateScore(double newScore) {
    // Keep a running average or just the latest depending on gamification needs
    state = newScore;
  }
}

@riverpod
class IsSignCorrect extends _$IsSignCorrect {
  @override
  bool build() => false;

  void setCorrect(bool isCorrect) {
    state = isCorrect;
  }
}

@riverpod
class IsDarkMode extends _$IsDarkMode {
  @override
  bool build() => true;

  void toggle() {
    state = !state;
  }
}
