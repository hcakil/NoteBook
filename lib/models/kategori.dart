

class Kategori {
  int kategoriID;
  String kategoriBaslik;

  Kategori( this.kategoriBaslik);//Kategori eklerken Id gereksiz Database autoincrement

  Kategori.withID(this.kategoriID, this.kategoriBaslik);//Databaseden veri okurken kullanılır.

  Map<String,dynamic> toMap(){
    var map = Map<String,dynamic>();
    map['kategoriID']=kategoriID;
    map['kategoriBaslik']=kategoriBaslik;
    return map;
  }
  //Şimdi de bunun tam tersi işlemi gerçekleştireceğiz
   Kategori.fromMap(Map<String,dynamic> map){
    this.kategoriID = map['kategoriID'];
    this.kategoriBaslik = map['kategoriBaslik'];
   }
  @override
  String toString() {
    // TODO: implement toString
    return "Kategori{ id:$kategoriID,  baslik : $kategoriBaslik}";
  }



}