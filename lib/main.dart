import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timer/bloc/bloc.dart';
import 'package:timer/ticker.dart';
import 'package:wave/wave.dart';
import 'package:wave/config.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Color.fromRGBO(109, 234, 255, 1),
        accentColor: Color.fromRGBO(72, 74, 126, 1),
        brightness: Brightness.dark,
      ),
      title: 'Flutter Timer',
      home: BlocProvider(
        create: (context) => TimerBloc(ticker: Ticker()),
        child: Timer(),
      ),
    );
  }
}

class Timer extends StatelessWidget {
  static const TextStyle timerTextStyle = TextStyle(
    fontSize: 60,
    fontWeight: FontWeight.bold,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Flutter Timer')),
      body: Stack(
        children: [
          BlocBuilder<TimerBloc, TimerState>(
            builder: (context, state) => Background(),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              BlocBuilder<TimerBloc, TimerState>(
                builder: (context, state) => AwesomeInput(),
              ),
              BlocBuilder<TimerBloc, TimerState>(
                builder: (context, state) => Actions(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AwesomeInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 100.0),
      child: Center(
          child: _mapStateToInputType(
        timerBloc: BlocProvider.of<TimerBloc>(context),
      )),
    );
  }

  Widget _mapStateToInputType({
    TimerBloc timerBloc,
  }) {
    final TimerState currentState = timerBloc.state;

    final String minutesStr =
        ((currentState.duration / 60) % 60).floor().toString().padLeft(2, '0');
    final String secondsStr =
        (currentState.duration % 60).floor().toString().padLeft(2, '0');

    if (currentState is TimerInitial) {
      return Padding(
        padding: EdgeInsets.only(left: 100, right: 100),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: TextField(
                style: Timer.timerTextStyle,
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  hintText: "Penis",
                ),
                onChanged: (value) =>
                    timerBloc.add(MinutesSetEvent(int.parse(value))),
              ),
            ),
            Text(
              ":",
              style: Timer.timerTextStyle,
            ),
            Expanded(
              child: TextField(
                style: Timer.timerTextStyle,
                decoration: InputDecoration(
                  hintText: "Penis",
                ),
                onChanged: (value) =>
                    timerBloc.add(SecondsSetEvent(int.parse(value))),
              ),
            ),
          ],
        ),
      );
    }

    return Text(
      '$minutesStr:$secondsStr',
      style: Timer.timerTextStyle,
    );
  }
}

class Actions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: _mapStateToActionButtons(
        timerBloc: BlocProvider.of<TimerBloc>(context),
      ),
    );
  }

  List<Widget> _mapStateToActionButtons({
    TimerBloc timerBloc,
  }) {
    final TimerState currentState = timerBloc.state;
    if (currentState is TimerInitial) {
      return [
        FloatingActionButton(
          child: Icon(Icons.play_arrow),
          onPressed: () =>
              timerBloc.add(TimerStartedEvent(currentState.duration)),
        ),
      ];
    }
    if (currentState is InvalidTimerState) {
      return [
        FloatingActionButton(
          child: Icon(Icons.replay),
          onPressed: () => timerBloc.add(TimerResetEvent()),
        ),
      ];
    }
    if (currentState is TimerRunInProgressState) {
      return [
        FloatingActionButton(
          child: Icon(Icons.pause),
          onPressed: () => timerBloc.add(TimerPausedEvent()),
        ),
        FloatingActionButton(
          child: Icon(Icons.replay),
          onPressed: () => timerBloc.add(TimerResetEvent()),
        ),
      ];
    }
    if (currentState is TimerRunPauseState) {
      return [
        FloatingActionButton(
          child: Icon(Icons.play_arrow),
          onPressed: () => timerBloc.add(TimerResumedEvent()),
        ),
        FloatingActionButton(
          child: Icon(Icons.replay),
          onPressed: () => timerBloc.add(TimerResetEvent()),
        ),
      ];
    }
    if (currentState is TimerRunComplete) {
      return [
        FloatingActionButton(
          child: Icon(Icons.replay),
          onPressed: () => timerBloc.add(TimerResetEvent()),
        ),
      ];
    }
    return [];
  }
}

class Background extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WaveWidget(
      config: CustomConfig(
        gradients:
            _mapStateToColors(timerBloc: BlocProvider.of<TimerBloc>(context)),
        durations: [19440, 10800, 6000],
        heightPercentages: [0.03, 0.01, 0.02],
        gradientBegin: Alignment.bottomCenter,
        gradientEnd: Alignment.topCenter,
      ),
      size: Size(double.infinity, double.infinity),
      waveAmplitude: 25,
      backgroundColor: Colors.blue[50],
    );
  }

  List<List<Color>> _mapStateToColors({
    TimerBloc timerBloc,
  }) {
    if (timerBloc.state is InvalidTimerState) {
      return [
        [Colors.red, Color(0xEEF44336)],
        [Colors.red[800], Color(0x77E57373)],
        [Colors.purple, Color(0x66FF9800)],
        [Colors.pink, Color(0x55FFEB3B)]
      ];
    }

    return [
      [
        Color.fromRGBO(72, 74, 126, 1),
        Color.fromRGBO(125, 170, 206, 1),
        Color.fromRGBO(184, 189, 245, 0.7)
      ],
      [
        Color.fromRGBO(72, 74, 126, 1),
        Color.fromRGBO(125, 170, 206, 1),
        Color.fromRGBO(172, 182, 219, 0.7)
      ],
      [
        Color.fromRGBO(72, 73, 126, 1),
        Color.fromRGBO(125, 170, 206, 1),
        Color.fromRGBO(190, 238, 246, 0.7)
      ],
    ];
  }
}
