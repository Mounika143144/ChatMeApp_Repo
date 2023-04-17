import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

final httpClient = HttpClient();
const httpResp = http.Response;

class HttpClient {
  static const baseUrl = "https://fcm.googleapis.com/fcm/send";
  static const fcmServerKey =
      "AAAA-xlGXuA:APA91bH_6fj_EjAnuO8I_8g2vf4dwGlflp-beZoZAh8s6lGfAZnXG09Gb6cia98OIV9DmPwjYRYsYfP2fFA_WQuOozL9BiGC0ZfD1ocUB0aMQUOZBh1v0-REjr6lM5OonM49aN2t4-sp";

  Future pushNotification(
      {String? fcmToken, String? title, String? body}) async {
    print('start http');

    Map<String, dynamic> data = {
      "to": fcmToken!,
      "notification": {"title": title!, "body": body!}
    };
    http.Response response = await http.post(Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=$fcmServerKey'
        },
        body: jsonEncode(data));
    return response;
  }
}
