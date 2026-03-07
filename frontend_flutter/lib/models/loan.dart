class Loan {
  final int id;
  final double amount;
  final double remaining;
  final double interestRate;
  final String storeName;
  /// 案件名稱（如：汽車、房屋、機車），API 若有 case_name / name 會帶入
  final String? caseName;
  /// 月還款金額（API 若有則帶入，否則可為 null 由 UI 顯示「--」或估算）
  final double? monthlyPayment;
  /// 還款日說明（如：「每月5號」「每30天」），API 若有則帶入
  final String? repaymentDay;

  Loan({
    required this.id,
    required this.amount,
    required this.remaining,
    required this.interestRate,
    required this.storeName,
    this.caseName,
    this.monthlyPayment,
    this.repaymentDay,
  });

  factory Loan.fromJson(Map<String, dynamic> json) {
    final store = json['store'];
    final storeName = store != null && store is Map
        ? (store['name']?.toString() ?? '')
        : '';
    double? monthly;
    try {
      if (json['monthly_payment'] != null) {
        monthly = double.parse(json['monthly_payment'].toString());
      }
    } catch (_) {}
    return Loan(
      id: json['id'] as int,
      amount: double.parse(json['loan_amount'].toString()),
      remaining: double.parse(json['remaining_amount'].toString()),
      interestRate: double.parse(json['interest_rate'].toString()),
      storeName: storeName,
      caseName: json['case_name']?.toString() ?? json['name']?.toString(),
      monthlyPayment: monthly,
      repaymentDay: json['repayment_day']?.toString(),
    );
  }
}
