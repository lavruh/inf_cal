import 'dart:io' show HttpServer, Platform;

import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart';
import 'package:googleapis/people/v1.dart';
import 'package:http/http.dart' as http;
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:url_launcher/url_launcher.dart';
import 'package:window_to_front/window_to_front.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';

class CalendarUser extends GetxController {
  static CalendarUser? _instance;
  static CalendarUser get instance => _instance ?? CalendarUser._();
  factory CalendarUser() => instance;
  CalendarUser._();

  final isLoggedIn = false.obs;

  static const scopes = <String>[
    CalendarApi.calendarScope,
    CalendarApi.calendarEventsScope,
    PeopleServiceApi.contactsReadonlyScope,
    PeopleServiceApi.userinfoProfileScope,
  ];

  HttpServer? redirectServer;
  http.Client? httpClient;

  final Rx<String?> userName = (null as String?).obs;

  googleSignInAndroid() async {
    final clientIdAndroid = Platform.environment['CLIENT_ID_ANDROID'];
    if (clientIdAndroid == null) {
      throw Exception('CLIENT_ID_ANDROID environment variable is not set');
    }
    final googleSignIn =
        GoogleSignIn(clientId: clientIdAndroid, scopes: scopes);
    final user = await googleSignIn.signIn();
    final c = (await googleSignIn.authenticatedClient());
    if (c != null) {
      userName.value = user?.email;
      httpClient = c;
      isLoggedIn.value = true;
    }
  }

  googleDesktopSignIn(Future<String> Function(String uri) tokenRequest) async {
    try {
      await redirectServer?.close();
      redirectServer = await HttpServer.bind('localhost', 0);
      final redirectURL = 'http://localhost:${redirectServer!.port}';
      var authenticatedHttpClient =
          await _getOAuth2Client(Uri.parse(redirectURL));
      httpClient = authenticatedHttpClient;
      final PeopleServiceApi peopleApi =
          PeopleServiceApi(authenticatedHttpClient);
      final response = await peopleApi.people
          .get('people/me', personFields: 'emailAddresses');
      userName.value = response.emailAddresses?.first.value;
      isLoggedIn.value = true;
      update();
    } catch (err) {
      Get.snackbar("Authorization Error", err.toString());
    }
  }

  googleSignOut() async {
    httpClient?.close();
    isLoggedIn.value = false;
    userName.value = null;
  }

  Future<void> redirect(Uri authorizationUrl) async {
    if (await canLaunchUrl(authorizationUrl)) {
      await launchUrl(authorizationUrl);
    } else {
      throw Exception('Could not launch $authorizationUrl');
    }
  }

  Future<Map<String, String>> listen() async {
    var request = await redirectServer!.first;
    var params = request.uri.queryParameters;
    await WindowToFront
        .activate(); // Using window_to_front package to bring the window to the front after successful login.
    request.response.statusCode = 200;
    request.response.headers.set('content-type', 'text/plain');
    request.response.writeln('Authenticated! You can close this tab.');
    await request.response.close();
    await redirectServer!.close();
    redirectServer = null;
    return params;
  }

  Future<oauth2.Client> _getOAuth2Client(Uri redirectUrl) async {
    final secret = Platform.environment['APP_SECRET_DESKTOP'];
    final clientIdDesktop = Platform.environment['CLIENT_ID_DESKTOP'];
    if (secret == null) {
      throw Exception('APP_SECRET_DESKTOP is not set');
    }
    if (clientIdDesktop == null) {
      throw Exception('CLIENT_ID_DESKTOP is not set');
    }
    var grant = oauth2.AuthorizationCodeGrant(
      clientIdDesktop,
      Uri.parse("https://accounts.google.com/o/oauth2/v2/auth"),
      Uri.parse("https://oauth2.googleapis.com/token"),
      httpClient: _JsonAcceptingHttpClient(),
      secret: secret,
    );
    var authorizationUrl =
        grant.getAuthorizationUrl(redirectUrl, scopes: scopes);

    await redirect(authorizationUrl);
    var responseQueryParameters = await listen();
    var client =
        await grant.handleAuthorizationResponse(responseQueryParameters);
    return client;
  }
}

class _JsonAcceptingHttpClient extends http.BaseClient {
  final _httpClient = http.Client();
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['Accept'] = 'application/json';
    return _httpClient.send(request);
  }
}
