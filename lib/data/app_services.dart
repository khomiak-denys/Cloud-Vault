import '../api/api_client.dart';
import '../api/api_repository.dart';

final ApiClient appApiClient = ApiClient();
final ApiRepository appApiRepository = ApiRepository(appApiClient);
