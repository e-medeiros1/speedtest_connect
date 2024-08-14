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

  bool testInProgress = false;
  double downloadRate = 0;

  String downloadProgress = '0';

  int downloadCompletionTime = 0;

  bool isServerSelected = false;
  double displayNumber = 0.0;
  String myIp = '';

  String unitText = 'Mbps';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      reset();
    });
  }

  Widget _getRadialGauge() {
    return SfRadialGauge(axes: <RadialAxis>[
      RadialAxis(canRotateLabels: true, minimum: 0, maximum: 150, ranges: <GaugeRange>[
        GaugeRange(
            startValue: 0,
            endValue: 50,
            color: Colors.green,
            startWidth: 10,
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
          endWidth: 10,
        )
      ], pointers: <GaugePointer>[
        NeedlePointer(
          value: downloadRate,
          animationType: AnimationType.elasticOut,
          animationDuration: 3000,
          enableAnimation: true,
        )
      ], annotations: <GaugeAnnotation>[
        GaugeAnnotation(
            widget: Text(
              '${downloadRate.toStringAsFixed(2)} $unitText',
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            angle: 90,
            positionFactor: 1.1)
      ])
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Teste de velocidade',
            style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            if (testInProgress)
              Text(
                isServerSelected ? 'Procurando servidor...' : myIp,
                style: const TextStyle(fontSize: 30.0),
              ),
            if (testInProgress)
              AnimatedContainer(
                  duration: const Duration(seconds: 1), child: _getRadialGauge()),
            Center(
              child: Column(
                children: [
                  ElevatedButton(
                    child: Text(
                      downloadProgress != '100' ? 'Começar teste' : 'Recomeçar teste',
                      style: const TextStyle(fontSize: 22),
                    ),
                    onPressed: () async {
                      reset();
                      await internetSpeedTest.startTesting(onStarted: () {
                        setState(() => testInProgress = true);
                      }, onCompleted: (TestResult download, TestResult upload) {
                        setState(() {
                          downloadRate = download.transferRate;
                          unitText = download.unit == SpeedUnit.kbps ? 'Kbps' : 'Mbps';
                          downloadProgress = '100';
                          downloadCompletionTime = download.durationInMillis;
                        });
                      }, onProgress: (double percent, TestResult data) {
                        setState(() {
                          unitText = data.unit == SpeedUnit.kbps ? 'Kbps' : 'Mbps';
                          if (data.type == TestType.download) {
                            downloadRate = data.transferRate;
                            downloadProgress = percent.toStringAsFixed(2);
                          }
                        });
                      }, onError: (String errorMessage, String speedTestError) {
                        reset();
                      }, onDefaultServerSelectionInProgress: () {
                        setState(() {
                          isServerSelected = true;
                        });
                      }, onDefaultServerSelectionDone: (Client? client) {
                        setState(() {
                          isServerSelected = false;
                          myIp = client?.ip ?? '--';
                        });
                      }, onDownloadComplete: (TestResult data) {
                        setState(() {
                          downloadRate = data.transferRate;
                          unitText = data.unit == SpeedUnit.kbps ? 'Kbps' : 'Mbps';
                          downloadCompletionTime = data.durationInMillis;
                        });
                      }, onCancel: () {
                        reset();
                      });
                    },
                  )
                ],
              ),
            ),
          ],
        ));
  }

  void reset() {
    setState(() {
      {
        testInProgress = false;
        downloadRate = 0;

        downloadProgress = '0';

        unitText = 'Mbps';
        downloadCompletionTime = 0;

        myIp = '';
      }
    });
  }
}
