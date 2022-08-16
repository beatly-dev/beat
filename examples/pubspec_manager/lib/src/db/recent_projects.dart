import 'package:isar/isar.dart';

part 'recent_projects.g.dart';

@Collection()
class RecentProjects {
  Id id = Isar.autoIncrement;
  late String name;
  @Index(unique: true, replace: true)
  late String path;
}
