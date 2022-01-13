import 'package:flutter/material.dart';
import 'package:safe/models/house_model.dart';
import 'package:safe/screens/history.dart';

class HouseCard extends StatelessWidget {
  House house;
  Function delete;
  Function update;
  HouseCard(this.house, this.delete, this.update);
  confirm(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Confirm removing this house'),
            content: Text(
                'All messaging history associated to this house will be removed'),
            actions: [
              FlatButton(
                onPressed: () {
                  delete();
                  Navigator.of(context).pop();
                },
                child: Text('Yes'),
              ),
              FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        margin: const EdgeInsets.fromLTRB(5, 5, 5, 0),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 5),
          child: ListTile(
            leading: FlutterLogo(),
            title: Text(house.name),
            subtitle: Text(house.phone),
            trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  confirm(context);
                }),
            onLongPress: () async {
              await Navigator.pushNamed(context, '/new', arguments: house);
              update();
            },
            onTap: () async => await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      History(house)),
            ), //onTap: ,
          ),
        ));
  }
}
