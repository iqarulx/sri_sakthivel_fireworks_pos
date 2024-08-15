import 'package:flutter/material.dart';

import '../../utlities/varibales.dart';
import 'commenwidget.dart';

class StateAlert extends StatefulWidget {
  const StateAlert({super.key});

  @override
  State<StateAlert> createState() => _StateAlertState();
}

class _StateAlertState extends State<StateAlert> {
  TextEditingController searchForm = TextEditingController();
  List<String> state = [];
  List<String> tmpstate = [];

  getState() {
    for (var element in stateMapList.keys) {
      setState(() {
        state.add(element);
      });
    }
    setState(() {
      tmpstate.addAll(state);
    });
  }

  searchStatefun() {
    setState(() {
      state.clear();
    });
    if (searchForm.text.isNotEmpty) {
      Iterable<String> list = tmpstate
          .where((element) => element.toLowerCase().replaceAll(' ', '').startsWith(searchForm.text.toLowerCase()));
      if (list.isNotEmpty) {
        setState(() {
          state.addAll(list);
        });
      }
    } else {
      setState(() {
        state.addAll(tmpstate);
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
        formName: "Search State Name",
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
      // content: const Column(
      //   children: [
      //     Expanded(
      //       child: SizedBox(),
      //     ),
      //   ],
      // ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var element in state)
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
