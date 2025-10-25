import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GraphicCard extends StatefulWidget {
  final String title;
  final List<double> values;
  final Widget? content;
  final VoidCallback? onNewMetric;

  const GraphicCard({
    super.key,
    required this.title,
    required this.values,
    this.content,
    this.onNewMetric,
  });

  @override
  State<GraphicCard> createState() => _GraphicCardState();
}

class _GraphicCardState extends State<GraphicCard> {
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    final values = widget.values;
    final hasMetrics = values.isNotEmpty;
    final lastValue = hasMetrics ? values.last : 0.0;

    final mainContent =
        widget.content ??
        SizedBox(
          height: 80,
          child: hasMetrics && values.length > 1
              ? LineChart(
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
                    minY: hasMetrics
                        ? values.reduce((a, b) => a < b ? a : b) - 5
                        : 0,
                    maxY: hasMetrics
                        ? values.reduce((a, b) => a > b ? a : b) + 5
                        : 10,
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
                          (
                            FlTouchEvent event,
                            LineTouchResponse? touchResponse,
                          ) {
                            if (!event.isInterestedForInteractions ||
                                touchResponse == null ||
                                touchResponse.lineBarSpots == null) {
                              if (_touchedIndex != null)
                                setState(() => _touchedIndex = null);
                              return;
                            }
                            final spotIndex =
                                touchResponse.lineBarSpots!.first.spotIndex;
                            if (_touchedIndex != spotIndex)
                              setState(() => _touchedIndex = spotIndex);
                          },
                      handleBuiltInTouches: true,
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipColor: (spot) =>
                            const Color(0xFF0E382C).withOpacity(0.9),
                        tooltipBorderRadius: BorderRadius.circular(8),
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
                      ),
                    ),
                  ),
                )
              : Center(child: Text("Dados insuficientes para o gráfico.")),
        );

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
                Text(
                  widget.title,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 12),
            if (widget.content == null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        "${lastValue.toStringAsFixed(0)}%",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 32,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Últimos ${values.length} registros',
                    style: TextStyle(color: Colors.grey[700], fontSize: 11),
                  ),
                ],
              ),
            const SizedBox(height: 12),
            mainContent,
          ],
        ),
      ),
    );
  }
}
