import '../api/api_client.dart';
import '../api/api_repository.dart';
import 'cache_store.dart';

final ApiClient appApiClient = ApiClient();
final ApiRepository appApiRepository = ApiRepository(appApiClient);
final CacheStore appCacheStore = CacheStore();
