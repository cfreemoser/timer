part of 'timer_bloc.dart';

abstract class TimerState extends Equatable {
  final int duration;

  const TimerState(this.duration);

  @override
  List<Object> get props => [duration];
}

class TimerInitial extends TimerState {
  const TimerInitial(int duration) : super(duration);

  @override
  String toString() => 'TimerInitial { duration: $duration }';
}

class TimerRunPauseState extends TimerState {
  const TimerRunPauseState(int duration) : super(duration);

  @override
  String toString() => 'TimerRunPause { duration: $duration }';
}

class TimerRunInProgressState extends TimerState {
  const TimerRunInProgressState(int duration) : super(duration);

  @override
  String toString() => 'TimerRunInProgress { duration: $duration }';
}

class TimerRunComplete extends TimerState {
  const TimerRunComplete(int duration) : super(duration);

  @override
  String toString() => 'TimerRunComplete { duration: $duration }';
}
class InvalidTimerState extends TimerState {
  const InvalidTimerState(int duration) : super(-1);

  @override
  String toString() => 'InvalidTimerState';
}
