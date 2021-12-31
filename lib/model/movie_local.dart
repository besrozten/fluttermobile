class MovieLocal {
  final int id;
  final String title;
  final String poster;
  final String overview;

  MovieLocal(
    this.id,
    this.title,
    this.poster,
    this.overview,
  );

  Map<String, dynamic> toMovieMap() {
    var map = <String, dynamic>{
      'id': id,
      'title': title,
      'poster_path': poster,
      'overview': overview
    };
    return map;
  }

  MovieLocal.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        title = json["title"],
        poster = json["poster_path"],
        overview = json["overview"];
}
