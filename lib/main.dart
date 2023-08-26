import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import "dart:math" as math;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Web with JS',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyKeyboardScrollingPage(),
    );
  }
}

class MyKeyboardScrollingPage extends StatefulWidget {
  @override
  _MyKeyboardScrollingPageState createState() =>
      _MyKeyboardScrollingPageState();
}

class _MyKeyboardScrollingPageState extends State<MyKeyboardScrollingPage> {
  final FocusNode _focusNode = FocusNode();
  final ScrollController _controller = ScrollController();
  int focusedCardIndex = 0;
  final cardHeight = 80.0;
  final cardWidth = 80.0;
  final columns = 4; // Number of columns in the GridView
  final List<String> items = [
    'Item 1',
    'Item 2',
    'Item 3',
    'Item 4',
    'Item 5',
    'Item 6',
    'Item 7',
    'Item 8',
    'Item 9',
    'Item 10',
  ];

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        RawKeyboard.instance.addListener(_handleKeyEvent);
      } else {
        RawKeyboard.instance.removeListener(_handleKeyEvent);
      }
    });
  }

  void _handleKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        _moveFocusAndScroll(-1);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        _moveFocusAndScroll(1);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        _moveFocusAndScroll(-columns);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        _moveFocusAndScroll(columns);
      }
    }
  }

  void _moveFocusAndScroll(int offset) {
    setState(() {
      focusedCardIndex = (focusedCardIndex + offset).clamp(0, items.length - 1);
      print(focusedCardIndex);
    });
    final rowCount = (items.length / columns).ceil();
    final newRow = (focusedCardIndex / columns).floor();
    print("newRow:  ${newRow}");
    final newScrollOffset =
        (newRow * cardHeight + 16) - (rowCount * cardHeight + 16);

    print("newScrollOffset:  ${newScrollOffset}");

    // _controller.animateTo(
    //   newScrollOffset,
    //   duration: Duration(milliseconds: 100),
    //   curve: Curves.easeInOut,
    // );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    RawKeyboard.instance.removeListener(_handleKeyEvent);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(_focusNode);
        },
        child: Center(
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
            ),
            controller: _controller,
            itemCount: items.length,
            itemBuilder: (context, index) {
              return Focus(
                focusNode: focusedCardIndex == index ? _focusNode : null,
                child: Card(
                  elevation: focusedCardIndex == index ? 8 : 4,
                  color: focusedCardIndex == index ? Colors.blue[100] : null,
                  child: Container(
                    width: cardWidth,
                    height: cardHeight,
                    child: ListTile(
                      title: Text(items[index]),
                      subtitle: Text('Subtitle for ${items[index]}'),
                      leading: Icon(Icons.star),
                      trailing: Icon(Icons.arrow_forward),
                      onTap: () {
                        print('Tapped on ${items[index]}');
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
