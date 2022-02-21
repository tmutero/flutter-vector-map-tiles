import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:vector_tile_renderer/vector_tile_renderer.dart';
import '../executor/executor.dart';

import '../../vector_map_tiles.dart';
import 'byte_storage.dart';
import 'memory_cache.dart';
import 'storage_cache.dart';
import 'vector_tile_loading_cache.dart';

class Caches {
  final Executor executor;
  final ByteStorage _storage = ByteStorage(
      pather: () => getTemporaryDirectory()
          .then((value) => Directory('${value.path}/.vector_map')));
  late final StorageCache _cache;
  late final VectorTileLoadingCache vectorTileCache;
  late final MemoryCache memoryVectorTileCache;
  late final List<String> providerSources;

  Caches(
      {required TileProviders providers,
      required Theme theme,
      required this.executor,
      required Duration ttl,
      required int memoryTileCacheMaxSize,
      required int maxSizeInBytes}) {
    providerSources = providers.tileProviderBySource.keys.toList();
    _cache = StorageCache(_storage, ttl, maxSizeInBytes);
    memoryVectorTileCache = MemoryCache(maxSizeBytes: memoryTileCacheMaxSize);
    vectorTileCache = VectorTileLoadingCache(
        _cache, memoryVectorTileCache, providers, executor, theme);
  }

  Future<void> applyConstraints() => _cache.applyConstraints();

  void dispose() {
    memoryVectorTileCache.dispose();
  }

  void didHaveMemoryPressure() {
    memoryVectorTileCache.didHaveMemoryPressure();
  }

  String stats() {
    final cacheStats = <String>[];
    cacheStats
        .add('Storage cache hit ratio:           ${_cache.hitRatio.asPct()}%');
    cacheStats.add(
        'Vector tile cache hit ratio:       ${memoryVectorTileCache.hitRatio.asPct()}% size: ${memoryVectorTileCache.size}');
    return cacheStats.join('\n');
  }
}

extension _PctExtension on double {
  double asPct() => (this * 1000).roundToDouble() / 10;
}
