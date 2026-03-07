class Loan {
  final int id;
  final double amount;
  final double remaining;
  final double interestRate;
  final String storeName;

  Loan({
    required this.id,
    required this.amount,
    required this.remaining,
    required this.interestRate,
    required this.storeName,
  });

  factory Loan.fromJson(Map<String, dynamic> json) {
    return Loan(
      id: json['id'],
      amount: double.parse(json['loan_amount'].toString()),
      remaining: double.parse(json['remaining_amount'].toString()),
      interestRate: double.parse(json['interest_rate'].toString()),
      storeName: json['store']['name'],
    );
  }
}
