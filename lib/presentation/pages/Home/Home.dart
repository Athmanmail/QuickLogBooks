import 'package:flutter/material.dart';

import '../../../core/configs/theme/appcolor.dart';

class HomeContent extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return Container(
      child: Scaffold(
        body: Center(
          child: Text(
            'Home Screen',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}