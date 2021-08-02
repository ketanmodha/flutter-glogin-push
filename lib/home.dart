import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import './api/google_sign_in_api.dart';
import './models/user.dart';

class Home extends StatefulWidget {
  static const routeName = '/home';
  static const oneSignalAppId = 'YOUR_ONE_SIGNAL_APP_ID';

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late User user;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  @override
  Widget build(BuildContext context) {
    user = ModalRoute.of(context)!.settings.arguments as User;
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome'),
      ),
      body: SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                child: FadeInImage.assetNetwork(
                  placeholder: 'assets/images/google_logo.png',
                  image: user.photoUrl ?? '',
                  imageErrorBuilder: (BuildContext context, Object error,
                      StackTrace? stackTrace) {
                    return Image.asset(
                      'assets/images/google_logo.png',
                      width: 50,
                      height: 50,
                    );
                  },
                  height: 50,
                  width: 50,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '${user.displayName}',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '${user.email}',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w100,
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => signOut(),
                child: Text('Sign out'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future signOut() async {
    await GoogleSignInApi.logOut();
    _unSubscribeOneSignalNotification();
    Navigator.pushReplacementNamed(context, '/');
  }

  Future initPlatformState() async {
    if (!mounted) return;
    OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);
    OneSignal.shared.setAppId(Home.oneSignalAppId);
    // The promptForPushNotificationsWithUserResponse function will show the iOS push notification prompt. We recommend removing the following code and instead using an In-App Message to prompt for notification permission
    _handlePromptForPushPermission();
    _handleNotificationObserver();
  }

  void _handlePromptForPushPermission() {
    print("Prompting for Permission");
    OneSignal.shared.promptUserForPushNotificationPermission().then((accepted) {
      print("Accepted permission: $accepted");
    });
  }

  void _handleNotificationObserver() {
    OneSignal.shared.setNotificationWillShowInForegroundHandler(
        (OSNotificationReceivedEvent event) {
      // Will be called whenever a notification is received in foreground
      // Display Notification, pass null param for not displaying the notification
      event.complete(event.notification);
      debugPrint('Received notification in foreground');
    });

    OneSignal.shared
        .setNotificationOpenedHandler((OSNotificationOpenedResult result) {
      // Will be called whenever a notification is opened/button pressed.
      debugPrint('Notification is opened/button pressed');
    });

    OneSignal.shared.setPermissionObserver((OSPermissionStateChanges changes) {
      // Will be called whenever the permission changes
      // (ie. user taps Allow on the permission prompt in iOS)
      debugPrint('Notification permission changed in iOS');
    });

    OneSignal.shared
        .setSubscriptionObserver((OSSubscriptionStateChanges changes) {
      // Will be called whenever the subscription changes
      // (ie. user gets registered with OneSignal and gets a user ID)
      debugPrint('Notification subscription changes');
    });

    OneSignal.shared.setEmailSubscriptionObserver(
        (OSEmailSubscriptionStateChanges emailChanges) {
      // Will be called whenever then user's email subscription changes
      // (ie. OneSignal.setEmail(email) is called and the user gets registered
      debugPrint('Users email subscription changes');
    });
  }

  Future _unSubscribeOneSignalNotification() async {
    await OneSignal.shared.disablePush(true);
  }
}
