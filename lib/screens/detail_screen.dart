import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:movieapp/bloc/get_movie_videos_bloc.dart';
import 'package:movieapp/database/db_helper.dart';
import 'package:movieapp/model/movie.dart';
import 'package:movieapp/model/movie_local.dart';
import 'package:movieapp/model/video.dart';
import 'package:movieapp/model/video_response.dart';
import 'package:movieapp/style/theme.dart' as Style;
import 'package:movieapp/widgets/casts.dart';

import 'package:movieapp/widgets/movie_info.dart';

import 'package:sliver_fab/sliver_fab.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'video_player.dart';

class MovieDetailScreen extends StatefulWidget {
  final Movie movie;
  MovieDetailScreen({Key key, @required this.movie}) : super(key: key);
  @override
  _MovieDetailScreenState createState() => _MovieDetailScreenState(movie);
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _commentEditController = TextEditingController();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final Movie movie;
  int _totalRateCount = 0;
  double _totalRating = 0;
  double _rating;
  bool _isVisible = false;

  _MovieDetailScreenState(this.movie);

  @override
  void initState() {
    super.initState();
    movieVideosBloc..getMovieVideos(movie.id);
    getRateById();
  }

  @override
  void dispose() {
    super.dispose();
    movieVideosBloc..drainStream();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Style.Colors.mainColor,
      body: new Builder(
        builder: (context) {
          return new SliverFab(
            floatingPosition: FloatingPosition(right: 20),
            floatingWidget: StreamBuilder<VideoResponse>(
              stream: movieVideosBloc.subject.stream,
              builder: (context, AsyncSnapshot<VideoResponse> snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data.error != null &&
                      snapshot.data.error.length > 0) {
                    return _buildErrorWidget(snapshot.data.error);
                  }
                  return _buildVideoWidget(snapshot.data);
                } else if (snapshot.hasError) {
                  return _buildErrorWidget(snapshot.error);
                } else {
                  return _buildLoadingWidget();
                }
              },
            ),
            expandedHeight: 200.0,
            slivers: <Widget>[
              new SliverAppBar(
                backgroundColor: Style.Colors.mainColor,
                expandedHeight: 200.0,
                pinned: true,
                flexibleSpace: new FlexibleSpaceBar(
                    title: Text(
                      movie.title.length > 40
                          ? movie.title.substring(0, 37) + "..."
                          : movie.title,
                      style: TextStyle(
                          fontSize: 12.0, fontWeight: FontWeight.normal),
                    ),
                    background: Stack(
                      children: <Widget>[
                        Container(
                          decoration: new BoxDecoration(
                            shape: BoxShape.rectangle,
                            image: new DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage(
                                    "https://image.tmdb.org/t/p/original/" +
                                        movie.backPoster)),
                          ),
                          child: new Container(
                            decoration: new BoxDecoration(
                                color: Colors.black.withOpacity(0.5)),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                stops: [
                                  0.1,
                                  0.9
                                ],
                                colors: [
                                  Colors.black.withOpacity(0.9),
                                  Colors.black.withOpacity(0.0)
                                ]),
                          ),
                        ),
                      ],
                    )),
              ),
              SliverPadding(
                  padding: EdgeInsets.all(0.0),
                  sliver: SliverList(
                      delegate: SliverChildListDelegate([
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0, top: 20.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            meanString(),
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.0,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            width: 5.0,
                          ),
                          RatingBar.builder(
                            itemSize: 17.0,
                            initialRating: meanDouble(), //fire get
                            minRating: 1,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 10,
                            itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                            tapOnlyMode: true,
                            itemBuilder: (context, _) => Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            onRatingUpdate: (rating) {
                              setState(() {
                                _rating = rating;
                              });
                              saveRate(_rating);
                            },
                          ),
                          IconButton(
                              onPressed: addWatchList,
                              icon: Icon(
                                Icons.favorite_border,
                                color: Colors.pinkAccent,
                                size: 25,
                              )),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0, top: 20.0),
                      child: Text(
                        "OVERVIEW",
                        style: TextStyle(
                            color: Style.Colors.titleColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 12.0),
                      ),
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        movie.overview,
                        style: TextStyle(
                            color: Colors.white, fontSize: 12.0, height: 1.5),
                      ),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    MovieInfo(
                      id: movie.id,
                    ),
                    Casts(
                      id: movie.id,
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: Colors.lime[200],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          )),
                      onPressed: () {
                        setState(() {
                          _isVisible = !_isVisible;
                        });
                      },
                      child: Wrap(
                        children: <Widget>[
                          Icon(
                            Icons.comment_sharp,
                            color: Colors.white,
                            size: 25,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text("Comments",
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Style.Colors.secondColor)),
                        ],
                      ),
                    ),
                    Visibility(
                        maintainSize: true,
                        maintainAnimation: true,
                        maintainState: true,
                        visible: _isVisible,
                        child: SingleChildScrollView(
                            child: Container(
                          height: 200,
                          child: StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('comments')
                                  .where('movie_id', isEqualTo: movie.id)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  return Center(
                                    child: CircularProgressIndicator(
                                      backgroundColor: Colors.lightBlueAccent,
                                    ),
                                  );
                                }
                                if (!snapshot.hasData) {
                                  return Center(
                                    child: CircularProgressIndicator(
                                      backgroundColor: Colors.lightBlueAccent,
                                    ),
                                  );
                                }
                                // else if (snapshot.hasData) {
                                //   return Text(
                                //       snapshot.data.docs[0]['${movie.id}']);
                                // }
                                List<DocumentSnapshot> listOfComment =
                                    snapshot.data.docs;
                                return Expanded(
                                    child: Column(
                                  children: [
                                    SizedBox(
                                      height: 150,
                                      child: ListView.builder(
                                          itemCount: listOfComment.length,
                                          itemBuilder: (context, index) {
                                            return Card(
                                              color: Colors.lime[100],
                                              elevation: 2.0,
                                              child: ListTile(
                                                title: Text(
                                                  '${listOfComment[index]['comment']}',
                                                ),
                                                subtitle: Text(
                                                  '${listOfComment[index]['email']}',
                                                ),
                                              ),
                                            );
                                          }),
                                    ),
                                  ],
                                ));
                              }),
                        ))),
                    Container(
                      margin: EdgeInsets.only(left: 16.0),
                      child: TextFormField(
                        key: _formKey,
                        controller: _commentEditController,
                        keyboardType: TextInputType.text,
                        textAlign: TextAlign.center,
                        cursorColor: Colors.white,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                              onPressed: saveComment,
                              icon: Icon(
                                Icons.send_sharp,
                                color: Colors.white,
                                size: 25,
                              )),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          labelText: 'Write a comment...',
                          focusColor: Colors.white,
                          fillColor: Colors.white,
                          labelStyle: TextStyle(color: Colors.white),
                        ),
                        validator: (value) =>
                            value.isNotEmpty ? 'Comment cannot be blank' : null,
                      ),
                    ),
                  ])))
            ],
          );
        },
      ),
    );
  }

  String meanString() {
    if (_totalRating != 0) {
      return (_totalRating / _totalRateCount).toStringAsFixed(1);
    } else {
      return 0.toString();
    }
  }

  double meanDouble() {
    if (_totalRating != 0) {
      return (_totalRating / _totalRateCount).toDouble();
    } else {
      return 0.toDouble();
    }
  }

  getRateById() async {
    _totalRateCount = 0;
    _totalRating = 0;
    await FirebaseFirestore.instance
        .collection('ratings')
        .get()
        .then((movieId) {
      for (var element in movieId.docs) {
        if (element.data()['${movie.id}'] != null) {
          setState(() {
            _totalRateCount++;
            _totalRating += element.data()['${movie.id}'];
          });

          //print(element.data()['${movie.id}']);
        }
      }
    });
  }

  Widget _buildLoadingWidget() {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [],
    ));
  }

  Widget _buildErrorWidget(String error) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Error occured: $error"),
      ],
    ));
  }

  Widget _buildVideoWidget(VideoResponse data) {
    List<Video> videos = data.videos;
    return FloatingActionButton(
      backgroundColor: Style.Colors.secondColor,
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoPlayerScreen(
              controller: YoutubePlayerController(
                initialVideoId: videos[0].key,
                flags: YoutubePlayerFlags(
                  autoPlay: true,
                  mute: true,
                ),
              ),
            ),
          ),
        );
      },
      child: Icon(Icons.play_arrow),
    );
  }

  Future<void> addWatchList() async {
    await DbHelper.instance
        .insertMovie(
            MovieLocal(movie.id, movie.title, movie.poster, movie.overview))
        .then((result) {
      if (result == -1) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('The movie could not be add $result')));
      } else if (result == 0) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('The movie already Added')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('The movie Added Succesfully $result')));
      }
    });
  }

  Future<void> saveRate(double rating) async {
    await FirebaseFirestore.instance
        .collection('ratings')
        .doc(_firebaseAuth.currentUser.email)
        .set({movie.id.toString(): rating}, SetOptions(merge: true)).then(
            (value) {
      getRateById();
    });
  }

  Future<void> saveComment() async {
    if (_commentEditController.text.isNotEmpty) {
      await FirebaseFirestore.instance.collection('comments').doc().set({
        'movie_id': movie.id,
        'comment': _commentEditController.text,
        'email': FirebaseAuth.instance.currentUser.email
      }).whenComplete(() => _commentEditController.clear());
    }
  }
}
