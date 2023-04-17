import 'dart:developer';

import 'package:dio/dio.dart';

import '../error_handler/dio_failure.dart';
import '../error_handler/dio_handler_extension.dart';
import '../error_handler/failure.dart';
import '../new_network/network_response.dart';
import '../new_network/remote_service_response.dart';

import 'base_remote_service.dart';
import 'dynamic_auth.dart';
import 'interceptor/network_interceptor.dart';
import 'interceptor/local/config_interceptor.dart';
import 'interceptor/local/user_interceptor.dart';
import 'remote_service_config.dart';
import 'network_request.dart';
import 'remote_service_request.dart';

import 'package:injectable/injectable.dart';

/// handles network business logic
abstract class _NetworkInterface {
  Future<NetworkResponse> makeRequest(NetworkRequest request);

  const _NetworkInterface();
}

/// Communicates with [BaseRemoteService] to send the request
///
/// This gateway handles:
/// 1. generic business request structure "it builds the request"
/// 2. calls the dynamic authentication
@singleton
class NetworkGateway implements _NetworkInterface {
  final BaseRemoteService _remoteService;
  final DynamicAuth _dynamicAuth;

  const NetworkGateway(this._remoteService, this._dynamicAuth);

  /// generic interceptors goes here
  NetworkRequest _intercept(NetworkRequest request) {
    UserInterceptor().call(request);
    ConfigInterceptors().call(request);
    return request;
  }

  /// sends the given [request] to servers,
  /// applies the required changes [except] on the request
  Future<NetworkResponse> makeRequest(NetworkRequest request, {NetworkInterceptor? except}) async {
    /// calls generic interception
    _intercept(request);

    /// exception interceptor
    except?.call(request);
    // request is ready to go

    try {
      //dynamic auth
      // await _dynamicAuth(request);

      final RemoteServiceResponse remoteResponse = await _remoteService.post(RemoteServiceRequest(
          endpoint: RemoteServiceConfig.baseURL,
          body: request.toJson()));

      final networkResponse = NetworkResponse(remoteResponse.response);

      return networkResponse;
    } catch (exception) {
      if (exception is DynamicAuthCancel) rethrow;

      ///network error
      if (exception is DioError) throw exception.handleDioError();

      log(exception.toString());
      throw Failure.DEFAULT;
    }
  }
}
