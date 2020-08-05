import 'package:flutter/material.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';

class ColorPickerDialog extends StatefulWidget {
  final Color initColor;

  ColorPickerDialog({this.initColor});

  @override
  _ColorPickerDialogState createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<ColorPickerDialog> {
  Color _selectedColor;

  @override
  void initState() {
    _selectedColor = widget.initColor;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Container(
        height: 200,
        child: MaterialColorPicker(
            onColorChange: (c) {
              setState(() {
                _selectedColor = c;
              });
            },
            selectedColor: _selectedColor),
      ),
      actions: [
        FlatButton(
          child: Text("Cancel"),
          onPressed: () => Navigator.pop(context, null),
        ),
        FlatButton(
          child: Text("Ok"),
          onPressed: () => Navigator.pop(context, _selectedColor),
        )
      ],
    );
  }
}
