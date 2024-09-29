import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trade_stream/features/trading_home/presentation/cubit/trading_cubit.dart';
import 'package:trade_stream/features/trading_home/presentation/pages/instrument_details_page.dart';
import 'package:trade_stream/core/consts.dart';
import 'package:trade_stream/features/trading_home/presentation/widgets/instrument_list_item.dart';
import 'package:trade_stream/features/trading_home/presentation/widgets/search_bar.dart';
import 'package:trade_stream/features/trading_home/presentation/widgets/shimmer_list_item.dart';

class TradingHomePage extends StatefulWidget {
  const TradingHomePage({super.key});

  @override
  TradingHomePageState createState() => TradingHomePageState();
}

class TradingHomePageState extends State<TradingHomePage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String selectedMarket = AppConstants.forex; // Default market
  late final TradingCubit _tradingCubit;

  @override
  void initState() {
    super.initState();
    _tradingCubit = BlocProvider.of<TradingCubit>(context);
    _initData();
  }

  @override
  void dispose() {
    super.dispose();
  }

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
            backgroundColor: AppColors.primaryBackground,
            title: const Text('Trade Stream',
                style: TextStyle(
                    color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
            actions: [
              if (state is TradingLoaded) _buildMarketSelector(state),
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(AppMargins.margin16),
              child: Column(
                children: [
                  if (state is! TradingLoading)
                    HomeSearchBar(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value.toLowerCase();
                        });
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
          items: [
            DropdownMenuItem(
              value: AppConstants.forex.toLowerCase(),
              child: const Icon(Icons.currency_exchange,
                  color: AppColors.accentColorLight),
            ),
            DropdownMenuItem(
              value: AppConstants.crypto.toLowerCase(),
              child: const Icon(Icons.currency_bitcoin,
                  color: AppColors.accentColorLight),
            ),
          ],
          onChanged: (String? newValue) {
            if (newValue != null && newValue != selectedMarket) {
              setState(() {
                selectedMarket = newValue.toLowerCase();
              });
              _updateMarket();
            }
          },
          icon: const Icon(Icons.arrow_drop_down,
              color: AppColors.accentColorLight),
          dropdownColor: AppColors.secondaryBackground,
        ),
      ),
    );
  }

  Future<void> _updateMarket() async {
    try {
      print('Updating market: $selectedMarket');
      await _tradingCubit.getSymbols(selectedMarket);
    } catch (error) {
      print('Error updating market: $error');
    }
  }

  Widget _buildContent(TradingState state) {
    print('State: $state');
    if (state is TradingLoading) {
      return _buildShimmerList();
    } else if (state is TradingLoaded) {
      return _buildInstrumentList(state);
    } else if (state is TradingError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child:
                  Text(state.error, style: const TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              onPressed: _updateMarket,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentColor,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    } else {
      return const Center(
        child: Text('No data available',
            style: TextStyle(color: AppColors.textPrimary)),
      );
    }
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 10,
      itemBuilder: (context, index) => const ShimmerListItem(),
    );
  }

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
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  InstrumentDetailPage(instrument: instrument),
            ),
          ),
        );
      },
    );
  }
}
