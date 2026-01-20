import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkInfo {
  final Connectivity _connectivity = Connectivity();
  
  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    // In connectivity_plus 5.0.2, checkConnectivity returns a single ConnectivityResult
    return result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.ethernet;
  }
  
  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map((result) {
      // onConnectivityChanged emits ConnectivityResult
      return result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.ethernet;
    });
  }
}
