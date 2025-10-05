import 'package:flutter/material.dart';
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
  final ScrollController _scrollController = ScrollController();
  late List<CommentModel> comments;
  bool _isPostingComment = false;

  @override
  void initState() {
    super.initState();
    // Load existing comments for this post
    comments = DummyData.getCommentsForPost(widget.post.id);
  }

  @override
  void dispose() {
    // Clean up controllers when screen is disposed
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Posts a new comment to the post
  void _postComment() {
    final text = _commentController.text.trim();

    // Don't post empty comments
    if (text.isEmpty) return;

    // Show loading state
    setState(() {
      _isPostingComment = true;
    });

    // Create new comment with unique ID based on timestamp
    final newComment = CommentModel(
      id: 'comment_${DateTime.now().millisecondsSinceEpoch}',
      userId: DummyData.currentUser.id,
      text: text,
      timeAgo: 'Just now',
      likes: 0,
      isLiked: false,
      // Mark as author if current user owns the post
      isAuthor: widget.post.userId == DummyData.currentUser.id,
    );

    // Add comment to the data store
    DummyData.addComment(widget.post.id, newComment);

    // Refresh comments list from data store
    setState(() {
      comments = DummyData.getCommentsForPost(widget.post.id);
      _isPostingComment = false;
    });

    // Clear the input field
    _commentController.clear();

    // Auto-scroll to bottom to show the new comment
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    // Hide keyboard
    FocusScope.of(context).unfocus();

    // Show success feedback to user
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Comment posted'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Inserts emoji at cursor position in text field
  void _onEmojiTap(String emoji) {
    final currentText = _commentController.text;
    final selection = _commentController.selection;

    // Check if there's a valid text selection/cursor position
    if (selection.isValid) {
      // Replace selected text or insert at cursor
      final newText = currentText.replaceRange(
        selection.start,
        selection.end,
        emoji,
      );
      _commentController.text = newText;
      // Move cursor after the inserted emoji
      _commentController.selection = TextSelection.collapsed(
        offset: selection.start + emoji.length,
      );
    } else {
      // No valid selection, append to end
      _commentController.text = currentText + emoji;
      _commentController.selection = TextSelection.collapsed(
        offset: _commentController.text.length,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9, // Opens at 90% of screen height
      minChildSize: 0.5, // Can be dragged down to 50%
      maxChildSize: 0.95, // Can be dragged up to 95%
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // ===== DRAG HANDLE =====
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // ===== HEADER WITH TITLE AND COUNT =====
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
                    // Display total comment count
                    Text(
                      '${widget.post.comments}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),

              // ===== COMMENTS LIST =====
              Expanded(
                child: comments.isEmpty
                    // Show empty state when no comments
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 64,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No comments yet',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Start the conversation.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    // Display list of comments
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          return _buildCommentItem(comments[index]);
                        },
                      ),
              ),

              // ===== EMOJI QUICK REACTIONS BAR =====
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

              // ===== COMMENT INPUT BOX =====
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Colors.grey[200]!)),
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      // User profile picture
                      CircleAvatar(
                        radius: 18,
                        backgroundImage: NetworkImage(
                          DummyData.currentUser.profileImage,
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Text input field
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
                            fillColor: Colors.grey[100],
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                          ),
                          maxLines: null, // Allows multi-line input
                          textCapitalization: TextCapitalization.sentences,
                          onSubmitted: (_) => _postComment(), // Submit on Enter
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Post button or loading indicator
                      if (_isPostingComment)
                        // Show loading spinner while posting
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      else
                        // Show Post button
                        ValueListenableBuilder(
                          valueListenable: _commentController,
                          builder: (context, value, child) {
                            final hasText = value.text.trim().isNotEmpty;
                            return GestureDetector(
                              onTap: hasText ? _postComment : null,
                              child: Text(
                                'Post',
                                style: TextStyle(
                                  // Blue when enabled, grey when disabled
                                  color: hasText ? Colors.blue : Colors.grey,
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

  /// Builds a tappable emoji button
  Widget _buildEmojiButton(String emoji) {
    return GestureDetector(
      onTap: () => _onEmojiTap(emoji),
      child: Text(emoji, style: const TextStyle(fontSize: 28)),
    );
  }

  /// Builds individual comment item widget
  Widget _buildCommentItem(CommentModel comment) {
    // Get user data for this comment
    final user = DummyData.getUserById(comment.userId);
    if (user == null) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User avatar
          CircleAvatar(
            radius: 18,
            backgroundImage: NetworkImage(user.profileImage),
          ),
          const SizedBox(width: 12),

          // Comment content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Username, time, and author badge
                Row(
                  children: [
                    Text(
                      user.username,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      comment.timeAgo,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    // Show "Author" badge if commenter is post owner
                    if (comment.isAuthor) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Author',
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),

                // Comment text
                Text(comment.text),
                const SizedBox(height: 4),

                // Reply button and like count
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {},
                      child: Text(
                        'Reply',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    // Show like count if greater than 0
                    if (comment.likes > 0) ...[
                      const SizedBox(width: 16),
                      Text(
                        '${comment.likes} ${comment.likes == 1 ? 'like' : 'likes'}',
                        style: TextStyle(
                          color: Colors.grey[600],
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

          // Like button
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
            child: Column(
              children: [
                Icon(
                  comment.isLiked ? Icons.favorite : Icons.favorite_border,
                  size: 16,
                  color: comment.isLiked ? Colors.red : Colors.grey,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
