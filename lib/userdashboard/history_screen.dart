import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  final List<double> _sampleData = [2, 3, 1.5, 2.2, 3.5, 2.8, 3.1];

  final List<Map<String, dynamic>> _historyData = [
    {'date': '2025-04-20', 'status': 'Alert Issued'},
    {'date': '2025-04-21', 'status': 'Normal'},
    {'date': '2025-04-22', 'status': 'Alert Issued'},
    {'date': '2025-04-23', 'status': 'Normal'},
    {'date': '2025-04-24', 'status': 'Normal'},
  ];

   HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Determine the current theme
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'History & Statistics',
          style: TextStyle(color: theme.textTheme.bodyLarge?.color), // Adjust text color based on theme
        ),
        backgroundColor: theme.appBarTheme.backgroundColor, // Set AppBar color based on theme
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats title
              Text(
                'Driving Statistics',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.textTheme.bodyLarge?.color, // Adjust text color based on theme
                ),
              ),
              const SizedBox(height: 16),

              // Graph section
              SizedBox(
                height: 180, // Reduced graph size for a better fit
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: true),
                    titlesData: FlTitlesData(show: true),
                    borderData: FlBorderData(show: true),
                    lineBarsData: [
                      LineChartBarData(
                        spots: List.generate(
                          _sampleData.length,
                          (index) => FlSpot(index.toDouble(), _sampleData[index]),
                        ),
                        isCurved: true,
                        barWidth: 3,
                        color: theme.brightness == Brightness.dark ? Colors.greenAccent : Colors.blue, // Change color based on theme
                        belowBarData: BarAreaData(show: false),
                        dotData: FlDotData(show: true),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // History log title
              Text(
                'History Log',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.textTheme.bodyLarge?.color, // Adjust text color based on theme
                ),
              ),
              const SizedBox(height: 10),

              // History list
              Expanded(
                child: ListView.builder(
                  itemCount: _historyData.length,
                  itemBuilder: (context, index) {
                    return Card(
                      color: theme.cardColor, // Change card color based on theme
                      child: ListTile(
                        leading: Icon(Icons.history, color: theme.iconTheme.color), // Icon color based on theme
                        title: Text(
                          _historyData[index]['date'],
                          style: TextStyle(color: theme.textTheme.bodyLarge?.color), // Title text color based on theme
                        ),
                        subtitle: Text(
                          _historyData[index]['status'],
                          style: TextStyle(color: theme.textTheme.bodyMedium?.color), // Subtitle color based on theme
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
