import 'package:beat/beat.dart';
import 'package:source_gen/source_gen.dart';

/// [Beat] annotation
TypeChecker get beatChecker => TypeChecker.fromRuntime(Beat);

/// [Station] annotation
TypeChecker get stationChecker => TypeChecker.fromRuntime(Station);

/// [Substation] annotation
TypeChecker get substationChecker => TypeChecker.fromRuntime(Substation);

/// [Services] annotation
TypeChecker get servicesChecker => TypeChecker.fromRuntime(Services);

/// [AsyncService] annotation
TypeChecker get asyncChecker => TypeChecker.fromRuntime(AsyncService);

/// [ParallelStation] annotation
TypeChecker get parallelChecker => TypeChecker.fromRuntime(ParallelStation);
