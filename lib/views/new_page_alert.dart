import 'package:flutter/material.dart';

class newPageAlert extends StatelessWidget {
  newPageAlert({
    super.key,
  });

  final TextEditingController _controller = TextEditingController();
  final FocusNode _todoInputFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    FocusScope.of(context).requestFocus(_todoInputFocusNode);
    return AlertDialog(
      title: const Text('Enter New Page Name'),
      content: TextField(
        focusNode: _todoInputFocusNode,
        controller: _controller,
        onSubmitted: (value) {
          if (value.isNotEmpty) {
            Navigator.pop(context, value);
            Navigator.pop(context, value);
          }
        },
      ),
      actions: [
        TextButton(
            onPressed: () {
              if (_controller.text.isEmpty) return;

              Navigator.pop<String>(context, _controller.text);
              Navigator.pop(context);
            },
            child: const Text('Confirm')),
        ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'))
      ],
    );
  }
}
