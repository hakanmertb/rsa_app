import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FullContentPage extends StatefulWidget {
  final String filePath;

  const FullContentPage({super.key, required this.filePath});

  @override
  State createState() => _FullContentPageState();
}

class _FullContentPageState extends State<FullContentPage> {
  String _content = '';

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    try {
      final file = File(widget.filePath);
      final content = await file.readAsString();
      setState(() {
        _content = content;
      });
    } catch (e) {
      setState(() {
        _content = 'Dosya içeriği yüklenirken hata oluştu: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CupertinoColors.extraLightBackgroundGray,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Dosya İçeriği'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Text(_content),
      ),
    );
  }
}
