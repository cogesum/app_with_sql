import 'dart:io';

import 'package:flutter_sql/model/student.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:sqflite/sqflite.dart';

class DBProvider {
  DBProvider._();

  static final DBProvider db = DBProvider._();
  static late Database _database;

  String studentsTable = "Students";
  String columnId = "id";
  String columnName = "name";

  Future<Database> get database async {
    //if (_database != null) return _database;

    _database = await _intDB();
    return _database;
  }

  Future<Database> _intDB() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String path = dir.path + "Students.db";

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  void _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $studentsTable(
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnName TEXT
      )
    ''');
  }

  //read
  Future<List<Student>> getStudents() async {
    Database db = await this.database;
    final List<Map<String, dynamic>> studentsMapList =
        await db.query(studentsTable);
    final List<Student> studentsList = [];

    studentsMapList.forEach((element) {
      studentsList.add(Student.fromMap(element));
    });

    return studentsList;
  }

  //insert
  Future<Student> insertStudent(Student student) async {
    Database db = await this.database;
    student.id = await db.insert(studentsTable, student.toMap());

    return student;
  }

  //update
  Future<int> updateStudent(Student student) async {
    Database db = await this.database;

    return await db.update(
      studentsTable,
      student.toMap(),
      where: '$columnId = ?',
      whereArgs: [student.id],
    );
  }

  //delete
  Future<int> deleteStudent(int? id) async {
    Database db = await this.database;

    return await db.delete(
      studentsTable,
      where: "$columnId = ?",
      whereArgs: [id],
    );
  }
}
