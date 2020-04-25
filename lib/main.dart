import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_not_sepeti/kategori_islemleri.dart';
import 'package:flutter_not_sepeti/models/kategori.dart';
import 'package:flutter_not_sepeti/models/notlar.dart';
import 'package:flutter_not_sepeti/not_detay.dart';
import 'package:flutter_not_sepeti/utils/database_helper.dart';
import 'dart:core';

void main() => runApp(MyApp());
//sqflite.org dan tablolarda on delete cascade on update cascade

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        fontFamily: "Raleway",
        primaryColor: Colors.purpleAccent,
        primarySwatch: Colors.deepOrange,
      ),
      home: NotListesi(),
    );
  }
}

class NotListesi extends StatelessWidget {
  DatabaseHelper databaseHelper = DatabaseHelper();
  var _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Center(
          child: Text("Not Defteri"),
        ),
        actions: <Widget>[
          PopupMenuButton(itemBuilder: (context) {
            return [
              PopupMenuItem(child: ListTile(leading: Icon(Icons.category),
                  title: Text("Kategoriler"),
                  onTap: () {
                Navigator.pop(context);
                    _kategorilerSayfasinaGit(context);

                  }),),
            ];
          },),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(
            onPressed: () => _detaySayafasinaGit(context),
            tooltip: "Not Ekle",
            heroTag: "Not Ekle",
            child: Icon(
              Icons.flag,
            ),
            mini: true,
          ),
          FloatingActionButton(
              onPressed: () {
                kategoriEkleDialog(context);
              },
              heroTag: "Kategori Ekle",
              tooltip: "Kategori Ekle",
              child: Icon(
                Icons.add,
              )),
        ],
      ),
      body: Notlar(),
    );
  }

  void kategoriEkleDialog(BuildContext context) {
    var formKey = GlobalKey<FormState>();
    String yeniKAtegoriAdi = "";

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text(
            "Kategori Ekle",
            style: TextStyle(color: Theme
                .of(context)
                .primaryColor),
          ),
          children: <Widget>[
            Form(
              key: formKey,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  onSaved: (yeniDeger) {
                    yeniKAtegoriAdi = yeniDeger;
                  },
                  validator: (girilenKategoriAdi) {
                    if (girilenKategoriAdi.length < 3) {
                      return "En az 3 karakter olmalı";
                    }
                  },
                  decoration: InputDecoration(
                      labelText: "Kategori Adı", border: OutlineInputBorder()),
                ),
              ),
            ),
            ButtonBar(
              children: <Widget>[
                RaisedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  color: Colors.red,
                  child: Text(
                    "Vazgeç",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                RaisedButton(
                  onPressed: () {
                    if (formKey.currentState.validate()) {
                      formKey.currentState.save();
                      databaseHelper
                          .kategoriEkle(Kategori(yeniKAtegoriAdi))
                          .then((kategoriID) {
                        if (kategoriID > 0) {
                          _scaffoldKey.currentState.showSnackBar(
                            SnackBar(
                              content: Text("Kategori eklendi   : $kategoriID"),
                              duration: Duration(seconds: 2),
                            ),
                          );
                          debugPrint("KATEGORİ EKLKLENDİ   : $kategoriID");
                          Navigator.pop(context);
                        }
                      });
                    }
                  },
                  color: Colors.green,
                  child: Text(
                    "Kaydet",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            )
          ],
        );
      },
    );
  }

  _detaySayafasinaGit(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              NotDetay(
                baslik: "Yeni Not",
              ),
        ));
  }

  _kategorilerSayfasinaGit(BuildContext context) {
    Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => Kategoriler(),
        ));
  }
}

class Notlar extends StatefulWidget {
  @override
  _NotlarState createState() => _NotlarState();
}

class _NotlarState extends State<Notlar> {
  List<Not> tumNotlar;
  DatabaseHelper databaseHelper;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tumNotlar = List<Not>();
    databaseHelper = DatabaseHelper();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      builder: (context, AsyncSnapshot<List<Not>> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          tumNotlar = snapshot.data;
          sleep(Duration(milliseconds: 500));
          return ListView.builder(
            itemCount: tumNotlar.length,
            itemBuilder: (context, index) {
              return ExpansionTile(
                title: Text(tumNotlar[index].notBaslik),
                leading: _oncelikIconuAta(tumNotlar[index].notOncelik),
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(4),
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "Kategori :",
                                style: TextStyle(color: Colors.purpleAccent),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                tumNotlar[index].kategoriBaslik,
                                style: TextStyle(color: Colors.purpleAccent),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "Oluşturulma Tarihi :",
                                style: TextStyle(color: Colors.green),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("Bugün",
                                  style: TextStyle(color: Colors.green)),
                              //Text(databaseHelper.dateFormat(DateTime.parse((tumNotlar[index].notTarih))),style: TextStyle(color: Colors.green),),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("İçerik  :" + tumNotlar[index].notIcerik,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12)),
                        ),
                        ButtonBar(
                          alignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            FlatButton(
                                onPressed: () =>
                                    _notSil(tumNotlar[index].notID),
                                child: Text(
                                  "Sil",
                                  style: TextStyle(color: Colors.redAccent),
                                )),
                            FlatButton(
                                onPressed: () {
                                  _detaySayafasinaGit(
                                      context, tumNotlar[index]);
                                },
                                child: Text(
                                  "Güncelle",
                                  style: TextStyle(color: Colors.lightGreen),
                                ))
                          ],
                        )
                      ],
                    ),
                  )
                ],
              );
            },
          );
        } else {
          return Center(child: Text("Yükleniyor"));
        }
      },
      future: databaseHelper.notListesiniGetir(),
    );
  }

  _detaySayafasinaGit(BuildContext context, Not not) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              NotDetay(
                baslik: "Notu Düzenle",
                duzenlenecekNot: not,
              ),
        ));
  }

  _oncelikIconuAta(int notOncelik) {
    switch (notOncelik) {
      case 0:
        return CircleAvatar(
          child: Text(
            "Az",
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.red.shade50,
        );
        break;
      case 1:
        return CircleAvatar(
          child: Text(
            "Orta",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red.shade200,
        );
        break;
      case 2:
        return CircleAvatar(
          child: Text(
            "Yüksek",
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
          backgroundColor: Colors.red.shade300,
        );
        break;
      case 3:
        return CircleAvatar(
          child: Text(
            "Acil",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red.shade500,
        );
        break;
      case 4:
        return CircleAvatar(
          child: Center(
              child: Text(
                "İvedi",
                style: TextStyle(color: Colors.white),
              )),
          backgroundColor: Colors.red.shade700,
        );
        break;
    }
  }

  _notSil(int notID) {
    databaseHelper.notSil(notID).then((silinenID) {
      if (silinenID != 0) {
        Scaffold.of(context)
            .showSnackBar(SnackBar(content: Text("Not Silindi")));
        setState(() {});
      }
    });
  }
}
