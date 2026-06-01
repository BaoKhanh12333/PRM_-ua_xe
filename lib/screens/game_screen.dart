import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/race_data.dart';
import '../models/user_service.dart';
import '../models/sound_service.dart';
import 'instruction_screen.dart';
import 'result_screen.dart';

// Ferrari F40 - xe đỏ (mũi xe bên PHẢI, đuôi bên TRÁI)
const String _ferrariSvg = '''
<svg viewBox="0 0 100 50" xmlns="http://www.w3.org/2000/svg">
  <path d="M5,37 L6,28 L10,22 L20,17 L38,13 L56,11 L68,11 L76,14 L86,19 L93,25 L94,31 L94,37 Z" fill="#CC0000"/>
  <path d="M38,13 L34,22 L58,22 L56,11 Z" fill="#AA0000"/>
  <path d="M56,11 L68,11 L72,16 L70,22 L58,22 Z" fill="#AA0000"/>
  <path d="M39,14 L35,21 L56,21 L55,12 Z" fill="rgba(160,220,255,0.5)"/>
  <path d="M57,12 L67,12 L71,17 L69,21 L58,21 Z" fill="rgba(160,220,255,0.4)"/>
  <rect x="76" y="15" width="5" height="3" rx="1" fill="#880000"/>
  <path d="M76,19 L86,19 L88,24 L76,24 Z" fill="rgba(0,0,0,0.35)"/>
  <rect x="89" y="22" width="6" height="7" rx="1" fill="#FFEE55" opacity="0.95"/>
  <rect x="5" y="24" width="3" height="9" rx="1" fill="#FF2222"/>
  <path d="M88,32 L95,33 L95,37 L88,37 Z" fill="#990000"/>
  <circle cx="74" cy="41" r="9" fill="#111"/>
  <circle cx="74" cy="41" r="6.5" fill="#2a2a2a"/>
  <circle cx="74" cy="41" r="3" fill="#505050"/>
  <line x1="74" y1="35" x2="74" y2="47" stroke="#666" stroke-width="0.8"/>
  <line x1="68" y1="41" x2="80" y2="41" stroke="#666" stroke-width="0.8"/>
  <circle cx="22" cy="41" r="9" fill="#111"/>
  <circle cx="22" cy="41" r="6.5" fill="#2a2a2a"/>
  <circle cx="22" cy="41" r="3" fill="#505050"/>
  <line x1="22" y1="35" x2="22" y2="47" stroke="#666" stroke-width="0.8"/>
  <line x1="16" y1="41" x2="28" y2="41" stroke="#666" stroke-width="0.8"/>
  <ellipse cx="50" cy="49" rx="38" ry="3" fill="rgba(0,0,0,0.25)"/>
</svg>''';

// Lamborghini Aventador - xe xanh (wedge cực kỳ góc cạnh)
const String _lamborghiniSvg = '''
<svg viewBox="0 0 100 50" xmlns="http://www.w3.org/2000/svg">
  <path d="M5,37 L5,26 L10,20 L22,15 L42,11 L64,10 L76,10 L86,14 L93,20 L96,27 L96,37 Z" fill="#0044CC"/>
  <path d="M22,15 L18,22 L42,22 L42,11 Z" fill="#003399"/>
  <path d="M42,11 L64,10 L76,10 L74,22 L42,22 Z" fill="#003399"/>
  <path d="M23,15 L19,21 L40,21 L41,12 Z" fill="rgba(130,210,255,0.48)"/>
  <path d="M43,11 L63,11 L73,11 L72,21 L43,21 Z" fill="rgba(130,210,255,0.38)"/>
  <path d="M76,10 L86,14 L84,17 L76,14 Z" fill="#002288"/>
  <path d="M84,21 L93,20 L92,26 L83,26 Z" fill="rgba(0,0,0,0.5)"/>
  <path d="M90,21 L97,22 L97,26 L90,25 Z" fill="#88CCFF" opacity="0.9"/>
  <rect x="4" y="21" width="2" height="12" fill="#2255EE"/>
  <rect x="90" y="35" width="7" height="2" fill="#002299"/>
  <circle cx="75" cy="41" r="9" fill="#0a0a1a"/>
  <circle cx="75" cy="41" r="6.5" fill="#141428"/>
  <circle cx="75" cy="41" r="3" fill="#223366"/>
  <line x1="75" y1="35" x2="75" y2="47" stroke="#3344AA" stroke-width="0.8"/>
  <line x1="69" y1="41" x2="81" y2="41" stroke="#3344AA" stroke-width="0.8"/>
  <circle cx="22" cy="41" r="9" fill="#0a0a1a"/>
  <circle cx="22" cy="41" r="6.5" fill="#141428"/>
  <circle cx="22" cy="41" r="3" fill="#223366"/>
  <line x1="22" y1="35" x2="22" y2="47" stroke="#3344AA" stroke-width="0.8"/>
  <line x1="16" y1="41" x2="28" y2="41" stroke="#3344AA" stroke-width="0.8"/>
  <ellipse cx="50" cy="49" rx="38" ry="3" fill="rgba(0,0,0,0.25)"/>
</svg>''';

// McLaren 720S - xe vàng (đường cong mượt mà)
const String _mclarenSvg = '''
<svg viewBox="0 0 100 50" xmlns="http://www.w3.org/2000/svg">
  <path d="M7,37 L6,28 L10,20 L22,15 L44,11 L66,11 L78,14 L88,20 L93,27 L93,37 Z" fill="#D4900A"/>
  <path d="M22,15 L20,22 L46,22 L44,11 Z" fill="#B07800"/>
  <path d="M44,11 L66,11 L70,15 L68,22 L46,22 Z" fill="#B07800"/>
  <path d="M23,15 L21,21 L44,21 L43,12 Z" fill="rgba(180,235,255,0.5)"/>
  <path d="M45,12 L65,12 L69,16 L67,21 L46,21 Z" fill="rgba(180,235,255,0.4)"/>
  <path d="M66,11 L78,14 L76,17 L66,15 Z" fill="#8C6000"/>
  <path d="M79,18 L89,21 L87,26 L77,24 Z" fill="rgba(0,0,0,0.38)"/>
  <rect x="78" y="15" width="5" height="3" rx="1" fill="#9A6E00"/>
  <path d="M89,21 L95,24 L95,29 L89,28 Z" fill="#FFEE44" opacity="0.95"/>
  <rect x="5" y="23" width="3" height="9" rx="1" fill="#FFAA00"/>
  <circle cx="75" cy="41" r="9" fill="#111"/>
  <circle cx="75" cy="41" r="6.5" fill="#2a2a2a"/>
  <circle cx="75" cy="41" r="3" fill="#554400"/>
  <line x1="75" y1="35" x2="75" y2="47" stroke="#886600" stroke-width="0.8"/>
  <line x1="69" y1="41" x2="81" y2="41" stroke="#886600" stroke-width="0.8"/>
  <circle cx="23" cy="41" r="9" fill="#111"/>
  <circle cx="23" cy="41" r="6.5" fill="#2a2a2a"/>
  <circle cx="23" cy="41" r="3" fill="#554400"/>
  <line x1="23" y1="35" x2="23" y2="47" stroke="#886600" stroke-width="0.8"/>
  <line x1="17" y1="41" x2="29" y2="41" stroke="#886600" stroke-width="0.8"/>
  <ellipse cx="50" cy="49" rx="38" ry="3" fill="rgba(0,0,0,0.25)"/>
</svg>''';

class GameScreen extends StatefulWidget {
  final String username;

  const GameScreen({super.key, required this.username});

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
      balance -= totalBet; // Trừ tiền cược ngay khi bắt đầu đua
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

    // balance đã bị trừ totalBet khi bắt đầu đua, chỉ cộng thêm tiền thắng
    double newBalance = balance + winAmount;
    if (newBalance < 0) newBalance = 0;

    // Lưu số dư mới vào SharedPreferences
    await UserService.updateBalance(widget.username, newBalance);

    setState(() {
      balance = newBalance;
      soundCaption = "🔊 PHANH CHÁY ĐƯỜNG: KÉEEEEEÉTTT!!! 🏁";
    });

    // 1. Xe cán đích -> Phát ngay tiếng phanh xe cháy đường

    // Tự động xoá caption âm thanh sau 2.5 giây
    Future.delayed(Duration(milliseconds: 2500), () {
      if (mounted && soundCaption.contains("PHANH")) {
        setState(() {
          soundCaption = "";
        });
      }
    });

    // 2. Chờ 0.6 giây để tiếng phanh kêu xong -> Mở bảng kết quả và phát nhạc Thắng/Thua
    Future.delayed(Duration(milliseconds: 600), () {
      
      // KIỂM TRA LỢI NHUẬN ĐỂ PHÁT ÂM THANH
      if (profit > 0) {
        SoundService.playWinSound(); // Lãi -> Phát nhạc thắng
      } else {
        SoundService.playLoseSound(); // Lỗ hoặc huề vốn -> Phát nhạc thua
      }

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
                  color: Colors.redAccent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amberAccent.withValues(alpha: 0.5)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amberAccent.withValues(alpha: 0.1),
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
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.amberAccent.withValues(alpha: 0.3)),
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
      trackColor = Colors.redAccent.withValues(alpha: 0.15);
      carColor = Colors.redAccent;
      carName = "SIÊU XE ĐỎ 🔥";
    } else if (index == 1) {
      trackColor = Colors.blueAccent.withValues(alpha: 0.15);
      carColor = Colors.blueAccent;
      carName = "TIEU TỬ XANH ⚡";
    } else {
      trackColor = Colors.amberAccent.withValues(alpha: 0.15);
      carColor = Colors.amberAccent;
      carName = "HOÀNG KIM GIÁP 🏆";
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: trackColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: carColor.withValues(alpha: 0.3)),
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
              SizedBox(
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
              double maxTrackWidth = constraints.maxWidth - 72; // Trừ chiều rộng của xe đua
              double leftPosition = carValues[index] * maxTrackWidth;
              if (leftPosition < 0) leftPosition = 0;

              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    // Nền nhựa đường
                    color: const Color(0xFF222222),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      // Vạch trắng lề trên
                      Positioned(
                        top: 4,
                        left: 0,
                        right: 0,
                        child: Container(height: 3, color: Colors.white.withValues(alpha: 0.85)),
                      ),
                      // Vạch trắng lề dưới
                      Positioned(
                        bottom: 4,
                        left: 0,
                        right: 0,
                        child: Container(height: 3, color: Colors.white.withValues(alpha: 0.85)),
                      ),
                      // Vạch vàng đứt đoạn giữa đường
                      Positioned.fill(
                        child: Row(
                          children: List.generate(
                            16,
                            (i) => Expanded(
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                      height: 3,
                                      color: i % 2 == 0
                                          ? Colors.yellow.withValues(alpha: 0.75)
                                          : Colors.transparent,
                                    ),
                                  ),
                                  Expanded(flex: 1, child: SizedBox()),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Vạch đích dạng cờ ca-rô
                      Positioned(
                        right: 0,
                        top: 0,
                        bottom: 0,
                        child: SizedBox(
                          width: 20,
                          child: Column(
                            children: List.generate(
                              6,
                              (r) => Expanded(
                                child: Row(
                                  children: List.generate(
                                    2,
                                    (c) => Expanded(
                                      child: Container(
                                        color: (r + c) % 2 == 0 ? Colors.white : Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Xe chuyển động tịnh tiến
                      AnimatedPositioned(
                        duration: Duration(milliseconds: 50),
                        left: leftPosition,
                        child: SizedBox(
                          width: 72,
                          height: 46,
                          child: SvgPicture.string(
                            [_ferrariSvg, _lamborghiniSvg, _mclarenSvg][index],
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ],
                  ),
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