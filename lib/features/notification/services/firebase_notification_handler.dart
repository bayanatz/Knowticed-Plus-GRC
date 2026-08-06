import 'dart:convert';

import 'package:crypto/crypto.dart'; // for sha256
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart' as http;

class FirebaseNotificationHandler {
  static Future<String> getAccessToken() async {
    final serviceAccountJson = {
      "type": "service_account",
      "project_id": "knowticed-v2-scheme",
      "private_key_id": "43814e85a78629e76a6da324e854b0141f9e6c05",
      "private_key":
          "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCsJZS+Dti88EjG\nxfF09uQH6PWPzcFfszA3yVlTxQb7UhVNTGcAJTeEb8oWq0Yh1oiBxyzwZ357Jq+i\nN2NFCV2tveZ7/p0cY60FRfdz92JdPSsUwvJimisd4GoxfHSTH2/PqY7ToPVb+jG/\nwOCzZVg30Wyi7ZwC4b49WKxBXVtUjTjDsoRY63O/LN7xegl8tcsHAEOSvTLagt4S\ns92pixmHr+O6Nw/vubBwM2Qgl9QwZwmSCT1JA7/5rn5kKAC9ABSvwWEAScl7tIWG\nDbZ6cRsvRHilZ640TmzYFUS2/Eh05g8vTOH2a2guLGyQeTeZZQCzevu1ocXwc/pB\niC+DSxeHAgMBAAECggEARmcGOmZTAI5ajSR19+pi3tNI3lt9KrjbTu1jQW2yScVL\nnfXRqA8QcfLQGM5KG9ujr0O4XsdMxGvRZ4u0Zw8KB1zDLtG2Cl6/a4kuRviU+2Hh\nRRfnTikT2h+l/oASIvs33JtRJL7OqaOchfoJS4T2e7mD7uwzIkCVb3xc0kyuZdjB\nRhF+/QMZt0SJgx1uwInz3Bl+HMPuRihP9LQhTGBwP09+fPXJZ8iq5Kj+ixZ8w3BA\nWoBaA8sW4YhtSLgbINEC4XWmZ+AXpXbGmpn87I/Yi17+4YVm0XMBmdUQ5SkDfxCs\niTh0YIvnET9xKf6i18sA+0b95iyOtB51VMkbxt5vsQKBgQC/0IWUYOWUpG4273/6\nnQSRp9fDVh1PM5wabT0gF6MDOVnG+wJYwz7XgTB/dm5NrpJKcctAuJHxURrHmC5e\n5x1W4f+68pkzt1dECHShXIwLWM106/q8VwTetWGbGJLdu/g+2Lpie1SAxVwbdHAN\nX1d8OJQZ1eqpymFegXIQQQON0QKBgQDlwEE1po8DKX1Xa+qE8qUdLPZm7s327278\nBx2xelYc2d/eV/Z4fgr8Lz2LzY3vdUQfP5BWkLEgUkShcX8KxalSVQ5GjxFNQK90\nPi0YPo7MQBaNlpuzPg74tz9fa/jUMUAcrt/jB5xql0penGcuL70isNHKj+7rbi3V\nwhQVEV1t1wKBgAwFOknJJLoC7/E7Yw7GhkHGfev82otbFZ5GWD1JneqWznx8wHHl\nkmuY6fwi5NizZvGJXg5pQqQXzBDUBZvm6dzG/uqtR1KJW8ukqAJwtUoEv6NjImxp\nG6IFRd+dU57Xp7/wfwWq6unC9Hm3+0mrPuVG+mkAEdugFigA/q/sExfxAoGBANaY\nktAn+OC9OiQT2oO/mNX9j1FpsNv7nLCvfN6vJAvivaYSh1bYdC5FeblBkFegMrb1\nSj5w++DytsQNHNrU8WjDpYfmTgTYbImpIbnJhNvm6KnriRcM2jMaBol8cnjQX8/q\nz5hhHYq6MW7Zq86KLKFggzQu6LzittE4bEWZaKkVAoGAcuza4FvT9ukt75GlG4tr\nJ0U/4FlSJUfLSqNOW2FmJuIOpPK5QtoFCellhdp79S9v7BGnh/SAlmEbgt6hXJcJ\nhzuKUsumXtJLRArMjfz0HyFf96B9urRMT5+HjMpBALgE1c5ofEFTsp1vvxqGjSBD\ng9MSTzCo+V7W8UqzJ9S+3vE=\n-----END PRIVATE KEY-----\n",
      "client_email":
          "firebase-adminsdk-2szdm@knowticed-v2-scheme.iam.gserviceaccount.com",
      "client_id": "108712132861240366762",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url":
          "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url":
          "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-2szdm%40knowticed-v2-scheme.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    };

    List<String> scopes = [
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/firebase.database",
      "https://www.googleapis.com/auth/firebase.messaging"
    ];

    http.Client client = await auth.clientViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
    );

    auth.AccessCredentials credentials =
        await auth.obtainAccessCredentialsViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
      client,
    );

    client.close();
    return credentials.accessToken.data;
  }

  static Future<void> sendNotification(String title, String body,
      List<String> usersIds, Map<String, dynamic> notificationData) async {
    final String accessToken = await getAccessToken();
    List<String> hashedIds = _idsHashing(usersIds);
    if (accessToken.isEmpty) {
      print('❌ Access token retrieval failed.');
      return;
    }

    print('✅ Access Token: $accessToken');

    String endpointFCM =
        'https://fcm.googleapis.com/v1/projects/knowticed-v2-scheme/messages:send';
    for (String id in hashedIds) {
      print(" hashId is $id");
      final Map<String, dynamic> message = {
        "message": {
          "topic": id,
          "notification": {"title": title, "body": body},
          "data": notificationData
        }
      };

      print('notification sent');
      try {
        final http.Response response = await http.post(
          Uri.parse(endpointFCM),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken'
          },
          body: jsonEncode(message),
        );

        print('Response Code: ${response.statusCode}');
        print('Response Body: ${response.body}');

        if (response.statusCode == 200) {
          print('✅ Notification sent successfully.');
        } else {
          print('❌ Failed to send notification: ${response.body}');
        }
      } catch (e) {
        print('❌ Error sending notification: $e');
      }
    }
  }

  static List<String> _idsHashing(List<String> ids) {
    List<String> hashedIds = [];
    for (String id in ids) {
      String hashedId = sha256.convert(utf8.encode(id)).toString();
      hashedIds.add(hashedId);
    }
    return hashedIds;
  }

  static Future<void> subscribeToTopic(String email) async {
    String topic = _idsHashing([email])[0];
    await FirebaseMessaging.instance.subscribeToTopic(topic);
    print('subscribed to topic by new  $email');
  }

  /// ✨Unsubscribe from a topic.⭐
  /// This will remove the user from a topic, and they will stop receiving notifications
  /// for that topic.
  static Future<void> unsubscribeFromTopic(String email) async {
    String topic = _idsHashing([email])[0];
    await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
  }
}
