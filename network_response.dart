import '../../constants/core_constant.dart';
import '../../typedefs/json.dart';

abstract class ResponseStatus {
  static const _statusKey = 'responseStatus';
  static const success = 'Succeeded';
  static const failed = 'Failed';
}

/// factory pattern
/// this class takes the JSON response and process it
/// so it will be ether a [SuccessResponse] or [FailureResponse]
abstract class NetworkResponse {
  NetworkResponse._(this.response);

  bool get succeed => isSucceed(response);

  /// static method to be used in the factory constructor before initiating an object
  static bool isSucceed(JSON res) => res[ResponseStatus._statusKey] == ResponseStatus.success;

  String get timeStamp => response['timestamp'];

  String get apiCode => response['apiCode'];

  final JSON response;

  /// what to do whether success or failure
  fold(
    void Function(SuccessResponse successResponse) success,
    void Function(FailureResponse failureResponse) failure,
  ) {
    if (this is SuccessResponse) return success(this as SuccessResponse);
    return failure(this as FailureResponse);
  }

  factory NetworkResponse(JSON response) {
    if (isSucceed(response['response'])) {
      return SuccessResponse(response);
    }
    return FailureResponse(response);
  }
}

/// represents the generic success response structure
class SuccessResponse extends NetworkResponse {
  final String signature;

  SuccessResponse(JSON response)
      : this.signature = response['signature'] ?? Constants.emptyString,
        super._(response['response']);

  // bool get hasResult => response['result'] != null;
  JSON? get result => response['result'];

  String? get successMessage => response['successMessage'];
}

/// represents the generic failure response structure
class FailureResponse extends NetworkResponse {
  FailureResponse(JSON response) : super._(response['response']);

  String get errorMessage => response['responseError']['errorMessage'] ?? 'default error message';

  String get errorCode => response['responseError']['errorCode'] ?? 'unknown';

  String get errorCategory => response['responseError']['errorCategory'] ?? 'unknown';

  List<String>? get errorMsgList => response['responseError']['errorMsgList'];
}
