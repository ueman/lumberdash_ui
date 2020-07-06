import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:lumberdashui/src/ansi_parser.dart';
import 'package:lumberdashui/src/level.dart';
import 'package:lumberdashui/src/log_entry.dart';
import 'package:lumberdashui/src/lumberdash_ui_client.dart';

class LogConsole extends StatefulWidget {
  LogConsole({Key key}) : super(key: key);

  @override
  _LogConsoleState createState() => _LogConsoleState();
}

class RenderedEvent {
  final int id;
  final Level level;
  final TextSpan span;
  final String lowerCaseText;

  Color get color {
    switch (level) {
      case Level.message:
        return Colors.blue;
        break;
      case Level.warning:
        return Colors.yellow;
        break;
      case Level.fatal:
        return Colors.orange;
        break;
      case Level.error:
        return Colors.red;
        break;
    }
    throw Exception();
  }

  String get icon {
    switch (level) {
      case Level.message:
        return '💡';
        break;
      case Level.warning:
        return '⚠️';
        break;
      case Level.fatal:
        return '⛔️';
        break;
      case Level.error:
        return '💣';
        break;
    }
    throw Exception();
  }

  RenderedEvent(this.id, this.level, this.span, this.lowerCaseText);
}

class _LogConsoleState extends State<LogConsole> {
  Queue<RenderedEvent> _renderedBuffer = Queue();
  List<RenderedEvent> _filteredBuffer = [];

  var _scrollController = ScrollController();
  var _filterController = TextEditingController();

  Level _filterLevel = Level.message;
  double _logFontSize = 14;

  var _currentId = 0;
  bool _scrollListenerEnabled = true;
  bool _followBottom = true;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      if (!_scrollListenerEnabled) return;
      var scrolledToBottom = _scrollController.offset >=
          _scrollController.position.maxScrollExtent;
      setState(() {
        _followBottom = scrolledToBottom;
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _renderedBuffer.clear();
    for (var event in LumberdashUiClient.queue) {
      _renderedBuffer.add(_renderEvent(event));
    }
    _refreshFilter();
  }

  void _refreshFilter() {
    var newFilteredBuffer = _renderedBuffer.where((it) {
      var logLevelMatches = it.level.index >= _filterLevel.index;
      if (!logLevelMatches) {
        return false;
      } else if (_filterController.text.isNotEmpty) {
        var filterText = _filterController.text.toLowerCase();
        return it.lowerCaseText.contains(filterText);
      } else {
        return true;
      }
    }).toList();
    setState(() {
      _filteredBuffer = newFilteredBuffer;
    });

    if (_followBottom) {
      Future.delayed(Duration.zero, _scrollToBottom);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Log Console'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              setState(() {
                _logFontSize++;
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.remove),
            onPressed: () {
              setState(() {
                _logFontSize--;
              });
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: _buildLogContent(),
          ),
          _buildBottomBar(),
        ],
      ),
      floatingActionButton: AnimatedOpacity(
        opacity: _followBottom ? 0 : 1,
        duration: Duration(milliseconds: 150),
        child: Padding(
          padding: EdgeInsets.only(bottom: 60),
          child: FloatingActionButton(
            mini: true,
            clipBehavior: Clip.antiAlias,
            child: Icon(Icons.arrow_downward),
            onPressed: _scrollToBottom,
          ),
        ),
      ),
    );
  }

  Widget _buildLogContent() {
    return ListView.builder(
      shrinkWrap: true,
      controller: _scrollController,
      itemCount: _filteredBuffer.length,
      itemBuilder: (context, index) {
        var logEntry = _filteredBuffer[index];
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  logEntry.icon,
                  style: TextStyle(fontSize: 25),
                ),
              ),
              Text.rich(
                logEntry.span,
                key: Key(logEntry.id.toString()),
                style: TextStyle(fontSize: _logFontSize, color: logEntry.color),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      padding: EdgeInsets.only(left: 16, top: 16, right: 16),
      child: SafeArea(
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Expanded(
              child: TextField(
                style: TextStyle(fontSize: 20),
                controller: _filterController,
                onChanged: (s) => _refreshFilter(),
                decoration: InputDecoration(
                  labelText: "Filter log output",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(width: 20),
            DropdownButton(
              value: _filterLevel,
              items: [
                DropdownMenuItem(
                  child: Text("MESSAGE"),
                  value: Level.message,
                ),
                DropdownMenuItem(
                  child: Text("WARNING"),
                  value: Level.warning,
                ),
                DropdownMenuItem(
                  child: Text("FATAL"),
                  value: Level.fatal,
                ),
                DropdownMenuItem(
                  child: Text("ERROR"),
                  value: Level.error,
                ),
              ],
              onChanged: (value) {
                _filterLevel = value;
                _refreshFilter();
              },
            )
          ],
        ),
      ),
    );
  }

  void _scrollToBottom() async {
    _scrollListenerEnabled = false;

    setState(() {
      _followBottom = true;
    });

    var scrollPosition = _scrollController.position;
    await _scrollController.animateTo(
      scrollPosition.maxScrollExtent,
      duration: new Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );

    _scrollListenerEnabled = true;
  }

  RenderedEvent _renderEvent(LogEntry event) {
    final dark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    var parser = AnsiParser(dark);
    var text = event.lines.join('\n');
    parser.parse(text);
    return RenderedEvent(
      _currentId++,
      event.level,
      TextSpan(children: parser.spans),
      text.toLowerCase(),
    );
  }
}
