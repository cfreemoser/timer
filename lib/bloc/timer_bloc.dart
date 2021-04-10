import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:timer/ticker.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'timer_event.dart';
part 'timer_state.dart';

class TimerBloc extends Bloc<TimerEvent, TimerState> {
  final Ticker _ticker;
  int _minutes = 0;
  int _secounds = 0;

  StreamSubscription<int> _tickerSubscription;

  TimerBloc({@required Ticker ticker})
      : assert(ticker != null),
        _ticker = ticker,
        super(TimerInitial(0));

  @override
  Stream<TimerState> mapEventToState(TimerEvent event) async* {
    if (event is TimerStartedEvent) {
      yield* _mapTimerStartedToState(event);
    } else if (event is TimerTickedEvent) {
      yield* _mapTimerTickedToState(event);
    } else if (event is TimerPausedEvent) {
      yield* _mapTimerPausedToState(event);
    } else if (event is TimerResumedEvent) {
      yield* _mapTimerResumedToState(event);
    } else if (event is TimerResetEvent) {
      yield* _mapTimerResetToState(event);
    } else if (event is MinutesSetEvent) {
      yield* _mapMinutesSetToState(event);
    } else if (event is SecondsSetEvent) {
      yield* _mapSecondsSetToState(event);
    }
  }

  Stream<TimerState> _mapTimerStartedToState(TimerStartedEvent start) async* {
    // reset
    _tickerSubscription?.cancel();
    _tickerSubscription = _ticker
        .tick(ticks: start.duration)
        .listen((duration) => add(TimerTickedEvent(duration)));

    yield TimerRunInProgressState(start.duration);
  }

  Stream<TimerState> _mapTimerTickedToState(TimerTickedEvent ticked) async* {
    if (ticked.duration == 0) {
      yield TimerRunComplete(0);
    }

    yield TimerRunInProgressState(ticked.duration);
  }

  Stream<TimerState> _mapTimerResumedToState(TimerResumedEvent resume) async* {
    if (state is TimerRunPauseState) {
      _tickerSubscription?.resume();
      yield TimerRunInProgressState(state.duration);
    }
  }

  Stream<TimerState> _mapTimerPausedToState(TimerPausedEvent pause) async* {
    if (state is TimerRunInProgressState) {
      _tickerSubscription?.pause();
      yield TimerRunPauseState(state.duration);
    }
  }

  Stream<TimerState> _mapTimerResetToState(TimerResetEvent resetEvent) async* {
    _tickerSubscription?.cancel();
    _minutes = 0;
    _secounds = 0;
    yield TimerInitial(0);
  }

  Stream<TimerState> _mapMinutesSetToState(
      MinutesSetEvent minutesSetEvent) async* {
    if (_isValidTime(minutesSetEvent.minutes, _secounds)) {
      yield InvalidTimerState(-1);
    } else {
      _minutes = minutesSetEvent.minutes;
      yield TimerInitial(_minutes * 60 + _secounds);
    }
  }

  Stream<TimerState> _mapSecondsSetToState(
      SecondsSetEvent secondsSetEvent) async* {
    if (_isValidTime(_minutes, secondsSetEvent.seconds)) {
      yield InvalidTimerState(-1);
    } else {
      _secounds = secondsSetEvent.seconds;
      yield TimerInitial(_minutes * 60 + _secounds);
    }
  }

  bool _isValidTime(int minutes, int secounds) {
    return 3600 < minutes * 60 + secounds;
  }
}
