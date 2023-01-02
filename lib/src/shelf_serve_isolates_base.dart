/*
Copyright 2023 Koga Kazuo (kkazuo@kkazuo.com)

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
 */
import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_docker_shutdown/shelf_docker_shutdown.dart';

/// Serve with multi-isolates
class ServeWithMultiIsolates {
  /// construct
  ServeWithMultiIsolates({
    required this.handler,
    required this.address,
    required this.port,
    this.securityContext,
    this.backlog,
    this.poweredByHeader,
    this.onStart,
    this.onClose,
  });

  /// handler
  final FutureOr<Response> Function(Request) handler;

  /// address
  final Object address;

  /// port
  final int port;

  /// security context
  final SecurityContext? securityContext;

  /// backlog
  final int? backlog;

  /// powerd by header
  final String? poweredByHeader;

  /// on start server hook.
  final FutureOr<void> Function(HttpServer)? onStart;

  /// on close server hook.
  final FutureOr<void> Function(HttpServer)? onClose;

  /// Start serve with [numberOfIsolates] (default: numberOfProcessors).
  ///
  /// Await until server shutdown.
  Future<void> serve({int? numberOfIsolates}) async {
    final total = numberOfIsolates ?? Platform.numberOfProcessors;

    for (var n = 1; n < total; n += 1) {
      await Isolate.spawn(_serve, this);
    }
    await _serve(this);
  }
}

Future<void> _serve(ServeWithMultiIsolates arg) async {
  final server = await shelf_io.serve(
    arg.handler,
    arg.address,
    arg.port,
    shared: true,
    securityContext: arg.securityContext,
    backlog: arg.backlog,
    poweredByHeader: arg.poweredByHeader,
  );
  final onStart = arg.onStart;
  if (onStart != null) {
    await onStart(server);
  }
  await server.closeOnTermSignal();
  final onClose = arg.onClose;
  if (onClose != null) {
    await onClose(server);
  }
}
