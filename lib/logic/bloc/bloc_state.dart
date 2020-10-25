import 'package:equatable/equatable.dart';
import 'package:random_film_app/logic/bloc/status/abstract_bloc_status.dart';
import 'package:random_film_app/util/entity/id_generator.dart';

import 'bloc_event.dart';

abstract class BlocState<EventType extends BlocEvent> extends Equatable {
  final BlocStatus status;
  final int id;
  final EventType event;

  BlocState(this.status, this.event) : id = IdGenerator.nextId;

  @override
  List<Object> get props => [id];
}