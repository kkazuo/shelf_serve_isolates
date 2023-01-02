import 'dart:async';

import 'package:shelf/shelf.dart';
import 'package:shelf_serve_isolates/shelf_serve_isolates.dart';

Future<void> serve({int port = 8080}) async {
  final handler =
      const Pipeline().addMiddleware(logRequests()).addHandler(_echoRequest);

  await ServeWithMultiIsolates(
    handler: handler,
    address: 'localhost',
    port: port,
    onStart: (server) {
      print('Serving at http://${server.address.host}:${server.port}');
    },
    onClose: (server) {
      print('server shutdown');
    },
  ).serve();
}

Future<Response> _echoRequest(Request request) async {
  return Response.ok('Request for "${request.url}"');
}
