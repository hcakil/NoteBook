import 'package:flutter/material.dart';
import 'package:flutter_not_sepeti/models/kategori.dart';
import 'package:flutter_not_sepeti/models/notlar.dart';
import 'package:flutter_not_sepeti/utils/database_helper.dart';

class NotDetay extends StatefulWidget {
  String baslik;
  Not duzenlenecekNot;

  NotDetay({this.baslik, this.duzenlenecekNot});

  @override
  _NotDetayState createState() => _NotDetayState();
}

class _NotDetayState extends State<NotDetay> {
  var formKey = GlobalKey<FormState>();
  List<Kategori> tumKategoriler;
  DatabaseHelper databaseHelper;
  int kategoriID ;
  int secilenOncelik;
  String notBaslik,notIcerik;
  static var _oncelik = ["Düşük", "Orta", "Yüksek", "Acil", "Çok Acil"];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //aşağıdakileri boş bir şekilde oluşturuyoruz.
    tumKategoriler = List<Kategori>();
    databaseHelper = DatabaseHelper();
    databaseHelper.kategorileriGetir().then((kategorileriIcerenMapListesi) {
      for (Map map in kategorileriIcerenMapListesi) {
        tumKategoriler.add(Kategori.fromMap(map));
      }

      if(widget.duzenlenecekNot != null){
         kategoriID = widget.duzenlenecekNot.kategoriID;
         secilenOncelik = widget.duzenlenecekNot.notOncelik;
      }
      else{
         kategoriID = 1;
         secilenOncelik = 0;
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //bu klavyeyide alıp padding de taşmalar oluyor
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text(widget.baslik),
      ),
      body: tumKategoriler.length <= 0
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              child: Form(
                key: formKey,
                child: Column(children: <Widget>[
                  Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          "Kategori :",
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                          //style: etiket,
                        ),
                      ),
                      Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 1, horizontal: 12),
                        margin: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: Theme.of(context).primaryColor,
                                width: 1),
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        child: DropdownButtonHideUnderline(
                            child: DropdownButton(
                                items: kategoriItemleriOlustur(),
                                value: kategoriID,
                                onChanged: (secilenKategoriID) {
                                  setState(() {
                                    kategoriID = secilenKategoriID;
                                  });
                                })),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      initialValue: widget.duzenlenecekNot != null ? widget.duzenlenecekNot.notBaslik : "",
                      validator: (text){
                        if(text.length<3){
                          return "En az 6 karakter olmalıdır.";
                        }
                      },
                      onSaved: (text){
                        notBaslik = text;
                      },
                      decoration: InputDecoration(
                          hintText: "Not Başlığını Giriniz",
                          labelText: "Başlık",
                          border: OutlineInputBorder()),
                    ),
                  ),
                  Padding(

                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      initialValue: widget.duzenlenecekNot != null ? widget.duzenlenecekNot.notIcerik : "",
                      onSaved: (gelenIcerik){
                        notIcerik=gelenIcerik;
                      },
                      maxLines: 4,
                      decoration: InputDecoration(
                          hintText: "Not İçeriğini Giriniz",
                          labelText: "İçerik",
                          border: OutlineInputBorder()),
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          "Öncelik :",
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                          //style: etiket,
                        ),
                      ),
                      Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 1, horizontal: 12),
                        margin: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: Theme.of(context).primaryColor,
                                width: 1),
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                                items: _oncelik.map((oncelik) {
                                  return DropdownMenuItem<int>(
                                    child: Text(
                                      oncelik,
                                      style: TextStyle(fontSize: 15),
                                    ),
                                    value: _oncelik.indexOf(oncelik),
                                  );
                                }).toList(),
                                value: secilenOncelik,
                                onChanged: (secilenOncelikID) {
                                  setState(() {
                                    secilenOncelik = secilenOncelikID;
                                  });
                                })),
                      ),
                    ],
                  ),
                  ButtonBar(
                    alignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      RaisedButton(onPressed: (){Navigator.pop(context);},child: Text("Vazgeç"),color: Colors.redAccent.shade50,),
                      OutlineButton(
                          borderSide: BorderSide(color: Theme.of(context).accentColor),
                          onPressed: () {
                            if (formKey.currentState.validate()) {
                              formKey.currentState.save();

                              var suan = DateTime.now();
                              if (widget.duzenlenecekNot == null)
                              {

                                print("metod çalıştı"+ databaseHelper.dateFormat(suan));
                                databaseHelper.notEkle(Not(
                                    kategoriID, notBaslik, notIcerik, suan.toString(),
                                    secilenOncelik)).then((kaydedilenNotID) {
                                  if (kaydedilenNotID != 0) {
                                    debugPrint("kaydedilen not id $kaydedilenNotID");
                                    Navigator.pop(context);
                                  }
                                });
                              }
                              else {

                                databaseHelper.notGuncelle(Not.withID(
                                    widget.duzenlenecekNot.notID, kategoriID,
                                    notBaslik, notIcerik, suan.toString(),
                                    secilenOncelik)).then((guncellenenID){
                                  if (guncellenenID != 0) {
                                    Navigator.pop(context);
                                  }
                                });
                              }
                            }
                          },
                          child: Text(
                            "KAYDET",
                            style: TextStyle(color: Theme.of(context).accentColor, fontSize: 20, fontWeight: FontWeight.w700),
                          )),
                    ],
                  )
                ]),
              ),
            ),
    );
  }

  //Burda veritabanına gidip kategorileri bir liste yapıp geri dönğcem
  List<DropdownMenuItem<int>> kategoriItemleriOlustur() {
    //veri tabanından kategoriler geldi
    //bunları drop down menu itema dönüş türüyoruz yani map şeklinde key/value tutuyor
    return tumKategoriler
        .map((kategori) => DropdownMenuItem<int>(
              value: kategori.kategoriID,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  kategori.kategoriBaslik,
                  style: TextStyle(fontSize: 15),
                ),
              ),
            ))
        .toList();
  }
}

/*
*  @override
  Widget build(BuildContext context) {

    var etiket = TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 20,
        color: Colors.blueGrey);

    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text(widget.baslik),
      ),
      body: tumKategoriler.length <= 0
          ? Center(
        child: CircularProgressIndicator(),
      )
          : Container(
        child: Form(
          key: formKey,
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      "Kategori :",
                      style: etiket,
                    ),
                  ),
                  Container(
                    padding:
                    EdgeInsets.symmetric(vertical: 1, horizontal: 12),
                    margin: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        border:
                        Border.all(color: Theme.of(context).primaryColor, width: 1),
                        borderRadius:
                        BorderRadius.all(Radius.circular(10))),
                    child: DropdownButtonHideUnderline(
                        child: DropdownButton(
                            items: kategoriItemleriOlustur(),
                            value: kategoriID,
                            onChanged: (secilenKategoriID) {
                              setState(() {
                                kategoriID = secilenKategoriID;
                              });
                            })),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  initialValue: widget.duzenlenecekNot != null ? widget
                      .duzenlenecekNot.notBaslik : "",
                  validator: (text) {
                    if (text.length < 3) {
                      return "En az 3 karakter olmalı";
                    }
                  },
                  onSaved: (text) {
                    notBaslik = text;
                  },
                  decoration: InputDecoration(
                    hintText: "Not başlığını giriniz",
                    labelText: "Başlık",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  initialValue: widget.duzenlenecekNot != null ? widget
                      .duzenlenecekNot.notIcerik : "",
                  onSaved: (text) {
                    notIcerik = text;
                  },
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: "Not içeriğini giriniz",
                    labelText: "İçerik",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      "Öncelik :",
                      style: etiket,
                    ),
                  ),
                  Container(
                    padding:
                    EdgeInsets.symmetric(vertical: 2, horizontal: 12),
                    margin: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        border:
                        Border.all(color: Theme.of(context).primaryColor, width: 1),
                        borderRadius:
                        BorderRadius.all(Radius.circular(10))),
                    child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                            items: _oncelik.map((oncelik) {
                              return DropdownMenuItem<int>(
                                child: Text(
                                  oncelik,
                                  style: TextStyle(fontSize: 16),
                                ),
                                value: _oncelik.indexOf(oncelik),
                              );
                            }).toList(),
                            value: secilenOncelik,
                            onChanged: (secilenOncelikID) {
                              setState(() {
                                secilenOncelik = secilenOncelikID;
                              });
                            })),
                  ),
                ],
              ),

              ButtonBar(
                alignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  OutlineButton(
                      borderSide: BorderSide(color: Theme.of(context).primaryColor),
                      onPressed: () {
                      Navigator.pop(context);
                      },
                      child: Text(
                        "VAZGEÇ",
                        style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 20, fontWeight: FontWeight.w700),
                      )),
                  OutlineButton(
                      borderSide: BorderSide(color: Theme.of(context).accentColor),
                      onPressed: () {
                        if (formKey.currentState.validate()) {
                          formKey.currentState.save();

                          var suan = DateTime.now();
                          if (widget.duzenlenecekNot == null) {
                            databaseHelper.notEkle(Not(
                                kategoriID, notBaslik, notIcerik, suan.toString(),
                                secilenOncelik)).then((kaydedilenNotID) {
                              if (kaydedilenNotID != 0) {
                                Navigator.pop(context);
                              }
                            });
                          } else {

                            databaseHelper.notGuncelle(Not.withID(
                                widget.duzenlenecekNot.notID, kategoriID,
                                notBaslik, notIcerik, suan.toString(),
                                secilenOncelik)).then((guncellenenID){
                              if (guncellenenID != 0) {
                                Navigator.pop(context);
                              }
                            });
                          }
                        }
                      },
                      child: Text(
                        "KAYDET",
                        style: TextStyle(color: Theme.of(context).accentColor, fontSize: 20, fontWeight: FontWeight.w700),
                      )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
* */
