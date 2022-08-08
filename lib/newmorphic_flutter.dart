import 'package:flutter/material.dart';

class NeumorphicFlutter extends StatefulWidget {
  const NeumorphicFlutter({Key? key}) : super(key: key);

  @override
  _NeumorphicFlutterState createState() => _NeumorphicFlutterState();
}

class _NeumorphicFlutterState extends State<NeumorphicFlutter> {

  bool _isElevated=true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Center(
        child: GestureDetector(
          onTap: (){
            setState(() {
              _isElevated=!_isElevated;
            });
          },
          child: _isElevated?AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            height: 200,width: 200,
            child: const Center(child: Text("GO",style: TextStyle(
              fontSize: 40,fontWeight: FontWeight.bold
            ),)),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                 BoxShadow(
                   color: Colors.grey[500]!,
                   offset: const Offset(4, 4),
                   blurRadius: 15,
                   spreadRadius: 1
                 ),
                 const BoxShadow(
                    color: Colors.green,
                    offset: Offset(-4,-4),
                    blurRadius: 15,
                    spreadRadius: 1
                )
              ]
            ),
          ):AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            height: 200,width: 200,
            child: const Center(child: Text("Sensor Starts Working",style: TextStyle(
                fontSize: 20,fontWeight: FontWeight.bold
            ),textAlign: TextAlign.center,)),
            decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey[500]!,
                      offset: const Offset(4, 4),
                      blurRadius: 15,
                      spreadRadius: 1
                  ),
                  const BoxShadow(
                      color: Colors.red,
                      offset: Offset(-2,-2),
                      blurRadius: 15,
                      spreadRadius: 2
                  )
                ]
            ),
          ),
        ),
      ),
    );
  }
}
