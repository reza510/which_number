import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'حدس عدد',
      theme: ThemeData(
        primarySwatch: Colors.blue,fontFamily: 'Vazir', 
        // در صورت تمایل فونت فارسی اضافه کنید
      ),
      debugShowCheckedModeBanner: false,
      home: GuessGame(),
    );
  }
}

class GuessGame extends StatefulWidget {
  @override
  _GuessGameState createState() => _GuessGameState();
}

class _GuessGameState extends State<GuessGame> {
  late int _targetNumber;
  late int _remainingAttempts;
  late bool _isGameActive;
  late String _message;
  late IconData? _arrowIcon;
  // String get _isArrowUp => _arrowIcon == Icons.arrow_upward?'up':_arrowIcon==Icons.arrow_downward?'down':'null';
  bool get _isArrowUp => _arrowIcon == Icons.arrow_upward;
  late Color _arrowColor;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _resetGame();
  }

  void _resetGame() {
    setState(() {
      _targetNumber = Random().nextInt(100) + 1; // عدد بین ۱ تا ۱۰۰
      _remainingAttempts = 5;
      _isGameActive = true;
      _message = '';
      _arrowIcon = null;
      _arrowColor = Colors.transparent;
      _controller.clear();
    });
  }

  void _checkGuess() {
    if (!_isGameActive) return;

    final String input = _controller.text;
    if (input.isEmpty) {
      setState(() {
        _message = 'لطفاً یک عدد وارد کنید.';
        _arrowIcon = null;
        _arrowColor = Colors.transparent;
      });
      return;
    }

    final int? guess = int.tryParse(input);
    print(_targetNumber);
    if (guess == null) {
      setState(() {
        _message = 'عدد معتبر وارد کنید.';
        _arrowIcon = null;
        _arrowColor = Colors.transparent;
      });
      return;
    }

    if (guess < 1 || guess > 100) {
      setState(() {
        _message = 'عدد باید بین ۱ تا ۱۰۰ باشد.';
        _arrowIcon = null;
        _arrowColor = Colors.transparent;
      });
      return;
    }

    setState(() {
      if (guess == _targetNumber) {
        // برد
        _message = '🎉 تبریک! درست حدس زدی';
        _arrowIcon = Icons.task_alt_outlined;
        _arrowColor = Colors.cyan;
        _isGameActive = false;
      } else {
        _remainingAttempts--;
        if (_remainingAttempts == 0) {
          // باخت
          _message = '😢 باختی! عدد $_targetNumber بود.';
          _arrowIcon = null;
          _arrowColor = Colors.transparent;
          _isGameActive = false;
        } else {
          // راهنمایی با فلش
          if (guess < _targetNumber) {
            _arrowIcon = Icons.arrow_upward;
            _arrowColor = Colors.green;
            _message = 'عدد از $guess بزرگتره';
          } else {
            _arrowIcon = Icons.arrow_downward;
            _arrowColor = Colors.red;
            _message = 'عدد از $guess کوچیکتره';
          }
        }
      }
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.deepPurple.shade400, Colors.blue.shade300],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 20,
              shadowColor: Colors.black45,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              child: Container(
                padding: const EdgeInsets.all(32.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Colors.white.withOpacity(0.9),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 15,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '🎯 حدس عدد',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            blurRadius: 5,
                            color: Colors.grey,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'عدد بین ۱ تا ۱۰۰ را حدس بزنید',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // نمایش تعداد شانس‌ها
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          child: Icon(
                            index < _remainingAttempts
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: Colors.red,
                            size: 35,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 30),

                    // فیلد ورودی
                    TextField(
                      controller: _controller,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 24),
                      decoration: InputDecoration(
                        hintText: 'حدس ات چیه؟',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 20,
                          horizontal: 20,
                        ),
                      ),
                      enabled: _isGameActive,
                    ),
                    const SizedBox(height: 20),

                    // دکمه حدس
                    RaisedButton(
                      onPressed: _isGameActive ? _checkGuess : null,
                      color: Colors.deepPurple,
                      textColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 50,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Text(
                        'درسته؟',
                        style: TextStyle(fontSize: 22),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // نمایش فلش راهنما با انیمیشن ساده (AnimatedSwitcher)
                    AnimatedCrossFade(
                      duration: const Duration(milliseconds: 300),
                      firstChild: const Icon(
                        Icons.arrow_upward,
                        color: Colors.green,
                        size: 80,
                      ),
                      secondChild: Icon(
                        _arrowIcon,
                        color: _arrowColor,
                        size: 80,
                      ),
                      crossFadeState: _isArrowUp
                          ? CrossFadeState.showFirst
                          : CrossFadeState.showSecond,
                      layoutBuilder:
                          (topChild, topChildKey, bottomChild, bottomChildKey) {
                        // اطمینان از ثابت ماندن اندازه
                        return SizedBox(
                          height: 80,
                          width: 80,
                          child: Stack(
                            children: [
                              Positioned.fill(
                                  child: bottomChild, key: bottomChildKey),
                              Positioned.fill(
                                  child: topChild, key: topChildKey),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    // نمایش پیام
                    Text(
                      _message,
                      style: TextStyle(
                        fontSize: 18,
                        color: _arrowColor == Colors.green
                            ? Colors.green
                            : (_arrowColor == Colors.red
                                ? Colors.red
                                : Colors.black),
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    // دکمه بازی دوباره
                    OutlineButton(
                      onPressed: _resetGame,
                      borderSide: const BorderSide(color: Colors.deepPurple),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 7,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.repeat,
                        color: Colors.purple,
                        size: 25,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
