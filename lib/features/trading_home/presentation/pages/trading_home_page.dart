import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:trade_stream/core/utils/extensions.dart';
import 'package:trade_stream/features/trading_home/presentation/cubit/trading_cubit.dart';
import 'package:trade_stream/features/trading_home/presentation/pages/instrument_details_page.dart';
import 'package:trade_stream/core/consts.dart';
import 'package:trade_stream/features/trading_home/presentation/widgets/instrument_list_item.dart';
import 'package:trade_stream/features/trading_home/presentation/widgets/search_bar.dart';
import 'package:trade_stream/features/trading_home/presentation/widgets/shimmer_list_item.dart';

/// The main trading home page of the application.
///
/// This page displays a list of trading instruments, allows searching and filtering,
/// and provides navigation to detailed instrument views.
class TradingHomePage extends StatefulWidget {
  const TradingHomePage({super.key});

  @override
  TradingHomePageState createState() => TradingHomePageState();
}

/// The state for the [TradingHomePage] widget.
///
/// This class manages the state of the trading home page, including
/// search functionality, market selection, and data loading.
class TradingHomePageState extends State<TradingHomePage> {
  /// Controller for the search input field.
  final TextEditingController _searchController = TextEditingController();

  /// The current search query entered by the user.
  String _searchQuery = '';

  /// The currently selected market (e.g., forex, crypto, stocks).
  String selectedMarket = AppConstants.forex; // Default market

  /// The [TradingCubit] used to manage the trading state and data.
  late final TradingCubit _tradingCubit;

  @override
  void initState() {
    super.initState();
    _tradingCubit = GetIt.I<TradingCubit>();
    _initData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// Initializes the data by fetching symbols and trading instruments for the selected market.
  Future<void> _initData() async {
    await _tradingCubit.getSymbols(selectedMarket);
    await _tradingCubit.getTradingInstruments(selectedMarket);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TradingCubit, TradingState>(
      bloc: _tradingCubit,
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.primaryBackground,
          appBar: AppBar(
            leading:
                const Icon(Icons.show_chart, color: AppColors.accentColorLight),
            centerTitle: true,
            backgroundColor: AppColors.primaryBackground,
            title: const Text('Trade Stream',
                style: TextStyle(
                  color: AppColors.accentColorLight,
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                  letterSpacing: 0.5,
                )),
            actions: [
              if (state is TradingLoaded) _buildMarketSelector(state),
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(AppMargins.margin08),
              child: Column(
                children: [
                  if (state is! TradingLoading)
                    HomeSearchBar(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() => _searchQuery = value.toLowerCase());
                      },
                    ),
                  const SizedBox(height: AppMargins.margin08),
                  _buildContent(state),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Builds the market selector dropdown widget.
  ///
  /// This widget allows users to switch between different markets (forex, crypto, stocks).
  Widget _buildMarketSelector(TradingLoaded state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppMargins.margin08),
      padding: const EdgeInsets.symmetric(horizontal: AppMargins.margin12),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground,
        borderRadius: BorderRadius.circular(AppMargins.margin20),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedMarket.toLowerCase(),
          menuWidth: AppMargins.margin120,
          alignment: Alignment.center,
          items: [
            _buildMarketSelectorItem(AppConstants.forex),
            _buildMarketSelectorItem(AppConstants.crypto),
            _buildMarketSelectorItem(AppConstants.stocks),
          ],
          onChanged: (String? newValue) {
            if (newValue != null && newValue != selectedMarket) {
              setState(() => selectedMarket = newValue.toLowerCase());
              _updateMarket();
            }
          },
          icon: const Icon(Icons.arrow_drop_down,
              color: AppColors.accentColorLight),
          dropdownColor: AppColors.secondaryBackground,
          selectedItemBuilder: (BuildContext context) {
            return [
              AppConstants.forex,
              AppConstants.crypto,
              AppConstants.stocks
            ].map<Widget>((String item) {
              return Container(
                alignment: Alignment.center,
                child: _getIconForMarket(item),
              );
            }).toList();
          },
        ),
      ),
    );
  }

  /// Builds a dropdown menu item for a specific market.
  DropdownMenuItem<String> _buildMarketSelectorItem(String market) {
    return DropdownMenuItem(
        value: market.toLowerCase(),
        child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _getIconForMarket(market),
              const SizedBox(width: AppMargins.margin08),
              Text(market.capitalize(),
                  style: const TextStyle(color: AppColors.accentColorLight)),
            ]));
  }

  /// Returns the appropriate icon for a given market.
  Widget _getIconForMarket(String market) {
    switch (market.toLowerCase()) {
      case 'forex':
        return const Icon(Icons.currency_exchange,
            color: AppColors.accentColorLight);
      case 'crypto':
        return const Icon(Icons.currency_bitcoin,
            color: AppColors.accentColorLight);
      case 'stocks':
        return const Icon(Icons.candlestick_chart,
            color: AppColors.accentColorLight);
      default:
        return const Icon(Icons.error, color: AppColors.accentColorLight);
    }
  }

  /// Updates the selected market and fetches new data.
  Future<void> _updateMarket() async {
    try {
      dev.log('Updating market: $selectedMarket');
      await _tradingCubit.getSymbols(selectedMarket);
    } catch (error) {
      dev.log('Error updating market: $error');
    }
  }

  /// Builds the main content of the page based on the current trading state.
  Widget _buildContent(TradingState state) {
    dev.log('State: $state');
    if (state is TradingLoading) {
      return _buildShimmerList();
    } else if (state is TradingLoaded) {
      return _buildInstrumentList(state);
    } else if (state is TradingError) {
      // Show the AlertDialog immediately when a TradingError occurs
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            backgroundColor: AppColors.secondaryBackground,
            title: const Text(
              'Error',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            content: Text(
              state.error,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _updateMarket();
                },
                child: const Text(
                  'Retry',
                  style: TextStyle(color: AppColors.accentColorLight),
                ),
              ),
            ],
          ),
        );
      });
      return const SizedBox.shrink();
    } else {
      return const Center(
        child: Text('No data available',
            style: TextStyle(color: AppColors.textPrimary)),
      );
    }
  }

  /// Builds a shimmer effect list to display while loading data.
  Widget _buildShimmerList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 10,
      itemBuilder: (context, index) => const ShimmerListItem(),
    );
  }

  /// Builds the list of trading instruments.
  ///
  /// This list is filtered based on the current search query.
  Widget _buildInstrumentList(TradingLoaded state) {
    final filteredInstruments = state.instruments.where((instrument) {
      return instrument.displaySymbol.toLowerCase().contains(_searchQuery) ||
          instrument.description.toLowerCase().contains(_searchQuery);
    }).toList();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredInstruments.length,
      itemBuilder: (context, index) {
        final instrument = filteredInstruments[index];
        return InstrumentListItem(
          instrument: instrument,
          onTap: () {
            if (instrument.price != null && instrument.price! > 0) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => BlocProvider.value(
                    value: _tradingCubit,
                    child: InstrumentDetailPage(instrument: instrument),
                  ),
                ),
              );
            }
          },
        );
      },
    );
  }
}
