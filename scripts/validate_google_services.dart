import 'dart:convert';
import 'dart:io';

/// Quick validator for android/app/google-services.json
/// Run with: dart run scripts/validate_google_services.dart

void main(List<String> args) {
  final file = File('android/app/google-services.json');
  if (!file.existsSync()) {
    stderr.writeln('ERROR: android/app/google-services.json not found');
    exit(2);
  }

  final jsonStr = file.readAsStringSync();
  dynamic json;
  try {
    json = jsonDecode(jsonStr);
  } catch (e) {
    stderr.writeln('ERROR: Failed to parse google-services.json: $e');
    exit(3);
  }

  print('google-services.json found');

  final projectInfo = json['project_info'];
  if (projectInfo != null) {
    print('project_id: ${projectInfo['project_id']}');
    print('project_number: ${projectInfo['project_number']}');
    print('storage_bucket: ${projectInfo['storage_bucket']}');
  }

  final clientList = json['client'] as List<dynamic>?;
  if (clientList == null || clientList.isEmpty) {
    print('No clients found in google-services.json');
    exit(0);
  }

  for (var i = 0; i < clientList.length; i++) {
    final client = clientList[i];
    final clientInfo = client['client_info'];
    final oauthClient = client['oauth_client'] as List<dynamic>?;
    print('\n--- client #${i + 1} ---');
    if (clientInfo != null) {
      print('  package_name: ${clientInfo['android_client_info']?['package_name'] ?? clientInfo['mobilesdk_app_id'] ?? 'N/A'}');
    }
    if (oauthClient != null) {
      for (var oc in oauthClient) {
        final type = oc['client_type'];
        final id = oc['client_id'];
        final hint = oc['android_info']?['package_name'] ?? oc['client_type']?.toString();
        print('  oauth_client (type=$type) client_id=$id hint=$hint');
      }
    }
  }

  // Quick sanity checks
  final androidClient = clientList.firstWhere((c) => c['client_info']?['android_client_info'] != null, orElse: () => null);
  if (androidClient == null) {
    print('\nWARNING: No Android client entry found in google-services.json (this will break Android config)');
  } else {
    final packageName = androidClient['client_info']['android_client_info']['package_name'];
    print('\nDetected Android package_name: $packageName');
  }

  print('\nValidation finished');
}

