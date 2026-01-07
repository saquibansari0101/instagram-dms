import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Defaults
  bool _hideHome = true;
  bool _hideExplore = true;
  bool _hideReels = true;
  bool _hideStories = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _hideHome = prefs.getBool('hide_home') ?? true;
      _hideExplore = prefs.getBool('hide_explore') ?? true;
      _hideReels = prefs.getBool('hide_reels') ?? true;
      // _hideStories = prefs.getBool('hide_stories') ?? false; // Future
    });
  }

  Future<void> _saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Distraction Control",
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          SwitchListTile(
            title: const Text(
              "Hide Feed (Home)",
              style: TextStyle(color: Colors.white),
            ),
            subtitle: const Text(
              "Hides the main feed and home button",
              style: TextStyle(color: Colors.grey),
            ),
            value: _hideHome,
            onChanged: (val) {
              setState(() => _hideHome = val);
              _saveSetting('hide_home', val);
            },
            activeColor: Colors.purpleAccent,
          ),
          SwitchListTile(
            title: const Text(
              "Hide Explore",
              style: TextStyle(color: Colors.white),
            ),
            subtitle: const Text(
              "Hides the search/explore tab",
              style: TextStyle(color: Colors.grey),
            ),
            value: _hideExplore,
            onChanged: (val) {
              setState(() => _hideExplore = val);
              _saveSetting('hide_explore', val);
            },
            activeColor: Colors.purpleAccent,
          ),
          SwitchListTile(
            title: const Text(
              "Hide Reels",
              style: TextStyle(color: Colors.white),
            ),
            subtitle: const Text(
              "Hides the reels tab",
              style: TextStyle(color: Colors.grey),
            ),
            value: _hideReels,
            onChanged: (val) {
              setState(() => _hideReels = val);
              _saveSetting('hide_reels', val);
            },
            activeColor: Colors.purpleAccent,
          ),
          const Divider(color: Colors.grey),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Note: Changes require a page reload to take full effect.",
              style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }
}
