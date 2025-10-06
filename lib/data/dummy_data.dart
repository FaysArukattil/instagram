import '../models/user_model.dart';
import '../models/post_model.dart';
import '../models/story_model.dart';
import '../models/comment_model.dart';

class DummyData {
  // Add this to your DummyData class in dummy_data.dart

  static final Map<String, List<Map<String, dynamic>>> chatMessages = {
    'user_3': [
      {
        'text': 'Inganonnm avooleykm lle',
        'isSent': false,
        'time': '21 Jun, 11:39 pm',
        'type': 'text',
        'showTime': true,
      },
      {
        'type': 'reel',
        'username': 'tasty.treks_',
        'time': 'Today 2:17 pm',
        'isSent': false,
        'imageUrl':
            'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400',
      },
      {'text': 'Hi', 'isSent': true, 'time': 'Today 2:17 pm', 'type': 'text'},
      {
        'text': 'Hello',
        'isSent': true,
        'time': 'Today 2:17 pm',
        'type': 'text',
      },
      {
        'text': 'How are you',
        'isSent': true,
        'time': 'Today 2:17 pm',
        'type': 'text',
      },
      {
        'text': 'Xbsbbsbs',
        'isSent': true,
        'time': 'Today 2:18 pm',
        'type': 'text',
        'showHint': true,
      },
      {
        'text': 'Abcd',
        'isSent': false,
        'time': 'Today 2:20 pm',
        'type': 'text',
      },
      {'text': 'Efg', 'isSent': false, 'time': 'Today 2:20 pm', 'type': 'text'},
    ],
    'user_4': [
      {
        'text': 'Hello where you at?',
        'isSent': false,
        'time': '3d ago',
        'type': 'text',
        'showTime': true,
      },
      {
        'text': 'I\'m at home',
        'isSent': true,
        'time': '3d ago',
        'type': 'text',
      },
      {
        'text': 'Coming to meet you',
        'isSent': false,
        'time': '3d ago',
        'type': 'text',
      },
    ],
    'user_2': [
      {
        'text': 'Mentioned you in a story',
        'isSent': false,
        'time': '1w ago',
        'type': 'text',
        'showTime': true,
      },
      {'text': 'Thanks bro!', 'isSent': true, 'time': '1w ago', 'type': 'text'},
    ],
    'user_8': [
      {
        'text': 'Assignment submission date?',
        'isSent': false,
        'time': '4w ago',
        'type': 'text',
        'showTime': true,
      },
      {'text': 'Next Monday', 'isSent': true, 'time': '4w ago', 'type': 'text'},
      {'text': 'Thanks!', 'isSent': false, 'time': '4w ago', 'type': 'text'},
    ],
    'user_7': [
      {
        'type': 'reel',
        'username': 'kashmir_reels',
        'time': '4w ago',
        'isSent': false,
        'imageUrl':
            'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400',
        'showTime': true,
      },
      {
        'text': 'Beautiful place!',
        'isSent': true,
        'time': '4w ago',
        'type': 'text',
      },
    ],
    'user_12': [
      {
        'type': 'reel',
        'username': 'fitness_freak',
        'time': '4w ago',
        'isSent': false,
        'imageUrl':
            'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400',
        'showTime': true,
      },
      {
        'text': 'Great workout tips!',
        'isSent': true,
        'time': '4w ago',
        'type': 'text',
      },
    ],
    'user_9': [
      {
        'text': 'Hey, long time!',
        'isSent': false,
        'time': '6w ago',
        'type': 'text',
        'showTime': true,
      },
      {
        'text': 'Yeah! How have you been?',
        'isSent': true,
        'time': '6w ago',
        'type': 'text',
      },
    ],
    'user_5': [
      {
        'text': 'Check this post',
        'isSent': false,
        'time': '8w ago',
        'type': 'text',
        'showTime': true,
      },
      {
        'text': 'Will check it out',
        'isSent': true,
        'time': '8w ago',
        'type': 'text',
      },
    ],
    'user_11': [
      {
        'text': 'Hi! I love your travel content',
        'isSent': false,
        'time': '2w ago',
        'type': 'text',
        'showTime': true,
      },
    ],
  };

  static List<Map<String, dynamic>> getChatMessages(String userId) {
    return chatMessages[userId] ?? [];
  }

  static final UserModel currentUser = UserModel(
    id: 'user_1',
    username: 'FaysAruka',
    name: 'Fays Arukattil',
    profileImage:
        'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
    hasStory: true,
    followers: 543,
    following: 432,
    posts: 78,
  );

  static final List<UserModel> users = [
    UserModel(
      id: 'user_2',
      username: 'sayyid_hussain_shihab',
      name: 'Sayyid Hussain Shihab',
      profileImage:
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
      hasStory: true,
      followers: 1234,
      following: 567,
      posts: 89,
      bio: 'Panakkad',
      isFollowing: true,
    ),
    UserModel(
      id: 'user_3',
      username: 'foodie4.ever',
      name: 'Foodie Forever',
      profileImage:
          'https://images.unsplash.com/photo-1599566150163-29194dcaad36?w=150',
      hasStory: true,
      followers: 2341,
      following: 432,
      posts: 156,
      bio: 'Food lover 🍔',
      isFollowing: false,
    ),
    UserModel(
      id: 'user_4',
      username: 'mohammed.uvais.thennala',
      name: 'Mohammed Uvais',
      profileImage:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
      hasStory: true,
      followers: 987,
      following: 234,
      posts: 67,
      bio: 'Thennala',
      isFollowing: true,
    ),
    UserModel(
      id: 'user_5',
      username: '_gopeesh_007',
      name: 'Gopeesh',
      profileImage:
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
      hasStory: true,
      followers: 7335,
      following: 4822,
      posts: 109,
      isOnline: false,
      lastSeen: '36 m',
    ),
    UserModel(
      id: 'user_6',
      username: 'mallu_boyys',
      name: 'Mallu Boys',
      profileImage:
          'https://images.unsplash.com/photo-1614680376593-902f74cf0d41?w=150',
      hasStory: true,
      isOnline: false,
      lastSeen: '36 m',
      followers: 5621,
      following: 892,
      posts: 234,
    ),
    UserModel(
      id: 'user_7',
      username: 'kashmir_reels',
      name: 'Kashmir Reels',
      profileImage:
          'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=150',
      hasStory: true,
      isOnline: false,
      lastSeen: '16 m',
      followers: 12456,
      following: 234,
      posts: 567,
      bio: 'Kashmir ki kahaniyan 🏔️',
    ),
    UserModel(
      id: 'user_8',
      username: 'cse_a_batch',
      name: 'CSE A',
      profileImage:
          'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150',
      hasStory: true,
      isOnline: true,
      followers: 456,
      following: 123,
      posts: 89,
    ),
    UserModel(
      id: 'user_9',
      username: '10th_katta_chunkz',
      name: '10th Katta',
      profileImage:
          'https://images.unsplash.com/photo-1463453091185-61582044d556?w=150',
      hasStory: true,
      followers: 892,
      following: 456,
      posts: 134,
    ),
    UserModel(
      id: 'user_10',
      username: 'fuhad_arang',
      name: 'Fuhad Arang',
      profileImage:
          'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=150',
      hasStory: true,
      isOnline: false,
      lastSeen: '16 m',
      followers: 1567,
      following: 678,
      posts: 234,
    ),
    UserModel(
      id: 'user_11',
      username: 'travel_diaries',
      name: 'Travel Diaries',
      profileImage:
          'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150',
      hasStory: true,
      followers: 8934,
      following: 234,
      posts: 456,
      bio: 'Exploring the world 🌍',
    ),
    UserModel(
      id: 'user_12',
      username: 'fitness_freak',
      name: 'Fitness Guru',
      profileImage:
          'https://images.unsplash.com/photo-1566492031773-4f4e44671857?w=150',
      hasStory: true,
      followers: 15234,
      following: 567,
      posts: 789,
      bio: 'No pain, no gain 💪',
    ),
    UserModel(
      id: 'user_13',
      username: 'tech_enthusiast',
      name: 'Tech Lover',
      profileImage:
          'https://images.unsplash.com/photo-1531427186611-ecfd6d936c79?w=150',
      hasStory: true,
      followers: 6789,
      following: 432,
      posts: 345,
      bio: 'Coding | AI | Tech Reviews',
    ),
    UserModel(
      id: 'user_14',
      username: 'nature_photography',
      name: 'Nature Clicks',
      profileImage:
          'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=150',
      hasStory: true,
      followers: 23456,
      following: 891,
      posts: 1234,
      bio: 'Capturing nature 📸🌿',
    ),
    UserModel(
      id: 'user_15',
      username: 'art_gallery',
      name: 'Art Gallery',
      profileImage:
          'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150',
      hasStory: true,
      followers: 9876,
      following: 234,
      posts: 567,
      bio: 'Art is life 🎨',
    ),
  ];

  static final List<PostModel> posts = [
    PostModel(
      id: 'post_1',
      userId: 'user_2',
      images: [
        'https://images.unsplash.com/photo-1449824913935-59a10b8d2000?w=800',
      ],
      caption: 'Beautiful sunset at Thamarasseri Churam 🌅',
      likes: 1234,
      comments: 4,
      timeAgo: '59m',
      location: 'Thamarasseri Churam',
      isLiked: false,
    ),
    PostModel(
      id: 'post_2',
      userId: 'user_6',
      images: [
        'https://images.unsplash.com/photo-1541643600914-78b084683601?w=800',
        'https://images.unsplash.com/photo-1592945403244-b3fbafd7f539?w=800',
      ],
      caption:
          'Purple Mystique\nMake your loved ones special with MYOP personalised perfumes.',
      likes: 5432,
      comments: 234,
      timeAgo: '2h',
      isLiked: false,
      isSponsored: true,
    ),
    PostModel(
      id: 'post_3',
      userId: 'user_3',
      images: [
        'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800',
      ],
      caption: 'Mountain views 🏔️',
      likes: 892,
      comments: 34,
      timeAgo: '5h',
      isLiked: true,
    ),
    PostModel(
      id: 'post_4',
      userId: 'user_11',
      images: [
        'https://images.unsplash.com/photo-1488646953014-85cb44e25828?w=800',
      ],
      caption: 'Wanderlust and city dust ✈️',
      likes: 2341,
      comments: 87,
      timeAgo: '6h',
      location: 'Dubai, UAE',
      isLiked: false,
    ),
    PostModel(
      id: 'post_5',
      userId: 'user_12',
      images: [
        'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800',
        'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=800',
      ],
      caption: 'Push yourself because no one else is going to do it for you 💪',
      likes: 4567,
      comments: 156,
      timeAgo: '8h',
      isLiked: true,
    ),
    PostModel(
      id: 'post_6',
      userId: 'user_7',
      images: [
        'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800',
      ],
      caption: 'Heaven on earth 🏔️❄️',
      likes: 8923,
      comments: 345,
      timeAgo: '10h',
      location: 'Gulmarg, Kashmir',
      isLiked: false,
    ),
    PostModel(
      id: 'post_7',
      userId: 'user_13',
      images: [
        'https://images.unsplash.com/photo-1498050108023-c5249f4df085?w=800',
      ],
      caption: 'Code. Compile. Debug. Repeat. 💻',
      likes: 1234,
      comments: 67,
      timeAgo: '12h',
      isLiked: false,
    ),
    PostModel(
      id: 'post_8',
      userId: 'user_14',
      images: [
        'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?w=800',
        'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=800',
        'https://images.unsplash.com/photo-1469474968028-56623f02e42e?w=800',
      ],
      caption: 'Nature never goes out of style 🌲🌿',
      likes: 12456,
      comments: 456,
      timeAgo: '15h',
      isLiked: true,
    ),
    PostModel(
      id: 'post_9',
      userId: 'user_15',
      images: [
        'https://images.unsplash.com/photo-1513364776144-60967b0f800f?w=800',
      ],
      caption: 'Art speaks where words are unable to explain 🎨',
      likes: 3456,
      comments: 123,
      timeAgo: '18h',
      isLiked: false,
    ),
    PostModel(
      id: 'post_10',
      userId: 'user_4',
      images: [
        'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800',
      ],
      caption: 'Beach vibes 🌊☀️',
      likes: 2134,
      comments: 89,
      timeAgo: '20h',
      location: 'Kovalam Beach',
      isLiked: true,
    ),
    PostModel(
      id: 'post_11',
      userId: 'user_5',
      images: [
        'https://images.unsplash.com/photo-1551218808-94e220e084d2?w=800',
      ],
      caption: 'Good times and tan lines 😎',
      likes: 5678,
      comments: 234,
      timeAgo: '1d',
      isLiked: false,
    ),
    PostModel(
      id: 'post_12',
      userId: 'user_8',
      images: [
        'https://images.unsplash.com/photo-1523580494863-6f3031224c94?w=800',
        'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=800',
      ],
      caption: 'Squad goals 🎓👨‍💻',
      likes: 892,
      comments: 45,
      timeAgo: '1d',
      location: 'College Campus',
      isLiked: true,
    ),
    PostModel(
      id: 'post_13',
      userId: 'user_9',
      images: [
        'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?w=800',
      ],
      caption: 'Friends who slay together, stay together 💯',
      likes: 1567,
      comments: 78,
      timeAgo: '1d',
      isLiked: false,
    ),
    PostModel(
      id: 'post_14',
      userId: 'user_10',
      images: [
        'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=800',
      ],
      caption: 'Food is my love language 🍕🍔',
      likes: 3421,
      comments: 156,
      timeAgo: '2d',
      isLiked: true,
    ),
    PostModel(
      id: 'post_15',
      userId: 'user_11',
      images: [
        'https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?w=800',
        'https://images.unsplash.com/photo-1530789253388-582c481c54b0?w=800',
      ],
      caption: 'Take only memories, leave only footprints 👣',
      likes: 6789,
      comments: 267,
      timeAgo: '2d',
      location: 'Munnar',
      isLiked: false,
    ),
    PostModel(
      id: 'post_16',
      userId: 'user_12',
      images: [
        'https://images.unsplash.com/photo-1549060279-7e168fcee0c2?w=800',
      ],
      caption: 'Stronger than yesterday 💪🔥',
      likes: 4532,
      comments: 189,
      timeAgo: '2d',
      isLiked: true,
    ),
    PostModel(
      id: 'post_17',
      userId: 'user_13',
      images: [
        'https://images.unsplash.com/photo-1519389950473-47ba0277781c?w=800',
      ],
      caption: 'Innovation distinguishes between a leader and a follower 🚀',
      likes: 2341,
      comments: 98,
      timeAgo: '3d',
      isLiked: false,
    ),
    PostModel(
      id: 'post_18',
      userId: 'user_14',
      images: [
        'https://images.unsplash.com/photo-1472214103451-9374bd1c798e?w=800',
        'https://images.unsplash.com/photo-1426604966848-d7adac402bff?w=800',
      ],
      caption:
          'In every walk with nature, one receives far more than he seeks 🌲',
      likes: 9876,
      comments: 423,
      timeAgo: '3d',
      isLiked: true,
    ),
    PostModel(
      id: 'post_19',
      userId: 'user_15',
      images: [
        'https://images.unsplash.com/photo-1460661419201-fd4cecdf8a8b?w=800',
      ],
      caption: 'Creativity is intelligence having fun 🎨✨',
      likes: 5432,
      comments: 234,
      timeAgo: '3d',
      isLiked: false,
    ),
    PostModel(
      id: 'post_20',
      userId: 'user_2',
      images: [
        'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=800',
      ],
      caption: 'Adventure awaits 🏔️⛰️',
      likes: 3456,
      comments: 145,
      timeAgo: '4d',
      location: 'Wayanad',
      isLiked: true,
    ),
  ];

  static final List<StoryModel> stories = [
    StoryModel(
      id: 'story_1',
      userId: 'user_2',
      image:
          'https://images.unsplash.com/photo-1449824913935-59a10b8d2000?w=400',
      timeAgo: '2h',
    ),
    StoryModel(
      id: 'story_2',
      userId: 'user_3',
      image:
          'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400',
      timeAgo: '4h',
    ),
    StoryModel(
      id: 'story_3',
      userId: 'user_4',
      image:
          'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=400',
      timeAgo: '5h',
    ),
    StoryModel(
      id: 'story_4',
      userId: 'user_5',
      image: 'https://images.unsplash.com/photo-1551218808-94e220e084d2?w=400',
      timeAgo: '6h',
    ),
    StoryModel(
      id: 'story_5',
      userId: 'user_6',
      image:
          'https://images.unsplash.com/photo-1541643600914-78b084683601?w=400',
      timeAgo: '8h',
    ),
    StoryModel(
      id: 'story_6',
      userId: 'user_7',
      image:
          'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400',
      timeAgo: '10h',
    ),
    StoryModel(
      id: 'story_7',
      userId: 'user_8',
      image:
          'https://images.unsplash.com/photo-1523580494863-6f3031224c94?w=400',
      timeAgo: '12h',
    ),
    StoryModel(
      id: 'story_8',
      userId: 'user_9',
      image:
          'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?w=400',
      timeAgo: '14h',
    ),
    StoryModel(
      id: 'story_9',
      userId: 'user_10',
      image:
          'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400',
      timeAgo: '16h',
    ),
    StoryModel(
      id: 'story_10',
      userId: 'user_11',
      image:
          'https://images.unsplash.com/photo-1488646953014-85cb44e25828?w=400',
      timeAgo: '18h',
    ),
    StoryModel(
      id: 'story_11',
      userId: 'user_12',
      image:
          'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400',
      timeAgo: '20h',
    ),
    StoryModel(
      id: 'story_12',
      userId: 'user_13',
      image:
          'https://images.unsplash.com/photo-1498050108023-c5249f4df085?w=400',
      timeAgo: '22h',
    ),
    StoryModel(
      id: 'story_13',
      userId: 'user_14',
      image:
          'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?w=400',
      timeAgo: '23h',
    ),
    StoryModel(
      id: 'story_14',
      userId: 'user_15',
      image:
          'https://images.unsplash.com/photo-1513364776144-60967b0f800f?w=400',
      timeAgo: '1d',
    ),
  ];

  static final Map<String, List<CommentModel>> postComments = {
    'post_1': [
      CommentModel(
        id: 'comment_1',
        userId: 'user_3',
        text: 'Mashallah😍',
        timeAgo: '1d',
        likes: 1,
      ),
      CommentModel(
        id: 'comment_2',
        userId: 'user_2',
        text: '@foodie4.ever 🌻🤍',
        timeAgo: '1d',
        isAuthor: true,
      ),
      CommentModel(
        id: 'comment_3',
        userId: 'user_4',
        text: '❤️',
        timeAgo: '2d',
      ),
      CommentModel(
        id: 'comment_4',
        userId: 'user_2',
        text: '😍',
        timeAgo: '2d',
        isAuthor: true,
      ),
    ],
  };

  static UserModel? getUserById(String userId) {
    if (userId == currentUser.id) return currentUser;
    try {
      return users.firstWhere((user) => user.id == userId);
    } catch (e) {
      return null;
    }
  }

  static List<CommentModel> getCommentsForPost(String postId) {
    return postComments[postId] ?? [];
  }

  // Add a new comment to a post
  static void addComment(String postId, CommentModel comment) {
    if (postComments.containsKey(postId)) {
      postComments[postId]!.add(comment);
    } else {
      postComments[postId] = [comment];
    }

    // Update the post's comment count
    final postIndex = posts.indexWhere((post) => post.id == postId);
    if (postIndex != -1) {
      posts[postIndex].comments++;
    }
  }
}
