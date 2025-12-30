import 'module_registry.dart';
// import 'inventory/inventory_module.dart';
// import 'invoice/invoice_module.dart';
// import 'sales/sales_module.dart';
import 'sample/demo_module.dart';
import 'sample/sample_module.dart';

/// Auto-generated file. Do not edit manually.
/// This file registers all available modules to the registry.
class ModuleManifest {
  static void register() {
    // ModuleRegistry.register(InventoryModule());
    // ModuleRegistry.register(InvoiceModule());
    // ModuleRegistry.register(SalesModule());
    ModuleRegistry.register(DemoModule());
    ModuleRegistry.register(SampleModule());
  }
}
