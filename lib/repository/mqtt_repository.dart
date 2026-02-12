import 'dart:async';
import 'dart:convert';

import 'package:mqtt_client/mqtt_browser_client.dart';
import 'package:mqtt_client/mqtt_client.dart';

class MqttRepository {
  late MqttBrowserClient client;
  bool _initialized = false;

  Stream<Map<String, dynamic>> get projectorStream => _controller.stream;
  final _controller = StreamController<Map<String, dynamic>>.broadcast();

  Future<void> initializeMqtt() async {
    if (_initialized) return;
    _initialized = true;

    client = MqttBrowserClient(
      'wss://broker.emqx.io/mqtt',
      'flutter_client_${DateTime.now().millisecondsSinceEpoch}',
    );
    client.port = 8084;

    client.websocketProtocols = MqttClientConstants.protocolsSingleDefault;
    client.logging(on: true);

    try {
      await client.connect();
      client.subscribe("sensor/data/thesis", MqttQos.atLeastOnce);

      if (client.connectionStatus!.state == MqttConnectionState.connected) {
        print("MQTT Connected");

        client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
          final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
          final String message = MqttPublishPayload.bytesToStringAsString(
            recMess.payload.message,
          );

          print('MQTT Msg Received: $message');

          /*
          Format data JSON
          {
            "room": "HD3",
            "data": {
              "status": "on",
              "usage": 1234,
              "temp": 46.5
            }
          }
        */
          _controller.add(Map<String, dynamic>.from(jsonDecode(message)));
        });
      }
    } catch (e) {
      print('MQTT Connection failed: $e');
    }
  }
}
