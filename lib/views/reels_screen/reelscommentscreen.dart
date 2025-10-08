import 'package:flutter/material.dart';
import 'package:instagram/models/reel_model.dart';

class ReelCommentsScreen extends StatelessWidget {
  final ReelModel reel;

  const ReelCommentsScreen({super.key, required this.reel});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            height: 4,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: reel.comments,
              itemBuilder: (context, index) => ListTile(
                leading: const CircleAvatar(),
                title: Text("Comment ${index + 1} on ${reel.caption}"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
