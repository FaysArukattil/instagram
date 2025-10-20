import 'package:flutter/material.dart';
import 'package:instagram/core/constants/app_colors.dart';
import 'package:instagram/data/dummy_data.dart';
import 'package:instagram/models/comment_model.dart';
import 'package:instagram/models/reel_model.dart';

class ReelCommentsScreen extends StatefulWidget {
  final ReelModel reel;

  const ReelCommentsScreen({super.key, required this.reel});

  @override
  State<ReelCommentsScreen> createState() => _ReelCommentsScreenState();
}

class _ReelCommentsScreenState extends State<ReelCommentsScreen> {
  final TextEditingController _commentController = TextEditingController();
  late ScrollController _sheetScrollController;
  late List<CommentModel> comments;
  bool _isPostingComment = false;

  @override
  void initState() {
    super.initState();
    // Load existing comments for this reel (uses DummyData.postComments map)
    comments = DummyData.getCommentsForPost(widget.reel.id);
  }

  @override
  void dispose() {
    _commentController.dispose();
    // _sheetScrollController is managed by the DraggableScrollableSheet (don't dispose here)
    super.dispose();
  }

  void _postComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isPostingComment = true;
    });

    final newComment = CommentModel(
      id: 'comment_${DateTime.now().millisecondsSinceEpoch}',
      userId: DummyData.currentUser.id,
      text: text,
      timeAgo: 'Just now',
      likes: 0,
      isLiked: false,
      isAuthor: widget.reel.userId == DummyData.currentUser.id,
    );

    // Add to the central map (works even if key wasn't present previously)
    DummyData.addComment(widget.reel.id, newComment);

    // update local list and reel counter
    setState(() {
      comments = DummyData.getCommentsForPost(widget.reel.id);
      widget.reel.comments++; // increment reel comment count for UI consistency
      _isPostingComment = false;
    });

    // clear input
    _commentController.clear();

    // scroll to bottom to show newly posted comment
    Future.delayed(const Duration(milliseconds: 150), () {
      try {
        if (_sheetScrollController.hasClients) {
          _sheetScrollController.animateTo(
            _sheetScrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      } catch (_) {}
    });

    // hide keyboard
    FocusScope.of(context).unfocus();

    // feedback
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Comment posted'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onEmojiTap(String emoji) {
    final currentText = _commentController.text;
    final selection = _commentController.selection;

    if (selection.isValid) {
      final newText = currentText.replaceRange(
        selection.start,
        selection.end,
        emoji,
      );
      _commentController.text = newText;
      _commentController.selection = TextSelection.collapsed(
        offset: selection.start + emoji.length,
      );
    } else {
      _commentController.text = currentText + emoji;
      _commentController.selection = TextSelection.collapsed(
        offset: _commentController.text.length,
      );
    }
  }

  Widget _buildEmojiButton(String emoji) {
    return GestureDetector(
      onTap: () => _onEmojiTap(emoji),
      child: Text(emoji, style: const TextStyle(fontSize: 28)),
    );
  }

  Widget _buildCommentItem(CommentModel comment) {
    final user = DummyData.getUserById(comment.userId);
    if (user == null) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundImage: NetworkImage(user.profileImage),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      user.username,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      comment.timeAgo,
                      style: const TextStyle(
                        color: AppColors.grey,
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
                          border: Border.all(color: AppColors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Author',
                          style: TextStyle(fontSize: 10, color: AppColors.grey),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(comment.text),
                const SizedBox(height: 6),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {},
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
                        '${comment.likes} ${comment.likes == 1 ? 'like' : 'likes'}',
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
          GestureDetector(
            onTap: () {
              setState(() {
                comment.isLiked = !comment.isLiked;
                if (comment.isLiked) {
                  comment.likes++;
                } else {
                  comment.likes--;
                }
              });
            },
            child: Icon(
              comment.isLiked ? Icons.favorite : Icons.favorite_border,
              size: 16,
              color: comment.isLiked ? AppColors.red : AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        // keep reference so post scroll animation works
        _sheetScrollController = scrollController;

        return Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // drag handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grey300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Comments',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${widget.reel.comments}',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.grey600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              // comments list
              Expanded(
                child: comments.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 64,
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
                              'Start the conversation.',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.grey500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: comments.length,
                        itemBuilder: (context, index) =>
                            _buildCommentItem(comments[index]),
                      ),
              ),
              // emoji quick bar
              Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildEmojiButton('❤️'),
                    const SizedBox(width: 12),
                    _buildEmojiButton('🙌'),
                    const SizedBox(width: 12),
                    _buildEmojiButton('🔥'),
                    const SizedBox(width: 12),
                    _buildEmojiButton('👏'),
                    const SizedBox(width: 12),
                    _buildEmojiButton('😢'),
                    const SizedBox(width: 12),
                    _buildEmojiButton('😍'),
                    const SizedBox(width: 12),
                    _buildEmojiButton('😮'),
                    const SizedBox(width: 12),
                    _buildEmojiButton('😂'),
                  ],
                ),
              ),
              // input
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  border: Border(top: BorderSide(color: AppColors.grey200!)),
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
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          decoration: InputDecoration(
                            hintText: 'Add a comment...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: AppColors.grey100,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                          ),
                          maxLines: null,
                          textCapitalization: TextCapitalization.sentences,
                          onSubmitted: (_) => _postComment(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (_isPostingComment)
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      else
                        ValueListenableBuilder<TextEditingValue>(
                          valueListenable: _commentController,
                          builder: (context, value, child) {
                            final hasText = value.text.trim().isNotEmpty;
                            return GestureDetector(
                              onTap: hasText ? _postComment : null,
                              child: Text(
                                'Post',
                                style: TextStyle(
                                  color: hasText
                                      ? AppColors.blue
                                      : AppColors.grey,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
