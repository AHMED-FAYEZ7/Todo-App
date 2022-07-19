import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/modules/archived_tasks/archive_tasks_screen.dart';
import 'package:todo_app/modules/done_tasks/done_tasks_screen.dart';
import 'package:todo_app/modules/new_tasks/new_tasks_screen.dart';
import 'package:todo_app/shared/cubit/states.dart';

class AppCubit extends Cubit<AppStates>
{
  AppCubit() : super(AppInitialState());

  static AppCubit get(context) => BlocProvider.of(context);

  int currentIndex = 0;

  List<Widget> screens = [
    NewTasksScreen(),
    DoneTasksScreen(),
    ArchiveTasksScreen(),
  ];

  List<String> titles = [
    'New Tasks',
    'Done Tasks',
    'Archived Tasks',
  ];

  void changeIndex(int index)
  {
    currentIndex = index;
    emit(AppChangeNavBarState());
  }

  late Database database;
  List<Map> newTasks = [];
  List<Map> doneTasks = [];
  List<Map> archiveTasks = [];

  void createDatabase()
  {
    openDatabase(
      'todo.db',
      version: 1,
      onCreate: (database , version)
      {
        print('dataBase created');
        database.execute(
            'CREATE TABLE tasks (id INTEGER PRIMARY KEY , title TEXT,date TEXT,time TEXT,status Text)'
        ).then((value)
        {
          print('table created');
        }).catchError((error)
        {
          print('Error When Created Table ${error.toString()}');
        });
      },
      onOpen: (database)
      {
        getDataFromDatabase(database);
        print('dataBase opened');
      },
    ).then((value) {
      database = value;
      emit(AppCreateDatabaseState());
    });
  }

  insertToDatabase ({
    required String title,
    required String time,
    required String date,
  }) async
  {
    await database.transaction((txn)
    {
      return txn.rawInsert(
          'INSERT INTO tasks(title, date ,time ,status) VALUES("$title","$date","$time","new")'
      );
    }).then((value){
      print('$value inserted into database');
      emit(AppInsertDatabaseState());

      getDataFromDatabase(database);
    }).catchError((error){
      print('Error When Inserted New Record ${error.toString()}');
    });
  }

  void getDataFromDatabase(database)
  {
    newTasks = [];
    doneTasks = [];
    archiveTasks = [];

    emit(AppGetLoadingDatabaseState());
    return database.rawQuery('SELECT * FROM tasks').then((value)
    {
      value.forEach((element) {
        if(element['status'] == 'new')
          newTasks.add(element);
        else if(element['status'] == 'done')
          doneTasks.add(element);
        else archiveTasks.add(element);
      });

      emit(AppGetDatabaseState());
    });
  }

  void updateDate({
  required String status,
    required int id,
}) async
  {
    database.rawUpdate(
        'UPDATE tasks SET status = ? WHERE id = ?',
        ['$status', id],
    ).then((value) {
      getDataFromDatabase(database);
      emit(AppUpdateDatabaseState());
    });
  }

  void deleteDate({
    required int id,
  }) async
  {
    database.rawDelete('DELETE FROM tasks WHERE id = ?', [id])
        .then((value) {
      getDataFromDatabase(database);
      emit(AppDeleteDatabaseState());
    });
  }

  bool isBottomSheetShow = false;
  IconData fabIcon = Icons.edit;

  void changeBottomSheetState ({
  required bool isShow,
    required IconData icon,
})
  {
    isBottomSheetShow = isShow;
    fabIcon = icon;

    emit(AppChangeBottomSheetState());
  }

}