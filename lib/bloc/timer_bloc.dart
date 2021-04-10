import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:timer/ticker.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'timer_event.dart';
part 'timer_state.dart';

class TimerBloc extends Bloc<TimerEvent, TimerState> {
  final Ticker _ticker;
  static const int _defaultDuration = 60;

  StreamSubscription<int> _tickerSubscription;

  TimerBloc({@required Ticker ticker})
      : assert(ticker != null),
        _ticker = ticker,
        super(TimerInitial(_defaultDuration));

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
    }
  }

  Stream<TimerState> _mapTimerStartedToState(TimerStartedEvent start) async* {
    // reset
    _tickerSubscription?.cancel();
    _tickerSubscription = _ticker
        .tick(ticks: start.duration)
        .listen((duration) => add(TimerTickedEvent(duration: duration)));

    yield TimerRunInProgressState(start.duration);
  }


  Stream<TimerState> _mapTimerTickedToState(TimerTickedEvent ticked) async* {
    if (ticked.duration == 0) {
      yield TimerRunComplete(0);
    }

    yield TimerRunInProgressState(ticked.duration);
  }

  Stream<TimerState> _mapTimerResumedToState(TimerResumedEvent resume) async* {
    if (state is TimerRunPause) {
      _tickerSubscription?.resume();
      yield TimerRunInProgressState(state.duration);
    }
  }

  Stream<TimerState> _mapTimerPausedToState(TimerPausedEvent pause) async* {
    if (state is TimerRunInProgressState) {
      _tickerSubscription?.pause();
      yield TimerRunPause(state.duration);
    }
  }

  Stream<TimerState> _mapTimerResetToState(TimerResetEvent resetEvent) async* {
    _tickerSubscription?.cancel();
    yield TimerInitial(_defaultDuration);
  }
}
