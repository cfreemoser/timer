part of 'timer_bloc.dart';

abstract class TimerEvent extends Equatable {
  const TimerEvent();

  @override
  List<Object> get props => [];
}

class TimerStartedEvent extends TimerEvent {
  final int duration;

  const TimerStartedEvent(this.duration);

  @override
  String toString() => "TimerStarted { duration: $duration }";
}

class TimerPausedEvent extends TimerEvent {}

class TimerResumedEvent extends TimerEvent {}

class TimerResetEvent extends TimerEvent {}

class TimerTickedEvent extends TimerEvent {
  final int duration;

  const TimerTickedEvent(this.duration);

  @override
  List<Object> get props => [duration];

  @override
  String toString() => "TimerTicked { duration: $duration }";
}
