import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:trade_stream/features/trading_home/data/models/trading_instrument_model.dart';
import 'package:trade_stream/features/trading_home/domain/entities/trading_instrument.dart';
import 'package:shimmer/shimmer.dart';
import 'package:trade_stream/core/consts.dart';
import 'dart:async';
import 'dart:math';
import 'package:trade_stream/features/trading_home/presentation/widgets/price_widget.dart';
import 'package:trade_stream/features/trading_home/presentation/cubit/trading_cubit.dart';

/// Enum to represent chart types
enum ChartType { line, bar }

/// A page that displays detailed information about a specific trading instrument.
///
/// This page shows the instrument's description, current price, and a chart of price history.
/// It uses BLoC pattern for state management and real-time updates.
class InstrumentDetailPage extends StatefulWidget {
  /// The trading instrument to display details for.
  final TradingInstrument instrument;

  /// Creates an [InstrumentDetailPage].
  ///
  /// The [instrument] parameter is required.
  const InstrumentDetailPage({super.key, required this.instrument});

  @override
  InstrumentDetailPageState createState() => InstrumentDetailPageState();
}

/// State for the [InstrumentDetailPage].
class InstrumentDetailPageState extends State<InstrumentDetailPage>
    with SingleTickerProviderStateMixin {
  /// List of price data points for the chart.
  final List<FlSpot> _priceData = [];

  /// Controller for the horizontal scrolling of the chart.
  final ScrollController _scrollController = ScrollController();

  /// Controller for the price update animation.
  late AnimationController _animationController;

  /// Animation for smooth price updates.
  late Animation<double> _animation;

  /// Flag to indicate if data is still loading.
  bool _isLoading = true;

  /// The current trading instrument being displayed.
  late TradingInstrument _currentInstrument;

  /// The number of visible points on the chart.
  final int visiblePoints = 50;

  /// Current chart type
  ChartType _currentChartType = ChartType.line;

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
    _currentInstrument = widget.instrument;
    _loadData();
  }

  /// Simulates data loading with a delay.
  Future<void> _loadData() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TradingCubit, TradingState>(
      bloc: GetIt.I<TradingCubit>(),
      builder: (context, state) {
        if (state is TradingLoaded) {
          _updateInstrumentData(state);
        }
        return Scaffold(
          backgroundColor: AppColors.primaryBackground,
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(_currentInstrument.displaySymbol,
                style: const TextStyle(
                    color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
            actions: [
              _buildChartTypeSwitcher(),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(AppMargins.margin16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentInstrument.description,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 18),
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
      },
    );
  }

  /// Updates the current instrument data when new state is received.
  void _updateInstrumentData(TradingLoaded state) {
    final updatedInstrument = state.instruments.firstWhere(
      (instrument) => instrument.symbol == _currentInstrument.symbol,
      orElse: () => _currentInstrument as TradingInstrumentModel,
    );

    if (updatedInstrument != _currentInstrument) {
      _currentInstrument = updatedInstrument;
      if (_currentInstrument.price != null && _currentInstrument.price! > 0) {
        _priceData.add(
            FlSpot(_priceData.length.toDouble(), _currentInstrument.price!));
      }

      _animationController.forward(from: 0.0);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    }
  }

  /// Builds a shimmer effect for the price info while loading.
  Widget _buildShimmerPriceInfo() {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: Container(
        height: AppMargins.margin80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppMargins.margin16),
        ),
      ),
    );
  }

  /// Builds a shimmer effect for the chart while loading.
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

  /// Builds the chart type switcher widget
  Widget _buildChartTypeSwitcher() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppMargins.margin08),
      padding: const EdgeInsets.symmetric(horizontal: AppMargins.margin12),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground,
        borderRadius: BorderRadius.circular(AppMargins.margin20),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<ChartType>(
          value: _currentChartType,
          menuWidth: AppMargins.margin120,
          alignment: Alignment.center,
          items: [
            _buildChartTypeSelectorItem(ChartType.line),
            _buildChartTypeSelectorItem(ChartType.bar),
          ],
          onChanged: (ChartType? newValue) {
            if (newValue != null && newValue != _currentChartType) {
              setState(() => _currentChartType = newValue);
            }
          },
          icon: const Icon(Icons.arrow_drop_down,
              color: AppColors.accentColorLight),
          dropdownColor: AppColors.secondaryBackground,
          selectedItemBuilder: (BuildContext context) {
            return ChartType.values.map<Widget>((ChartType type) {
              return Container(
                alignment: Alignment.center,
                child: _getIconForChartType(type),
              );
            }).toList();
          },
        ),
      ),
    );
  }

  /// Builds a dropdown menu item for a specific chart type.
  DropdownMenuItem<ChartType> _buildChartTypeSelectorItem(ChartType type) {
    return DropdownMenuItem(
      value: type,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _getIconForChartType(type),
          const SizedBox(width: AppMargins.margin08),
          Text(
            type == ChartType.line ? 'Line' : 'Bar',
            style: const TextStyle(color: AppColors.accentColorLight),
          ),
        ],
      ),
    );
  }

  /// Returns the appropriate icon for a given chart type.
  Widget _getIconForChartType(ChartType type) {
    switch (type) {
      case ChartType.line:
        return const Icon(Icons.show_chart, color: AppColors.accentColorLight);
      case ChartType.bar:
        return const Icon(Icons.bar_chart, color: AppColors.accentColorLight);
    }
  }

  /// Builds the price chart widget
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
            if (_priceData.isEmpty) {
              return const SizedBox();
            }

            double currentPrice = _currentInstrument.price ?? 0;

            // Calculate the range based on both historical data and current price
            double minY =
                min(_priceData.map((spot) => spot.y).reduce(min), currentPrice);
            double maxY =
                max(_priceData.map((spot) => spot.y).reduce(max), currentPrice);

            // Calculate the range and add padding
            double yRange = (maxY - minY);
            double padding = yRange * 0.1;
            double adjustedMinY = max(0, minY - padding);
            double adjustedMaxY = maxY + padding;

            // Ensure the current price is within the range
            adjustedMinY = min(adjustedMinY, currentPrice);
            adjustedMaxY = max(adjustedMaxY, currentPrice);

            double minX = max(0, _priceData.length.toDouble() - visiblePoints);
            double maxX = _priceData.length.toDouble();

            return _currentChartType == ChartType.line
                ? _buildLineChart(
                    minX, maxX, adjustedMinY, adjustedMaxY, currentPrice)
                : _buildBarChart(
                    minX, maxX, adjustedMinY, adjustedMaxY, currentPrice);
          },
        ),
      ),
    );
  }

  /// Builds the line chart
  Widget _buildLineChart(
      double minX, double maxX, double minY, double maxY, double currentPrice) {
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
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(
              showTitles: false,
              reservedSize: 5,
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: minX,
        maxX: maxX,
        minY: minY,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: _priceData.asMap().entries.map((entry) {
              return FlSpot(entry.key.toDouble(), entry.value.y);
            }).toList(),
            isCurved: true,
            gradient: const LinearGradient(
              colors: [AppColors.accentColor, AppColors.accentColorLight],
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
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            HorizontalLine(
              y: currentPrice,
              color: AppColors.accentColorLight,
              strokeWidth: 1.5,
              dashArray: [5, 5],
              label: HorizontalLineLabel(
                show: true,
                alignment: Alignment.topRight,
                padding: const EdgeInsets.only(
                    right: AppMargins.margin20,
                    top: AppMargins.margin04,
                    bottom: AppMargins.margin04),
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  backgroundColor:
                      AppColors.secondaryBackground.withOpacity(0.7),
                ),
                labelResolver: (line) =>
                    '  ${currentPrice.toStringAsFixed(5)}   ',
              ),
            ),
          ],
        ),
        clipData: const FlClipData.all(),
      ),
    );
  }

  /// Builds the bar chart
  Widget _buildBarChart(
      double minX, double maxX, double minY, double maxY, double currentPrice) {
    return BarChart(
      BarChartData(
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
          leftTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        minY: minY,
        maxY: maxY,
        barGroups: _priceData.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value.y,
                gradient: const LinearGradient(
                  colors: [AppColors.accentColor, AppColors.accentColorLight],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                width: 8,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
          );
        }).toList(),
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            HorizontalLine(
              y: currentPrice,
              color: AppColors.accentColorLight,
              strokeWidth: 1.5,
              dashArray: [5, 5],
              label: HorizontalLineLabel(
                show: true,
                alignment: Alignment.topRight,
                padding: const EdgeInsets.only(
                    right: AppMargins.margin20, top: 2, bottom: 2),
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  backgroundColor:
                      AppColors.secondaryBackground.withOpacity(0.7),
                ),
                labelResolver: (line) =>
                    '  ${currentPrice.toStringAsFixed(5)}  ',
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the price information widget.
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
              PriceWidget(
                price: _currentInstrument.price ?? 0,
                previousPrice: _currentInstrument.previousTickPrice ??
                    _currentInstrument.price ??
                    0,
              )
            ],
          ),
        ],
      ),
    );
  }
}
