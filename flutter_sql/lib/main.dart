// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_sql/db/database.dart';
import 'package:flutter_sql/model/student.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: StudentPage(),
    );
  }
}

class StudentPage extends StatefulWidget {
  const StudentPage({Key? key}) : super(key: key);

  @override
  State<StudentPage> createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
  final GlobalKey<FormState> _formStateKey = GlobalKey<FormState>();
  final _studentNameController = TextEditingController();

  late Future<List<Student>> _studentsList;
  late String _studentName;
  int? studentIdForUpdate;
  bool isUpdate = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    updateStudentList();
  }

  updateStudentList() {
    setState(() {
      _studentsList = DBProvider.db.getStudents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SQL CRUD Demo"),
        centerTitle: true,
        backgroundColor: Colors.indigo,
      ),
      body: Column(children: [
        Form(
          key: _formStateKey,
          autovalidateMode: AutovalidateMode.always,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(10.0),
                child: TextFormField(
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Please Endter Student Name";
                    } else if (value.trim() == "") {
                      return "Enter correct value";
                    }
                  },
                  onSaved: (value) {
                    _studentName = value!;
                  },
                  controller: _studentNameController,
                  decoration: InputDecoration(
                    focusedBorder: new UnderlineInputBorder(
                      borderSide: new BorderSide(
                          color: Colors.indigoAccent,
                          width: 1,
                          style: BorderStyle.solid),
                    ),
                    labelText: "Student Name",
                    icon: Icon(
                      Icons.people,
                      color: Colors.indigoAccent,
                    ),
                    fillColor: Colors.white,
                    labelStyle: TextStyle(color: Colors.indigo),
                  ),
                ),
              )
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                if (isUpdate) {
                  if (_formStateKey.currentState!.validate()) {
                    _formStateKey.currentState!.save();
                    DBProvider.db
                        .updateStudent(
                            Student(studentIdForUpdate, _studentName))
                        .then((data) {
                      setState(() {
                        isUpdate = false;
                      });
                    });
                  }
                } else {
                  if (_formStateKey.currentState!.validate()) {
                    _formStateKey.currentState!.save();
                    DBProvider.db.insertStudent(Student(null, _studentName));
                  }
                }
                _studentNameController.text = "";
                updateStudentList();
              },
              child: Text((isUpdate ? "Update" : "Add")),
              style: ElevatedButton.styleFrom(
                primary: Colors.green,
                textStyle: TextStyle(color: Colors.white),
              ),
            ),
            Padding(padding: EdgeInsets.all(10)),
            ElevatedButton(
              onPressed: () {
                _studentNameController.text = '';
                setState(() {
                  isUpdate = false;
                  studentIdForUpdate = null;
                });
              },
              child: Text((isUpdate ? "Cancel" : "Clear")),
              style: ElevatedButton.styleFrom(
                primary: Colors.red,
                textStyle: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        Divider(
          height: 5.0,
        ),
        Expanded(
            child: FutureBuilder(
          future: _studentsList,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return generateList(snapshot.data as List<Student>);
            }
            if (snapshot.data == null ||
                (snapshot.data as List<Student>).length == 0) {
              return Text("Data no found");
            }
            return CircularProgressIndicator();
          },
        )),
        Divider(
          height: 5.0,
        ),
      ]),
    );
  }

  SingleChildScrollView generateList(List<Student> students) {
    return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: DataTable(
            // ignore: prefer_const_literals_to_create_immutables
            columns: [
              DataColumn(
                label: Text("Name"),
              ),
              DataColumn(
                label: Text("Delete"),
              )
            ],
            rows: students
                .map((student) => DataRow(cells: [
                      DataCell(Text(student.name as String), onTap: () {
                        setState(() {
                          isUpdate = true;
                          studentIdForUpdate = student.id;
                        });
                        _studentNameController.text = student.name as String;
                      }),
                      DataCell(IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          DBProvider.db.deleteStudent(student.id);
                          updateStudentList();
                        },
                      ))
                    ]))
                .toList(),
          ),
        ));
  }
}
