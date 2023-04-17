import '../../typedefs/json.dart';

/// the basic form factor for the request
class RemoteServiceRequest {
  final String endpoint;
  final JSON body;

  const RemoteServiceRequest({
    required this.endpoint,
    JSON? body,
  }) : this.body = body ?? const {};
}
