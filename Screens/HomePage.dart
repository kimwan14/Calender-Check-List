import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:w_calendar_check_list/Screens/MemoPage.dart';
import 'package:w_calendar_check_list/Screens/UpdatePage.dart';
import '../Model/Model.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime focuseday = DateTime.now();
  DateTime selectday =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  bool _isMonthView = true;
  late final void Function(CalendarFormat format)? onFormatChanged;
  CalendarFormat format = CalendarFormat.month;
  final DateFormat formatter = DateFormat('yyyy-MM-dd');

  final CollectionReference _products = FirebaseFirestore.instance.collection(
      'Memo'); // 컬랙션의 주소를 읽어와 특정문서를 CRUD 하는데 이용, DocumentReference으로 할 경우 문서 ID값을 주소로 가져와 문서 안의 내용을 CRUD함

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose(){
    super.dispose();
  }

  Future<List<Model>> getData(DateTime day) async {
    final String now = formatter.format(day);
    String path = "Memo/$now";

    DocumentSnapshot<Map<String, dynamic>> docSnapshot =
        await FirebaseFirestore.instance.doc(path).get();
    if (docSnapshot.exists) {
      final List<dynamic> titleList = docSnapshot.data()!['Title'];
      final List<dynamic> timeList = docSnapshot.data()!['Time'];

      final List<Model> ModelList = [];
      for (int i = 0; i < titleList.length; i++) {
        Model model = Model(title: titleList[i], time: timeList[i]);

        ModelList.add(model);
      }
      return ModelList;
    } else {
      return [];
    }
  }

  // List<Model> events(DateTime day) {
  //   final List<Model> ll = getData(day) as List<Model>;
  //   return ll;
  // }



  @override
  Widget build(BuildContext context) {
    final String dayNow = formatter.format(selectday);
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.add_box_rounded,
                  size: 40,
                  color: Colors.black,
                )),
            title: TextButton(
                onPressed: () {
                  setState(() {
                    _isMonthView = !_isMonthView;
                  });
                },
                child: Row(
                  children: [
                    Text(dayNow,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 28,
                            color: Colors.black)),
                    Icon(
                      _isMonthView
                          ? Icons.keyboard_arrow_up_outlined
                          : Icons.keyboard_arrow_down_outlined,
                      color: Colors.black,
                      size: 40,
                    )
                  ],
                )),
            actions: [
              IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.settings,
                    color: Colors.black,
                    size: 40,
                  ))
            ],
            backgroundColor: Colors.transparent,
            //appbar 투명색
            elevation: 0, //그림자 농도 값 0으로 해서 제거
          ),
          body: SafeArea(
            // 앱의 실제 화면 크기를 계산하여 잘리는 거 없이 화면을 출력
            child: Container(
              child: FutureBuilder<List<Model>>(
                future: getData(selectday),
                builder: (context, sanpshot) {
                  return Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(5.0),
                      ),
                      TableCalendar<Model>(
                        focusedDay: focuseday,
                        firstDay: DateTime.utc(1900),
                        lastDay: DateTime(2100),
                        calendarFormat: format,
                        onFormatChanged: (CalendarFormat format) {
                          setState(() {
                            this.format = format;
                          });
                        },
                        onDaySelected: (DateTime focusday, DateTime selectday) {
                          setState(() {
                            this.focuseday = focusday;
                            this.selectday = selectday;
                          });
                        },
                        selectedDayPredicate: (DateTime day) {
                          return isSameDay(focuseday, day);
                        },
                       // eventLoader: events,

                      ),
                      Expanded(
                          child: StreamBuilder(
                        stream: _products.snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          return FutureBuilder<List<Model>>(
                              future: getData(selectday),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.done) {
                                  if (snapshot.hasData) {
                                    return ListView.builder(
                                        itemCount: snapshot.data!.length,
                                        itemBuilder: (context,index) {
                                          return GestureDetector(
                                            onTap: () => Get.to(UpdatePage(DateNow: selectday,titleData :snapshot.data![index].title)),
                                            child: ListTile(
                                              title: Text(snapshot.data![index].title),
                                              subtitle: Text(snapshot.data![index].time),
                                            ),
                                          );
                                        });
                                  } else {
                                    return ListTile(
                                      title: Text("데이터가 없습니다"),
                                    );
                                  }
                                }
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              });
                        },
                      ))
                    ],
                  );
                },
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => Get.to(MemoPage(DateNow: selectday)),
            tooltip: 'MemoHomePage',
            child: const Icon(Icons.add),
          ),
        );
  }
}
