import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'store_cubit.dart';
import 'store_repository.dart';
import 'store_screen.dart';

void main() {
  runApp(
    RepositoryProvider<StoreRepository>(
      create: (_) => StoreRepository(),
      child: BlocProvider<StoreCubit>(
        create: (context) =>
            StoreCubit(context.read<StoreRepository>())..loadStore(),
        child: const GemStoreApp(),
      ),
    ),
  );
}

class GemStoreApp extends StatelessWidget {
  const GemStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GemStore',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF34343B),
        ),
        scaffoldBackgroundColor: const Color(0xFFFAF9F7),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFAF9F7),
        ),
      ),
      home: const StoreScreen(),
    );
  }
}
