import 'repositories.dart';

enum PremiumPlan { yearly, thisYear }

enum PurchaseOutcome { success, cancelled, unavailable }

/// Store abstraction for Premium.
///
/// The app talks only to this interface. [LocalPurchaseService] keeps the
/// entitlement on the device and, when [LocalPurchaseService.simulatePurchases]
/// is on, grants Premium without a store so the full flow can be tested.
/// A RevenueCat or `in_app_purchase` implementation can replace it in
/// `main.dart` without touching any screen.
abstract class PurchaseService {
  bool get isPremium;

  /// Localised price string per plan, or null while unknown.
  String? priceFor(PremiumPlan plan);

  Future<PurchaseOutcome> buy(PremiumPlan plan);

  /// Returns true when an entitlement was found.
  Future<bool> restore();
}

class LocalPurchaseService implements PurchaseService {
  LocalPurchaseService(this._store, {required this.simulatePurchases});

  final JsonStore _store;

  /// Debug/test builds: purchases succeed immediately without a store.
  final bool simulatePurchases;

  static const _key = 'premium.v1';

  /// Placeholder prices shown until a real store delivers localised ones.
  static const Map<PremiumPlan, String> placeholderPrices = {
    PremiumPlan.yearly: '9,99 €',
    PremiumPlan.thisYear: '6,99 €',
  };

  @override
  bool get isPremium => _store.readBool(_key) ?? false;

  @override
  String? priceFor(PremiumPlan plan) => placeholderPrices[plan];

  @override
  Future<PurchaseOutcome> buy(PremiumPlan plan) async {
    if (!simulatePurchases) return PurchaseOutcome.unavailable;
    await _store.writeBool(_key, true);
    return PurchaseOutcome.success;
  }

  @override
  Future<bool> restore() async => isPremium;

  /// Used by the debug switch in the profile screen.
  Future<void> setPremiumForTesting(bool value) => _store.writeBool(_key, value);
}
