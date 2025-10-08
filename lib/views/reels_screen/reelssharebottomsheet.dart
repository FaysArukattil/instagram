import 'package:flutter/material.dart';
import 'package:instagram/models/reel_model.dart';

class ReelShareBottomSheet extends StatelessWidget {
  final ReelModel reel;

  const ReelShareBottomSheet({super.key, required this.reel});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
          ListTile(
            leading: const Icon(Icons.send),
            title: const Text("Send Reel"),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text("Reel sent!")));
            },
          ),
        ],
      ),
    );
  }
}
