import 'package:flutter/material.dart';
import 'package:movieapp/database/db_helper.dart';
import 'package:movieapp/model/movie_local.dart';
import 'package:movieapp/screens/home_screen.dart';
import 'package:movieapp/style/theme.dart' as Style;
import 'package:movieapp/widgets/movie_cell.dart';

class WatchListScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _WatchListScreenState();
}

class _WatchListScreenState extends State<WatchListScreen> {
  List<MovieLocal> movies;
  int movieCount = 0;

  void get() {
    DbHelper.instance.getMovies().then((result) {
      setState(() {
        movies = result;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    get();
    return Scaffold(
      backgroundColor: Style.Colors.mainColor,
      appBar: AppBar(
        elevation: 0.3,
        centerTitle: true,
        backgroundColor: Style.Colors.mainColor,
        leading: IconButton(
            onPressed: goHome,
            icon: Icon(
              Icons.arrow_back_ios_new_outlined,
              color: Colors.white,
              size: 25,
            )),
        title: Text(
          'Watch List',
          style: new TextStyle(
              color: Style.Colors.titleColor,
              fontFamily: 'Arvo',
              fontWeight: FontWeight.bold),
        ),
      ),
      body: new Padding(
        padding: const EdgeInsets.all(16.0),
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            //new MovieTitle(mainColor),
            Expanded(
              child: new ListView.builder(
                  itemCount: movies == null ? 0 : movies.length,
                  itemBuilder: (context, i) {
                    return MovieCell(movies, i);
                  }),
            )
          ],
        ),
      ),
    );
  }

  Future<void> goHome() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (contex) => HomeScreen(),
      ),
    );
  }
}
