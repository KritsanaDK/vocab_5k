import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class IAPService {
  static final IAPService _instance = IAPService._internal();

  factory IAPService() => _instance;

  IAPService._internal();

  final InAppPurchase _iap = InAppPurchase.instance;

  bool available = false;
  List<ProductDetails> products = [];
  Stream<List<PurchaseDetails>>? purchaseStream;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  /// Initialize the store and listen to purchases
  Future<void> init(Set<String> productIds) async {
    available = await _iap.isAvailable();
    if (!available) return;

    final response = await _iap.queryProductDetails(productIds);
    products = response.productDetails;

    purchaseStream = _iap.purchaseStream;
    _subscription = purchaseStream?.listen(
      _onPurchaseUpdated,
      onDone: () => dispose(),
      onError: (error) => print("Purchase stream error: $error"),
    );
  }

  void _onPurchaseUpdated(List<PurchaseDetails> purchases) {
    for (var purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased) {
        // TODO: unlock product / deliver content
        if (kDebugMode) {
          print("Purchased: ${purchase.productID}");
        }
        completePurchase(purchase);
      } else if (purchase.status == PurchaseStatus.error) {
        if (kDebugMode) {
          print("Purchase error: ${purchase.error}");
        }
      }
    }
  }

  /// Buy a non-consumable product
  void buyNonConsumable(ProductDetails product) {
    final param = PurchaseParam(productDetails: product);
    _iap.buyNonConsumable(purchaseParam: param);
  }

  /// Buy a consumable product
  void buyConsumable(ProductDetails product) {
    final param = PurchaseParam(productDetails: product);
    _iap.buyConsumable(purchaseParam: param);
  }

  /// Complete the purchase
  void completePurchase(PurchaseDetails purchase) {
    _iap.completePurchase(purchase);
  }

  void dispose() {
    _subscription?.cancel();
  }
}
