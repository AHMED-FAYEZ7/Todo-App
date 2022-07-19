import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/shared/cubit/cubit.dart';

Widget defaultFormField({
  required TextEditingController controller,
  required TextInputType type,
  String? Function(String? s)? onSubmit,
  String? Function(String? s)? onChange,
  Function? onTap,
  required String? Function(String? val)? validator,
  required String label,
  required IconData prefix,
  bool isPassword = false,
  IconData? suffix,
  Function? suffixPressed,
  bool isClickable = true,

}) => TextFormField(
  controller: controller,
  keyboardType:type,
  enabled: isClickable,
  onFieldSubmitted: onSubmit,
  onChanged: onChange,
  obscureText: isPassword,
  onTap: (){
    onTap!();
  },
  decoration: InputDecoration(
    labelText: label,
    border: const OutlineInputBorder(),
    prefixIcon: Icon(
      prefix,
    ),
    suffixIcon: IconButton(
      icon: Icon(
        suffix,
      ),
      onPressed: ()
      {
        suffixPressed!();
      },
    ),
  ),
  validator: validator,
);


Widget buildTaskItem(Map model, context) => Dismissible(
  key: Key(model['id'].toString()),
  child: Padding(

    padding: const EdgeInsets.all(20.0),

    child: Row(

      children: [

        CircleAvatar(

          radius: 40,

          child: Text(

            '${model['time']}',

          ),

        ),

        SizedBox(width: 20,),

        Expanded(

          child: Column(

            crossAxisAlignment: CrossAxisAlignment.start,

            mainAxisSize: MainAxisSize.min,

            children: [

              Text(

                '${model['title']}',

                style: TextStyle(

                  fontSize: 18,

                  fontWeight: FontWeight.bold,

                ),

              ),

              Text(

                '${model['date']}',

                style: TextStyle(

                  color: Colors.grey,

                ),

              ),

            ],

          ),

        ),

        SizedBox(width: 20,),

        IconButton(

          color: Colors.green,

            onPressed: ()

            {

              AppCubit.get(context).updateDate(

                  status: 'done',

                  id: model['id'],

              );

            },

            icon: Icon(

              Icons.check_box,

            ),

        ),

        IconButton(

          color: Colors.black45,

          onPressed: ()

          {

            AppCubit.get(context).updateDate(

              status: 'archive',

              id: model['id'],

            );

          },

            icon: Icon(

              Icons.archive,

            ),

        ),

      ],

    ),

  ),
  onDismissed: (direction)
  {
    AppCubit.get(context).deleteDate(id: model['id'],);
  },
);

Widget tasksBuilder({
  required List<Map> tasks,
}) => ConditionalBuilder(
  condition: tasks.length > 0,
  builder: (context) => ListView.separated(
    itemBuilder: (context ,index) => buildTaskItem(tasks[index],context),
    separatorBuilder: (context, index) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20,),
      child: Container(
        width: double.infinity,
        height: 1,
        color: Colors.grey[350],
      ),
    ),
    itemCount: tasks.length,
  ),
  fallback: (context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.menu,
          size: 100,
          color: Colors.grey,
        ),
        Text(
          'No Tasks Yet, please Add Tasks',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey,

          ),
        ),
      ],
    ),
  ),
);