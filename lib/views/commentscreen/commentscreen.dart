import 'package:flutter/material.dart';
import 'package:instagram/core/constants/app_colors.dart';
import 'package:instagram/data/dummy_data.dart';
import 'package:instagram/models/comment_model.dart';
import 'package:instagram/models/post_model.dart';

class CommentsScreen extends StatefulWidget {
  final PostModel post;

  const CommentsScreen({super.key, required this.post});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final TextEditingController _commentController = TextEditingController();
  late List<CommentModel> _comments;

  @override
  void initState() {
    super.initState();
    _comments = List.from(DummyData.getCommentsForPost(widget.post.id));
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _addComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final newComment = CommentModel(
      id: 'comment_${DateTime.now().millisecondsSinceEpoch}',
      userId: DummyData.currentUser.id,
      text: text,
      timeAgo: 'Just now',
      isAuthor: widget.post.userId == DummyData.currentUser.id,
    );

    setState(() {
      _comments.insert(0, newComment);
      _commentController.clear();
    });

    // Save to DummyData and persist
    DummyData.addComment(widget.post.id, newComment);

    // Unfocus keyboard
    // ignore: use_build_context_synchronously
    FocusScope.of(context).unfocus();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Comment added'),
          duration: Duration(seconds: 1),
          backgroundColor: AppColors.green,
        ),
      );
    }
  }

  void _likeComment(int index) {
    setState(() {
      _comments[index].likes++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.grey300!)),
            ),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: AppColors.grey300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Text(
                  'Comments',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // Comments List
          Expanded(
            child: _comments.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 80,
                          color: AppColors.grey300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No comments yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: AppColors.grey600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Start the conversation',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.grey500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _comments.length,
                    itemBuilder: (context, index) {
                      final comment = _comments[index];
                      final commentUser = DummyData.getUserById(comment.userId);

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Profile Picture
                            CircleAvatar(
                              radius: 18,
                              backgroundImage: NetworkImage(
                                commentUser?.profileImage ?? '',
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Comment Content
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        commentUser?.username ?? 'Unknown',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        comment.timeAgo,
                                        style: TextStyle(
                                          color: AppColors.grey600,
                                          fontSize: 12,
                                        ),
                                      ),
                                      if (comment.isAuthor) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.grey200,
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: const Text(
                                            'Author',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.grey,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    comment.text,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () => _likeComment(index),
                                        child: Text(
                                          'Reply',
                                          style: TextStyle(
                                            color: AppColors.grey600,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      if (comment.likes > 0) ...[
                                        const SizedBox(width: 16),
                                        Text(
                                          '${comment.likes} ${comment.likes == 1 ? "like" : "likes"}',
                                          style: TextStyle(
                                            color: AppColors.grey600,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Like Button
                            IconButton(
                              icon: Icon(
                                Icons.favorite_border,
                                size: 16,
                                color: AppColors.grey600,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () => _likeComment(index),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          // Comment Input
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border(top: BorderSide(color: AppColors.grey300!)),
            ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 8,
            ),
            child: SafeArea(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundImage: NetworkImage(
                      DummyData.currentUser.profileImage,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: 'Add a comment...',
                        hintStyle: TextStyle(color: AppColors.grey500),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _addComment,
                    child: Text(
                      'Post',
                      style: TextStyle(
                        color: _commentController.text.trim().isEmpty
                            ? AppColors.blue200
                            : AppColors.blue,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
