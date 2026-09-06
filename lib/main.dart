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
        scaffoldBackgroundColor: const Color(0xFFF3E5F5),
      ),
      home: const WelcomeScreen(),
    );
  }
}

// نموذج لحفظ بيانات اللاعبين وأعلى سكور لكل لاعب
class PlayerScore {
  String name;
  int score;
  PlayerScore({required this.name, required this.score});
}

class LeaderboardData {
  static List<PlayerScore> players = [];

  static void updateScore(String name, int score) {
    name = name.trim();
    var existingPlayer = players.firstWhere(
      (p) => p.name.toLowerCase() == name.toLowerCase(),
      orElse: () => PlayerScore(name: '', score: -1),
    );

    if (existingPlayer.score == -1) {
      players.add(PlayerScore(name: name, score: score));
    } else {
      if (score > existingPlayer.score) {
        existingPlayer.score = score;
      }
    }
    players.sort((a, b) => b.score.compareTo(a.score));
  }

  static List<PlayerScore> getTopPlayers() {
    return players.take(3).toList();
  }
}

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    List<PlayerScore> topPlayers = LeaderboardData.getTopPlayers();

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.calculate_rounded, size: 80, color: Colors.deepPurple),
              const SizedBox(height: 12),
              const Text(
                '🎮 ماراثون الرياضيات 🧠',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepPurple),
              ),
              const SizedBox(height: 6),
              const Text(
                'تحدّ نفسك في العمليات على الأعداد الصحيحة',
                style: TextStyle(fontSize: 13, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              
              if (topPlayers.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [const BoxShadow(color: Colors.black12, blurRadius: 4)],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        '🏆 لوحة الشرف (أفضل 3 لاعبين)',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                      ),
                      const Divider(),
                      ...topPlayers.asMap().entries.map((entry) {
                        int index = entry.key;
                        var player = entry.value;
                        String medal = index == 0 ? '🥇' : (index == 1 ? '🥈' : '🥉');
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('$medal ${player.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text('السكور: ${player.score}', style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'اكتب اسمك هنا...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                  prefixIcon: const Icon(Icons.person, color: Colors.deepPurple),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                onPressed: () {
                  String name = _nameController.text.trim();
                  if (name.isEmpty) name = 'لاعب مجهول';
                  
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => GameScreen(userName: name)),
                  ).then((_) {
                    setState(() {});
                  });
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

class GameScreen extends StatefulWidget {
  final String userName;
  const GameScreen({Key? key, required this.userName}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  final Random _random = Random();
  int num1 = 0;
  int num2 = 0;
  String operator = '+';
  int correctAnswer = 0;
  
  int currentScore = 0;
  List<int> options = [];

  late AnimationController _fireworksController;

  @override
  void initState() {
    super.initState();
    _fireworksController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _generateNewQuestion();
  }

  @override
  void dispose() {
    _fireworksController.dispose();
    super.dispose();
  }

  void _generateNewQuestion() {
    List<String> ops = ['+', '-', '×', '÷'];
    operator = ops[_random.nextInt(ops.length)];

    if (operator == '+') {
      num1 = _random.nextInt(30) - 15;
      num2 = _random.nextInt(30) - 15;
      correctAnswer = num1 + num2;
    } else if (operator == '-') {
      num1 = _random.nextInt(30) - 15;
      num2 = _random.nextInt(30) - 15;
      correctAnswer = num1 - num2;
    } else if (operator == '×') {
      num1 = _random.nextInt(12) - 6;
      num2 = _random.nextInt(12) - 6;
      correctAnswer = num1 * num2;
    } else {
      num2 = _random.nextInt(10) + 1;
      int quotient = _random.nextInt(10) - 5;
      correctAnswer = quotient;
      num1 = num2 * correctAnswer;
    }

    Set<int> optionSet = {correctAnswer};
    while (optionSet.length < 4) {
      int wrongAnswer = correctAnswer + (_random.nextInt(10) - 5);
      if (wrongAnswer != correctAnswer) {
        optionSet.add(wrongAnswer);
      }
    }
    options = optionSet.toList();
    options.shuffle();
    setState(() {});
  }

  void _checkAnswer(int selectedOption) {
    if (selectedOption == correctAnswer) {
      currentScore++;
      LeaderboardData.updateScore(widget.userName, currentScore);
      _generateNewQuestion();
    } else {
      LeaderboardData.updateScore(widget.userName, currentScore);
      _showGameOverDialog();
    }
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: AnimatedBuilder(
          animation: _fireworksController,
          builder: (context, child) {
            return Transform.scale(
              scale: 1.0 + (_fireworksController.value * 0.1),
              child: const Text('🎉 انتهت اللعبة! 🎆', textAlign: TextAlign.center, style: TextStyle(color: Colors.deepPurple)),
            );
          },
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'عادي يا بطل! ستجيب أفضل المرة القادمة وتجيب نتيجة أعلى بكثير 💪✨',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                'السكور النهائي: $currentScore 🏆',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 20),
              ),
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('العودة للرئيسية 🏠', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('البطل: ${widget.userName} ✨'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildScoreCard('النقاط الحالية 🔥', '$currentScore', Colors.orange),
              ],
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
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
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      '($num1) $operator ($num2)',
                      style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            ...options.map((option) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.deepPurple,
                    elevation: 2,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () => _checkAnswer(option),
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text('$option', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  ),
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
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [const BoxShadow(color: Colors.black12, blurRadius: 5)],
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
