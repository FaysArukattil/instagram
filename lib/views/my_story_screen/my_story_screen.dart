import 'package:flutter/material.dart';

class MyStoryScreen extends StatelessWidget {
  const MyStoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> dummyImages = [
      'https://picsum.photos/id/1011/400/400',
      'https://picsum.photos/id/1015/400/400',
      'https://picsum.photos/id/1016/400/400',
      'https://picsum.photos/id/1025/400/400',
      'https://picsum.photos/id/1027/400/400',
      'https://picsum.photos/id/1035/400/400',
      'https://picsum.photos/id/1043/400/400',
      'https://picsum.photos/id/1049/400/400',
      'https://picsum.photos/id/1052/400/400',
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Add to story',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Cards
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                _storyCard("Templates", "Add yours", Colors.pink),
                _storyCard("AI images", "NEW", Colors.blue),
              ],
            ),
          ),

          // Recents + Select
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recents',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Select',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          // Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(4),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: dummyImages.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  // Camera Tile
                  return Container(
                    color: Colors.black,
                    child: const Center(
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  );
                }
                return Image.network(dummyImages[index - 1], fit: BoxFit.cover);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _storyCard(String title, String tag, Color color) {
    return Expanded(
      child: Container(
        height: 70,
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1C),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.image, color: Colors.white, size: 26),
                  const SizedBox(height: 5),
                  Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 6,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  tag,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
