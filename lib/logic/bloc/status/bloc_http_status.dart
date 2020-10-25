import 'package:random_film_app/logic/bloc/status/abstract_bloc_status.dart';

abstract class HttpStatus extends BlocStatus {
  @override
  List<Object> get props => [this.runtimeType];
}

class HttpOk extends HttpStatus {}
class HttpTimeout extends HttpStatus {}
class HttpUnauth extends HttpStatus {}
class HttpInvalidData extends HttpStatus {
  final String message;

  HttpInvalidData(this.message);
}
class HttpError extends HttpStatus {
  final String error;

  HttpError(this.error);
}
class WaitForResponse extends HttpStatus {}
