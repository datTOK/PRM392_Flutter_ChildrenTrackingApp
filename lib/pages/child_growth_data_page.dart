import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:children_tracking_mobileapp/models/growth_models.dart'; // Import your growth models
import 'package:children_tracking_mobileapp/services/growth_data_service.dart';
import 'package:provider/provider.dart';
import 'package:children_tracking_mobileapp/provider/auth_provider.dart';

class ChildGrowthDataPage extends StatefulWidget {
  final String childId;
  final String childName; // Pass child name for app bar title

  const ChildGrowthDataPage({
    super.key,
    required this.childId,
    required this.childName,
  });

  @override
  State<ChildGrowthDataPage> createState() => _ChildGrowthDataPageState();
}

class _ChildGrowthDataPageState extends State<ChildGrowthDataPage> {
  List<GrowthData> _growthData = [];
  bool _isLoadingGrowthData = true;
  String? _growthDataErrorMessage;
  String? _authToken;
  late final GrowthDataService _growthDataService = GrowthDataService();

  @override
  void initState() {
    super.initState();
    _loadAuthDataAndFetchGrowthData();
  }

  Future<void> _loadAuthDataAndFetchGrowthData() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    _authToken = auth.token;

    if (_authToken == null) {
      setState(() {
        _isLoadingGrowthData = false;
        _growthDataErrorMessage = 'Authentication data not found. Please log in again.';
      });
      return;
    }
    await _fetchGrowthData();
  }

  Future<void> _fetchGrowthData() async {
    setState(() {
      _isLoadingGrowthData = true;
      _growthDataErrorMessage = null;
    });

    if (_authToken == null) {
      setState(() {
        _growthDataErrorMessage = 'Authentication token is missing. Cannot fetch growth data.';
        _isLoadingGrowthData = false;
      });
      return;
    }

    try {
      final growthData = await _growthDataService.fetchGrowthData(childId: widget.childId, authToken: _authToken!);
      setState(() {
        _growthData = growthData;
        _growthData.sort((a, b) => a.inputDate.compareTo(b.inputDate));
        _isLoadingGrowthData = false;
      });
    } catch (e) {
      setState(() {
        _growthDataErrorMessage = 'An error occurred fetching growth data: $e';
        _isLoadingGrowthData = false;
      });
    }
  }

  // Helper method to build a growth chart
  Widget _buildGrowthChart(String title, List<double?> dataPoints, Function(GrowthData) getYValue) {
    if (dataPoints.isEmpty || dataPoints.every((element) => element == null || element == 0)) {
      return Container(); // Don't show chart if no valid data points
    }

    // Filter out null or zero values for chart plotting
    List<FlSpot> spots = [];
    List<DateTime> dates = [];
    for (int i = 0; i < _growthData.length; i++) {
      final value = getYValue(_growthData[i]) as double?;
      if (value != null && value > 0) { // Only add if value is not null and greater than 0
        spots.add(FlSpot(i.toDouble(), value));
        dates.add(_growthData[i].inputDate);
      }
    }

    if (spots.isEmpty) {
      return Container(); // No valid spots to draw chart
    }

    // Determine min/max Y values for the chart, adding some padding
    double minY = spots.map((e) => e.y).reduce((min, current) => min < current ? min : current);
    double maxY = spots.map((e) => e.y).reduce((max, current) => max > current ? max : current);

    // Add some padding to min/max Y values
    minY = (minY * 0.9).floorToDouble();
    maxY = (maxY * 1.1).ceilToDouble();

    return Card(
      elevation: 4,
      color: Colors.blue.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 200, // Fixed height for charts
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < dates.length) {
                            final date = dates[value.toInt()];
                            return SideTitleWidget(
                              meta: meta,
                              space: 4.0,
                              child: Text(
                                  '${date.day}/${date.month}/${date.year}',
                                  style: const TextStyle(fontSize: 10)
                              ),
                            );
                          }
                          return const Text('');
                        },
                        interval: (dates.length / 5).ceilToDouble().clamp(1.0, dates.length.toDouble()),
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                        reservedSize: 40,
                        interval: (maxY - minY) / 4,
                      ),
                    ),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: const Color(0xff37434d), width: 1),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                  minX: 0,
                  maxX: (spots.length - 1).toDouble(),
                  minY: minY,
                  maxY: maxY,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build a row for each growth attribute result
  Widget _buildGrowthResultRow(String label, GrowthAttributeResult? result) {
    if (result == null || result.percentile == -1) {
      return Container();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '$label:',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
              ),
              const SizedBox(width: 10),
              Chip(
                label: Text('Percentile: ${result.percentile.toStringAsFixed(2)}'),
                backgroundColor: _getColorForLevel(result.level).withOpacity(0.15),
                labelStyle: TextStyle(color: _getColorForLevel(result.level), fontWeight: FontWeight.bold),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
              ),
            ],
          ),
          Text(result.description),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  // Helper to get color based on 'level'
  Color _getColorForLevel(int level) {
    switch (level) {
      case 0: return Colors.red;
      case 1: return Colors.orange;
      case 2: return Colors.green;
      case 3: return Colors.purple;
      case 4: return Colors.yellow[800]!;
      case 5: return Colors.grey;
      default: return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.childName}'s Growth Data"),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: _isLoadingGrowthData
            ? const Center(child: CircularProgressIndicator())
            : _growthDataErrorMessage != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Error loading growth data: $_growthDataErrorMessage',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red, fontSize: 16),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _fetchGrowthData,
                            child: const Text('Retry Growth Data'),
                          ),
                        ],
                      ),
                    ),
                  )
                : _growthData.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'No growth data recorded yet. Please add data from the child details page.',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Growth Chart Section
                          Text(
                            'Growth History Charts',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo,
                                ),
                          ),
                          const SizedBox(height: 18),
                          _buildGrowthChart('Weight (kg)', _growthData.map((e) => e.weight).toList(), (data) => data.weight),
                          const SizedBox(height: 22),
                          _buildGrowthChart('Height (cm)', _growthData.map((e) => e.height).toList(), (data) => data.height),
                          const SizedBox(height: 22),
                          if (_growthData.any((e) => e.bmi != null && e.bmi! > 0))
                            _buildGrowthChart('BMI', _growthData.where((e) => e.bmi != null).map((e) => e.bmi!).toList(), (data) => data.bmi),
                          const SizedBox(height: 22),
                          if (_growthData.any((e) => e.headCircumference != null && e.headCircumference! > 0))
                            _buildGrowthChart('Head Circumference (cm)', _growthData.where((e) => e.headCircumference != null).map((e) => e.headCircumference!).toList(), (data) => data.headCircumference),
                          const SizedBox(height: 22),
                          if (_growthData.any((e) => e.armCircumference != null && e.armCircumference! > 0))
                            _buildGrowthChart('Arm Circumference (cm)', _growthData.where((e) => e.armCircumference != null).map((e) => e.armCircumference!).toList(), (data) => data.armCircumference),

                          const SizedBox(height: 32),

                          // Detailed Growth Results Section
                          Text(
                            'Detailed Growth Results',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo,
                                ),
                          ),
                          const SizedBox(height: 18),
                          ListView.builder(
                            reverse: true,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _growthData.length,
                            itemBuilder: (context, index) {
                              final growthEntry = _growthData[index];
                              final formattedDate = "${growthEntry.inputDate.toLocal().day}/${growthEntry.inputDate.toLocal().month}/${growthEntry.inputDate.toLocal().year}";

                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 10.0),
                                elevation: 3,
                                color: Colors.blue.shade50,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Theme(
                                  data: Theme.of(context).copyWith(
                                    dividerColor: Colors.transparent,
                                    splashColor: Colors.blue.shade100,
                                    highlightColor: Colors.blue.shade50,
                                  ),
                                  child: ExpansionTile(
                                    leading: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade100,
                                        shape: BoxShape.circle,
                                      ),
                                      padding: const EdgeInsets.all(8),
                                      child: Icon(Icons.bar_chart, color: Colors.indigo, size: 24),
                                    ),
                                    title: Text(
                                      'Growth Data on $formattedDate',
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
                                    ),
                                    subtitle: Text(
                                      'Weight: ${growthEntry.weight} kg, Height: ${growthEntry.height} cm',
                                    ),
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            _buildGrowthResultRow('Weight', growthEntry.growthResult?.weight),
                                            _buildGrowthResultRow('Height', growthEntry.growthResult?.height),
                                            _buildGrowthResultRow('BMI', growthEntry.growthResult?.bmi),
                                            _buildGrowthResultRow('Head Circumference', growthEntry.growthResult?.headCircumference),
                                            _buildGrowthResultRow('Arm Circumference', growthEntry.growthResult?.armCircumference),
                                            _buildGrowthResultRow('Weight For Length', growthEntry.growthResult?.weightForLength),
                                            if (growthEntry.growthResult?.description != null && growthEntry.growthResult!.description!.isNotEmpty)
                                              Padding(
                                                padding: const EdgeInsets.only(top: 8.0),
                                                child: Text(
                                                  'Overall Description: ${growthEntry.growthResult!.description!}',
                                                  style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
      ),
    );
  }
}