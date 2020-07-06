# lumberdashui

A [lumberdash](https://pub.dev/packages/lumberdash) client wich shows the logs in a widget inside your app.

It shows the logs and can filter based on verbosity and it can search through your logs.

## Usage

```dart
putLumberdashToWork(withClients: [LumberdashUiClient()]);

// ...

// open log console
RaisedButton(
  child: Text('open log console'),
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
)
```
