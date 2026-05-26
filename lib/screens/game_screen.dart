import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/race_data.dart';
import '../models/user_service.dart';
import '../models/sound_service.dart';
import 'instruction_screen.dart';
import 'result_screen.dart';

class GameScreen extends StatefulWidget {
  final String username;

  GameScreen({required this.username});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  double balance = 1000000;
  List<double> carValues = [0.0, 0.0, 0.0];
  List<TextEditingController> controllers = List.generate(3, (index) => TextEditingController(text: "0"));
  bool isRacing = false;
  Timer? timer;
  String soundCaption = '';

  // Tốc độ và gia tốc ngẫu nhiên riêng biệt cho từng xe
  List<double> carSpeeds = [0.0, 0.0, 0.0];
  List<double> carAccelerations = [0.0, 0.0, 0.0];

  @override
  void initState() {
    super.initState();
    _loadBalance();
  }

  Future<void> _loadBalance() async {
    double currentBalance = await UserService.getBalance(widget.username);
    setState(() {
      balance = currentBalance;
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    for (var controller in controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void startRace() {
    // 1. Validate cược của từng ô
    double totalBet = 0;
    List<double> bets = [0, 0, 0];

    for (int i = 0; i < 3; i++) {
      String text = controllers[i].text.trim();
      if (text.isEmpty) {
        text = "0";
      }

      double? betVal = double.tryParse(text);
      if (betVal == null) {
        _showError("Tiền cược xe số ${i + 1} phải là một số hợp lệ!");
        return;
      }
      if (betVal < 0) {
        _showError("Tiền cược xe số ${i + 1} không được âm!");
        return;
      }
      bets[i] = betVal;
      totalBet += betVal;
    }

    // 2. Validate tài chính tổng
    if (totalBet <= 0) {
      _showError("Vui lòng đặt cược ít nhất một xe để bắt đầu cuộc đua!");
      return;
    }
    if (totalBet > balance) {
      _showError("Tổng tiền cược (${UserService.formatMoney(totalBet)} VNĐ) vượt quá số dư hiện có!");
      return;
    }

    // Khóa cược, khởi tạo xe và random gia tốc
    setState(() {
      isRacing = true;
      carValues = [0.0, 0.0, 0.0];
      soundCaption = "🔊 ĐỘNG CƠ GẦM RÚ: VROOOOOOMM!!! ⚡";
      // Random tốc độ khởi điểm và gia tốc
      final rand = Random();
      for (int i = 0; i < 3; i++) {
        // Tốc độ ban đầu từ 0.002 đến 0.008
        carSpeeds[i] = 0.002 + rand.nextDouble() * 0.006;
        // Gia tốc từ 0.0005 đến 0.0025
        carAccelerations[i] = 0.0005 + rand.nextDouble() * 0.002;
      }
    });

    // Phát nhạc động cơ khi đua xe
    SoundService.playEngineStart();

    // Tự động xoá caption âm thanh sau 2.5 giây
    Future.delayed(Duration(milliseconds: 2500), () {
      if (mounted && soundCaption.contains("ĐỘNG CƠ")) {
        setState(() {
          soundCaption = "";
        });
      }
    });

    // Vận hành cuộc đua
    timer = Timer.periodic(Duration(milliseconds: 50), (t) {
      setState(() {
        for (int i = 0; i < 3; i++) {
          // Cộng dồn gia tốc vào tốc độ
          carSpeeds[i] += carAccelerations[i];
          // Tiến trình tịnh tiến của xe
          carValues[i] += carSpeeds[i];

          if (carValues[i] >= 1.0) {
            carValues[i] = 1.0;
            t.cancel();
            finishRace(i, bets, totalBet);
            break;
          }
        }
      });
    });
  }

  void finishRace(int winner, List<double> bets, double totalBet) async {
    double betOnWinner = bets[winner];
    double winAmount = betOnWinner * 3;
    double profit = winAmount - totalBet;

    double newBalance = balance + profit;
    if (newBalance < 0) newBalance = 0;

    // Lưu số dư mới vào SharedPreferences
    await UserService.updateBalance(widget.username, newBalance);

    setState(() {
      balance = newBalance;
      soundCaption = "🔊 PHANH CHÁY ĐƯỜNG: KÉEEEEEÉTTT!!! 🏁";
    });

    // Phát âm thanh phanh xe cháy đường khi về đích
    SoundService.playBrakeScreech();

    // Tự động xoá caption âm thanh sau 2.5 giây
    Future.delayed(Duration(milliseconds: 2500), () {
      if (mounted && soundCaption.contains("PHANH")) {
        setState(() {
          soundCaption = "";
        });
      }
    });

    Future.delayed(Duration(milliseconds: 600), () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(
            username: widget.username,
            result: RaceResult(
              winnerIndex: winner,
              totalBet: totalBet,
              winAmount: winAmount,
              profit: profit,
              currentBalance: newBalance,
            ),
          ),
        ),
      ).then((_) {
        // Reload balance from database after returning from ResultScreen
        _loadBalance();
        setState(() {
          isRacing = false;
          soundCaption = ""; // Clear sound caption just in case
        });
      });
    });
  }

  void resetRace() {
    setState(() {
      carValues = [0.0, 0.0, 0.0];
      for (var c in controllers) {
        c.text = "0";
      }
    });
    _showError("Đã reset đường đua và đưa các mức cược về 0.");
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "🏎️ PHÒNG GAME SIÊU CẤP",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Color(0xFF0f0c1b),
        elevation: 0,
        actions: [
          // Nút xem hướng dẫn
          IconButton(
            icon: Icon(Icons.help_outline, color: Colors.amberAccent),
            tooltip: 'Hướng dẫn chơi',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => InstructionScreen(username: widget.username),
                ),
              );
            },
          ),
          // Nút logout
          IconButton(
            icon: Icon(Icons.logout, color: Colors.redAccent),
            tooltip: 'Đăng xuất',
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0f0c1b), Color(0xFF201a30)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            _buildBalanceHeader(),
            if (soundCaption.isNotEmpty) ...[
              AnimatedContainer(
                duration: Duration(milliseconds: 300),
                margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amberAccent.withOpacity(0.5)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amberAccent.withOpacity(0.1),
                      blurRadius: 8,
                      spreadRadius: 1,
                    )
                  ],
                ),
                child: Text(
                  soundCaption,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.amberAccent,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 10),
                itemCount: 3,
                itemBuilder: (context, i) => _buildRacetrack(i),
              ),
            ),
            _buildActionControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceHeader() {
    return Container(
      margin: EdgeInsets.all(15),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.amberAccent.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.amberAccent,
                child: Icon(Icons.person, color: Colors.black),
              ),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.username,
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text("Racer", style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("SỐ DƯ HIỆN TẠI", style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text(
                "${UserService.formatMoney(balance)} VNĐ",
                style: TextStyle(color: Colors.greenAccent, fontSize: 18, fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRacetrack(int index) {
    Color trackColor;
    Color carColor;
    String carName;

    if (index == 0) {
      trackColor = Colors.redAccent.withOpacity(0.15);
      carColor = Colors.redAccent;
      carName = "SIÊU XE ĐỎ 🔥";
    } else if (index == 1) {
      trackColor = Colors.blueAccent.withOpacity(0.15);
      carColor = Colors.blueAccent;
      carName = "TIEU TỬ XANH ⚡";
    } else {
      trackColor = Colors.amberAccent.withOpacity(0.15);
      carColor = Colors.amberAccent;
      carName = "HOÀNG KIM GIÁP 🏆";
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: trackColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: carColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                carName,
                style: TextStyle(color: carColor, fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Container(
                width: 100,
                height: 38,
                child: TextField(
                  controller: controllers[index],
                  keyboardType: TextInputType.number,
                  enabled: !isRacing,
                  style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    hintText: "Đặt cược",
                    hintStyle: TextStyle(color: Colors.grey[600], fontSize: 12),
                    filled: true,
                    fillColor: Colors.black26,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: carColor, width: 1.5),
                    ),
                  ),
                ),
              )
            ],
          ),
          SizedBox(height: 12),
          // Đường đua tịnh tiến dùng LayoutBuilder để Responsive
          LayoutBuilder(
            builder: (context, constraints) {
              double maxTrackWidth = constraints.maxWidth - 40; // Trừ chiều rộng của xe đua
              double leftPosition = carValues[index] * maxTrackWidth;
              if (leftPosition < 0) leftPosition = 0;

              return Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                ),
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    // Các vạch phân làn tượng trưng cho trường đua chuyên nghiệp
                    Positioned.fill(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(
                          10,
                          (index) => Container(width: 3, height: 8, color: Colors.grey[800]),
                        ),
                      ),
                    ),
                    // Vạch đích
                    Positioned(
                      right: 15,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: 6,
                        color: Colors.redAccent,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(
                            4,
                            (index) => Container(
                              width: 6,
                              height: 6,
                              color: index % 2 == 0 ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Xe chuyển động tịnh tiến
                    AnimatedPositioned(
                      duration: Duration(milliseconds: 50),
                      left: leftPosition,
                      child: Transform.rotate(
                        angle: 0.0,
                        child: Icon(
                          Icons.directions_car_filled,
                          color: carColor,
                          size: 32,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          )
        ],
      ),
    );
  }

  Widget _buildActionControls() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF0f0c1b),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              icon: Icon(Icons.flash_on),
              label: Text("START RACE"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent[700],
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: isRacing ? null : startRace,
            ),
          ),
          SizedBox(width: 15),
          ElevatedButton.icon(
            icon: Icon(Icons.restart_alt),
            label: Text("RESET"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orangeAccent[700],
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: isRacing ? null : resetRace,
          ),
        ],
      ),
    );
  }
}