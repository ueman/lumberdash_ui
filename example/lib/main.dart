import 'package:flutter/material.dart';
import 'package:lumberdash/lumberdash.dart';
import 'package:lumberdashui/lumberdashui.dart';

void main() {
  putLumberdashToWork(withClients: [LumberdashUiClient()]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              child: Text('Log message'),
              onPressed: () {
                logMessage('Example message');
              },
            ),
            RaisedButton(
              child: Text('Log warning'),
              onPressed: () {
                logWarning('Example warning');
              },
            ),
            RaisedButton(
              child: Text('Log fatal'),
              onPressed: () {
                logFatal('Example fatal');
              },
            ),
            RaisedButton(
              child: Text('Log exception'),
              onPressed: () {
                try {
                  throw Exception('Sample exception');
                } catch (e, stacktrace) {
                  logError(e, stacktrace: stacktrace);
                }
              },
            ),
            RaisedButton(
              child: Text('open console'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return LogConsole();
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
