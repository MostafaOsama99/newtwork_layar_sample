import 'remote_service_request.dart';
import 'remote_service_response.dart';

/// Defines basic remote service methods
/// The remote service contract
abstract class BaseRemoteService {
  Future<RemoteServiceResponse> get(RemoteServiceRequest request);

  Future<RemoteServiceResponse> post(RemoteServiceRequest request);

  Future<RemoteServiceResponse> patch(RemoteServiceRequest request);

  Future<RemoteServiceResponse> delete(RemoteServiceRequest request);
}
