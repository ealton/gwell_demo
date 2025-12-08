import 'package:flutter/material.dart';
import 'package:gw_demo/gwell_device.dart';
import 'package:gw_demo/gwell_platform_channel.dart';

class DeviceListDialogPanel extends StatefulWidget {
  const DeviceListDialogPanel({super.key});

  @override
  State<DeviceListDialogPanel> createState() => _DeviceListDialogPanelState();
}

class _DeviceListDialogPanelState extends State<DeviceListDialogPanel> {
  List<GwellDevice> _deviceList = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onRefreshTap();
    });
  }

  void _displaySuccess(String content) {
    final snackBar = SnackBar(content: Center(child: Text(content)));
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _onRefreshTap() async {
    _isLoading = true;
    setState(() {});
    await Future.delayed(Duration(seconds: 0));
    final devices = await GwellPlatformChannel().getDeviceList();
    _deviceList.clear();
    _deviceList.addAll(devices);
    _isLoading = false;
    setState(() {});
  }

  void _onDeviceTap(String deviceId) async {
    await GwellPlatformChannel().openLiveviewPage(deviceId);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Expanded(child: _isLoading ? Text("Loading...") : Text("Device List")),
          IconButton(onPressed: _onRefreshTap, icon: Icon(Icons.refresh)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          children: _deviceList
              .map(
                (item) => TextButton(
                  onPressed: () {
                    _onDeviceTap(item.deviceId);
                  },
                  child: Text(item.remarkName),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
