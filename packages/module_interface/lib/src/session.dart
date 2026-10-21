import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Id user yang sedang login (null bila belum login), untuk modul.
///
/// Aplikasi utama meng-override provider ini di `ProviderScope` dengan user dari auth provider
/// aktif. Modul yang menyimpan data milik user (daftar peralatan, kuda, sesi latihan, dll.) cukup
/// memantaunya di provider-nya:
///
/// ```dart
/// final myItemsProvider = FutureProvider<List<Item>>((ref) async {
///   ref.watch(sessionUserIdProvider); // dimuat ulang saat user berganti
///   ...
/// });
/// ```
///
/// Tanpa ini, provider yang tidak `autoDispose` menyimpan data user sebelumnya sampai aplikasi
/// ditutup: setelah logout lalu login sebagai user lain, daftar milik user lama masih tampil.
final sessionUserIdProvider = Provider<String?>((ref) => null);
