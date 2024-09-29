// import 'package:flutter/material.dart';
// import 'package:trade_stream/features/trading_home/domain/entities/trading_instrument.dart';
//
// class TradingList extends StatelessWidget {
//   final List<TradingInstrument> instruments;
//
//   const TradingList({Key? key, required this.instruments}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return ListView.builder(
//       itemCount: instruments.length,
//       itemBuilder: (context, index) {
//         final instrument = instruments[index];
//         return ListTile(
//           title: Text(instrument.volume.toString()),
//           subtitle: Text(instrument.symbol),
//           trailing: Text('\$${instrument.price.toStringAsFixed(2)}'),
//         );
//       },
//     );
//   }
// }
