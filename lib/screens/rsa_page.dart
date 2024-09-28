import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/rsa_service.dart';
import 'full_content_page.dart';

class RSAPage extends StatefulWidget {
  const RSAPage({super.key});

  @override
  State createState() => _RSAPageState();
}

class _RSAPageState extends State<RSAPage> {
  final RSAService _rsaService = RSAService();
  String _selectedFilePath = '';
  String _outputFilePath = '';
  String _inputPreview = '';
  String _outputPreview = '';
  bool _isProcessed = false;
  bool _isEncrypted = false;
  Map<String, int> _publicKey = {};
  Map<String, int> _privateKey = {};

  @override
  void initState() {
    super.initState();
    _initializeKeys();
  }

  void _initializeKeys() {
    setState(() {
      _publicKey = _rsaService.publicKey;
      _privateKey = _rsaService.privateKey;
    });
  }

  Future<void> _selectFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt'],
    );

    if (result != null) {
      setState(() {
        _selectedFilePath = result.files.single.path!;
        _outputFilePath = '';
        _outputPreview = '';
        _isProcessed = false;
      });
      _generatePreview(_selectedFilePath, true);
    }
  }

  Future<void> _generatePreview(String filePath, bool isInput) async {
    try {
      final file = File(filePath);
      final lines = await file.readAsLines();
      final previewLines = lines.take(5).join('\n');
      setState(() {
        if (isInput) {
          _inputPreview = previewLines.substring(
              0, previewLines.length > 250 ? 250 : previewLines.length);
        } else {
          _outputPreview = previewLines.substring(
              0, previewLines.length > 250 ? 250 : previewLines.length);
        }
      });
    } catch (e) {
      showSnackBar(e.toString());
    }
  }

  showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 3),
    ));
  }

  Future<void> _processFile(bool encrypt) async {
    if (_selectedFilePath.isEmpty) {
      showSnackBar('Lütfen önce bir dosya seçin.');
      return;
    }

    try {
      String content = await File(_selectedFilePath).readAsString();
      String processedContent =
          encrypt ? _rsaService.encrypt(content) : _rsaService.decrypt(content);

      final fileName = encrypt ? 'encrypted.txt' : 'decrypted.txt';

      String? outputPath = await FilePicker.platform
          .saveFile(fileName: fileName, bytes: utf8.encode(processedContent));
      if (outputPath == null) throw PathAccessException;
      final outputFile = File(outputPath + fileName);
      await outputFile.writeAsString(processedContent);

      setState(() {
        _outputFilePath = outputFile.path;
        _isProcessed = true;
        _isEncrypted = encrypt;
      });
      _generatePreview(_outputFilePath, false);
      showSnackBar(
          '${encrypt ? 'Şifreleme' : 'Şifre çözme'} tamamlandı. Çıktı dosyası: $_outputFilePath');
    } on FormatException {
      showSnackBar('Şifre Çözülemiyor');
    } catch (e) {
      showSnackBar('Hata oluştu: $e');
    }
  }

  void _showFullContent(bool isInput) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullContentPage(
            filePath: isInput ? _selectedFilePath : _outputFilePath),
      ),
    );
  }

  String get _selectedFileName {
    return _selectedFilePath.split('/').last;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CupertinoColors.extraLightBackgroundGray,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildKeyDisplay(),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: CupertinoColors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: CupertinoColors.systemGrey4),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                          _selectedFilePath.isEmpty
                              ? 'Dosya seçilmedi'
                              : _selectedFileName,
                          style:
                              Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    color: _selectedFilePath.isEmpty
                                        ? CupertinoColors.systemGrey
                                        : CupertinoColors.black,
                                  )),
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: _selectFile,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.yellow[800],
                        borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                            topLeft: Radius.circular(2),
                            bottomLeft: Radius.circular(2)),
                      ),
                      child: Text(
                        'Dosya Seç',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 1,
                  )
                ],
              ),
            ),
            if (_inputPreview.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                "Seçilen Dosya:",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 5),
              _buildPreviewContainer(_inputPreview, true),
            ],
            if (_outputPreview.isNotEmpty && _isProcessed) ...[
              const SizedBox(height: 10),
              Text(
                _isEncrypted ? "Şifrelenmiş Dosya:" : "Çözülmüş Dosya:",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 5),
              _buildPreviewContainer(_outputPreview, false),
            ],
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    color: Colors.blue[800],
                    onPressed: () => _processFile(true),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.lock_outlined,
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          maxLines: 1,
                          'Şifrele',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    color: Colors.green[500],
                    onPressed: () => _processFile(false),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.lock_open_outlined,
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          maxLines: 1,
                          'Şifre Çöz',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyDisplay() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: CupertinoColors.systemGrey4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'RSA Anahtarları',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Public Key:',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Text('e: ${_publicKey['e']}'),
          Text('n: ${_publicKey['n']}'),
          const SizedBox(height: 8),
          Text(
            'Private Key:',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Text('d: ${_privateKey['d']}'),
          Text('n: ${_privateKey['n']}'),
        ],
      ),
    );
  }

  Widget _buildPreviewContainer(String preview, bool isInput) {
    return GestureDetector(
      onTap: () => _showFullContent(isInput),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(9)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                preview,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const Text('Tam içeriği görmek için tıklayın...',
                  style: TextStyle(color: Colors.blue)),
            ],
          ),
        ),
      ),
    );
  }
}
