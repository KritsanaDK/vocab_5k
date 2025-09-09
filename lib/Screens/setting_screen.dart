import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';

import '../Helper/app_colors.dart';
import '../Providers/db_provider.dart';
import '../Providers/main_provider.dart';
import '../Services/iap_service.dart';
import '../Widgets/CustomStepper.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  // final InAppPurchase _iap = InAppPurchase.instance;
  List<ProductDetails> products = [];
  late Stream<List<PurchaseDetails>> _subscription;
  bool available = false;

  final IAPService _iapService = IAPService();
  final Set<String> _productIds = {'your_product_id'};

  @override
  void initState() {
    super.initState();
    _initIAP();
  }

  Future<void> _initIAP() async {
    await _iapService.init(_productIds);

    _iapService.purchaseStream?.listen((purchaseDetailsList) {
      for (var purchase in purchaseDetailsList) {
        if (purchase.productID == 'premium_upgrade' &&
            purchase.status == PurchaseStatus.purchased) {
          Provider.of<MainProvider>(context, listen: false).unlockPremium();
          _iapService.completePurchase(purchase);
          _showAlertDialog(context, "Premium unlocked successfully!");
        }
      }
    });
  }

  void _buyPremium() {
    if (_iapService.products.isNotEmpty) {
      _iapService.buyNonConsumable(_iapService.products[0]);
    } else {
      _showAlertDialog(context, "Product not available");
    }
  }

  void _showAlertDialog(BuildContext context, String message) {
    showCupertinoDialog<void>(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text('Alert'),
        content: Text(message),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildRow({required String label, Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          LabelText(text: label),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var mainProvider = context.watch<MainProvider>();
    var dbProvider = context.watch<DbProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        toolbarHeight: 0,
      ),
      backgroundColor: AppColors.facebookBackground,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🟦 Header
              Row(
                children: [
                  const Icon(Icons.settings, size: 26, color: Colors.black87),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Settings",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        "Customize your app preferences",
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 🟦 General Zone
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildRow(
                      label: "Number of choice",
                      trailing: CustomStepper(
                        lowerLimit: 2,
                        upperLimit: 10,
                        stepValue: 1,
                        iconSize: 30,
                        value: mainProvider.maxChoice,
                        onChanged: (int value) async {
                          mainProvider.maxChoice = value;
                          await mainProvider.vocabularyListRandomize(false);
                          await dbProvider.insertOrUpdateConfig(
                            "max_choice",
                            value.toString(),
                          );
                          setState(() {});
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // 🟩 Score Zone
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildRow(
                      label: "Reset score today",
                      trailing: IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: Icon(Icons.refresh, color: Colors.green.shade700),
                        onPressed: () async {
                          bool result = await dbProvider.insertOrUpdateResult(
                            mainProvider.getDateString(addDays: 0),
                            0,
                            0,
                          );
                          if (result) {
                            _showAlertDialog(
                              context,
                              "Score reset successfully",
                            );
                          }
                        },
                      ),
                    ),
                    _buildRow(
                      label: "Clear All History",
                      trailing: IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: Icon(Icons.delete, color: Colors.red.shade700),
                        onPressed: () async {
                          bool result = await dbProvider.deleteAllResults();
                          if (result) {
                            _showAlertDialog(context, "All history cleared");
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // 🟨 Sound Zone
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.yellow.shade50,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildRow(
                      label: "Sound",
                      trailing: InkWell(
                        onTap: () async {
                          setState(
                            () => mainProvider.isOn = !mainProvider.isOn,
                          );
                          await dbProvider.insertOrUpdateConfig(
                            "sound",
                            mainProvider.isOn.toString(),
                          );
                        },
                        child: Container(
                          width: 50,
                          height: 26,
                          padding: const EdgeInsets.symmetric(
                            vertical: 2,
                            horizontal: 10,
                          ),
                          decoration: BoxDecoration(
                            color: mainProvider.isOn
                                ? Colors.green
                                : Colors.red,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Center(
                            child: Text(
                              mainProvider.isOn ? "ON" : "OFF",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 🟪 Premium Upgrade Zone
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      "Premium Upgrade",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      mainProvider.isPremium
                          ? "Thank you for purchasing Premium!"
                          : "Unlock extra features like ad-free experience and more quizzes.",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.purple.shade700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (!mainProvider.isPremium)
                      ElevatedButton(
                        onPressed: _buyPremium,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 20,
                          ),
                        ),
                        child: const Text(
                          "Upgrade to Premium",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// LabelText Widget
class LabelText extends StatelessWidget {
  final String text;

  const LabelText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.primary,
      ),
    );
  }
}
