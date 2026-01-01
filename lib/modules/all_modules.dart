import 'module_registry.dart';
import 'sample/demo_module.dart';
import 'sample/sample_module.dart';
import 'package:super_module/super_module_module.dart';
import 'package:crm/crm_module.dart';

/// Auto-generated file. Do not edit manually.
/// This file registers all available modules to the registry.
class ModuleManifest {
  static void register() {
    ModuleRegistry.register(DemoModule());
    ModuleRegistry.register(SampleModule());
    ModuleRegistry.register(SuperModuleModule());
    ModuleRegistry.register(CrmModule());
  }
}
