import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class Test extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("FireStore"),
      ),
      body: StreamBuilder<QuerySnapshot>(      
      stream: Firestore.instance.collection('users').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError)
          return new Text('Error: ${snapshot.error}');
        switch (snapshot.connectionState) {
          case ConnectionState.waiting: return new Text('Loading...');
          default:
            return new ListView.builder(
              itemCount: snapshot.data.documents.length,
              itemBuilder: (BuildContext context, int index){
                return ListTile(
                  title: Text(snapshot.data.documents[index]['name']),
                  subtitle: Text(snapshot.data.documents[index]['surname']),
                );
              },
            );
            /*return new ListView(
              children: snapshot.data.documents.map((DocumentSnapshot document) {
                return new ListTile(
                  title: new Text(document['name']),
                  subtitle: new Text(document['surname']),
                );
              }).toList(),
            );*/
        }
      },
      ),
    );
  }
  
}