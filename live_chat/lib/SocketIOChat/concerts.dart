class Concert {
  int id;
  String concertname;

  Concert({this.id,this.concertname});

  factory Concert.fromJson(Map<String,dynamic> json){
    return Concert(
      id: json["id"] as int,
      concertname: json["name"] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "concertname": concertname,
  };
}