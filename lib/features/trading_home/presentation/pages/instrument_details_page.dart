import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:trade_stream/features/trading_home/domain/entities/trading_instrument.dart';
import 'package:shimmer/shimmer.dart';
import 'package:trade_stream/core/consts.dart';
import 'dart:async';
import 'dart:math';
import 'package:trade_stream/features/trading_home/presentation/widgets/price_widget.dart';

class InstrumentDetailPage extends StatefulWidget {
  final TradingInstrument instrument;

  const InstrumentDetailPage({super.key, required this.instrument});

  @override
  InstrumentDetailPageState createState() => InstrumentDetailPageState();
}

class InstrumentDetailPageState extends State<InstrumentDetailPage>
    with SingleTickerProviderStateMixin {
  final List<FlSpot> _priceData = [];
  late Timer _timer;
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isLoading = true;
  double _currentPrice = 0;
  double _previousPrice = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _currentPrice = widget.instrument.price!;
    _previousPrice = widget.instrument.previousTickPrice!;
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      _startDataStream();
    }
  }

  void _startDataStream() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _previousPrice = _currentPrice;
        _currentPrice = _currentPrice +
            (Random().nextDouble() - 0.5) * 2; // Simulate price change
        _priceData.add(FlSpot(_priceData.length.toDouble(), _currentPrice));
      });
      _animationController.forward(from: 0.0);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(widget.instrument.displaySymbol,
            style: const TextStyle(
                color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppMargins.margin16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.instrument.description,
              style:
                  const TextStyle(color: AppColors.textSecondary, fontSize: 18),
            ),
            const SizedBox(height: AppMargins.margin20),
            _isLoading ? _buildShimmerPriceInfo() : _buildPriceInfo(),
            const SizedBox(height: AppMargins.margin20),
            Expanded(
              child: _isLoading ? _buildShimmerChart() : _buildChart(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerPriceInfo() {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppMargins.margin16),
        ),
      ),
    );
  }

  Widget _buildShimmerChart() {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppMargins.margin16),
        ),
      ),
    );
  }

  Widget _buildChart() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: _scrollController,
      child: Container(
        width: max(MediaQuery.of(context).size.width - 2 * AppMargins.margin20,
            _priceData.length * 10.0),
        decoration: BoxDecoration(
          color: AppColors.secondaryBackground,
          borderRadius: BorderRadius.circular(AppMargins.margin16),
        ),
        padding: const EdgeInsets.all(AppMargins.margin16),
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  getDrawingHorizontalLine: (value) {
                    return const FlLine(
                      color: AppColors.accentColor,
                      strokeWidth: 1,
                    );
                  },
                  getDrawingVerticalLine: (value) {
                    return const FlLine(
                      color: AppColors.accentColor,
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        if (value % 10 == 0) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 12),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) => Text(
                        value.toStringAsFixed(2),
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 12),
                      ),
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: _priceData.length.toDouble() - 1,
                minY: _priceData.isEmpty
                    ? 0
                    : _priceData.map((spot) => spot.y).reduce(min) - 1,
                maxY: _priceData.isEmpty
                    ? 10
                    : _priceData.map((spot) => spot.y).reduce(max) + 1,
                lineBarsData: [
                  LineChartBarData(
                    spots: _priceData,
                    isCurved: true,
                    gradient: const LinearGradient(
                      colors: [
                        AppColors.accentColor,
                        AppColors.accentColorLight
                      ],
                    ),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.accentColor.withOpacity(0.3),
                          AppColors.accentColorLight.withOpacity(0.3),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPriceInfo() {
    return Container(
      padding: const EdgeInsets.all(AppMargins.margin16),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground,
        borderRadius: BorderRadius.circular(AppMargins.margin16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Current Price',
                  style:
                      TextStyle(color: AppColors.textSecondary, fontSize: 14)),
              const SizedBox(height: AppMargins.margin08),
              PriceWidget(price: _currentPrice, previousPrice: _previousPrice)
            ],
          ),
        ],
      ),
    );
  }
}
