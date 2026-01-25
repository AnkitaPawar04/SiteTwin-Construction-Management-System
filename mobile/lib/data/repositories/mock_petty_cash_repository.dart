import '../models/petty_cash_wallet.dart';
import '../models/petty_cash_transaction.dart';

class MockPettyCashRepository {
  // Mock wallet data
  static final List<PettyCashWallet> _wallets = [
    PettyCashWallet(
      id: 1,
      projectId: 1,
      projectName: 'Tech Park Construction',
      balance: 25000.00,
    ),
    PettyCashWallet(
      id: 2,
      projectId: 2,
      projectName: 'Residential Complex',
      balance: 15000.00,
    ),
  ];

  // Mock transaction data
  static final List<PettyCashTransaction> _transactions = [
    PettyCashTransaction(
      id: 1,
      walletId: 1,
      userId: 3,
      userName: 'Rajesh Kumar (Worker)',
      amount: 450.00,
      description: 'Electrical nails and screws',
      receiptImage: 'https://via.placeholder.com/400x600/E3F2FD/1976D2?text=Receipt+1',
      imageHash: 'hash_001',
      latitude: 28.6139,
      longitude: 77.2090,
      gpsStatus: 'ON_SITE',
      duplicateFlag: false,
      status: 'PENDING',
      createdAt: DateTime.now().subtract(Duration(hours: 2)),
    ),
    PettyCashTransaction(
      id: 2,
      walletId: 1,
      userId: 4,
      userName: 'Amit Singh (Worker)',
      amount: 850.00,
      description: 'Cement bags - urgent purchase',
      receiptImage: 'https://via.placeholder.com/400x600/FFF3E0/F57C00?text=Receipt+2',
      imageHash: 'hash_002',
      latitude: 28.6200,
      longitude: 77.2100,
      gpsStatus: 'OUTSIDE_SITE',
      duplicateFlag: false,
      status: 'PENDING',
      createdAt: DateTime.now().subtract(Duration(hours: 5)),
    ),
    PettyCashTransaction(
      id: 3,
      walletId: 1,
      userId: 3,
      userName: 'Rajesh Kumar (Worker)',
      amount: 350.00,
      description: 'Safety gloves for team',
      receiptImage: 'https://via.placeholder.com/400x600/E8F5E9/388E3C?text=Receipt+3',
      imageHash: 'hash_003',
      latitude: 28.6139,
      longitude: 77.2090,
      gpsStatus: 'ON_SITE',
      duplicateFlag: true,
      status: 'PENDING',
      createdAt: DateTime.now().subtract(Duration(minutes: 30)),
    ),
    PettyCashTransaction(
      id: 4,
      walletId: 1,
      userId: 5,
      userName: 'Priya Sharma (Worker)',
      amount: 1200.00,
      description: 'Plumbing pipes and fittings',
      receiptImage: 'https://via.placeholder.com/400x600/E8F5E9/388E3C?text=Receipt+4',
      imageHash: 'hash_004',
      latitude: 28.6139,
      longitude: 77.2090,
      gpsStatus: 'ON_SITE',
      duplicateFlag: false,
      status: 'APPROVED',
      createdAt: DateTime.now().subtract(Duration(days: 1)),
      reviewedAt: DateTime.now().subtract(Duration(hours: 20)),
      managerComment: 'Approved - All checks passed',
    ),
    PettyCashTransaction(
      id: 5,
      walletId: 1,
      userId: 4,
      userName: 'Amit Singh (Worker)',
      amount: 600.00,
      description: 'Paint brushes and rollers',
      receiptImage: 'https://via.placeholder.com/400x600/FFEBEE/C62828?text=Receipt+5',
      imageHash: 'hash_005',
      latitude: 28.6200,
      longitude: 77.2100,
      gpsStatus: 'OUTSIDE_SITE',
      duplicateFlag: false,
      status: 'REJECTED',
      createdAt: DateTime.now().subtract(Duration(days: 2)),
      reviewedAt: DateTime.now().subtract(Duration(days: 1, hours: 20)),
      managerComment: 'Receipt location outside project site',
    ),
  ];

  Future<PettyCashWallet> getWallet(int projectId) async {
    await Future.delayed(Duration(milliseconds: 300));
    return _wallets.firstWhere(
      (w) => w.projectId == projectId,
      orElse: () => _wallets.first,
    );
  }

  Future<List<PettyCashTransaction>> getTransactions({
    int? walletId,
    String? status,
  }) async {
    await Future.delayed(Duration(milliseconds: 300));
    
    var filtered = _transactions;
    
    if (walletId != null) {
      filtered = filtered.where((t) => t.walletId == walletId).toList();
    }
    
    if (status != null) {
      filtered = filtered.where((t) => t.status == status).toList();
    }
    
    return filtered..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<Map<String, dynamic>> submitExpense({
    required int walletId,
    required double amount,
    required String description,
    required String receiptImagePath,
    double? latitude,
    double? longitude,
  }) async {
    await Future.delayed(Duration(milliseconds: 500));
    
    // Simulate GPS validation
    final gpsStatus = latitude != null && longitude != null
        ? (latitude > 28.610 && latitude < 28.620 && 
           longitude > 77.200 && longitude < 77.220 
           ? 'ON_SITE' 
           : 'OUTSIDE_SITE')
        : 'UNKNOWN';
    
    // Simulate duplicate detection
    final imageHash = 'hash_${DateTime.now().millisecondsSinceEpoch}';
    final isDuplicate = _transactions.any((t) => 
      t.imageHash == imageHash || 
      (t.amount == amount && t.description == description)
    );
    
    final transaction = PettyCashTransaction(
      id: _transactions.length + 1,
      walletId: walletId,
      userId: 3, // Current user
      userName: 'Current User',
      amount: amount,
      description: description,
      receiptImage: receiptImagePath,
      imageHash: imageHash,
      latitude: latitude,
      longitude: longitude,
      gpsStatus: gpsStatus,
      duplicateFlag: isDuplicate,
      status: 'PENDING',
      createdAt: DateTime.now(),
    );
    
    _transactions.insert(0, transaction);
    
    return {
      'success': true,
      'message': 'Expense submitted successfully',
      'transaction': transaction.toJson(),
    };
  }

  Future<Map<String, dynamic>> approveExpense(int transactionId, String? comment) async {
    await Future.delayed(Duration(milliseconds: 300));
    
    final index = _transactions.indexWhere((t) => t.id == transactionId);
    if (index == -1) {
      return {'success': false, 'message': 'Transaction not found'};
    }
    
    final oldTransaction = _transactions[index];
    final updatedTransaction = PettyCashTransaction(
      id: oldTransaction.id,
      walletId: oldTransaction.walletId,
      userId: oldTransaction.userId,
      userName: oldTransaction.userName,
      amount: oldTransaction.amount,
      description: oldTransaction.description,
      receiptImage: oldTransaction.receiptImage,
      imageHash: oldTransaction.imageHash,
      latitude: oldTransaction.latitude,
      longitude: oldTransaction.longitude,
      gpsStatus: oldTransaction.gpsStatus,
      duplicateFlag: oldTransaction.duplicateFlag,
      status: 'APPROVED',
      createdAt: oldTransaction.createdAt,
      reviewedAt: DateTime.now(),
      managerComment: comment ?? 'Approved',
    );
    
    _transactions[index] = updatedTransaction;
    
    // Update wallet balance
    final walletIndex = _wallets.indexWhere((w) => w.id == oldTransaction.walletId);
    if (walletIndex != -1) {
      final wallet = _wallets[walletIndex];
      _wallets[walletIndex] = PettyCashWallet(
        id: wallet.id,
        projectId: wallet.projectId,
        projectName: wallet.projectName,
        balance: wallet.balance - oldTransaction.amount,
      );
    }
    
    return {'success': true, 'message': 'Expense approved successfully'};
  }

  Future<Map<String, dynamic>> rejectExpense(int transactionId, String reason) async {
    await Future.delayed(Duration(milliseconds: 300));
    
    final index = _transactions.indexWhere((t) => t.id == transactionId);
    if (index == -1) {
      return {'success': false, 'message': 'Transaction not found'};
    }
    
    final oldTransaction = _transactions[index];
    final updatedTransaction = PettyCashTransaction(
      id: oldTransaction.id,
      walletId: oldTransaction.walletId,
      userId: oldTransaction.userId,
      userName: oldTransaction.userName,
      amount: oldTransaction.amount,
      description: oldTransaction.description,
      receiptImage: oldTransaction.receiptImage,
      imageHash: oldTransaction.imageHash,
      latitude: oldTransaction.latitude,
      longitude: oldTransaction.longitude,
      gpsStatus: oldTransaction.gpsStatus,
      duplicateFlag: oldTransaction.duplicateFlag,
      status: 'REJECTED',
      createdAt: oldTransaction.createdAt,
      reviewedAt: DateTime.now(),
      managerComment: reason,
    );
    
    _transactions[index] = updatedTransaction;
    
    return {'success': true, 'message': 'Expense rejected'};
  }

  Future<Map<String, dynamic>> getStatistics(int walletId) async {
    await Future.delayed(Duration(milliseconds: 300));
    
    final transactions = _transactions.where((t) => t.walletId == walletId).toList();
    
    return {
      'total_pending': transactions.where((t) => t.isPending).length,
      'total_approved': transactions.where((t) => t.isApproved).length,
      'total_rejected': transactions.where((t) => t.isRejected).length,
      'total_amount_approved': transactions
          .where((t) => t.isApproved)
          .fold(0.0, (sum, t) => sum + t.amount),
      'total_amount_pending': transactions
          .where((t) => t.isPending)
          .fold(0.0, (sum, t) => sum + t.amount),
    };
  }
}
