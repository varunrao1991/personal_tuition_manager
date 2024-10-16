import 'package:http/http.dart' as http;

class HttpTimeoutClient extends http.BaseClient {
  final http.Client _inner;

  HttpTimeoutClient([http.Client? inner]) : _inner = inner ?? http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _inner.send(request).timeout(const Duration(seconds: 5));
  }
}
