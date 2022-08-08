import 'dart:developer';

import 'package:flutter/material.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({Key? key}) : super(key: key);

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  var items = [];

  @override
  void initState() {
    // TODO: implement initState
    items.insert(items.length, Icon(Icons.add));
  }

  @override
  Widget build(BuildContext context) {
    log(MediaQuery.of(context).size.width.toString());
    return Scaffold(
      appBar: AppBar(),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: GridView.builder(
          shrinkWrap: true,
          // scrollDirection: Axis.horizontal,
          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10.0, mainAxisSpacing: 10.0),
          itemCount: items.length,
          itemBuilder: (_, index) {
            log("Value of Length ${items.length} and Value of index ${index}");

            return index == items.length - 1
                ? GestureDetector(
                    onTap: () {
                      log("value ${items.length - 1}");
                      items.insert(items.length - 1, Icon(Icons.error));
                      setState(() {});
                    },
                    child: Container(
                      height: 20,
                      color: Colors.grey,
                      child: Center(child: items[index]),
                    ),
                  )
                : GestureDetector(
                    onTap: () {
                      items.removeAt(index);
                      setState(() {

                      });
                    },
                    child: Container(
                      height: 20,
                      color: Colors.grey,
                      child: Center(child: items[index]),
                    ),
                  );
          },
        ),
      ),
    );
  }
}
