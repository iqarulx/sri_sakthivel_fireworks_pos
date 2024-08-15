import 'package:flutter/material.dart';

import '../../utlities/varibales.dart';
import 'commenwidget.dart';

class CityAlert extends StatefulWidget {
  final String state;
  const CityAlert({super.key, required this.state});

  @override
  State<CityAlert> createState() => _CityAlertState();
}

class _CityAlertState extends State<CityAlert> {
  TextEditingController searchForm = TextEditingController();
  List<String> city = [];
  List<String> tmpCity = [];

  getState() {
    for (var element in stateMapList[widget.state]!) {
      setState(() {
        city.add(element);
      });
    }
    setState(() {
      tmpCity.addAll(city);
    });
  }

  searchStatefun() {
    setState(() {
      city.clear();
    });
    if (searchForm.text.isNotEmpty) {
      Iterable<String> list = tmpCity
          .where((element) => element.toLowerCase().replaceAll(' ', '').startsWith(searchForm.text.toLowerCase()));
      if (list.isNotEmpty) {
        setState(() {
          city.addAll(list);
        });
      }
    } else {
      setState(() {
        city.addAll(tmpCity);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: InputForm(
        controller: searchForm,
        formName: "Search City Name",
        onChanged: (value) {
          searchStatefun();
        },
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            "Cancel",
            style: TextStyle(
              color: Colors.red,
            ),
          ),
        ),
      ],
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var element in city)
              ListTile(
                onTap: () {
                  Navigator.pop(context, element);
                },
                title: Text(
                  element,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
