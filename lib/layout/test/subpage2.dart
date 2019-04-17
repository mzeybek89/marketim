import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';



class SubPage extends StatefulWidget  {

 
  SubPage({Key key,this.id,this.stockCode,this.productName,this.img,this.remoteImg,this.remoteLink}) : super(key: key);

  final int id;
  final String stockCode;
  final String productName;
  final String img;
  final String remoteImg;
  final String remoteLink;
  
  @override
  _MyHomePageState createState() => _MyHomePageState(); 
}

class _MyHomePageState extends State<SubPage>  with SingleTickerProviderStateMixin {
  //var f = new NumberFormat("####.00# ₺", "tr_TR");
  
  var f = new NumberFormat.currency(locale: "tr_TR", name:"TL", symbol: "₺",decimalDigits: 2);
  TabController _tabController;
  ScrollController _scrollViewController;
  Color currentAppBarColor = Colors.black;
  final appBarColors = [
    Colors.black,
    Colors.red,
    Colors.orange,
    Colors.green,
    Colors.deepOrange,
    Colors.cyan,
    Colors.purple,
  ];
  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: appBarColors.length);
    _scrollViewController =ScrollController();
    _tabController.addListener(_handleTabSelection);
    
  }

 void _handleTabSelection() {
    setState(() {
      currentAppBarColor = appBarColors[_tabController.index];
      print('Sayfa değişti');
    });
  }

 @override
 void dispose() {
   _tabController.dispose();
   _scrollViewController.dispose();
   super.dispose();
 }

  @override
  Widget build(BuildContext context) {
   List<Choice> choices =  <Choice>[
    Choice(
     index:-1,
     title: 'Tümü', 
     stockCode: widget.stockCode, 
     productName: widget.productName, 
     img: widget.img, 
     remoteImg: widget.remoteImg, 
     remoteLink: widget.remoteLink,  
     icon: Icons.add_shopping_cart, 
     fiyat: 0,
     ),
   Choice(
     index:0,
     title: 'Bim', 
     stockCode: widget.stockCode, 
     productName: widget.productName, 
     img: widget.img, 
     remoteImg: widget.remoteImg, 
     remoteLink: widget.remoteLink,  
     icon: Icons.add_shopping_cart, 
     fiyat: 12,
     ),
     Choice(
     index:1,
     title: 'Şok', 
     stockCode: widget.stockCode, 
     productName: widget.productName, 
     img: widget.img, 
     remoteImg: widget.remoteImg, 
     remoteLink: widget.remoteLink, 
     icon: Icons.add_shopping_cart, 
     fiyat: 15,
     ),
     Choice(
     index:2,
     title: 'Pehlivanoğlu', 
     stockCode: widget.stockCode, 
     productName: widget.productName, 
     img: widget.img, 
     remoteImg: widget.remoteImg, 
     remoteLink: widget.remoteLink, 
     icon: Icons.add_shopping_cart, 
     fiyat: 6.84,
     ),
     Choice(
     index:3,
     title: 'Migros', 
     stockCode: widget.stockCode, 
     productName: widget.productName, 
     img: widget.img, 
     remoteImg: widget.remoteImg, 
     remoteLink: widget.remoteLink, 
     icon: Icons.add_shopping_cart, 
     fiyat: 13,
     ),
     Choice(
     index:4,
     title: 'A101', 
     stockCode: widget.stockCode, 
     productName: widget.productName, 
     img: widget.img, 
     remoteImg: widget.remoteImg, 
     remoteLink: widget.remoteLink, 
     icon: Icons.add_shopping_cart, 
     fiyat: 21,
     ),
     Choice(
     index:5,
     title: 'Çimmar', 
     stockCode: widget.stockCode, 
     productName: widget.productName, 
     img: widget.img, 
     remoteImg: widget.remoteImg, 
     remoteLink: widget.remoteLink, 
     icon: Icons.add_shopping_cart, 
     fiyat: 12.8,
     ),
];
var liste = [0.00];
choices.skip(1).forEach((element) {
  liste.add(element.fiyat);
});
liste.removeAt(0);
//choices2.sort((x,y)=>x.compareTo(y));

/*tabbar with scroll */
return Scaffold(
      body: NestedScrollView(
        controller: _scrollViewController,
        headerSliverBuilder: (BuildContext context, bool boxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              title: Text('Ürün Detay'),
              pinned: true,
              backgroundColor: currentAppBarColor,
              floating: true,
              forceElevated: boxIsScrolled,              
              bottom: TabBar(                      
                isScrollable: true,          
                tabs: choices.map((Choice choice) {             
                return Tab(
                  text: choice.title,
                  //icon: Icon(choice.icon),
                );
              }).toList(),
                controller: _tabController,
              ),
            )
          ];
        },
        body: TabBarView(                    
           children: choices.map((Choice choice) {
             if(choice.index>=0){
                return Padding(
                  padding: const EdgeInsets.all(16),                  
                  child:ChoiceCard(choice: choice),                               
                );
             }
             else{
              return  Center(                 
                 child:
               Column(                 
                 children: <Widget>[
                    Container(                      
                      alignment: Alignment.topCenter,          
                      padding: EdgeInsets.all(20),
                      child: Text(
                        widget.productName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,              
                        ),
                      ),
                      color: Color(0xcd000000),
                      height: 56,
                    ),
                    FadeInImage.assetNetwork(                               
                      placeholder: "assets/images/loading.gif",              
                      image: 'http://zeybek.tk/api/images/'+widget.img, 
                      height: 200,
                    ),
                   Center(
                     child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: choices.skip(1).map((choice) {  
                          var style;                       
                          if(choice.fiyat==liste.reduce(min)){                    
                            style = TextStyle(
                            color: Colors.green, 
                            fontSize: 20,
                            fontWeight: FontWeight.bold,                                       
                            );
                          }
                          else
                          {
                            style = TextStyle(
                            color: Colors.grey.shade700, 
                            fontSize: 20,
                            fontWeight: FontWeight.bold,                                       
                            );
                          } 
                            return Padding(
                              padding: const EdgeInsets.all(8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,                  
                                children: <Widget>[                    
                                  Text(choice.title,style: style,),
                                  Text(":"),
                                  Text(f.format(choice.fiyat),style: style,),
                                ],
                              )
                            );
                                        
                        }).toList(), 
                      ),
                   )
                 ],
               ),               
               
              
               );
             }
                
           }).toList(),
          controller: _tabController,
        ),
      ),
      
    
);

  /* tabBar Fakat dikey scroll yok */
  /*return DefaultTabController(
        length: choices.length,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Ürün Detay'),
            backgroundColor: currentAppBarColor,
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabs: choices.map((Choice choice) {
                return Tab(
                  text: choice.title,
                  //icon: Icon(choice.icon),
                );
              }).toList(),
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: choices.map((Choice choice) {
             if(choice.index>=0){
                return Padding(
                  padding: const EdgeInsets.all(16),                  
                  child:ChoiceCard(choice: choice),                               
                );
             }
             else{
               return Center(child: Column(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: choices.skip(1).map((choice) {  
                   var style;                       
                   if(choice.fiyat==liste.reduce(min)){                    
                    style = TextStyle(
                    color: Colors.green, 
                    fontSize: 28,
                    fontWeight: FontWeight.bold,                                       
                    );
                   }
                   else
                   {
                    style = Theme.of(context).textTheme.display1;
                   } 
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,                  
                        children: <Widget>[                    
                          Text(choice.title,style: style,),
                          Text(":"),
                          Text(f.format(choice.fiyat),style: style,),
                        ],
                      )
                    );
                                 
                 }).toList(), 
               ),
               );
             }
                
           }).toList(),
          ),
        ),
  );*/

/* Tabbarsız ilk düz sayfa versiyonu */
   /* return new Scaffold(
      appBar: AppBar(
        title: Text('Ürün Detay'),      
      ),
      body: Column(                
        children: <Widget>[
          Container(
          alignment: Alignment.topCenter,          
          padding: EdgeInsets.all(10),
          child: Text(
            widget.product_name,
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,              
            ),
          ),
          
          color: Color(0xcd000000),
          height: 56,
        ),

        FadeInImage.assetNetwork(                               
          placeholder: "assets/images/loading.gif",
          //image: "http://zeybek.tk/api/images/"+data[index]["img"],                        
          image: widget.remote_img, 
        ),
        Text("Stock Code: "+widget.stock_code),      
        Container(
          alignment: Alignment.bottomRight,
          margin: EdgeInsets.fromLTRB(0, 10, 20, 0),
          child: Text("12 TL",
           style: TextStyle(
              color: Colors.blue.shade600,
              fontWeight: FontWeight.bold,
              fontSize: 20,              
            ),
          ),
        )

        ],
      ),

  
    
    );*/
  }
}


class Choice {
  const Choice({this.index,this.title, this.stockCode, this.productName, this.img, this.remoteImg, this.remoteLink, this.icon, this.fiyat});
  final int index;
  final String title;
  final String stockCode;
  final String productName;
  final String img;
  final String remoteImg;
  final String remoteLink;
  final IconData icon;
  final double fiyat;

}



class ChoiceCard extends StatelessWidget {
  const ChoiceCard({Key key, this.choice}) : super(key: key);
  
  final Choice choice;

  @override
  Widget build(BuildContext context) {
    final TextStyle textStyle = Theme.of(context).textTheme.display1;
    //var f = new NumberFormat("####.00# ₺", "tr_TR");
    var f = new NumberFormat.currency(locale: "tr_TR", name:"TL", symbol: "₺",decimalDigits: 2);
    /*return Card(
      color: Colors.white,*/
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[            
            //Icon(choice.icon, size: 128.0, color: textStyle.color),
            Container(
              alignment: Alignment.topCenter,          
              padding: EdgeInsets.all(10),
              child: Text(
                choice.productName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,              
                ),
              ),
              color: Color(0xcd000000),
              height: 56,
            ),
            FadeInImage.assetNetwork(                               
              placeholder: "assets/images/loading.gif",              
              image: 'http://zeybek.tk/api/images/'+choice.img, 
              height: 200,
            ),
            Text("Stock Code: "+choice.stockCode),  
            Text(choice.title, style: textStyle),    
            Container(
              alignment: Alignment.bottomRight,
              margin: EdgeInsets.fromLTRB(0, 10, 20, 0),
              child: Text(f.format(choice.fiyat),
              style: TextStyle(
                  color: Colors.grey.shade600,
                  //fontWeight: FontWeight.bold,
                  fontSize: 37,              
                ),
              ),                           
            ),
            Expanded(
              child: Container(
                alignment: Alignment.bottomRight,
                margin: EdgeInsets.fromLTRB(0, 10, 10, 0),
                child:   FloatingActionButton(              
                  child: Icon(choice.icon),
                  onPressed: () {
                  }
                ),
              ),
            )
            
                       
          ],
        //),
      
    );
  } 
}