import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:w_calendar_check_list/Model/Model.dart';

class MemoPage extends StatefulWidget {
  const MemoPage({Key? key, required this.DateNow}) : super(key: key);
  final DateTime DateNow;

  @override
  State<MemoPage> createState() => _MemoPageState();
}

class _MemoPageState extends State<MemoPage> {
  final ctl1 = TextEditingController();
  final ctl2 = TextEditingController();
  final DateFormat formatter = DateFormat('yyyy-MM-dd');

  void _saveData(DateTime day, String title) {
    final String timenow = formatter.format(day);
    String path = "Memo/$timenow";

    FirebaseFirestore.instance.doc(path).get().then((docsnapshot) {
      if (docsnapshot.exists) {
        //기존 데이터가 있을 경우
        final List<dynamic> titleList = docsnapshot.data()!['Title'];
        final List<dynamic> timeList = docsnapshot.data()!['Time'];

        titleList.add(title);
        timeList.add(timenow);

        FirebaseFirestore.instance
            .doc(path)
            .update({'Title': titleList, 'Time': timeList});
      } else {
        FirebaseFirestore.instance.doc(path).set({
          'Title': [title],
          'Time': [timenow]
        });
      }
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        //appbar 투명색
        elevation: 0,
        //그림자 농도 값 0으로 해서 제거
        leading: GestureDetector(
          onTap: () {
            setState(() {
              Get.back();
            });
          },
          child: Icon(
            Icons.arrow_back_ios_new_outlined,
            color: Colors.black,
          ),
        ),
        title: Text(widget.DateNow.toString(),
            style: TextStyle(
                color: Colors.black,
                fontSize: 25,
                fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
              onPressed: () {
                _saveData(widget.DateNow, ctl1.text);
                Get.back();
              },
              icon: Icon(
                Icons.check,
                size: 40,
                color: Colors.black,
              ))
        ],
      ),
      body: Column(
        children: [
          TextFormField(
            controller: ctl1,
          )
        ],
      ),
    );
  }
}
