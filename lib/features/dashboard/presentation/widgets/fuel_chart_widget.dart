import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class FuelChartWidget extends StatelessWidget {
  const FuelChartWidget({super.key});

  static const _data = [28.0, 42.0, 19.0, 55.0, 34.0, 47.0, 22.0];
  static const _labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outline, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Weekly Fuel Spend',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.onSurfaceVariant,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    '€ 247',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                      fontFamily: 'Poppins',
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              const _PeriodChip(label: 'W', selected: true),
              const SizedBox(width: 6),
              const _PeriodChip(label: 'M', selected: false),
              const SizedBox(width: 6),
              const _PeriodChip(label: 'Y', selected: false),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 110,
            child: _BarChart(data: _data, labels: _labels),
          ),
        ],
      ),
    );
  }
}

class _PeriodChip extends StatelessWidget {
  const _PeriodChip({required this.label, required this.selected});
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: selected ? AppColors.primary : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.onSurfaceVariant,
            fontFamily: 'Poppins',
          ),
        ),
      ),
    );
  }
}

class _BarChart extends StatelessWidget {
  const _BarChart({required this.data, required this.labels});
  final List<double> data;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final maxVal = data.reduce((a, b) => a > b ? a : b);
    return CustomPaint(
      painter: _BarChartPainter(data: data, labels: labels, maxVal: maxVal),
      child: const SizedBox.expand(),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  _BarChartPainter({
    required this.data,
    required this.labels,
    required this.maxVal,
  });

  final List<double> data;
  final List<String> labels;
  final double maxVal;

  @override
  void paint(Canvas canvas, Size size) {
    final barWidth = size.width / (data.length * 1.6);
    final spacing = (size.width - barWidth * data.length) / (data.length + 1);
    const labelHeight = 20.0;
    final chartHeight = size.height - labelHeight;

    final bgPaint = Paint()..color = AppColors.surfaceVariant;
    final filledPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.primary,
          AppColors.primaryDark,
        ],
      ).createShader(Rect.fromLTWH(0, 0, barWidth, chartHeight));
    final accentPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [AppColors.accent, AppColors.chartBlue],
      ).createShader(Rect.fromLTWH(0, 0, 40, 110));

    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    final maxIdx = data.indexOf(maxVal);

    for (int i = 0; i < data.length; i++) {
      final x = spacing + i * (barWidth + spacing);
      final ratio = data[i] / maxVal;
      final barH = chartHeight * ratio;

      // Background track
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, 0, barWidth, chartHeight),
          const Radius.circular(6),
        ),
        bgPaint,
      );

      // Filled bar (no unused 'top' variable)
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, chartHeight - barH, barWidth, barH),
          const Radius.circular(6),
        ),
        i == maxIdx ? accentPaint : filledPaint,
      );

      // Label
      textPainter.text = TextSpan(
        text: labels[i],
        style: TextStyle(
          fontSize: 10,
          color: i == maxIdx ? AppColors.accent : AppColors.onSurfaceVariant,
          fontWeight: i == maxIdx ? FontWeight.w600 : FontWeight.w400,
          fontFamily: 'Poppins',
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          x + (barWidth - textPainter.width) / 2,
          chartHeight + 6,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(_BarChartPainter old) => false;
}
