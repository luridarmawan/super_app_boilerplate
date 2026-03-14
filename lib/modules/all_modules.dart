import 'module_registry.dart';
import 'news/news_module.dart';
import 'sample/demo_module.dart';
import 'sample/sample_module.dart';

/// Auto-generated file. Do not edit manually.
/// This file registers all available modules to the registry.
class ModuleManifest {
  static void register() {
    ModuleRegistry.register(DemoModule());
    ModuleRegistry.register(NewsModule());
    ModuleRegistry.register(SampleModule());
  }
}
