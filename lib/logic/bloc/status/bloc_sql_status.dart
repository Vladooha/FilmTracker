import 'package:random_film_app/logic/bloc/status/abstract_bloc_status.dart';

abstract class SqlStatus extends BlocStatus {}

class SqlLoading extends SqlStatus {
  @override
  List<Object> get props => [];
}

class SqlOk extends SqlStatus {
  @override
  List<Object> get props => [];
}

class SqlError extends SqlStatus {
  final String error;

  SqlError(this.error);

  @override
  List<Object> get props => [error];
}