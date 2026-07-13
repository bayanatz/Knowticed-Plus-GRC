import 'dart:convert';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart' as http;

class NotificationServiceApp {

  // ═══════════════════════════════════════════════════════════
  // METHOD 1: Get Access Token
  // ═══════════════════════════════════════════════════════════

  static Future<String> getAccessToken() async {

    // Step 1: Define Service Account Credentials
    // This is like a "robot account" that has permission to send notifications
    final serviceAccountJson = <String, String>{
      "type": "service_account",
      "project_id": "knowticed-v2-scheme",
      "private_key_id": "e792d498cf11499594cdb0ff45ad809ebe9a3c13",
      "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQCuxzuxtF3oG7DW\noimflC93DklC9L2N/Xgl7Np75J3Mt//Abc3kAxL7HB+HdC74YQnb6rLVhVNwCSO0\n8313YaDVGcZBBspa443dn7UinL0aWxLT1Yn85/JYFGuWarXOdTweHxN15xxzl/ug\naWEl8IEOU6HRDWQ4H5DqWigFunyswtUF2VdVR2Ofh2VJLmWc5vAmvk5ls8h7CTt+\ngr6wnvSyAFAQfwRTJuJWkQsYAGKpLGqijzjSfgtWoxH9PilkO+lBaFVWLf7w1vzH\nZSicxSHMdW+TbTnfknqIoMM1qgDUJPL7iFHUsHoYuVNkyz+JdJcrvbokDRB3dAPv\n9mzCxLw7AgMBAAECggEANXd0XvX23kkOTXKZOhyacpjXt5hoHnZCWZO9+LWkwlot\nbmAI4q5AEbp2OLlFny0MV47SO3iIYFcjabktEia3DUnPuNfLcod3QCuZvWdmgBgJ\nR+1kw43vOJuyl/a3/Fsn020dRm23afM+AkIKepE64bea4nluxa5+ZfrDkJEOj8ie\nYpPrgBZz0mnSVco0FUgGcZ9EwqxXeOvgzkFjYHFS5OGAoyvD4Knv9WDC/l5Pi+3G\nlami+CIdHEq90yEmEKOLeqX+hqmk9HZmuj9sKleuXmnLWroJUMn1PKj99rPWkV0W\n9ERwFkwgR6SFxnD6AhJnQsgWHIFHdqmE98HfVReZUQKBgQDomN4nHNsj4YgtNKvL\n4uTwKx28LH04oucdFzhQRXhOVPsK1wF0H5rwRmd7kSFDlpDU5nF5XGuzvPiAdsTk\npXYq7eb8fa/eFGiJCYLPLSx0yHipBkg1LT6GK/NzqnYBETBvZ4vMFhHCFlvLJB3M\nOdbP4M/9kLe7gMEVRU/dZ282iwKBgQDAXRe2oI4QA2NwpuMzKng+pSPM0KCGHGRe\nNWmUZvdwPTu/z70Tare3XB9dwGEhYX2g6jdKaRC5SnzFVLaOsyUTWKoPE7NV3s7u\nuYwTlFxDSWkay3ccJIzDflBodCNtg+SrgJXSrM+UGWp+bWXa59MIrJaTmTij6LKr\nOtPtXob3EQKBgQCQEYegcFYn7lzbq0Ex41Lsk7gyQtg5CWXfde9ygOUYl7h7KVuE\nIsNkSid0uRsCczM4O5hTlHQ9ezHs2CPyf64mvv6QrAUPqFJrdxGn45Iir71U7Egz\nb9fHYVfE7/Nxi8UVa+yCN7U+I30t4Sv3wGeWkOgjZcz3/bMayrjCKXwQKwKBgQCA\n0RZjLwtTP+Gke62kAum5Eb9ylbcZeAPibqRAQ9+pYugTH9s/GHTkriU3E/A3eWC2\nlIHoK4mOe4ooXv1NfDv0w6hGJmwuseEjTk+2gOB0EsH2tpAR4Yv+EiVofXWIDg3g\np2AtT5pGU+rTtRDDUgEpSuIe/zlF0jtrnR50U5vP8QKBgDC8MBiHWfk4nEkng5e/\n4XkRxBnm/CU7OkKz3Fr+wZQ3/J0zsbACbn7AuEtl8ir2Nnnsf+YrsuYHDUJCZN5g\nR1pFYTZP3WLJCOuldxUOzJkqf5J66v6g04dcsqinh3WLa5AEOomhdEmhb8fiHuVx\nyWgZuk32ktRnG2Y5oOtaE1F8\n-----END PRIVATE KEY-----\n",
      "client_email": "firebase-adminsdk-2szdm@knowticed-v2-scheme.iam.gserviceaccount.com",
      "client_id": "108712132861240366762",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-2szdm%40knowticed-v2-scheme.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    };

    // Step 2: Define required permissions (scopes)
    List<String> scopes = [
      "https://www.googleapis.com/auth/userinfo.email",        // Access email
      "https://www.googleapis.com/auth/firebase.database",     // Access database
      "https://www.googleapis.com/auth/firebase.messaging"     // Send notifications
    ];

    // Step 3: Create authenticated HTTP client
    http.Client client = await auth.clientViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
    );

    // Step 4: Get access credentials (token)
    auth.AccessCredentials credentials =
    await auth.obtainAccessCredentialsViaServiceAccount(
        auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
        scopes,
        client
    );

    // Step 5: Close client and return token
    client.close();
    return credentials.accessToken.data;  // Return the access token
  }

  // ═══════════════════════════════════════════════════════════
  // ✅ NEW HELPER METHOD: Sanitize Email for Topic
  // ═══════════════════════════════════════════════════════════

  static String sanitizeEmailForTopic(String email) {
    return email
        .trim()
        .toLowerCase()
        .replaceAll('@', '_at_')
        .replaceAll('.', '_dot_')
        .replaceAll('+', '_plus_')
        .replaceAll(' ', '_');
  }

  // ═══════════════════════════════════════════════════════════
  // METHOD 2: Send Notification (FIXED)
  // ═══════════════════════════════════════════════════════════

  static Future<void> sendNotification(
      String title,
      String body,
      String? channel,  // Can be email or topic name
      ) async
  {
    print('\n╔════════════════════════════════════════════════════════════╗');
    print('║  sendNotification() STARTED                                ║');
    print('╚════════════════════════════════════════════════════════════╝');

    // Step 1: Get authentication token
    final String accessToken = await getAccessToken();

    if (accessToken.isEmpty) {
      print('❌ Access token retrieval failed.');
      return;
    }

    print('✅ Access Token retrieved');

    // ✅ Step 2: Sanitize the channel (convert email to valid topic name)
    String topicName = "news";  // Default topic

    if (channel != null && channel.isNotEmpty) {
      // Check if channel looks like an email (contains @)
      if (channel.contains('@')) {
        topicName = sanitizeEmailForTopic(channel);
        print('📧 Original email: $channel');
        print('📢 Sanitized topic: $topicName');
      } else {
        // Already a topic name
        topicName = channel;
        print('📢 Using topic: $topicName');
      }
    } else {
      print('📢 Using default topic: $topicName');
    }

    // Step 3: Define FCM endpoint URL
    String endpointFCM = 'https://fcm.googleapis.com/v1/projects/knowticed-v2-scheme/messages:send';

    // Step 4: Create notification message
    final Map<String, dynamic> message = {
      "message": {
        "topic": topicName,  // ✅ Use sanitized topic name
        "notification": {
          "title": title,  // Notification title
          "body": body     // Notification content
        },
        "data": {
          "route": "serviceScreen"  // Custom data for navigation
        }
      }
    };

    print('📤 Sending notification...');
    print('   Title: $title');
    print('   Body: $body');
    print('   Topic: $topicName');

    try {
      // Step 5: Send HTTP POST request to Firebase
      final http.Response response = await http.post(
        Uri.parse(endpointFCM),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken'  // Authenticate with token
        },
        body: jsonEncode(message),  // Convert message to JSON
      );

      // Step 6: Handle response
      print('📥 Response Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('✅ Notification sent successfully!');
        print('   Topic: $topicName');
        if (channel != null && channel.contains('@')) {
          print('   Original email: $channel');
        }
      } else {
        print('❌ Failed to send notification');
        print('   Status: ${response.statusCode}');
        print('   Response: ${response.body}');
      }
    } catch (e) {
      print('❌ Error sending notification: $e');
    }

    print('╚════════════════════════════════════════════════════════════╝\n');
  }
}