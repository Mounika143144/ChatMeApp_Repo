import 'package:connectivity_plus/connectivity_plus.dart';


class CheckInternetConnectivity {

 Future<bool> checkInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      return false;
    } else {
      return true;
    }
  }


}