import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/routes/app_routes.dart';
import '../../core/widgets/app_drawer.dart';
import '../../providers/transport_provider.dart';
import '../../providers/language_provider.dart';

class TransportScreen extends StatelessWidget {
  const TransportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final transport = context.watch<TransportProvider>();
    final isHindi = context.watch<LanguageProvider>().isHindi;

    return Scaffold(
      backgroundColor: const Color(0xFFF7FBF7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B5E20),
        title: Text(isHindi ? "कृषि परिवहन एवं उपकरण किराया" : "Agri Transport & Rental", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      drawer: const AppDrawer(currentRoute: AppRoutes.transport),
      body: ListView.builder(
        padding: const EdgeInsets.all(14),
        itemCount: transport.vehicles.length,
        itemBuilder: (context, index) {
          final v = transport.vehicles[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(Icons.agriculture_rounded, color: Color(0xFF2E7D32), size: 24),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              v.modelName,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(12)),
                      child: Text(v.rate, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text('Owner: ${v.ownerName} • ${v.vehicleType}', style: const TextStyle(fontSize: 12, color: Colors.black87)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: Colors.black54),
                    const SizedBox(width: 4),
                    Text(v.location, style: const TextStyle(fontSize: 11, color: Colors.black54)),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Calling Owner ${v.ownerName} (${v.phone})...'), backgroundColor: const Color(0xFF2E7D32)),
                      );
                    },
                    icon: const Icon(Icons.phone, size: 16, color: Colors.white),
                    label: Text(isHindi ? "मालिक से संपर्क करें (${v.phone})" : "Call Owner (${v.phone})", style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
