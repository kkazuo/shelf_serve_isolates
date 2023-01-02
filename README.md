<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->

Shelf server with multi-isolates.

## Features

- Start shelf server on multiple isolates.
- Graceful shutdown with in docker containers.

## Usage

See `/example` folder.

```dart
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
```
