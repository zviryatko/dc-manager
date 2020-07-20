
import 'package:dc_manager/projects.dart';
import 'package:flutter/material.dart';
import 'package:window_size/window_size.dart';
import 'projects.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Docker Compose Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MainView(title: 'Docker Compose Manager'),
    );
  }
}

class MainView extends StatefulWidget {
  MainView({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(
          (_) {
            setWindowTitle(widget.title);
            setWindowMinSize(new Size(500.0, 800.0));
          },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        constraints: BoxConstraints(minWidth: 800.0),
        child: new Projects(),
      ),
    );
  }
}
