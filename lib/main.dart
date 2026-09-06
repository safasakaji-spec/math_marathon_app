import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const MathMarathonApp());
}

class MathMarathonApp extends StatelessWidget {
  const MathMarathonApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ماراثون الرياضيات',
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar', 'AE'),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
      theme: ThemeData(
        primarySwatch: Colors.purple,
        fontFamily: 'Cairo',
        scaffoldBackgroundColor: const Color(0xFFF3E5F5), // لون خلفية هادئ وكيوت
      ),
      home: const WelcomeScreen(),
    );
  }
}

// 1. شاشة الترحيب وإدخال اسم المستخدم
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.calculate_rounded, size: 90, color: Colors.deepPurple),
              const SizedBox(height: 16),
              const Text(
                '🎮 ماراثون الرياضيات 🧠',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.deepPurple),
              ),
              const SizedBox(height: 8),
              const Text(
                'تحدَّ نفسك في العمليات على الأعداد الصحيحة!',
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'اكتب اسمك البطل هنا...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                  prefixIcon: const Icon(Icons.person, color: Colors.deepPurple),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                onPressed: () {
                  String name = _nameController.text.trim();
                  if (name.isEmpty) name = 'بطل الرياضيات';
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => GameScreen(userName: name)),
                  );
                },
                child: const Text('ابدأ الماراثون 🚀', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 2. شاشة اللعبة والماراثون
class GameScreen extends StatefulWidget {
  final String userName;
  const GameScreen({Key? key, required this.userName}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final Random _random = Random();
  int num1 = 0;
  int num2 = 0;
  String operator = '+';
  int correctAnswer = 0;
  
  int currentStreak = 0; // الأسئلة المتتالية الصحيحة الحالية
  int bestStreak = 0;    // أفضل رقم قياسي
  
  List<int> options = [];
  bool? isCorrectAnswer;

  @override
  void initState() {
    super.initState();
    _generateNewQuestion();
  }

  void _generateNewQuestion() {
    setState(() {
  isCorrectAnswer = null;
})
    // توليد أعداد صحيحة (موجبة وسالبة)
    num1 = _random.nextInt(30) - 15; // من -15 إلى 15
    num2 = _random.nextInt(30) - 15;
    
    List<String> ops = ['+', '-', '×'];
    operator = ops[_random.nextInt(ops.length)];

    // منع القسمة على صفر أو نتائج معقدة جداً، واختيار العمليات بذكاء
    if (operator == '+') {
      correctAnswer = num1 + num2;
    } else if (operator == '-') {
      correctAnswer = num1 - num2;
    } else {
      // لنجعل الضرب معقولاً في الماراثون
      num1 = _random.nextInt(12) - 6;
      num2 = _random.nextInt(12) - 6;
      correctAnswer = num1 * num2;
    }

    // توليد خيارات متعددة للإجابة
    Set<int> optionSet = {correctAnswer};
    while (optionSet.length < 4) {
      int wrongAnswer = correctAnswer + (_random.nextInt(10) - 5);
      if (wrongAnswer != correctAnswer) {
        optionSet.add(wrongAnswer);
      }
    }
    options = optionSet.toList();
    options.shuffle();
  }

  void _checkAnswer(int selectedOption) {
    setState(() {
      if (selectedOption == correctAnswer) {
        isCorrectAnswer = true;
        currentStreak++;
        if (currentStreak > bestStreak) {
          bestStreak = currentStreak;
        }
      } else {
        isCorrectAnswer = false;
        currentStreak = 0; // خسارة السلسلة إذا أخطأ
      }
    });

    // الانتظار قليلاً ثم الانتقال للسؤال التالي تلقائياً
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        _generateNewQuestion();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('أهلاً بك، ${widget.userName} ✨'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // عداد الماراثون (السلسلة الحالية وأفضل نتيجة)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildScoreCard('التوالي الحالي 🔥', '$currentStreak', Colors.orange),
                _buildScoreCard('الأفضل (Best) 🏆', '$bestStreak', Colors.amber),
              ],
            ),
            const SizedBox(height: 40),
            
            // صندوق السؤال
            Container(
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.deepPurple.withOpacity(0.1), blurRadius: 10, spreadRadius: 2)
                ],
              ),
              child: Column(
                children: [
                  const Text('كم النتيجة؟', style: TextStyle(color: Colors.grey, fontSize: 16)),
                  const SizedBox(height: 15),
                  Text(
                    '($num1) $operator ($num2)',
                    style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // رسالة التقييم الفوري (صح أو غلط)
            if (isCorrectAnswer != null)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isCorrectAnswer! ? Colors.green.shade100 : Colors.red.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isCorrectAnswer! ? '🎉 بطل! إجابة صحيحة' : '❌ أوتش! إجابة خاطئة',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isCorrectAnswer! ? Colors.green.shade800 : Colors.red.shade800,
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // خيارات الإجابة
            ...options.map((option) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.deepPurple,
                    elevation: 2,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: isCorrectAnswer == null ? () => _checkAnswer(option) : null,
                  child: Text('$option', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                ),
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
