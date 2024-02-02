import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> task = [];
  final mybox = Hive.box('to_do_Box');

  @override
  void initState() {
    load_or_read_Task();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[200],
      appBar: AppBar(
        title: Text("TO Do"),
        elevation: 1,
      ),
      body: task.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: task.length,
              itemBuilder: (context, index) {
                final mytask = task[index]; //fetch each single list from map
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    child: ListTile(
                      title: Text(mytask['taskName']),
                      subtitle: Text(mytask['taskTime']),
                      trailing: Wrap(
                        children: [
                          IconButton(
                            onPressed: () {
                              showTask(context, mytask['id']);

                            },
                            icon: Icon(Icons.edit),
                          ),
                          IconButton(onPressed: () {
                            deleteTask(mytask['id']);

                          }, icon: Icon(Icons.delete))
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showTask(context, null),
        label: const Text("Create Task"),
        icon: const Icon(Icons.add),
      ),
    );
  }

  final task_controller = TextEditingController();
  final time_controller = TextEditingController();

  void showTask(BuildContext context, int? itemkey) {
    if(itemkey!= null){
      final existingTask=task.firstWhere((element) => element['id'] == itemkey);
      task_controller.text=existingTask['taskName'];
      time_controller.text=existingTask['taskTime'];
    }
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
              top: 15,
              left: 15,
              right: 15,
              bottom: MediaQuery.of(context).viewInsets.bottom + 120),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: task_controller,
                decoration: InputDecoration(
                    border: OutlineInputBorder(), hintText: "To-Do Task"),
              ),
              SizedBox(
                height: 15,
              ),
              TextField(
                controller: time_controller,
                decoration: InputDecoration(
                    border: OutlineInputBorder(), hintText: "Time"),
              ),
              SizedBox(
                height: 15,
              ),
              ElevatedButton(
                  onPressed: () {
                    if (task_controller.text != "" &&
                        time_controller.text != "") {
                      if (itemkey == null) {
                        createTask({
                          "Name": task_controller.text.trim(),
                          "Time": time_controller.text.trim()
                        });
                      } else {
                        updatetask(itemkey, {
                          "Name": task_controller.text.trim(),
                          "Time": time_controller.text.trim()
                        });
                      }
                    }
                    task_controller.text = "";
                    time_controller.text = "";
                    Navigator.of(context).pop();
                  },
                  child: Text(itemkey == null ? "Create task" : "Update task"))
            ],
          ),
        );
      },
    );
  }

  Future<void> createTask(Map<String, dynamic> task) async {
    await mybox.add(task);
    load_or_read_Task(); //to refrest ui and update list
  }

  Future<void> updatetask(int itemkey, Map<String, String> uptask) async{
    await mybox.put(itemkey,uptask);
    load_or_read_Task();

  }

  void load_or_read_Task() {
    final task_from_hive = mybox.keys.map((key) {
      final value = mybox.get(key);
      return {'id': key, 'taskName': value['Name'], 'taskTime': value['Time']};
    }).toList();
    setState(() {
      task = task_from_hive.reversed.toList();
      print(task);
    });
  }
  
  Future<void> deleteTask(int itemkey) async{
    await mybox.delete(itemkey) ;
    load_or_read_Task(); 
    ScaffoldMessenger.of(context).showSnackBar(
      
      const SnackBar(
        backgroundColor:Colors.red ,
        content: Text("Sucessfully Deleted"))
    );

  }
}
