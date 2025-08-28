import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import 'pro_service.dart';

/// 구독 결제를 담당하는 서비스.
/// - in_app_purchase를 통해 상품 조회/구매/복원을 처리합니다.
/// - 구매 성공 시 Pro 상태를 반영합니다.
class PurchaseService extends ChangeNotifier {
  PurchaseService._internal();
  static final PurchaseService _instance = PurchaseService._internal();
  factory PurchaseService() => _instance;

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;

  bool _isAvailable = false;
  bool get isAvailable => _isAvailable;

  /// 스토어에 등록된 상품 ID
  /// 실제 앱의 상품 ID로 교체하세요.
  static const String productIdMonthly = 'pro_monthly';
  static const String productIdYearly = 'pro_yearly';

  final Set<String> _productIds = const {productIdMonthly, productIdYearly};
  List<ProductDetails> _products = [];

  Future<void> initialize() async {
    // 중복 초기화 방지
    if (_purchaseSub != null) return;

    _isAvailable = await _inAppPurchase.isAvailable();
    if (!_isAvailable) {
      if (kDebugMode) {
        print('IAP not available');
      }
      return;
    }

    // 상품 메타 조회
    await _queryProducts();

    // 구매 업데이트 스트림 구독
    _purchaseSub = _inAppPurchase.purchaseStream.listen(
      _onPurchaseUpdated,
      onDone: () => _purchaseSub?.cancel(),
      onError: (Object error) {
        if (kDebugMode) {
          print('purchaseStream error: $error');
        }
      },
    );
  }

  Future<void> disposeService() async {
    await _purchaseSub?.cancel();
    _purchaseSub = null;
  }

  Future<void> _queryProducts() async {
    try {
      final response = await _inAppPurchase.queryProductDetails(_productIds);
      if (response.notFoundIDs.isNotEmpty && kDebugMode) {
        print('Not found product IDs: ${response.notFoundIDs}');
      }
      _products = response.productDetails;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('queryProductDetails error: $e');
      }
    }
  }

  /// 구독 구매
  /// [plan]에 따라 월간/연간 상품을 구매합니다.
  Future<bool> purchasePro(PurchasePlan plan) async {
    if (!_isAvailable) {
      await initialize();
      if (!_isAvailable) return false;
    }

    // 제품 상세 조회 (캐시 미존재 시 재조회)
    ProductDetails? details = _findProduct(plan);
    if (details == null) {
      await _queryProducts();
      details = _findProduct(plan);
    }
    if (details == null) {
      if (kDebugMode) {
        print('ProductDetails not found for: $plan');
      }
      return false;
    }

    final purchaseParam = PurchaseParam(productDetails: details);
    try {
      // 구독 상품도 buyNonConsumable로 트리거합니다.
      final success = await _inAppPurchase.buyNonConsumable(
        purchaseParam: purchaseParam,
      );
      return success;
    } catch (e) {
      if (kDebugMode) {
        print('buyNonConsumable error: $e');
      }
      return false;
    }
  }

  ProductDetails? _findProduct(PurchasePlan plan) {
    final targetId = plan == PurchasePlan.monthly
        ? productIdMonthly
        : productIdYearly;
    try {
      return _products.firstWhere((p) => p.id == targetId);
    } catch (_) {
      return null;
    }
  }

  Future<void> restorePurchases() async {
    try {
      await _inAppPurchase.restorePurchases();
    } catch (e) {
      if (kDebugMode) {
        print('restorePurchases error: $e');
      }
    }
  }

  Future<void> _onPurchaseUpdated(
    List<PurchaseDetails> purchaseDetailsList,
  ) async {
    for (final purchaseDetails in purchaseDetailsList) {
      switch (purchaseDetails.status) {
        case PurchaseStatus.pending:
          // 대기 상태: UI에서 로딩 처리 가능
          break;
        case PurchaseStatus.canceled:
          break;
        case PurchaseStatus.error:
          break;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          // 실제 앱에서는 영수증 검증을 수행하세요.
          final verified = await _verifyPurchase(purchaseDetails);
          if (verified) {
            await ProService().setPro(true);
          }
          break;
        // 일부 플랫폼/버전에서 존재하지 않을 수 있는 상태 값은 제외
      }

      if (purchaseDetails.pendingCompletePurchase) {
        try {
          await _inAppPurchase.completePurchase(purchaseDetails);
        } catch (e) {
          if (kDebugMode) {
            print('completePurchase error: $e');
          }
        }
      }
    }
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    // 서버 영수증 검증이 없다면 true로 처리 (개발/테스트용)
    // 실서비스에서는 서버 검증을 구현하세요.
    return true;
  }
}

enum PurchasePlan { monthly, yearly }
