import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as baglanti;
import 'dart:convert';

/*
{
userId: 1,
id: 1,
title: "sunt aut facere repellat provident occaecati excepturi optio reprehenderit",
body: "quia et suscipit suscipit recusandae consequuntur expedita et cum reprehenderit molestiae ut ut quas totam nostrum rerum est autem sunt rem eveniet architecto"
}
*/

class Post{
  int userId;
  int id;
  String title;
  String body;

  Post({this.userId,this.id,this.title,this.body});

  factory Post.fromJson(Map<String, dynamic> json){
    return Post(
      userId:  json['userId'],
      id:      json['id2'],
      title:   json['title'],
      body:    json['body']
    );
  }
}


Future<Post> getir() async{
  final response = await baglanti.get("https://jsonplaceholder.typicode.com/posts/1");

  if(response.statusCode == 200)
  {
    return Post.fromJson(json.decode(response.body));
  }
  else
  {
    throw Exception("Veri Alınamadı. Code => ${response.statusCode}");
  }
}

class Json extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Json"),),
      body: Center(
          child: FutureBuilder<Post>(
            future: getir(),
            builder: (context,snapshot){
              if(snapshot.hasData){
                int userId = snapshot.data.userId;
                int id = snapshot.data.id;
                String title = snapshot.data.title;
                String body = snapshot.data.body;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text("$userId"),
                    Text("$id"),
                    Text("$title"),
                    Text("$body"),
                  ],
                );
              }
              else if(snapshot.hasError)
              {
                return Text("Hata Oluştu ${snapshot.error}");
              }
              return CircularProgressIndicator();
            },
          ),
      ),
    );
  } 
}
