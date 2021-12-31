import 'package:flutter/material.dart';
import 'package:movieapp/database/db_helper.dart';
import 'package:movieapp/model/movie_local.dart';
import 'package:movieapp/style/theme.dart' as Style;

// ignore: must_be_immutable
class MovieCell extends StatefulWidget {
  final List<MovieLocal> movies;
  final int i;

  MovieCell(this.movies, this.i);

  @override
  State<MovieCell> createState() => _MovieCellState();
}

class _MovieCellState extends State<MovieCell> {
  Color mainColor = const Color(0xff3C3261);

  var imageUrl = "https://image.tmdb.org/t/p/original/";

  Widget build(BuildContext context) {
    return new Column(
      children: <Widget>[
        new Row(
          children: <Widget>[
            new Padding(
              padding: const EdgeInsets.all(0.0),
              child: new Container(
                margin: const EdgeInsets.all(16.0),
                child: new Container(
                  width: 90.0,
                  height: 140.0,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Colors.grey,
                  image: DecorationImage(
                      image: NetworkImage(
                          imageUrl + widget.movies[widget.i].poster),
                      fit: BoxFit.cover),
                  boxShadow: [
                    new BoxShadow(
                        color: mainColor,
                        blurRadius: 5.0,
                        offset: Offset(2.0, 5.0))
                  ],
                ),
              ),
            ),
            Expanded(
                child: Container(
              margin: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
              child: Column(
                children: [
                  IconButton(
                      padding: EdgeInsets.only(left: 155),
                      onPressed: removeFromWatchList,
                      icon: Icon(
                        Icons.delete_outlined,
                        color: Style.Colors.secondColor,
                        size: 25,
                      )),
                  Text(
                    widget.movies[widget.i].title,
                    style: new TextStyle(
                        fontSize: 20.0,
                        fontFamily: 'Arvo',
                        fontWeight: FontWeight.bold,
                        color: mainColor),
                  ),
                  new Padding(padding: const EdgeInsets.all(2.0)),
                  new Text(
                    widget.movies[widget.i].overview,
                    maxLines: 15,
                    style: new TextStyle(
                        color: const Color(0xff8785A4), fontFamily: 'Arvo'),
                  )
                ],
                crossAxisAlignment: CrossAxisAlignment.start,
              ),
            )),
          ],
        ),
        new Container(
          width: 300.0,
          height: 0.5,
          color: const Color(0xD2D2E1ff),
          margin: const EdgeInsets.all(16.0),
        )
      ],
    );
  }

  Future<void> removeFromWatchList() async {
    await DbHelper.instance
        .deleteMovie(widget.movies[widget.i].id)
        .then((result) {
      if (result == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('The movie could not be delete $result')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('The movie delete Succesfully $result')));
      }
    });
  }
}
