import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/models/market_data.dart';

class GlobalMarketView extends StatefulWidget {
  const GlobalMarketView({Key? key}) : super(key: key);

  @override
  State<GlobalMarketView> createState() => _GlobalMarketViewState();
}

class _GlobalMarketViewState extends State<GlobalMarketView> {
  List<MarketCategory> categories = [];
  bool isLoading = true;
  String asOfDate = "";

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/market_data.json');
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      final List<dynamic> catList = jsonMap['categories'];
      setState(() {
        asOfDate = jsonMap['asOf'] ?? "";
        categories = catList.map((c) => MarketCategory.fromJson(c)).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)));
    }
    if (categories.isEmpty) {
      return const Center(child: Text("No data available"));
    }

    return Column(
      children: [
        if (asOfDate.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              "Prices as of: $asOfDate",
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ExpansionTile(
                  title: Text(
                    category.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1B5E20)),
                  ),
                  initiallyExpanded: index == 0,
                  children: category.commodities.map((commodity) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            commodity.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              headingRowHeight: 35,
                              dataRowMinHeight: 35,
                              dataRowMaxHeight: 40,
                              columnSpacing: 20,
                              columns: const [
                                DataColumn(label: Text('Contract', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Last', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Change', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Trade Time', style: TextStyle(fontWeight: FontWeight.bold))),
                              ],
                              rows: commodity.contracts.map((contract) {
                                bool isUp = contract.change.startsWith('+');
                                bool isDown = contract.change.startsWith('-');
                                Color changeColor = isUp ? Colors.green : (isDown ? Colors.red : Colors.black87);
                                return DataRow(cells: [
                                  DataCell(Text(contract.contract)),
                                  DataCell(Text(contract.last, style: const TextStyle(fontWeight: FontWeight.w600))),
                                  DataCell(Text(
                                    contract.change,
                                    style: TextStyle(color: changeColor, fontWeight: FontWeight.bold),
                                  )),
                                  DataCell(Text(contract.tradeTime, style: const TextStyle(color: Colors.grey))),
                                ]);
                              }).toList(),
                            ),
                          ),
                          const Divider(),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
