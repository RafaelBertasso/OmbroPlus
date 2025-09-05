import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GraphicCard extends StatefulWidget {
  const GraphicCard({super.key});

  @override
  State<GraphicCard> createState() => _GraphicCardState();
}

class _GraphicCardState extends State<GraphicCard> {
  List<double> values = [100, 115, 220, 117, 120, 100];
  int? _touchedIndex;

  Future<void> _showAddMetricBottomSheet() async {
    final controller = TextEditingController();
    double? newValue;

    final result = await showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Color(0xFFF4F7F6),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Nova métrica',
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 24),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Adicione o valor',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF0E382C),
                  minimumSize: Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  newValue = double.tryParse(controller.text);
                  Navigator.pop(context, newValue);
                },
                child: Text(
                  'Adicionar',
                  style: GoogleFonts.openSans(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (result != null) {
      setState(() {
        values.add(result);
        if (values.length > 7) values.removeAt(0);
      });
    }
  }

  double _avaragePercentageChange(List<double> values) {
    if (values.length < 2) return double.nan;

    double sum = 0;
    int count = 0;

    for (int i = 1; i < values.length; i++) {
      final prev = values[i - 1];
      final curr = values[i];
      if (prev != 0) {
        sum +=
            ((curr - prev).abs() / prev) * 100 * ((curr - prev) >= 0 ? 1 : -1);
        count++;
      }
    }
    return count > 0 ? sum / count : double.nan;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Color(0xFFF4F7F6),
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  "Flexão do ombro",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: _showAddMetricBottomSheet,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text("Nova Métrica"),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              "${values.last.toStringAsFixed(0)}°",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Text(
                  "Últimos 7 dias",
                  style: TextStyle(color: Colors.grey[700], fontSize: 13),
                ),
                const SizedBox(width: 4),
                Text(
                  _avaragePercentageChange(values).isNaN
                      ? '--'
                      : "${_avaragePercentageChange(values).toStringAsFixed(1)}%",
                  style: TextStyle(color: Colors.green, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 80,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          const dias = [
                            'Seg',
                            'Ter',
                            'Qua',
                            'Qui',
                            'Sex',
                            'Sab',
                            'Dom',
                          ];
                          int idx = value.toInt();
                          return idx >= 0 && idx < dias.length
                              ? Text(
                                  dias[idx],
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                )
                              : const SizedBox();
                        },
                      ),
                    ),
                  ),
                  minX: 0,
                  maxX: 6,
                  lineBarsData: [
                    LineChartBarData(
                      isCurved: true,
                      color: Colors.black87,
                      barWidth: 2,
                      spots: List.generate(
                        values.length,
                        (i) => FlSpot(i.toDouble(), values[i]),
                      ),
                      dotData: FlDotData(show: false),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchCallback:
                        (FlTouchEvent event, LineTouchResponse? touchResponse) {
                          if (!event.isInterestedForInteractions ||
                              touchResponse == null ||
                              touchResponse.lineBarSpots == null) {
                            setState(() {
                              _touchedIndex = null;
                            });
                            return;
                          }
                          final spotIndex =
                              touchResponse.lineBarSpots!.first.spotIndex;
                          setState(() {
                            _touchedIndex = spotIndex;
                          });
                        },
                    handleBuiltInTouches: false,
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (spot) => Colors.black87,
                      tooltipBorderRadius: BorderRadius.circular(8),
                      // fitInsideHorizontally: true,
                      // fitInsideVertically: true,
                      getTooltipItems: (spots) {
                        if (_touchedIndex == null) return <LineTooltipItem>[];
                        final spot = spots.firstWhere(
                          (s) => s.spotIndex == _touchedIndex,
                          orElse: () => spots[0],
                        );
                        return [
                          LineTooltipItem(
                            '${values[spot.spotIndex].toStringAsFixed(0)}°',
                            GoogleFonts.openSans(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ];
                      },
                      tooltipPadding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
