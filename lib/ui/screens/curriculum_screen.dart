import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_state.dart';
import 'practice_screen.dart';

class CurriculumScreen extends ConsumerWidget {
  const CurriculumScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(isDarkModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ASL Curriculum',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              ref.read(isDarkModeProvider.notifier).toggle();
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionHeader('Basics'),
          _buildCurriculumCard(
            context,
            ref,
            'Alphabet',
            'Learn the fundamental ASL alphabet.',
            0,
          ),
          _buildCurriculumCard(
            context,
            ref,
            'Vowels',
            'Master the core vowel shapes.',
            1,
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Intermediate'),
          _buildCurriculumCard(
            context,
            ref,
            'Core Phrases',
            'Everyday greetings and phrases.',
            2,
            isLocked: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildCurriculumCard(
    BuildContext context,
    WidgetRef ref,
    String title,
    String subtitle,
    int index, {
    bool isLocked = false,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        leading: CircleAvatar(
          backgroundColor: isLocked ? Colors.grey.shade400 : Colors.blueAccent,
          child: Icon(
            isLocked ? Icons.lock : Icons.play_arrow,
            color: Colors.white,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: isLocked ? null : const Icon(Icons.chevron_right),
        onTap: isLocked
            ? null
            : () {
                // In a real app, 'index' would map to specific dictionary sets.
                // For now, we reset the current sign and go to practice.
                ref.read(currentSignIndexProvider.notifier).setSign(0);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PracticeScreen(),
                  ),
                );
              },
      ),
    );
  }
}
