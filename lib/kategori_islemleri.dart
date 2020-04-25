import 'package:flutter/material.dart';
import 'package:flutter_not_sepeti/models/kategori.dart';
import 'package:flutter_not_sepeti/utils/database_helper.dart';

class Kategoriler extends StatefulWidget {
  @override
  _KategorilerState createState() => _KategorilerState();
}

class _KategorilerState extends State<Kategoriler> {
  List<Kategori> tumKategoriler;
  DatabaseHelper databaseHelper;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    databaseHelper = DatabaseHelper();
  }

  @override
  Widget build(BuildContext context) {
    if (tumKategoriler == null) {
      tumKategoriler = List<Kategori>();
      kategoriListesiniGuncelle();
    } else {}

    return Scaffold(
      appBar: AppBar(
        title: Text("Kategoriler"),
      ),
      body: ListView.builder(
        itemCount: tumKategoriler.length,
        itemBuilder: (context, index) {
          return ListTile(
            onTap: ()=>_kategoriGuncelle(tumKategoriler[index],context),
            title: Text(tumKategoriler[index].kategoriBaslik),
            leading: Icon(Icons.portrait),
            trailing: InkWell(child: Icon(Icons.delete),onTap:()=> _kategoriSil(tumKategoriler[index].kategoriID),),


          );
        },
      ),
    );
  }

  void kategoriListesiniGuncelle() {
    databaseHelper.kategoriListesiniGetir().then((kategorileriIcerenList) {
      setState(() {
        tumKategoriler = kategorileriIcerenList;
      });
    });
  }

  _kategoriSil(int kategoriID) {
    showDialog(context: context,barrierDismissible: false,builder:(context){
      return Center(
        child: AlertDialog(title: Text("Kategori Siliniyor"),content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text("Bu kategoriyi sildiğinizde bununlaa ilgili tüm notlar da silinecektir. Emin misiniz?"),
            ButtonBar(children: <Widget>[
              FlatButton(onPressed: (){Navigator.of(context).pop();}, child: Text("Vazgeç",style: TextStyle(color: Colors.white),),color: Colors.green,),
              FlatButton(onPressed: (){
                databaseHelper.kategoriSil(kategoriID).then((silinenKategori){
                  if(silinenKategori != 0)
                    {
                      setState(() {
                        kategoriListesiniGuncelle();
                        Navigator.of(context).pop();
                      });
                    }
                });
              }, child: Text("Sil",style: TextStyle(color: Colors.white),),color: Colors.red,),
            ],)
          ],
        ),),
      );
    } );
  }

  _kategoriGuncelle(Kategori guncellenecekKategori,BuildContext context) {
  kategoriGuncelleDialog(context,guncellenecekKategori);
    }

void kategoriGuncelleDialog(BuildContext myContext, Kategori guncellenecekKategori){

  var formKey = GlobalKey<FormState>();
  String guncellenecekKategoriAdi="";

  showDialog(
    barrierDismissible: false,
    context: myContext,
    builder: (context) {
      return SimpleDialog(
        title: Text(
          "Kategori Düzenle",
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
                initialValue: guncellenecekKategori.kategoriBaslik,
                onSaved: (yeniDeger) {
                  guncellenecekKategoriAdi = yeniDeger;
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

                    databaseHelper.kategoriGuncelle(Kategori.withID(guncellenecekKategori.kategoriID, guncellenecekKategoriAdi)).then(
                        (katID){
                          if(katID != 0)
                            {
                              Scaffold.of(myContext).showSnackBar(
                                SnackBar(
                                  content: Text("Kategori güncellendi   : $katID"),
                                  duration: Duration(seconds: 1),
                                ),

                              );
                              kategoriListesiniGuncelle();
                              Navigator.pop(context);
                            }
                        });
                    /* databaseHelper
                            .kategoriEkle(Kategori(guncellenecekKategoriAdi))
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
                        });*/
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

}
