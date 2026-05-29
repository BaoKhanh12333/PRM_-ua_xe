import 'package:flutter/material.dart';
import '../models/race_data.dart';
import '../models/user_service.dart';

class ResultScreen extends StatelessWidget {
  final String username;
  final RaceResult result;

  const ResultScreen({super.key, required this.username, required this.result});

  @override
  Widget build(BuildContext context) {
    bool isBroke = result.currentBalance <= 0;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0f0c1b), Color(0xFF1a1a2e)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Container(
            margin: EdgeInsets.all(20),
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isBroke ? Colors.redAccent : Colors.amberAccent,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isBroke ? Colors.redAccent : Colors.amberAccent).withValues(alpha: 0.15),
                  blurRadius: 20,
                  spreadRadius: 2,
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) {
                    return LinearGradient(
                      colors: isBroke ? [Colors.red, Colors.orange] : [Colors.yellow, Colors.amber, Colors.orange],
                    ).createShader(bounds);
                  },
                  child: Text(
                    isBroke ? "CẠN KIỆT NGUỒN VỐN" : "BẢNG KẾT QUẢ CUỘC ĐUA",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                Divider(color: Colors.grey[800], height: 30),
                Icon(
                  isBroke ? Icons.sentiment_very_dissatisfied : Icons.emoji_events,
                  size: 80,
                  color: isBroke ? Colors.redAccent : Colors.amberAccent,
                ),
                SizedBox(height: 15),
                Text(
                  "Xe về nhất: XE SỐ ${result.winnerIndex + 1}",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: result.winnerIndex == 0
                        ? Colors.redAccent
                        : result.winnerIndex == 1
                            ? Colors.blueAccent
                            : Colors.amberAccent,
                  ),
                ),
                SizedBox(height: 20),
                _row("Tổng tiền cược:", "${UserService.formatMoney(result.totalBet)} VNĐ"),
                _row("Tổng tiền thắng:", "${UserService.formatMoney(result.winAmount)} VNĐ"),
                _row(
                  "Lời / Lỗ:",
                  "${result.profit >= 0 ? '+' : ''}${UserService.formatMoney(result.profit)} VNĐ",
                  color: result.profit >= 0 ? Colors.greenAccent : Colors.redAccent,
                  isBold: true,
                ),
                Divider(color: Colors.grey[800], height: 25),
                _row(
                  "Số dư tài khoản:",
                  "${UserService.formatMoney(result.currentBalance)} VNĐ",
                  color: Colors.amberAccent,
                  isBold: true,
                ),
                SizedBox(height: 20),
                if (isBroke) ...[
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      "Cảnh báo: Bạn đã cháy túi! Nhấn nút dưới đây để nhận lại 1,000,000 VNĐ hỗ trợ khởi nghiệp đua xe.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.redAccent, fontSize: 13, height: 1.4),
                    ),
                  ),
                  SizedBox(height: 25),
                ],
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isBroke ? Colors.redAccent : Colors.amberAccent,
                    foregroundColor: Colors.black,
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    if (isBroke) {
                      // Reset ví về 1,000,000 VNĐ
                      await UserService.resetBalance(username);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Đã nạp 1,000,000 VNĐ tiền khởi nghiệp thành công!")),
                      );
                    }
                    Navigator.pop(context);
                  },
                  child: Text(
                    isBroke ? "RESET VỐN & TIẾP TỤC" : "QUAY LẠI ĐẶT CƯỢC",
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                      letterSpacing: 1,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value, {Color color = Colors.white, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 14)),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}