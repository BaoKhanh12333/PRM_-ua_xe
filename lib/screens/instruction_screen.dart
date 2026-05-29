import 'package:flutter/material.dart';
import 'game_screen.dart';

class InstructionScreen extends StatelessWidget {
  final String username;

  const InstructionScreen({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.canPop(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
              'https://images.unsplash.com/photo-1568605117036-5fe5e7bab0b7?q=80&w=1000',
            ),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withValues(alpha: 0.8),
              BlendMode.srcOver,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "HƯỚNG DẪN SỬ DỤNG",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.amberAccent,
                        letterSpacing: 1.5,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.redAccent),
                      ),
                      child: Text(
                        "Racer: $username",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                // Instructions Box
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.grey.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Scrollbar(
                      thumbVisibility: true,
                      child: ListView(
                        padding: EdgeInsets.only(right: 10),
                        children: [
                          _buildStep(
                            "1",
                            "VỐN KHỞI ĐẦU",
                            "Mỗi tài khoản mới sẽ nhận ngay 1,000,000 VNĐ để làm vốn khởi nghiệp đua xe.",
                            Icons.monetization_on,
                            Colors.green,
                          ),
                          _buildStep(
                            "2",
                            "ĐẶT CƯỢC CHIẾN MÃ",
                            "Có 3 đường đua (tương ứng với 3 xe đua). Nhập số tiền cược vào ô cược bên phải của mỗi xe. Bạn có thể cược cho 1, 2 hoặc cả 3 xe tùy ý.",
                            Icons.edit_note,
                            Colors.blue,
                          ),
                          _buildStep(
                            "3",
                            "KHỞI ĐỘNG CUỘC ĐUA",
                            "Nhấn nút 'START' để bắt đầu cuộc đua. Hệ thống sẽ khóa toàn bộ ô cược và tiến hành đua ngẫu nhiên với tốc độ và gia tốc khác biệt cho từng xe.",
                            Icons.play_circle_fill,
                            Colors.orange,
                          ),
                          _buildStep(
                            "4",
                            "TỶ LỆ THƯỞNG PHẠT",
                            "• Xe bạn chọn giành chiến thắng (về Nhất): Nhận gấp 3 lần số tiền đã cược cho xe đó.\n• Xe bạn chọn không về Nhất hoặc không cược: Mất toàn bộ số tiền đã cược cho xe đó.\n• Công thức: Lời/Lỗ = (Tiền thắng xe Nhất) - (Tổng tiền cược 3 xe).",
                            Icons.calculate,
                            Colors.purple,
                          ),
                          _buildStep(
                            "5",
                            "LƯU Ý LUẬT TÀI CHÍNH",
                            "• Không thể cược số tiền lớn hơn số dư hiện có.\n• Không thể cược số tiền âm hoặc không phải là chữ số.\n• Nếu ví của bạn chạm mức 0 VNĐ (Cháy túi), bạn sẽ phải Reset lại ví về mức 1,000,000 VNĐ ở trang Kết quả để chơi tiếp.",
                            Icons.warning_amber_rounded,
                            Colors.red,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                // Navigate Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amberAccent,
                    foregroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () {
                    if (canPop) {
                      Navigator.pop(context);
                    } else {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GameScreen(username: username),
                        ),
                      );
                    }
                  },
                  child: Text(
                    canPop ? "QUAY LẠI ĐƯỜNG ĐUA" : "TÔI ĐÃ HIỂU - BẮT ĐẦU ĐUA",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep(
    String stepNumber,
    String title,
    String content,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Text(
              stepNumber,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 18, color: color),
                    SizedBox(width: 6),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6),
                Text(
                  content,
                  style: TextStyle(
                    color: Colors.grey[300],
                    fontSize: 13.5,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}