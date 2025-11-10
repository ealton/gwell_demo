import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gw_demo/gwell_platform_channel.dart';
import 'package:gw_demo/gwell_signin.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: "dot1.env");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void _initGwSdk() async {
    final result = await GwellPlatformChannel().initSdk();
    debugPrint("initSdk result: $result");
    if (result == 0) {
      _displaySuccess("SDK init success");
    }
  }

  void _login() async {
    final phoneUniqueId = await GwellPlatformChannel().getMobileDeviceUniqueId();
    debugPrint("phoneUniqueId: $phoneUniqueId");
    final backendController = GwellSignBackendController();
    final backendResult = await backendController.customerLogInV2(phoneUniqueId: phoneUniqueId);
    debugPrint("backendResult: $backendResult");
    assert(backendResult != null);

    final result = await GwellPlatformChannel().signInToGwellAccount(
      "${backendResult!["data"]["accessId"]}",
      "${backendResult["data"]["accessToken"]}",
      "${backendResult["data"]["expireTime"]}",
      "${backendResult["data"]["terminalId"]}",
      "${backendResult["data"]["expand"]}",
    );

    if (result == 0) {
      _displaySuccess("login success");
    }
  }

  void _processQrCodeContent() async {
    final qrcode = "https://domain.com/d/?p=PRODUCT_D&u=SKU_NUMBER&mac=F1:F1:F1:F1:F1:F1";
    final result = await GwellPlatformChannel().openDeviceBindingQRCodeProcess(qrcode);
    debugPrint("_processQrCodeContent result: $result");
    if (result == 0) {
      _displaySuccess("Success");
    }
  }

  void _openMessageCenterPage() async {
    final result = await GwellPlatformChannel().openMessageCenterPage();
    debugPrint("_processQrCodeContent result: $result");
    if (result == 0) {
      _displaySuccess("Success");
    }
  }

  void _displaySuccess(String content) {
    final snackBar = SnackBar(content: Center(child: Text(content)));
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Theme.of(context).colorScheme.inversePrimary, title: Text("GW Demo")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextButton(onPressed: _initGwSdk, child: Text("Init SDK")),
            TextButton(onPressed: _login, child: Text("Sign In")),
            TextButton(onPressed: _processQrCodeContent, child: Text("Process QR Code Content")),
            TextButton(onPressed: _openMessageCenterPage, child: Text("Message Center")),
          ],
        ),
      ),
    );
  }
}
