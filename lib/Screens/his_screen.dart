import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vocab_5k/Providers/db_provider.dart';

import '../Helper/app_colors.dart';

class HisScreen extends StatefulWidget {
  const HisScreen({super.key});

  @override
  State<HisScreen> createState() => _HisScreenState();
}

class _HisScreenState extends State<HisScreen> {
  List<Map<String, dynamic>> history = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final dbProvider = Provider.of<DbProvider>(context, listen: false);
      final results = await dbProvider.getResultsLast30Days();
      setState(() {
        history = results;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        toolbarHeight: 0,
      ),
      body: Container(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
        color: AppColors.facebookBackground,
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.history, size: 26, color: Colors.black87),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "History",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      "Your performance over the last 30 days",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child:
                  history.isEmpty
                      ? const Center(
                        child: Text(
                          'No results yet',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                      : ListView.builder(
                        // padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: history.length,
                        itemBuilder: (context, index) {
                          final item = history[index];
                          final isGood = item["right"] > item["wrong"];
                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 12,
                              ),
                              leading: CircleAvatar(
                                radius: 24,
                                backgroundColor:
                                    isGood ? Colors.green : Colors.red,
                                child: const Icon(
                                  Icons.star,
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(
                                DateFormat(
                                  'dd MMM yyyy',
                                ).format(DateTime.parse(item['id'])),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.check,
                                    color: Colors.green,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${item["right"]}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  const Icon(
                                    Icons.close,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${item["wrong"]}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
