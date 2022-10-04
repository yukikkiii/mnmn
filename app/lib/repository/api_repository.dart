import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:mnmn/utils/config.dart';

class ApiRepository {
  ApiRepository(this._client);

  final ApiClient _client;

  Future<Map<String, dynamic>> signIn(Map<String, dynamic> req) async {
    return _client._withoutAuth(_Method.POST, '/auth/sign-in', req);
  }

  Future<Map<String, dynamic>> signOut([Map<String, dynamic>? req]) async {
    return _client._withAuth(_Method.POST, '/auth/sign-out', req);
  }

  Future<Map<String, dynamic>> signUp(Map<String, dynamic> req) async {
    return _client._withoutAuth(_Method.POST, '/auth/sign-up', req);
  }

  Future<Map<String, dynamic>> requestResetPassword(
      Map<String, dynamic> req) async {
    return _client._withoutAuth(
        _Method.POST, '/auth/request-reset-password', req);
  }

  Future<Map<String, dynamic>> updateLocation(Map<String, dynamic> req) async {
    return _client._withAuth(_Method.POST, '/locations/update', req);
  }

  Future<Map<String, dynamic>> listMessages([Map<String, dynamic>? req]) async {
    return _client._withAuth(_Method.GET, '/messages', req);
  }

  Future<Map<String, dynamic>> listMessagesSent(
      [Map<String, dynamic>? req]) async {
    return _client._withAuth(_Method.GET, '/users/my/messages', req);
  }

  Future<Map<String, dynamic>> listMyLocations(
      [Map<String, dynamic>? req]) async {
    return _client._withAuth(_Method.GET, '/users/my/locations', req);
  }

  Future<Map<String, dynamic>> retrieveMessages(
      Map<String, dynamic> req) async {
    return _client._withAuth(_Method.POST, '/messages/retrieve', req);
  }

  Future<Map<String, dynamic>> sendMessage(Map<String, dynamic> req) async {
    return _client._withAuth(_Method.POST, '/messages', req);
  }

  Future<Map<String, dynamic>> uploadImage(Uint8List bytes, String ext) {
    final formData = FormData.fromMap(<String, dynamic>{
      'image': MultipartFile.fromBytes(bytes, filename: 'image.$ext'),
    });

    return _client._withAuth(_Method.POST, '/image', formData, <String, String>{
      'Content-Type': 'multipart/form-data',
    });
  }

  Future<Map<String, dynamic>> listPraySites([Map<String, dynamic>? req]) async {
    return _client._withAuth(_Method.GET, '/pray-sites', req);
  }

  Future<Map<String, dynamic>> searchUsers(Map<String, dynamic> req) async {
    return _client._withAuth(_Method.GET, '/friendships/search', req);
  }

  Future<Map<String, dynamic>> addFriends(Map<String, dynamic> req) async {
    return _client._withAuth(_Method.POST, '/friendships', req);
  }

  Future<Map<String, dynamic>> listFriends([Map<String, dynamic>? req]) async {
    return _client._withAuth(_Method.GET, '/users/my/friendships', req);
  }

  Future<Map<String, dynamic>> updateFcmToken(Map<String, dynamic> req) async {
    return _client._withAuth(_Method.POST, '/users/my/fcm-token', req);
  }

  Future<Map<String, dynamic>> getUnreadMessageCount() async {
    return _client._withAuth(_Method.GET, '/users/my/unread-messages');
  }

  Future<Map<String, dynamic>> getMyProfile() async {
    return _client._withAuth(_Method.GET, '/users/my');
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> req) async {
    return _client._withAuth(_Method.POST, '/users/my', req);
  }

  Future<Map<String, dynamic>> favoriteMessage(int id) async {
    return _client._withAuth(_Method.POST, '/messages/$id/favorite');
  }

  Future<Map<String, dynamic>> unfavoriteMessage(int id) async {
    return _client._withAuth(_Method.POST, '/messages/$id/unfavorite');
  }

  Future<Map<String, dynamic>> openMessage(int id) {
    return _client._withAuth(_Method.POST, '/messages/$id/open');
  }

  Future<Map<String, dynamic>> postContact(Map<String, dynamic> req) {
    return _client._withAuth(_Method.POST, '/contacts', req);
  }
}

class ApiClient {
  ApiClient({String? token}) : _token = token;

  String? _token;
  final Dio _dio = Dio();

  void setToken(String? token) {
    _token = token;
  }

  Options _createOptions(_Method method,
      {bool sendToken = false, Map<String, String>? headers}) {
    return Options(
      method: method.asString(),
      headers: <String, String>{
        if (sendToken) 'Authorization': 'Bearer $_token',
        if (headers != null) ...headers,
      },
    );
  }

  String _resolvePath(String fragment, [Map<String, String>? query]) {
    var queryString = '';
    if (query != null) {
      queryString =
          '?${query.entries.map((e) => '${Uri.encodeFull(e.key)}=${Uri.encodeFull(e.value)}').join('&')}';
    }

    return '${Config.API_URL}/api/v0$fragment$queryString';
  }

  Future<Map<String, dynamic>> _requestCore(
    _Method method,
    String path,
    dynamic payload, {
    required bool sendToken,
    Map<String, String>? headers,
  }) {
    return _dio
        .request<Map<String, dynamic>>(
          _resolvePath(
              path,
              method == _Method.GET && payload != null
                  ? payload as Map<String, String>
                  : null),
          data: method == _Method.GET ? null : payload,
          options:
              _createOptions(method, sendToken: sendToken, headers: headers),
        )
        .then(_handleResponse)
        .catchError(_handleErrorResponse, test: (Object e) => e is DioError);
  }

  Future<Map<String, dynamic>> _withoutAuth(_Method method, String path,
      [dynamic payload]) {
    return _requestCore(method, path, payload, sendToken: false);
  }

  Future<Map<String, dynamic>> _withAuth(
    _Method method,
    String path, [
    dynamic payload,
    Map<String, String>? headers,
  ]) {
    return _requestCore(
      method,
      path,
      payload,
      sendToken: true,
      headers: headers,
    );
  }

  Map<String, dynamic> _handleResponse(Response<Map<String, dynamic>> res) {
    return res.data!;
  }

  Map<String, dynamic> _buildError(String message) {
    return <String, dynamic>{
      'error': <String, dynamic>{
        'message': message,
      },
    };
  }

  Map<String, dynamic> _handleErrorResponse(Object error) {
    // The following condition is always true
    if (error is DioError) {
      late Map<String, dynamic> errorData;
      print(
          'Unhandled error occurred while communicating with server. (${error.requestOptions.uri})');
      if (error.response?.data is Map<String, dynamic>) {
        print(error.response!.data);
        errorData = Map<String, dynamic>.from(
            error.response!.data! as Map<String, dynamic>);
      } else if (error.response?.data is String) {
        print(error.response!.data);
        errorData = _buildError(error.response!.data as String);
      } else {
        print(error.message);
        errorData = _buildError(error.message);
      }

      errorData['_status'] = error.response?.statusCode;
      return errorData;
    }

    // This code is actually unreachable.
    return <String, dynamic>{};
  }
}

enum _Method {
  GET,
  POST,
}

extension _MethodToStringExtension on _Method {
  String asString() {
    switch (this) {
      case _Method.GET:
        return 'GET';
      case _Method.POST:
        return 'POST';
    }
  }
}
