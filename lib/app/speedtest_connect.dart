import 'package:flutter/material.dart';
import 'package:flutter_internet_speed_test/flutter_internet_speed_test.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class SpeedtestConnect extends StatefulWidget {
  const SpeedtestConnect({super.key});

  @override
  _SpeedtestConnectState createState() => _SpeedtestConnectState();
}

class _SpeedtestConnectState extends State<SpeedtestConnect> {
  final internetSpeedTest = FlutterInternetSpeedTest()..enableLog();

  bool _testInProgress = false;
  double _downloadRate = 0;
  double _uploadRate = 0;
  String _downloadProgress = '0';
  String _uploadProgress = '0';
  int _downloadCompletionTime = 0;
  int _uploadCompletionTime = 0;
  bool _isServerSelected = false;
  final double _displayNumber = 0.0;
  String _myIp = '';
  bool _isDownloadComplete = false;

  String _unitText = 'Mbps';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      reset();
    });
  }

  Widget _downloadGauge() {
    return SfRadialGauge(axes: <RadialAxis>[
      RadialAxis(
        canRotateLabels: true,
        minimum: 0,
        maximum: 150,
        ranges: <GaugeRange>[
          GaugeRange(
              startValue: 0,
              endValue: 50,
              color: Colors.green,
              startWidth: 15,
              endWidth: 10),
          GaugeRange(
              startValue: 50,
              endValue: 100,
              color: Colors.orange,
              startWidth: 10,
              endWidth: 10),
          GaugeRange(
            startValue: 100,
            endValue: 150,
            color: Colors.red,
            startWidth: 10,
            endWidth: 15,
          )
        ],
        pointers: <GaugePointer>[
          NeedlePointer(
            value: _downloadRate,
            animationType: AnimationType.elasticOut,
            animationDuration: 3000,
            enableAnimation: true,
          )
        ],
      )
    ]);
  }

  Widget _uploadGauge() {
    return SfRadialGauge(axes: <RadialAxis>[
      RadialAxis(
        canRotateLabels: true,
        minimum: 0,
        maximum: 150,
        ranges: <GaugeRange>[
          GaugeRange(
              startValue: 0,
              endValue: 50,
              color: Colors.purple[200],
              startWidth: 15,
              endWidth: 10),
          GaugeRange(
              startValue: 50,
              endValue: 100,
              color: Colors.purple[500],
              startWidth: 10,
              endWidth: 10),
          GaugeRange(
            startValue: 100,
            endValue: 150,
            color: Colors.purple[700],
            startWidth: 10,
            endWidth: 15,
          )
        ],
        pointers: <GaugePointer>[
          NeedlePointer(
            value: _uploadRate,
            animationType: AnimationType.elasticOut,
            animationDuration: 3000,
            enableAnimation: true,
          )
        ],
      )
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Align(
                child: Text(
                  'Teste de velocidade',
                  style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const Text(
              "Seu IP:",
              style: TextStyle(fontSize: 22.0),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                _isServerSelected ? 'Procurando servidor...' : _myIp,
                style: const TextStyle(fontSize: 30.0),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 1000),
              child: _isDownloadComplete ? _uploadGauge() : _downloadGauge(),
            ),
            const Text(
              "Download:",
              style: TextStyle(fontSize: 22.0),
            ),
            Text(
              _downloadRate.toStringAsFixed(2) + _unitText,
              style: const TextStyle(fontSize: 30.0),
            ),
            const Text(
              "Upload:",
              style: TextStyle(fontSize: 22.0),
            ),
            Text(
              _uploadRate.toStringAsFixed(2) + _unitText,
              style: const TextStyle(fontSize: 30.0),
            ),
            if (!_testInProgress) ...{
              Padding(
                  padding: const EdgeInsets.all(40),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      shape: WidgetStateProperty.all(
                        const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(25)),
                            side: BorderSide(
                              color: Colors.white,
                              width: 1,
                            )),
                      ),
                    ),
                    child: const Text(
                      'Começar teste',
                      style: TextStyle(fontSize: 22, color: Colors.white),
                    ),
                    onPressed: () async {
                      reset();
                      await internetSpeedTest.startTesting(onStarted: () {
                        setState(() => _testInProgress = true);
                      }, onCompleted: (TestResult download, TestResult upload) {
                        setState(() {
                          _downloadRate = download.transferRate;
                          _unitText = download.unit == SpeedUnit.kbps ? 'Kbps' : 'Mbps';
                          _downloadCompletionTime = download.durationInMillis;
                        });
                        setState(() {
                          _uploadRate = upload.transferRate;
                          _unitText = upload.unit == SpeedUnit.kbps ? 'Kbps' : 'Mbps';
                          _uploadCompletionTime = upload.durationInMillis;
                          _testInProgress = false;
                        });
                      }, onProgress: (double percent, TestResult data) {
                        setState(() {
                          _unitText = data.unit == SpeedUnit.kbps ? 'Kbps' : 'Mbps';
                          if (data.type == TestType.download) {
                            _downloadRate = data.transferRate;
                            _downloadProgress = percent.toStringAsFixed(2);
                          } else {
                            _uploadRate = data.transferRate;
                            _uploadProgress = percent.toStringAsFixed(2);
                          }
                        });
                      }, onError: (String errorMessage, String speedTestError) {
                        reset();
                      }, onDefaultServerSelectionInProgress: () {
                        setState(() {
                          _isServerSelected = true;
                          _myIp = '--';
                        });
                      }, onDefaultServerSelectionDone: (Client? client) {
                        setState(() {
                          _isServerSelected = false;
                          _myIp = client?.ip ?? '--';
                        });
                      }, onDownloadComplete: (TestResult data) {
                        setState(() {
                          _isDownloadComplete = true;
                          _downloadRate = data.transferRate;
                          _unitText = data.unit == SpeedUnit.kbps ? 'Kbps' : 'Mbps';
                          _downloadCompletionTime = data.durationInMillis;
                        });
                      }, onUploadComplete: (TestResult data) {
                        setState(() {
                          _uploadRate = data.transferRate;
                          _unitText = data.unit == SpeedUnit.kbps ? 'Kbps' : 'Mbps';
                          _uploadCompletionTime = data.durationInMillis;
                        });
                      }, onCancel: () {
                        reset();
                      });
                    },
                  )),
            } else ...{
              Padding(
                  padding: const EdgeInsets.all(40),
                  child: ElevatedButton.icon(
                    style: ButtonStyle(
                      shape: WidgetStateProperty.all(
                        const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(25)),
                            side: BorderSide(
                              color: Colors.white,
                              width: 1,
                            )),
                      ),
                    ),
                    onPressed: () => internetSpeedTest.cancelTest(),
                    icon: Icon(Icons.cancel_rounded, color: Colors.red[300]),
                    label: const Text(
                      'Cancelar',
                      style: TextStyle(fontSize: 22, color: Colors.white),
                    ),
                  )),
            },
          ],
        ),
      ),
    );
  }

  void reset() {
    setState(() {
      {
        _testInProgress = false;
        _downloadRate = 0;
        _uploadRate = 0;
        _downloadProgress = '0';
        _uploadProgress = '0';
        _unitText = 'Mbps';
        _downloadCompletionTime = 0;
        _uploadCompletionTime = 0;
        _isDownloadComplete = false;
        _myIp = '';
      }
    });
  }
}
