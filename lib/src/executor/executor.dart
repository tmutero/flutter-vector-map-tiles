import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:vector_map_tiles/src/executor/pool_executor.dart';

import 'queue_executor.dart';

typedef CancellationCallback = bool Function();

class Job<Q, R> {
  final String name;
  final deduplicationKey;
  final ComputeCallback<Q, R> computeFunction;
  final Q value;
  final CancellationCallback? cancelled;

  Job(this.name, this.computeFunction, this.value,
      {this.cancelled, required this.deduplicationKey});

  bool get isCancelled => cancelled == null ? false : cancelled!();
}

abstract class Executor {
  Future<R> submit<Q, R>(Job<Q, R> job);

  /// submits the given function and value to all isolates in the executor
  List<Future<R>> submitAll<Q, R>(Job<Q, R> job);

  void dispose();
  bool get disposed;
}

class CancellationException implements Exception {
  CancellationException();
}

Executor newExecutor({required int concurrency}) =>
    kDebugMode ? QueueExecutor() : PoolExecutor(concurrency: concurrency);
