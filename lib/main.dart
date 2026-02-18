import 'package:flutter/material.dart';
import 'package:remote_server_demo/repository/post_repository.dart';

import 'model/post.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrangeAccent),
          scaffoldBackgroundColor: Colors.white70,
      ),
      home: const PostScreen(),
    );
  }
}

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  PostScreenState createState() => PostScreenState();
}

class PostScreenState extends State<PostScreen> {
  final PostRepository _repository = PostRepository();
  late Future<List<Post>> _posts;

  @override
  void initState() {
    super.initState();
    _posts = _repository.fetchPosts();
  }

  // 1. Add a variable to hold your actual list of posts
  List<Post>? _cachedPosts;

  void _sendPost() async {
    Post newPost = Post(
      title: "Hello there",
      body: "This is a flutter post Example",
      userId: 1,
    );

    try {
      Post createdPost = await _repository.createPost(newPost);

      // 2. Manually insert the new post at the top of your list
      setState(() {
        _cachedPosts?.insert(0, createdPost);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Success! Created Post ID: ${createdPost.id}")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Post creation failed!!!")),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("API Post Demo")),
      body: FutureBuilder<List<Post>>(
        future: _posts,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting && _cachedPosts == null) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }

            // Save the initial fetch to our cache if it's empty
            _cachedPosts ??= snapshot.data;

            return ListView.builder(
              itemCount: _cachedPosts!.length,
              itemBuilder: (context, index) {
                final item = _cachedPosts![index];
                return Card(
                  child: ListTile(
                    title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(item.body),
                  ),
                );
              },
            );
          }

      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _sendPost,
        child: const Icon(Icons.add),
      ),
    );
  }
}
