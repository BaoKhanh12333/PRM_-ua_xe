class RaceResult {
  final int winnerIndex;
  final double totalBet;
  final double winAmount;
  final double profit;
  final double currentBalance;

  RaceResult({
    required this.winnerIndex,
    required this.totalBet,
    required this.winAmount,
    required this.profit,
    required this.currentBalance,
  });
}