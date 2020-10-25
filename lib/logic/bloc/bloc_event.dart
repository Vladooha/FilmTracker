import 'package:equatable/equatable.dart';
import 'package:random_film_app/util/entity/id_generator.dart';

abstract class BlocEvent extends Equatable {
  final int id;

  BlocEvent() : id = IdGenerator.nextId;

  @override
  List<Object> get props => [id];
}