import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:to_do_app/layout/homelayout.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:to_do_app/shared/cubit/bloc_obsever.dart';

void main() {
  Bloc.observer = MyBlocObserver();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home:HomeLayoutscreen(),
    );
  }
}