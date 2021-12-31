import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:movieapp/screens/watchlist_screen.dart';
import 'package:movieapp/style/theme.dart' as Style;
import 'package:movieapp/widgets/best_movies.dart';
import 'package:movieapp/widgets/genres.dart';
import 'package:movieapp/widgets/now_playing.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'Login_Screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
_signOut() async {
  await _firebaseAuth.signOut();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Style.Colors.mainColor,
      appBar: AppBar(
        backgroundColor: Style.Colors.mainColor,
        centerTitle: true,
        leading: IconButton(
            onPressed: goToWatchList,
            icon: Icon(
              Icons.playlist_add_check,
              color: Style.Colors.secondColor,
              size: 25,
            )),
        title: Text("Discover"), //${_firebaseAuth.currentUser.email}
        actions: <Widget>[
          IconButton(
              onPressed: () async {
                await _signOut();
                if (_firebaseAuth.currentUser == null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                }
              },
              icon: Icon(
                EvaIcons.logOut,
                color: Colors.white,
              ))
        ],
      ),
      body: ListView(
        children: <Widget>[
          NowPlaying(),
          GenresScreen(),
          BestMovies(),
        ],
      ),
    );
  }

  Future<void> goToWatchList() async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) => WatchListScreen()));
  }
}
