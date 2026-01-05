import 'package:flutter/material.dart';
import '../../data/database_builder.dart';

/// Admin screen to add songs to database
class AddSongScreen extends StatefulWidget {
  const AddSongScreen({super.key});

  @override
  State<AddSongScreen> createState() => _AddSongScreenState();
}

class _AddSongScreenState extends State<AddSongScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _artistController = TextEditingController();
  final _albumController = TextEditingController();
  final _durationController = TextEditingController();
  final _audioPathController = TextEditingController();
  final _albumArtController = TextEditingController();
  final _lyricsController = TextEditingController();

  String _selectedGenre = 'Lo-Fi';
  String _selectedPlaylist = 'lofi';
  bool _isTimeSynced = false;

  @override
  void dispose() {
    _titleController.dispose();
    _artistController.dispose();
    _albumController.dispose();
    _durationController.dispose();
    _audioPathController.dispose();
    _albumArtController.dispose();
    _lyricsController.dispose();
    super.dispose();
  }

  Future<void> _saveSong() async {
    if (_formKey.currentState!.validate()) {
      try {
        final builder = DatabaseBuilder();
        await builder.addSong(
          title: _titleController.text,
          artist: _artistController.text,
          album: _albumController.text,
          duration: _durationController.text,
          audioPath: _audioPathController.text,
          albumArt: _albumArtController.text,
          genre: _selectedGenre,
          playlistId: _selectedPlaylist,
          lyricsText: _lyricsController.text,
          isTimeSynced: _isTimeSynced,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Song added successfully!')),
          );
          _clearForm();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('❌ Error: $e')));
        }
      }
    }
  }

  void _clearForm() {
    _titleController.clear();
    _artistController.clear();
    _albumController.clear();
    _durationController.clear();
    _audioPathController.clear();
    _albumArtController.clear();
    _lyricsController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Song')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Song Title *'),
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            ),
            TextFormField(
              controller: _artistController,
              decoration: const InputDecoration(labelText: 'Artist *'),
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            ),
            TextFormField(
              controller: _albumController,
              decoration: const InputDecoration(labelText: 'Album'),
            ),
            TextFormField(
              controller: _durationController,
              decoration: const InputDecoration(
                labelText: 'Duration (e.g., 3:45) *',
              ),
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            ),
            TextFormField(
              controller: _audioPathController,
              decoration: const InputDecoration(
                labelText: 'Audio Path *',
                hintText: 'assets/audio/lofi/song.mp3',
              ),
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            ),
            TextFormField(
              controller: _albumArtController,
              decoration: const InputDecoration(
                labelText: 'Album Art Path',
                hintText: 'assets/album_art/cover.jpg',
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedGenre,
              decoration: const InputDecoration(labelText: 'Genre'),
              items: [
                'Lo-Fi',
                'Pop',
                'Synthwave',
                'Rock',
                'Jazz',
              ].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
              onChanged: (v) => setState(() => _selectedGenre = v!),
            ),
            DropdownButtonFormField<String>(
              initialValue: _selectedPlaylist,
              decoration: const InputDecoration(labelText: 'Playlist'),
              items: [
                'lofi',
                'pop',
                'synthwave',
              ].map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
              onChanged: (v) => setState(() => _selectedPlaylist = v!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _lyricsController,
              decoration: const InputDecoration(labelText: 'Lyrics'),
              maxLines: 8,
            ),
            CheckboxListTile(
              title: const Text('Time-synced lyrics (LRC format)'),
              value: _isTimeSynced,
              onChanged: (v) => setState(() => _isTimeSynced = v ?? false),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _saveSong,
              icon: const Icon(Icons.save),
              label: const Text('Save Song'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
