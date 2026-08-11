import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/dependencies.dart';
import 'data/datasources/bff_remote_data_source.dart';
import 'data/repositories/discovery_repository_impl.dart';
import 'domain/repositories/discovery_repository.dart';
import 'domain/usecases/get_recommendations.dart';

final bffRemoteDataSourceProvider = Provider<BffRemoteDataSource>((ref) {
  return BffRemoteDataSource(ref.watch(dioClientProvider).dio);
});

final discoveryRepositoryProvider = Provider<DiscoveryRepository>((ref) {
  return DiscoveryRepositoryImpl(ref.watch(bffRemoteDataSourceProvider));
});

final getRecommendationsProvider = Provider<GetRecommendations>((ref) {
  return GetRecommendations(ref.watch(discoveryRepositoryProvider));
});