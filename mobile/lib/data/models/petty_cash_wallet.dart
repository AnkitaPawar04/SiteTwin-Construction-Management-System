class PettyCashWallet {
  final int id;
  final int projectId;
  final String projectName;
  final double balance;

  PettyCashWallet({
    required this.id,
    required this.projectId,
    required this.projectName,
    required this.balance,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_id': projectId,
      'project_name': projectName,
      'balance': balance,
    };
  }

  factory PettyCashWallet.fromJson(Map<String, dynamic> json) {
    return PettyCashWallet(
      id: json['id'],
      projectId: json['project_id'],
      projectName: json['project_name'],
      balance: json['balance'].toDouble(),
    );
  }
}
