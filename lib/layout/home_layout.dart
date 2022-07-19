import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/modules/archived_tasks/archive_tasks_screen.dart';
import 'package:todo_app/modules/done_tasks/done_tasks_screen.dart';
import 'package:todo_app/modules/new_tasks/new_tasks_screen.dart';
import 'package:todo_app/shared/componants/componants.dart';
import 'package:todo_app/shared/componants/constants.dart';
import 'package:todo_app/shared/cubit/cubit.dart';
import 'package:todo_app/shared/cubit/states.dart';

class HomeLayout extends StatelessWidget {



  late Database database;
  var scaffoldKey = GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();


  var titleController = TextEditingController();
  var timeController = TextEditingController();
  var dateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => AppCubit()..createDatabase(),
      child: BlocConsumer<AppCubit,AppStates>(
        listener: (context ,state) {
          if(state is AppInsertDatabaseState){
            Navigator.pop(context);
          }
        },
        builder: (context,state)
        {
          AppCubit cubit = AppCubit.get(context);

          return Scaffold(
            key: scaffoldKey,
            appBar: AppBar(
              title: Text(
                cubit.titles[cubit.currentIndex],
              ),
            ),
            body:ConditionalBuilder(
              condition: state is! AppGetLoadingDatabaseState,
              fallback: (context) => const Center(child: CircularProgressIndicator()),
              builder: (BuildContext context) => cubit.screens[cubit.currentIndex],

            ),
            floatingActionButton: FloatingActionButton(
              onPressed: ()
              {
                if(cubit.isBottomSheetShow)
                {
                  if(formKey.currentState!.validate())
                  {
                    cubit.insertToDatabase(
                        title: titleController.text,
                        time: timeController.text,
                        date: dateController.text,
                    );
                  }
                }else
                {
                  scaffoldKey.currentState!.showBottomSheet(
                        (context) => Container(
                      color: Colors.white,
                      padding: EdgeInsets.all(20),
                      child: Form(
                        key: formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            defaultFormField(
                              controller: titleController,
                              type: TextInputType.text,
                              validator: (String? value)
                              {
                                if(value!.isEmpty)
                                {
                                  return 'title must not be empty';
                                }
                              },
                              label: 'Task Title',
                              prefix: Icons.title,
                            ),
                            const SizedBox(height: 15,),
                            defaultFormField(
                              controller: timeController,
                              type: TextInputType.datetime,
                              onTap: ()
                              {
                                showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                ).then((value)
                                {
                                  timeController.text = value!.format(context).toString();
                                  print(value.format(context));
                                });
                              },
                              validator: (String? value)
                              {
                                if(value!.isEmpty)
                                {
                                  return 'time must not be empty';
                                }
                              },
                              label: 'Task Time',
                              prefix: Icons.watch_later_outlined,
                            ),
                            const SizedBox(height: 15,),
                            defaultFormField(
                              controller: dateController,
                              type: TextInputType.datetime,
                              onTap: ()
                              {
                                showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.parse('2022-09-01'),
                                ).then((value)
                                {
                                  print(DateFormat.yMMMd().format(value!));
                                  dateController.text = DateFormat.yMMMd().format(value);

                                });
                              },
                              validator: (String? value)
                              {
                                if(value!.isEmpty)
                                {
                                  return 'date must not be empty';
                                }
                              },
                              label: 'Task Date',
                              prefix: Icons.calendar_today,
                            ),
                          ],
                        ),
                      ),
                    ),
                    elevation: 20,

                  ).closed.then((value)
                  {
                    cubit.changeBottomSheetState(
                        isShow: false,
                        icon: Icons.edit,
                    );
                  });
                  cubit.changeBottomSheetState(
                    isShow: true,
                    icon: Icons.add,
                  );
                }
              },
              child: Icon(
                cubit.fabIcon,
              ),
            ),
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: cubit.currentIndex,
              onTap: (index)
              {
                cubit.changeIndex(index);
              },
              items: [
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.menu,
                  ),
                  label: 'Tasks',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.check_box_rounded,
                  ),
                  label: 'Done',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.archive_outlined,
                  ),
                  label: 'Archived',
                ),
              ],
            ),
          );
        },

      ),
    );
  }


}


