import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc/bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:to_do_app/modules/archived/archived.dart';
import 'package:to_do_app/modules/done/done.dart';
import 'package:to_do_app/modules/new/new.dart';
import 'package:to_do_app/shared/cubit/states.dart';

class AppCubit extends Cubit<AppStates> {
  AppCubit() : super(AppInitialStates());

  static AppCubit get(context) => BlocProvider.of(context);

  int currentIndex = 0;

  List<Widget> screens = [
    NewTasksScreen(),
    DoneTasksScreen(),
    ArchivedTasksScreen(),
  ];

  List<String> titles = [
    'Tasks',
    'Done Tasks',
    'Archived Tasks'
  ];

  void changeIndex(int index) {
    currentIndex = index;
    emit(AppChangeBottomNavBarStates());
  }

  late Database database;

  List<Map> newTasks = [];
  List<Map> doneTasks = [];
  List<Map> archivedTasks = [];

  createDatabase() {
    openDatabase(
      'todo.db',
      version: 1,
      onCreate: (database, version) {
        print('database created');
        database
            .execute(
            'CREATE TABLE tasks (id INTEGER PRIMARY KEY, title TEXT, date TEXT, time TEXT, status TEXT)')
            .then((value) {
          print('table created');
        }).catchError((error) {
          print('Error when Creating Table ${error.toString()}');
        });
      }, onOpen: (database) {
      getDataFromDatabase(database);
      print('database opened');
    },
    ).then((value) {
      database = value;
      emit(AppCreateDatabaseStates());
    });
  }

  inserTODatabase({
    required String title,
    required String time,
    required String date,
  }) async {
    return await database
        .transaction((txn) =>
        txn.rawInsert(
            'INSERT INTO tasks(title, date, time, status) VALUES("$title ", "$time", "$date", "new")'))
        .then((value) {
      print('$value inserted successfully');
      emit(AppInsertDatebaseStates());
      getDataFromDatabase(database);
    })
        .catchError((error) {
      print('Error When Inserting New Record ${error.toString()}');
    });
  }
  void getDataFromDatabase(database) {
    newTasks = [];
    doneTasks = [];
    archivedTasks = [];
    emit(AppGetDatebaseStates());

    database.rawQuery('SELECT * FROM tasks').then((value) {
      value.forEach((element) {
        if (element['state'] == 'New')
          newTasks.add(element);
        else if (element['state'] == 'done')
          doneTasks.add(element);
        else archivedTasks.add(element);
      });
      emit(AppGetDatebaseStates());
    });
  }
  void updateDatebase({
  required String status,
  required int id,
  })async{
    database.rawUpdate(
        'UPDATE tasks SET state =? WHERE id =?',
      ['$state',id],
    ).then((value) {
      getDataFromDatabase(database);
      emit(AppUpdateDatebaseStates());
    });
}
 void deleteDatabase({
   required int id,
 })async{
    database.rawDelete('DELETE FROM tasks WHERE id=? ',[id]).
    then((value){
      getDataFromDatabase(database);
      emit(AppDeleteDatebaseStates());
    });
}
bool isBottomSheetShown =false;
  IconData fabIcon =Icons.edit;

  void changeBottomSheetState({
  required bool isShow, required IconData icon,
}){
    isBottomSheetShown=isShow;
    fabIcon=icon;
    emit(AppChangeBottomSheetState());
  }
}