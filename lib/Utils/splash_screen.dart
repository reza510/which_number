import 'package:flutter/material.dart';
import 'dart:async';

// مدل برای هر آیتم اطلاعاتی
class SplashInfoItem {
  final String key;
  final String value;
  SplashInfoItem({required this.key, required this.value});
}

// مدل‌های نمایشی مختلف
enum DisplayLayout {
  simpleList,
  twoColumn,
  cardGrid,
  minimalPairs,
  profileStyle,
  stackedBold,
  borderedItems,
  centeredList,
}

class SplashScreen extends StatefulWidget {
  final List<SplashInfoItem> items;
  final Duration duration;
  final DisplayLayout layout;
  final VoidCallback onFinish;
  final VoidCallback? earlyCloseCallback;

  const SplashScreen({
    Key? key,
    required this.items,
    required this.duration,
    required this.layout,
    required this.onFinish,
    this.earlyCloseCallback,
  }) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  Timer? _countdownTimer;
  Timer? _closeTimer;
  int _remainingSeconds = 0;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.duration.inSeconds;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        }
      });
    });

    _closeTimer = Timer(widget.duration, () {
      widget.onFinish();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _countdownTimer?.cancel();
    _closeTimer?.cancel();
    super.dispose();
  }

  void _earlyClose() {
    if (widget.earlyCloseCallback != null) {
      widget.earlyCloseCallback!();
    }
  }

  // تابع ساخت چیدمان بر اساس مدل انتخابی
  Widget _buildLayout() {
    // محاسبه ظرفیت استاندارد صفحه (تخمینی)
    final screenHeight = MediaQuery.of(context).size.height;
    final itemHeight = 70.0; // ارتفاع تقریبی هر آیتم
    final standardCapacity = (screenHeight * 0.6 / itemHeight).floor();

    // اگر تعداد آیتم‌ها از ظرفیت استاندارد بیشتر باشد، مدل فشرده‌تر انتخاب می‌شود
    DisplayLayout effectiveLayout = widget.layout;
    if (widget.items.length > standardCapacity) {
      if (widget.layout == DisplayLayout.simpleList) {
        effectiveLayout = DisplayLayout.twoColumn;
      } else if (widget.layout == DisplayLayout.cardGrid) {
        effectiveLayout = DisplayLayout.minimalPairs;
      } else if (widget.layout == DisplayLayout.profileStyle) {
        effectiveLayout = DisplayLayout.stackedBold;
      }
    }

    switch (effectiveLayout) {
      case DisplayLayout.simpleList:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: widget.items
              .map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${item.key}:',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          item.value,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        );

      case DisplayLayout.twoColumn:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: widget.items
                      .map((item) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: Text(
                              item.key,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white70,
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widget.items
                      .map((item) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: Text(
                              item.value,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ),
            ],
          ),
        );

      case DisplayLayout.cardGrid:
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          childAspectRatio: 2.0,
          children: widget.items
              .map((item) => Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white30),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          item.key,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.value,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ))
              .toList(),
        );

      case DisplayLayout.minimalPairs:
        return Wrap(
          alignment: WrapAlignment.center,
          spacing: 20,
          runSpacing: 20,
          children: widget.items
              .map((item) => Container(
                    width: 140,
                    child: Column(
                      children: [
                        Text(
                          item.key,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white60,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.value,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ))
              .toList(),
        );

      case DisplayLayout.profileStyle:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: widget.items
              .map((item) => Container(
                    margin:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 40),
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            item.key,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item.value,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        );

      case DisplayLayout.stackedBold:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: widget.items
              .map((item) => Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 32),
                    child: Column(
                      children: [
                        Text(
                          item.key,
                          style: const TextStyle(
                            fontSize: 14,
                            letterSpacing: 1.5,
                            color: Colors.white60,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.value,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        );

      case DisplayLayout.borderedItems:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: widget.items
              .map((item) => Container(
                    margin:
                        const EdgeInsets.symmetric(vertical: 6, horizontal: 40),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white30, width: 1.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item.key,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          item.value,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        );

      case DisplayLayout.centeredList:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: widget.items
              .map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      children: [
                        Text(
                          item.value,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          item.key,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white60,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ))
              .toList(),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.deepPurple.shade300, Colors.pink.shade200],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLayout(),
                  const SizedBox(height: 40),
                  Column(
                    children: [
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'در حال آماده‌سازی... $_remainingSeconds ثانیه',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  if (widget.earlyCloseCallback != null) ...[
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _earlyClose,
                      style: ElevatedButton.styleFrom(
                        primary: Colors.white, // رنگ پس‌زمینه در نسخه قدیمی
                        onPrimary: Colors.deepPurple, // رنگ متن در نسخه قدیمی
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'ورود مستقیم',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
