import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';

class VoiceRecorderApp extends StatefulWidget {
  const VoiceRecorderApp({Key? key}) : super(key: key);

  @override
  _VoiceRecorderAppState createState() => _VoiceRecorderAppState();
}

class _VoiceRecorderAppState extends State<VoiceRecorderApp> {
  bool _isRecording = false;
  final _audioRecorder = AudioRecorder();
  final _audioPlayer = AudioPlayer();
  List<FileSystemEntity> _recordings = [];
  String? _currentRecordingPath;
  String? _currentPlayingPath;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _loadRecordings();
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.microphone,
      Permission.storage,
    ].request();
  }

  Future<void> _loadRecordings() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final recordingsDir = Directory('${directory.path}/recordings');
      
      if (!await recordingsDir.exists()) {
        await recordingsDir.create(recursive: true);
      }
      
      final files = await recordingsDir.list().toList();
      setState(() {
        _recordings = files.where((file) => file.path.endsWith('.m4a')).toList();
      });
    } catch (e) {
      print('Error loading recordings: $e');
    }
  }

  Future<void> _startRecording() async {
    try {
      if (await Permission.microphone.isGranted) {
        final directory = await getApplicationDocumentsDirectory();
        final recordingsDir = Directory('${directory.path}/recordings');
        
        if (!await recordingsDir.exists()) {
          await recordingsDir.create(recursive: true);
        }
        
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        _currentRecordingPath = '${recordingsDir.path}/recording_$timestamp.m4a';
        
        await _audioRecorder.start(
          RecordConfig(
            encoder: AudioEncoder.aacLc,
            bitRate: 128000,
            sampleRate: 44100,
          ),
          path: _currentRecordingPath!,
        );
        
        setState(() {
          _isRecording = true;
        });
      } else {
        print('Microphone permission not granted');
      }
    } catch (e) {
      print('Error starting recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
      });
      _loadRecordings();
    } catch (e) {
      print('Error stopping recording: $e');
    }
  }

  Future<void> _playRecording(String path) async {
    try {
      if (_isPlaying) {
        await _audioPlayer.stop();
      }
      
      await _audioPlayer.play(DeviceFileSource(path));
      setState(() {
        _isPlaying = true;
        _currentPlayingPath = path;
      });
      
      _audioPlayer.onPlayerComplete.listen((event) {
        setState(() {
          _isPlaying = false;
          _currentPlayingPath = null;
        });
      });
    } catch (e) {
      print('Error playing recording: $e');
    }
  }

  Future<void> _deleteRecording(String path) async {
    try {
      final file = File(path);
      await file.delete();
      _loadRecordings();
    } catch (e) {
      print('Error deleting recording: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Recorder'),
      ),
      body: Column(
        children: [
          // Recording button
          Container(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton(
              onPressed: _isRecording ? _stopRecording : _startRecording,
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(24),
                backgroundColor: _isRecording ? Colors.red : Colors.blue,
              ),
              child: Icon(
                _isRecording ? Icons.stop : Icons.mic,
                size: 36,
                color: Colors.white,
              ),
            ),
          ),
          
          // Status text
          Text(
            _isRecording ? 'Recording...' : 'Tap the button to start recording',
            style: const TextStyle(fontSize: 16),
          ),
          
          const SizedBox(height: 20),
          
          // Recordings list
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Recordings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          
          Expanded(
            child: _recordings.isEmpty
                ? const Center(child: Text('No recordings yet'))
                : ListView.builder(
                    itemCount: _recordings.length,
                    itemBuilder: (context, index) {
                      final recording = _recordings[index];
                      final fileName = recording.path.split('/').last;
                      final isPlaying = _currentPlayingPath == recording.path && _isPlaying;
                      
                      return ListTile(
                        leading: Icon(isPlaying ? Icons.pause_circle : Icons.play_circle, size: 36),
                        title: Text(fileName),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteRecording(recording.path),
                        ),
                        onTap: () => _playRecording(recording.path),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}