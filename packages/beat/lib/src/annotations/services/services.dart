/// Invoking services is basically an asynchronous call to a service.
/// There should be an async gap to invoke services.
export 'future.dart';

/// Convenient way to define multiple services in one annotation.
class Services {
  const Services([this.services = const []]);
  final List<dynamic> services;
}
