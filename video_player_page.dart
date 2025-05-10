import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerPage extends StatefulWidget {
  const VideoPlayerPage({Key? key}) : super(key: key);

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late YoutubePlayerController _ytController;
  VideoPlayerController? _localController;
  final _urlController = TextEditingController();
  String _currentType = 'youtube';
  String? _currentVideoId;
  final List<Map<String, String>> videoList = [
    {
      'title': 'You Will Be in My Heart',
      'videoId': 'Bl0Gtp5FMd4',
      'type': 'youtube',
    },
    {
      'title': 'Mesra-Mesranya Kecil-kecilan Dulu',
      'videoId': 'aHxxbTq0TXE',
      'type': 'youtube',
    },
    {
      'title': 'Sampai Jadi Debu',
      'type': 'local',
      'path': 'assets/video/Sampai Jadi Debu.mp4',
      'thumbnail': 'assets/images/SJD.jpg',
    },
    {
      'title': 'Sesuatu di Jogja',
      'type': 'local',
      'path': 'assets/video/Sesuatu Di jogja.mp4',
      'thumbnail': 'assets/images/SDJ.jpg',
    },
  ];

  @override
  void initState() {
    super.initState();
    final defaultVideoId = YoutubePlayerController.convertUrlToId(
      'https://youtu.be/gIsoLyQX7W8',
    );

    _ytController = YoutubePlayerController.fromVideoId(
      videoId: defaultVideoId ?? '',
      autoPlay: false,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
      ),
    );
  }

  @override
  void dispose() {
    _ytController.close();
    _localController?.dispose();
    _urlController.dispose();
    super.dispose();
  }

  void _playYoutube(String videoId) { //Buat play video di youtube
    _localController?.pause();
    setState(() {
      _currentType = 'youtube';
      _currentVideoId = videoId;
    });
    _ytController.loadVideoById(videoId: videoId);
  }

  void _playLocal(String path) { //Buat play video di lokal
    _ytController.pauseVideo();
    _localController?.dispose();
    _localController = VideoPlayerController.asset(path)
      ..initialize().then((_) {
        setState(() {
          _currentType = 'local';
        });
        _localController?.play();
      });
  }

  Widget _buildVideoPlayer() { //Nampilin Video
    if (_currentType == 'youtube') {
      return YoutubePlayer(controller: _ytController);
    } else if (_currentType == 'local' &&
        _localController != null &&
        _localController!.value.isInitialized) {
      return AspectRatio(
        aspectRatio: _localController!.value.aspectRatio,
        child: VideoPlayer(_localController!),
      );
    } else {
      return const Center(child: CircularProgressIndicator());
    }
  }

  void _searchAndPlayVideo(String input) { //Nyari video
    final trimmedInput = input.trim();

    // Cek apakah input adalah URL YouTube
    final id = YoutubePlayerController.convertUrlToId(trimmedInput);
    if (id != null) {
      _playYoutube(id);
      return;
    }

    // Coba cari berdasarkan judul
    final foundVideo = videoList.firstWhere(
      (video) => video['title']!.toLowerCase() == trimmedInput.toLowerCase(),
      orElse: () => {},
    );

    if (foundVideo.isNotEmpty) {
      final type = foundVideo['type'];
      if (type == 'youtube') {
        _playYoutube(foundVideo['videoId']!);
      } else if (type == 'local') {
        _playLocal(foundVideo['path']!);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Judul atau URL tidak ditemukan")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF1F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFF26A69A),
        title: TextField(
          controller: _urlController,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            hintText: 'Paste YouTube URL atau ketik judul...',
            hintStyle: const TextStyle(color: Colors.black54),
            filled: true,
            fillColor: const Color(0xFFB2DFDB),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            suffixIcon: IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: () {
                _searchAndPlayVideo(_urlController.text);
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: _buildVideoPlayer(),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: videoList.length,
                itemBuilder: (context, index) {
                  final video = videoList[index];
                  final title = video['title']!;
                  final type = video['type']!;
                  final thumbnailUrl =
                      type == 'youtube'
                          ? 'https://img.youtube.com/vi/${video['videoId']}/0.jpg'
                          : video['thumbnail'];
                  bool isCurrentVideo =
                      _currentType == type &&
                      ((type == 'youtube' &&
                              video['videoId'] == _currentVideoId) ||
                          (type == 'local' &&
                              video['path'] == _localController?.dataSource));

                  return InkWell(
                    onTap: () {
                      if (type == 'youtube') {
                        _playYoutube(video['videoId']!);
                      } else {
                        _playLocal(video['path']!);
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color:
                            isCurrentVideo
                                ? const Color(0xFF26A69A)
                                : const Color(0xFFB2DFDB),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          if (thumbnailUrl != null && thumbnailUrl.isNotEmpty)
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(10),
                                bottomLeft: Radius.circular(10),
                              ),
                              child: Image.network(
                                thumbnailUrl,
                                width: 130,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            )
                          else
                            Container(
                              width: 130,
                              height: 80,
                              decoration: const BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  bottomLeft: Radius.circular(10),
                                ),
                              ),
                              child: const Icon(
                                Icons.videocam,
                                color: Colors.white,
                              ),
                            ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(
                                color:
                                    isCurrentVideo
                                        ? Colors.white
                                        : Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (isCurrentVideo)
                            const Icon(Icons.pause, color: Colors.white)
                          else
                            const Icon(Icons.play_arrow, color: Colors.black),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
