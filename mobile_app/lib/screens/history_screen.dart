import 'dart:io';
import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/scan_result.dart';
import 'result_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final DatabaseService _dbService = DatabaseService();
  late Future<List<ScanResult>> _scans;

  @override
  void initState() {
    super.initState();
    _loadScans();
  }

  void _loadScans() {
    setState(() {
      _scans = _dbService.getScans();
    });
  }

  Future<void> _deleteScan(int id) async {
    final db = await _dbService.database;
    await db.delete(DatabaseService.tableName, where: "id = ?", whereArgs: [id]);
    _loadScans();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("History")),
      body: FutureBuilder<List<ScanResult>>(
        future: _scans,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final scans = snapshot.data!;
          if (scans.isEmpty) {
            return const Center(child: Text("No history yet."));
          }

          return ListView.builder(
            itemCount: scans.length,
            itemBuilder: (context, index) {
              final scan = scans[index];
              return Card(
                child: ListTile(
                  leading: Image.file(
                    File(scan.imagePath),
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                  title: Text(scan.diseaseName),
                  subtitle: Text(
                    "Confidence: ${scan.confidence.toStringAsFixed(2)}%",
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteScan(scan.id!),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ResultScreen(
                          imagePath: scan.imagePath,
                          result: {
                            "label": scan.diseaseName,
                            "confidence": scan.confidence,
                          },
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
