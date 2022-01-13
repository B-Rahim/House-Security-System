import 'package:flutter/material.dart';
import 'package:safe/models/house_model.dart';
import 'package:safe/utils/dataBaseHelper.dart';




class NewHouse extends StatefulWidget {
  @override
  _NewHouseState createState() => _NewHouseState();
}

class _NewHouseState extends State<NewHouse> {

  DataBaseHelper dbHelper = DataBaseHelper();

  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressContoller = TextEditingController();

  House house;
  String _title;
@override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    house = ModalRoute.of(context).settings.arguments;
     _title = house.id==null? "Add new house": "Edit ${house.name}";
    nameController.text = house.name;
    phoneController.text = house.phone;
    return Scaffold(
      appBar: AppBar(
        title: Text('Add new house')
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left:10, right:10, top:10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              TextField(
                controller: nameController,
                onChanged: (value){house.name = nameController.text;},
                decoration: InputDecoration(
                    hintText: 'Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.house),

                ),
              ),
              TextField(
              controller: phoneController,
              onChanged: (value ){house.phone = phoneController.text;} ,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                  hintText: 'Phone',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),

              ),
            ),
              TextField(
              controller: addressContoller,
              onChanged: (value){house.address = addressContoller.text;},

              decoration: InputDecoration(
                  hintText: 'Address',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.edit_location)
              ),
            ),
                SizedBox(height: 50),
                Row(
                  children: [
                    Expanded(
                      child: RaisedButton(
                        onPressed: (){ Navigator.pop(context); },
                        child: Text('Cancel')
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: RaisedButton(
                        onPressed: (){
                          _save();
                        },
                        child: Text('Save')
                      ),
                    )
                  ],
                )
                ],
            ),
          ),
        ),
      )
    );
  }
  _save() async{
    int result;
    Navigator.pop(context);

    if(house.id == null){ //insert operation
       result  = await dbHelper.insertHouse(house);
    }
    else{ //update operation
       result = await dbHelper.updateHouse(house);
    }
    if(result == 0)
      _showDialog('Status', 'Failed to save House');
    else
      _showDialog('Status', 'House saved successfully');
 }
  _showDialog(String title, String content){
    return showDialog(context: context, builder: (context){
      Future.delayed(Duration(seconds: 1),(){ Navigator.pop(context);});
      return AlertDialog(
        title: Text(title),
        content: Text(content),
      );
    });
  }
}
