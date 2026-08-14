import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/stitch_colors.dart';
import '../../../core/theme/stitch_typography.dart';
import '../../../core/widgets/app_card.dart';

class AnalyticsReportsScreen extends StatelessWidget {
  const AnalyticsReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Analytics & Performance', style: StitchTypography.headlineLg),
          const SizedBox(height: 4),
          Text('Enterprise volume metrics and operator productivity trends.', style: StitchTypography.bodyMd),
          const SizedBox(height: 24),

          // 7-Day Scanning Line Chart
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Scanning Progress', style: StitchTypography.headlineMd),
                        Text('Pages scanned last 7 days', style: StitchTypography.bodySm),
                      ],
                    ),
                    const Icon(Icons.more_vert, color: StitchColors.onSurfaceVariant),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 240,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (value) => const FlLine(color: StitchColors.surfaceContainerHigh, strokeWidth: 1, dashArray: [4, 4]),
                      ),
                      titlesData: FlTitlesData(
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) => Text('${value.toInt()}', style: StitchTypography.labelSm),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                              if (value.toInt() >= 0 && value.toInt() < days.length) {
                                return Text(days[value.toInt()], style: StitchTypography.labelSm);
                              }
                              return const Text('');
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: const [
                            FlSpot(0, 1200),
                            FlSpot(1, 2400),
                            FlSpot(2, 1800),
                            FlSpot(3, 3800),
                            FlSpot(4, 3100),
                            FlSpot(5, 4500),
                            FlSpot(6, 4200),
                          ],
                          isCurved: true,
                          color: StitchColors.primary,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            color: StitchColors.primary.withValues(alpha: 0.12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Area Performance Bar Chart Card
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Area Performance', style: StitchTypography.headlineMd),
                Text('Volume by location (Pages)', style: StitchTypography.bodySm),
                const SizedBox(height: 24),
                SizedBox(
                  height: 220,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: 20000,
                      barTouchData: BarTouchData(enabled: true),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 45,
                            getTitlesWidget: (value, meta) => Text('${(value / 1000).toInt()}k', style: StitchTypography.labelSm),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              const labels = ['Umred', 'Wani', 'Majri'];
                              if (value.toInt() >= 0 && value.toInt() < labels.length) {
                                return Text(labels[value.toInt()], style: StitchTypography.labelMd);
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      barGroups: [
                        BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 18450, color: StitchColors.primary, width: 28, borderRadius: BorderRadius.circular(4))]),
                        BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 15220, color: StitchColors.primaryContainer, width: 28, borderRadius: BorderRadius.circular(4))]),
                        BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 11850, color: StitchColors.secondary, width: 28, borderRadius: BorderRadius.circular(4))]),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
