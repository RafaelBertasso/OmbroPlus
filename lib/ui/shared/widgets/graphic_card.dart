import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GraphicCard extends StatefulWidget {
  final String title;
  final List<double> values;
  final Widget? content;
  final VoidCallback? onNewMetric; // ✅ Callback para adicionar nova métrica
  final String? unit; // ✅ Unidade configurável (°, %, kg, etc)
  final List<String>? labels; // ✅ Labels configuráveis para o eixo X
  final Color? lineColor; // ✅ Cor da linha configurável
  final String? emptyMessage; // ✅ Mensagem quando não há dados

  const GraphicCard({
    super.key,
    required this.title,
    required this.values,
    this.content,
    this.onNewMetric,
    this.unit,
    this.labels,
    this.lineColor,
    this.emptyMessage,
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
    final effectiveUnit = widget.unit ?? '%';
    final effectiveLineColor = widget.lineColor ?? const Color(0xFF0E382C);

    // ✅ Labels padrão (dias da semana) ou customizadas
    final defaultLabels = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sab', 'Dom'];
    final labels = widget.labels ?? defaultLabels;

    final mainContent =
        widget.content ??
        SizedBox(
          height: 80,
          child: hasMetrics && values.length > 1
              ? LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            int idx = value.toInt();
                            // ✅ Usa labels customizadas ou padrão
                            return idx >= 0 && idx < labels.length
                                ? Text(
                                    labels[idx],
                                    style: GoogleFonts.openSans(
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                    ),
                                  )
                                : const SizedBox();
                          },
                        ),
                      ),
                    ),
                    minX: 0,
                    maxX: (values.length - 1).toDouble(), // ✅ Dinâmico
                    minY: hasMetrics
                        ? values.reduce((a, b) => a < b ? a : b) - 5
                        : 0,
                    maxY: hasMetrics
                        ? values.reduce((a, b) => a > b ? a : b) + 5
                        : 10,
                    lineBarsData: [
                      LineChartBarData(
                        isCurved: true,
                        color: effectiveLineColor,
                        barWidth: 3,
                        spots: List.generate(
                          values.length,
                          (i) => FlSpot(i.toDouble(), values[i]),
                        ),
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: effectiveLineColor.withOpacity(
                            0.1,
                          ), // ✅ Área preenchida
                        ),
                      ),
                    ],
                    lineTouchData: LineTouchData(
                      touchCallback: (event, touchResponse) {
                        if (!event.isInterestedForInteractions ||
                            touchResponse == null ||
                            touchResponse.lineBarSpots == null) {
                          if (_touchedIndex != null) {
                            setState(() => _touchedIndex = null);
                          }
                          return;
                        }
                        final spotIndex =
                            touchResponse.lineBarSpots!.first.spotIndex;
                        if (_touchedIndex != spotIndex) {
                          setState(() => _touchedIndex = spotIndex);
                        }
                      },
                      handleBuiltInTouches: true,
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipColor: (spot) =>
                            effectiveLineColor.withOpacity(0.9),
                        tooltipBorderRadius: BorderRadius.circular(8),
                        getTooltipItems: (spots) {
                          if (_touchedIndex == null) return [];
                          final spot = spots.firstWhere(
                            (s) => s.spotIndex == _touchedIndex,
                            orElse: () => spots[0],
                          );
                          return [
                            LineTooltipItem(
                              '${values[spot.spotIndex].toStringAsFixed(1)}$effectiveUnit', // ✅ Unidade dinâmica
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
              : Center(
                  child: Text(
                    widget.emptyMessage ?? "Dados insuficientes para o gráfico",
                    style: GoogleFonts.openSans(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                ),
        );

    return Card(
      color: const Color(0xFFF4F7F6),
      margin: const EdgeInsets.all(16),
      elevation: 2, // ✅ Sombra suave
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
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                // ✅ Botão para adicionar nova métrica
                if (widget.onNewMetric != null)
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, size: 20),
                    color: effectiveLineColor,
                    onPressed: widget.onNewMetric,
                    tooltip: 'Adicionar métrica',
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // ✅ Valor atual
            if (widget.content == null && hasMetrics)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        lastValue.toStringAsFixed(1),
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.bold,
                          fontSize: 32,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        effectiveUnit,
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Últimos ${values.length} registro${values.length > 1 ? 's' : ''}',
                    style: GoogleFonts.openSans(
                      color: Colors.grey[600],
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),

            mainContent,
          ],
        ),
      ),
    );
  }
}
