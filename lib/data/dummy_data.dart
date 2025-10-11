import '../models/user_model.dart';
import '../models/post_model.dart';
import '../models/story_model.dart';
import '../models/comment_model.dart';
import '../models/reel_model.dart';

class DummyData {
  static final List<ReelModel> reels = [
    ReelModel(
      id: 'reel_1',
      userId: 'user_2',
      videoUrl:
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1449824913935-59a10b8d2000?w=800',
      caption: 'Beautiful sunset views 🌅 #nature #sunset',
      likes: 15234,
      comments: 234,
      shares: 45,
      timeAgo: '2h',
      location: 'Thamarasseri Churam',
    ),
    ReelModel(
      id: 'reel_2',
      userId: 'user_3',
      videoUrl:
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=800',
      caption: 'Trying new recipes today! 🍕🔥',
      likes: 8923,
      comments: 156,
      shares: 89,
      timeAgo: '5h',
    ),
    ReelModel(
      id: 'reel_3',
      userId: 'user_11',
      videoUrl:
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1488646953014-85cb44e25828?w=800',
      caption: 'Travel vibes ✈️ #wanderlust',
      likes: 23456,
      comments: 567,
      shares: 234,
      timeAgo: '8h',
      location: 'Dubai, UAE',
    ),
    ReelModel(
      id: 'reel_4',
      userId: 'user_12',
      videoUrl:
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800',
      caption: 'Workout motivation 💪 #fitness #gym',
      likes: 34567,
      comments: 892,
      shares: 156,
      timeAgo: '12h',
    ),
    ReelModel(
      id: 'reel_5',
      userId: 'user_7',
      videoUrl:
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800',
      caption: 'Kashmir beauty 🏔️❄️',
      likes: 45678,
      comments: 1234,
      shares: 567,
      timeAgo: '1d',
      location: 'Gulmarg, Kashmir',
    ),
    ReelModel(
      id: 'reel_6',
      userId: 'user_13',
      videoUrl:
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1498050108023-c5249f4df085?w=800',
      caption: 'Coding life 💻 #developer',
      likes: 12345,
      comments: 234,
      shares: 78,
      timeAgo: '1d',
    ),
    ReelModel(
      id: 'reel_7',
      userId: 'user_14',
      videoUrl:
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?w=800',
      caption: 'Nature therapy 🌲🌿',
      likes: 56789,
      comments: 1567,
      shares: 345,
      timeAgo: '2d',
    ),
    ReelModel(
      id: 'reel_8',
      userId: 'user_15',
      videoUrl:
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1513364776144-60967b0f800f?w=800',
      caption: 'Art in motion 🎨✨',
      likes: 23456,
      comments: 678,
      shares: 123,
      timeAgo: '2d',
    ),
    ReelModel(
      id: 'reel_9',
      userId: 'user_4',
      videoUrl:
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/SubaruOutbackOnStreetAndDirt.mp4',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800',
      caption: 'Beach life 🌊☀️',
      likes: 34567,
      comments: 891,
      shares: 234,
      timeAgo: '3d',
      location: 'Kovalam Beach',
    ),
    ReelModel(
      id: 'reel_10',
      userId: 'user_5',
      videoUrl:
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1551218808-94e220e084d2?w=800',
      caption: 'Living my best life 😎',
      likes: 45678,
      comments: 1234,
      shares: 456,
      timeAgo: '3d',
    ),
  ];

  // Add helper methods
  static List<ReelModel> getReelsForUser(String userId) {
    return reels.where((reel) => reel.userId == userId).toList();
  }

  static void addRepost(String reelId, String currentUserId) {
    final reelIndex = reels.indexWhere((r) => r.id == reelId);
    if (reelIndex != -1) {
      reels[reelIndex].isReposted = true;
      reels[reelIndex].shares++;

      // Create a reposted reel entry for current user
      // You can implement this based on your requirements
    }
  }

  static final Map<String, List<Map<String, dynamic>>> chats = {
    // Chat with user_1
    "user_1": [
      {
        'text': "Hey, did you check the new reel I posted?",
        'isMe': false,
        'time': "Yesterday",
      },
      {
        'text': "Yeah! 🔥🔥 that was awesome!",
        'isMe': true,
        'time': "Yesterday",
        'seen': true,
      },
      {'text': "Thanks man 😄", 'isMe': false, 'time': "Yesterday"},
      {'text': "When are we meeting?", 'isMe': false, 'time': "Today 1:15 pm"},
    ],

    // Chat with user_2
    "user_2": [
      {
        'text': "Bro, are you coming to football today?",
        'isMe': false,
        'time': "Today 10:30 am",
      },
      {
        'text': "Not sure yet, bit busy 🫠",
        'isMe': true,
        'time': "Today 10:32 am",
        'seen': false,
      },
      {
        'text': "Come on, we need you as goalie 😂",
        'isMe': false,
        'time': "Today 10:35 am",
      },
    ],

    // Chat with user_3
    "user_3": [
      {
        'text': "Morning 🌞",
        'isMe': true,
        'time': "Today 8:15 am",
        'seen': true,
      },
      {
        'text': "Morning! Did you finish the assignment?",
        'isMe': false,
        'time': "Today 8:20 am",
      },
      {
        'text': "Almost, will send it tonight.",
        'isMe': true,
        'time': "Today 8:45 am",
        'seen': false,
      },
    ],

    // Chat with user_4
    "user_4": [
      {
        'text': "Happy Birthday 🥳🎂🎉",
        'isMe': true,
        'time': "2 days ago",
        'seen': true,
      },
      {'text': "Thank you so much ❤️", 'isMe': false, 'time': "2 days ago"},
      {
        'text': "Did you like the surprise gift?",
        'isMe': true,
        'time': "Yesterday",
        'seen': false,
      },
    ],

    // Chat with user_5
    "user_5": [
      {
        'text': "Let’s plan a trip next weekend ✈️",
        'isMe': false,
        'time': "Monday",
      },
      {
        'text': "I’m in! Where are we going?",
        'isMe': true,
        'time': "Monday",
        'seen': true,
      },
      {'text': "Maybe Manali or Goa 😎", 'isMe': false, 'time': "Monday"},
      {
        'text': "Goa sounds perfect! 🏖️",
        'isMe': true,
        'time': "Monday",
        'seen': false,
      },
    ],
  };

  // Add this to your dummy_data.dart file - REPLACE the existing users list and followingMap

  static UserModel currentUser = UserModel(
    id: 'user_1',
    username: 'FaysAruka',
    name: 'Fays Arukattil',
    profileImage:
        'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
    hasStory: true,
    followers: 37, // Will be calculated dynamically
    following: 30, // Will be calculated dynamically
    posts: 78,
  );

  // Helper method to get actual follower count
  static int getFollowerCount(String userId) {
    int count = 0;
    followingMap.forEach((key, value) {
      if (value.contains(userId)) {
        count++;
      }
    });
    return count;
  }

  // Helper method to get actual following count
  static int getFollowingCount(String userId) {
    return followingMap[userId]?.length ?? 0;
  }

  // Helper method to get friends count (mutual followers)
  static int getFriendsCount(String userId) {
    final following = followingMap[userId] ?? [];
    int friendsCount = 0;

    for (String followingUserId in following) {
      final theirFollowing = followingMap[followingUserId] ?? [];
      if (theirFollowing.contains(userId)) {
        friendsCount++;
      }
    }

    return friendsCount;
  }

  // Extended followingMap - user_1 (current user) relationships
  static Map<String, List<String>> followingMap = {
    // Current user follows these people
    'user_1': [
      'user_2',
      'user_3',
      'user_5',
      'user_7',
      'user_8',
      'user_10',
      'user_12',
      'user_14',
      'user_16',
      'user_18',
      'user_20',
      'user_22',
      'user_24',
      'user_26',
      'user_28',
      'user_30',
      'user_32',
      'user_34',
      'user_36',
      'user_38',
      'user_40',
      'user_42',
      'user_44',
      'user_46',
      'user_48',
      'user_50',
      'user_52',
      'user_54',
      'user_56',
      'user_58',
    ],

    // These users follow current user back (mutual - friends)
    'user_2': ['user_1'],
    'user_5': ['user_1'],
    'user_8': ['user_1'],
    'user_12': ['user_1'],
    'user_16': ['user_1'],
    'user_20': ['user_1'],
    'user_24': ['user_1'],
    'user_28': ['user_1'],

    // These users follow current user but current user doesn't follow back
    'user_4': ['user_1'],
    'user_6': ['user_1'],
    'user_9': ['user_1'],
    'user_11': ['user_1'],
    'user_13': ['user_1'],
    'user_15': ['user_1'],
    'user_17': ['user_1'],
    'user_19': ['user_1'],
    'user_21': ['user_1'],
    'user_23': ['user_1'],
    'user_25': ['user_1'],
    'user_27': ['user_1'],
    'user_29': ['user_1'],
    'user_31': ['user_1'],
    'user_33': ['user_1'],
    'user_35': ['user_1'],
    'user_37': ['user_1'],
    'user_39': ['user_1'],
    'user_41': ['user_1'],
    'user_43': ['user_1'],
    'user_45': ['user_1'],
    'user_47': ['user_1'],
    'user_49': ['user_1'],
    'user_51': ['user_1'],
    'user_53': ['user_1'],
    'user_55': ['user_1'],
    'user_57': ['user_1'],
    'user_59': ['user_1'],
    'user_60': ['user_1'],
  };

  static final List<UserModel> users = [
    // Original users
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
      isFollowing: true,
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
      isFollowing: true,
    ),
    UserModel(
      id: 'user_6',
      username: 'mallu_boyys',
      name: 'Mallu Boys',
      profileImage:
          'https://images.unsplash.com/photo-1614680376593-902f74cf0d41?w=150',
      hasStory: true,
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
      followers: 12456,
      following: 234,
      posts: 567,
      bio: 'Kashmir ki kahaniyan 🏔️',
      isFollowing: true,
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
      isFollowing: true,
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
      isFollowing: true,
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
      isFollowing: true,
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
      isFollowing: true,
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

    // NEW USERS - More followers and following
    UserModel(
      id: 'user_16',
      username: 'ishan_shbn',
      name: 'Ishan Shabin',
      profileImage:
          'https://images.unsplash.com/photo-1527980965255-d3b416303d12?w=150',
      followers: 892,
      following: 345,
      posts: 123,
      bio: 'Photographer 📷',
      isFollowing: true,
      gender: 'Not specified',
    ),
    UserModel(
      id: 'user_17',
      username: 'amarxch',
      name: 'Amar Chand',
      profileImage:
          'https://images.unsplash.com/photo-1628157588553-5eeea00af15c?w=150',
      followers: 567,
      following: 234,
      posts: 89,
      gender: 'Not specified',
    ),
    UserModel(
      id: 'user_18',
      username: '_j_k_v_',
      name: 'Jaseem Kv',
      profileImage:
          'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=150',
      followers: 1234,
      following: 567,
      posts: 156,
      isFollowing: true,
      gender: 'Not specified',
    ),
    UserModel(
      id: 'user_19',
      username: 'vah_id._',
      name: 'عبد الواحد',
      profileImage:
          'https://images.unsplash.com/photo-1506277886164-e25aa3f4ef7f?w=150',
      followers: 678,
      following: 234,
      posts: 78,
      gender: 'Not specified',
    ),
    UserModel(
      id: 'user_20',
      username: 'iyas__k_',
      name: 'iyas.k',
      profileImage:
          'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=150',
      followers: 890,
      following: 345,
      posts: 112,
      isFollowing: true,
      gender: 'Not specified',
    ),
    UserModel(
      id: 'user_21',
      username: 'harieeee',
      name: 'HARIMON🤗',
      profileImage:
          'https://images.unsplash.com/photo-1521119989659-a83eee488004?w=150',
      followers: 456,
      following: 178,
      posts: 67,
      gender: 'Not specified',
    ),
    UserModel(
      id: 'user_22',
      username: 'sanobar.rr',
      name: 'Sanoobarrr...',
      profileImage:
          'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=150',
      followers: 1123,
      following: 445,
      posts: 198,
      isFollowing: true,
      gender: 'Not specified',
    ),
    UserModel(
      id: 'user_23',
      username: 'jawahirr._',
      name: 'جواهر',
      profileImage:
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
      followers: 789,
      following: 312,
      posts: 145,
      gender: 'Not specified',
    ),
    UserModel(
      id: 'user_24',
      username: 'aslam_ahm...',
      name: 'اسلم ناصر احمد',
      profileImage:
          'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=150',
      followers: 934,
      following: 421,
      posts: 167,
      isFollowing: true,
      gender: 'Not specified',
    ),
    UserModel(
      id: 'user_25',
      username: '_rxhis_.',
      name: 'Hz',
      profileImage:
          'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?w=150',
      followers: 567,
      following: 234,
      posts: 89,
      gender: 'Not specified',
    ),
    UserModel(
      id: 'user_26',
      username: 'fah_zn_',
      name: 'FAHSIN🫧',
      profileImage:
          'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=150',
      followers: 1234,
      following: 567,
      posts: 234,
      isFollowing: true,
      gender: 'Not specified',
    ),
    UserModel(
      id: 'user_27',
      username: 'ramlabiabdussalam',
      name: 'ramlabiabd...',
      profileImage:
          'https://images.unsplash.com/photo-1488426862026-3ee34a7d66df?w=150',
      followers: 456,
      following: 189,
      posts: 78,
      gender: 'Not specified',
    ),
    UserModel(
      id: 'user_28',
      username: '_zyd__ziyad_',
      name: 'Zyd ziyad',
      profileImage:
          'https://images.unsplash.com/photo-1552058544-f2b08422138a?w=150',
      followers: 890,
      following: 367,
      posts: 145,
      isFollowing: true,
      gender: 'Not specified',
    ),
    UserModel(
      id: 'user_29',
      username: 'jimshan_panthodi_jibu',
      name: 'Jimshan Panthodi',
      profileImage:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
      followers: 678,
      following: 234,
      posts: 112,
      gender: 'Not specified',
    ),
    UserModel(
      id: 'user_30',
      username: 'ansilnaseem',
      name: 'Ansil Naseem',
      profileImage:
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
      followers: 1456,
      following: 623,
      posts: 289,
      isFollowing: true,
      gender: 'Not specified',
    ),
    UserModel(
      id: 'user_31',
      username: 'kerala_foodie',
      name: 'Kerala Food',
      profileImage:
          'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=150',
      followers: 8923,
      following: 345,
      posts: 567,
      bio: 'Best Kerala cuisine 🍛',
      gender: 'Not specified',
    ),
    UserModel(
      id: 'user_32',
      username: 'coding_ninja',
      name: 'Code Ninja',
      profileImage:
          'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150',
      followers: 4567,
      following: 234,
      posts: 456,
      bio: 'Full Stack Developer',
      isFollowing: true,
      gender: 'Not specified',
    ),
    UserModel(
      id: 'user_33',
      username: 'malappuram_vines',
      name: 'Malappuram Vines',
      profileImage:
          'https://images.unsplash.com/photo-1463453091185-61582044d556?w=150',
      followers: 12345,
      following: 456,
      posts: 789,
      gender: 'Not specified',
      bio: 'Comedy | Vlogs',
    ),
    UserModel(
      id: 'user_34',
      username: 'fitness_journey',
      name: 'Fitness Journey',
      profileImage:
          'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=150',
      followers: 6789,
      following: 345,
      posts: 567,
      isFollowing: true,
      gender: 'Not specified',
    ),
    UserModel(
      id: 'user_35',
      username: 'wayanad_explorer',
      name: 'Wayanad Tours',
      profileImage:
          'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150',
      followers: 9876,
      following: 234,
      posts: 678,
      bio: 'Explore Wayanad 🏞️',
      gender: 'Not specified',
    ),
    UserModel(
      id: 'user_36',
      username: 'calicut_diaries',
      name: 'Calicut Diaries',
      profileImage:
          'https://images.unsplash.com/photo-1566492031773-4f4e44671857?w=150',
      followers: 5432,
      following: 456,
      posts: 345,
      isFollowing: true,
      gender: 'Not specified',
    ),
    UserModel(
      id: 'user_37',
      username: 'memes_malayalam',
      name: 'Malayalam Memes',
      profileImage:
          'https://images.unsplash.com/photo-1531427186611-ecfd6d936c79?w=150',
      followers: 23456,
      following: 567,
      posts: 1234,
      bio: 'Daily memes 😂',
      gender: 'Not specified',
    ),
    UserModel(
      id: 'user_38',
      username: 'book_worm_kerala',
      name: 'Book Lover',
      profileImage:
          'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=150',
      followers: 3456,
      following: 234,
      posts: 456,
      isFollowing: true,
      gender: 'Not specified',
    ),
    UserModel(
      id: 'user_39',
      username: 'music_lover_mlp',
      name: 'Music Lover',
      profileImage:
          'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150',
      followers: 4567,
      following: 345,
      posts: 567,
      bio: '🎵 Music is life',
      gender: 'Not specified',
    ),
    UserModel(
      id: 'user_40',
      username: 'gaming_geek',
      name: 'Gaming Geek',
      profileImage:
          'https://images.unsplash.com/photo-1527980965255-d3b416303d12?w=150',
      followers: 7890,
      following: 456,
      posts: 678,
      isFollowing: true,
      gender: 'Not specified',
    ),
    UserModel(
      id: 'user_41',
      username: 'style_icon_kerala',
      name: 'Style Icon',
      profileImage:
          'https://images.unsplash.com/photo-1628157588553-5eeea00af15c?w=150',
      followers: 8901,
      following: 567,
      posts: 789,
      gender: 'Not specified',
    ),
    UserModel(
      id: 'user_42',
      username: 'beach_lover_kvlm',
      name: 'Beach Lover',
      profileImage:
          'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=150',
      followers: 5678,
      following: 345,
      posts: 456,
      isFollowing: true,
      gender: 'Not specified',
    ),
    UserModel(
      id: 'user_43',
      username: 'street_photography_ind',
      name: 'Street Photography',
      profileImage:
          'https://images.unsplash.com/photo-1506277886164-e25aa3f4ef7f?w=150',
      followers: 12345,
      following: 456,
      posts: 890,
      bio: 'Street Photography 📸',
      gender: 'Not specified',
    ),
    UserModel(
      id: 'user_44',
      username: 'business_mindset',
      name: 'Business Mind',
      profileImage:
          'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=150',
      followers: 9876,
      following: 234,
      posts: 567,
      isFollowing: true,
      gender: 'Not specified',
    ),
    UserModel(
      id: 'user_45',
      username: 'motivational_quotes_in',
      name: 'Motivation',
      profileImage:
          'https://images.unsplash.com/photo-1521119989659-a83eee488004?w=150',
      followers: 34567,
      following: 789,
      posts: 1234,
      bio: 'Daily Motivation 💪',
      gender: 'Not specified',
    ),
    UserModel(
      id: 'user_46',
      username: 'cricket_fan_kerala',
      name: 'Cricket Fan',
      profileImage:
          'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=150',
      followers: 6789,
      following: 345,
      posts: 456,
      isFollowing: true,
      gender: 'Not specified',
    ),
    UserModel(
      id: 'user_47',
      username: 'food_blogger_mlp',
      name: 'Food Blogger',
      profileImage:
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
      followers: 8901,
      following: 456,
      posts: 678,
      bio: 'Food reviews 🍔',
      gender: 'Not specified',
    ),
    UserModel(
      id: 'user_48',
      username: 'fashion_week_ind',
      name: 'Fashion Week',
      profileImage:
          'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=150',
      followers: 23456,
      following: 567,
      posts: 890,
      isFollowing: true,
      gender: 'Not specified',
    ),
    UserModel(
      id: 'user_49',
      username: 'yoga_kerala',
      name: 'Yoga Kerala',
      profileImage:
          'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?w=150',
      followers: 7890,
      following: 234,
      posts: 567,
      gender: 'Not specified',
    ),
    UserModel(
      id: 'user_50',
      username: 'startup_kerala',
      name: 'Startup Kerala',
      profileImage:
          'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=150',
      followers: 12345,
      following: 456,
      posts: 678,
      isFollowing: true,
      gender: 'Not specified',
    ),
    UserModel(
      id: 'user_51',
      username: 'pet_lovers_kerala',
      name: 'Pet Lovers',
      profileImage:
          'https://images.unsplash.com/photo-1488426862026-3ee34a7d66df?w=150',
      followers: 9876,
      following: 345,
      posts: 567,
      bio: 'Animal lover 🐶',
      gender: 'Not specified',
    ),
    UserModel(
      id: 'user_52',
      username: 'adventure_seekers',
      name: 'Adventure Seekers',
      profileImage:
          'https://images.unsplash.com/photo-1552058544-f2b08422138a?w=150',
      followers: 11234,
      following: 567,
      posts: 789,
      isFollowing: true,
      gender: 'Not specified',
    ),
    UserModel(
      id: 'user_53',
      username: 'makeup_artist_kerala',
      name: 'Makeup Artist',
      profileImage:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
      followers: 8765,
      following: 234,
      posts: 456,
      gender: 'Not specified',
    ),
    UserModel(
      id: 'user_54',
      username: 'dance_academy_mlp',
      name: 'Dance Academy',
      profileImage:
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
      followers: 6543,
      following: 345,
      posts: 567,
      isFollowing: true,
      gender: 'Not specified',
    ),
    UserModel(
      id: 'user_55',
      username: 'car_enthusiast_ind',
      name: 'Car Enthusiast',
      profileImage:
          'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=150',
      followers: 13456,
      following: 456,
      posts: 678,
      bio: 'Car lover 🚗',
      gender: 'Not specified',
    ),
    UserModel(
      id: 'user_56',
      username: 'wedding_photography_ker',
      name: 'Wedding Photography',
      profileImage:
          'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150',
      followers: 15678,
      following: 567,
      posts: 890,
      isFollowing: true,
      gender: 'Not specified',
    ),
    UserModel(
      id: 'user_57',
      username: 'comedy_shows_kerala',
      name: 'Comedy Shows',
      profileImage:
          'https://images.unsplash.com/photo-1463453091185-61582044d556?w=150',
      followers: 28901,
      following: 678,
      posts: 1234,
      gender: 'Not specified',
    ),
    UserModel(
      id: 'user_58',
      username: 'digital_marketing_ind',
      name: 'Digital Marketing',
      profileImage:
          'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=150',
      followers: 9876,
      following: 345,
      posts: 567,
      isFollowing: true,
      gender: 'Not specified',
    ),
    UserModel(
      id: 'user_59',
      username: 'traditional_kerala',
      name: 'Traditional Kerala',
      profileImage:
          'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150',
      followers: 11234,
      following: 456,
      posts: 678,
      bio: 'Kerala traditions 🌴',
      gender: 'Not specified',
    ),
    UserModel(
      id: 'user_60',
      username: 'film_industry_kerala',
      name: 'Film Industry',
      gender: 'Not specified',
      profileImage:
          'https://images.unsplash.com/photo-1566492031773-4f4e44671857?w=150',
      followers: 34567,
      following: 789,
      posts: 1234,
      bio: 'Malayalam Cinema 🎬',
    ),
  ];
  static void toggleFollow(String currentUserId, String targetUserId) {
    final user = users.firstWhere((u) => u.id == targetUserId);
    final currentUser = users.firstWhere((u) => u.id == currentUserId);

    user.isFollowing = !user.isFollowing;

    if (user.isFollowing) {
      currentUser.following++;
    } else {
      currentUser.following--;
    }
  }

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

  static List<StoryModel> stories = [
    StoryModel(
      id: 'story_1',
      userId: 'user_2',
      username: 'Emily Johnson',
      profileImageUrl: 'https://i.pravatar.cc/150?img=5',
      images: [
        'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=1200', // ocean
        'https://images.unsplash.com/photo-1501785888041-af3ef285b470?w=1200', // mountain
      ],
      timeAgo: '2h',
    ),
    StoryModel(
      id: 'story_2',
      userId: 'user_3',
      username: 'Michael Chen',
      profileImageUrl: 'https://i.pravatar.cc/150?img=12',
      images: [
        'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?w=1200', // portrait
        'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=1200', // food
        'https://images.unsplash.com/photo-1519681393784-d120267933ba?w=1200', // cityscape
      ],
      timeAgo: '4h',
    ),
    StoryModel(
      id: 'story_3',
      userId: 'user_4',
      username: 'Sophia Martinez',
      profileImageUrl: 'https://i.pravatar.cc/150?img=32',
      images: [
        'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=1200', // fashion
      ],
      timeAgo: '5h',
    ),
    StoryModel(
      id: 'story_4',
      userId: 'user_5',
      username: 'David Lee',
      profileImageUrl: 'https://i.pravatar.cc/150?img=8',
      images: [
        'https://images.unsplash.com/photo-1503264116251-35a269479413?w=1200', // landscape
        'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=1200', // portrait
      ],
      timeAgo: '6h',
    ),
    StoryModel(
      id: 'story_5',
      userId: 'user_6',
      username: 'Olivia Brown',
      profileImageUrl: 'https://i.pravatar.cc/150?img=47',
      images: [
        'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?w=1200', // desert
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=1200', // model
      ],
      timeAgo: '8h',
    ),
    StoryModel(
      id: 'story_6',
      userId: 'user_7',
      username: 'Daniel Smith',
      profileImageUrl: 'https://i.pravatar.cc/150?img=15',
      images: [
        'https://images.unsplash.com/photo-1520813792240-56fc4a3765a7?w=1200', // nature
        'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=1200', // dog
        'https://images.unsplash.com/photo-1503023345310-bd7c1de61c7d?w=1200', // street
      ],
      timeAgo: '10h',
    ),
    StoryModel(
      id: 'story_7',
      userId: 'user_8',
      username: 'Ava Williams',
      profileImageUrl: 'https://i.pravatar.cc/150?img=24',
      images: [
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=1200', // man
      ],
      timeAgo: '12h',
    ),
    StoryModel(
      id: 'story_8',
      userId: 'user_9',
      username: 'James Anderson',
      profileImageUrl: 'https://i.pravatar.cc/150?img=40',
      images: [
        'https://images.unsplash.com/photo-1552058544-f2b08422138a?w=1200', // portrait
        'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?w=1200', // another portrait
      ],
      timeAgo: '14h',
    ),
    StoryModel(
      id: 'story_9',
      userId: 'user_10',
      username: 'Liam Garcia',
      profileImageUrl: 'https://i.pravatar.cc/150?img=53',
      images: [
        'https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?w=1200', // glasses
      ],
      timeAgo: '16h',
    ),
    StoryModel(
      id: 'story_10',
      userId: 'user_11',
      username: 'Isabella Miller',
      profileImageUrl: 'https://i.pravatar.cc/150?img=28',
      images: [
        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=1200', // smiling man
        'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=1200', // woman
      ],
      timeAgo: '18h',
    ),
    StoryModel(
      id: 'story_11',
      userId: 'user_12',
      username: 'Ethan Davis',
      profileImageUrl: 'https://i.pravatar.cc/150?img=38',
      images: [
        'https://images.unsplash.com/photo-1512314889357-e157c22f938d?w=1200', // casual man
        'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=1200', // portrait
      ],
      timeAgo: '20h',
    ),
    StoryModel(
      id: 'story_12',
      userId: 'user_13',
      username: 'Mia Wilson',
      profileImageUrl: 'https://i.pravatar.cc/150?img=62',
      images: [
        'https://images.unsplash.com/photo-1503023345310-bd7c1de61c7d?w=1200', // street
        'https://images.unsplash.com/photo-1503264116251-35a269479413?w=1200', // mountain
      ],
      timeAgo: '22h',
    ),
    StoryModel(
      id: 'story_13',
      userId: 'user_14',
      username: 'Noah Martinez',
      profileImageUrl: 'https://i.pravatar.cc/150?img=19',
      images: [
        'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?w=1200', // portrait
      ],
      timeAgo: '23h',
    ),
    StoryModel(
      id: 'story_14',
      userId: 'user_15',
      username: 'Charlotte Taylor',
      profileImageUrl: 'https://i.pravatar.cc/150?img=70',
      images: [
        'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=1200', // food
        'https://images.unsplash.com/photo-1519681393784-d120267933ba?w=1200', // night city
      ],
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
