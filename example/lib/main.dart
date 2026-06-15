import 'package:flutter/material.dart';
import 'package:bm_flutter_networking/bm_flutter_networking.dart';

// ---------------------------------------------------------------------------
// Model
// ---------------------------------------------------------------------------

class Post {
  final int id;
  final String title;
  final String body;

  const Post({required this.id, required this.title, required this.body});

  factory Post.fromJson(Map<String, dynamic> json) => Post(
        id: json['id'] as int,
        title: json['title'] as String,
        body: json['body'] as String,
      );
}

// ---------------------------------------------------------------------------
// Target  (base URL / environment config)
// ---------------------------------------------------------------------------

class JsonPlaceholderTarget extends Target {
  @override
  String get kAppHost => 'jsonplaceholder.typicode.com';

  @override
  String get kAppScheme => 'https';
}

// ---------------------------------------------------------------------------
// Request
// ---------------------------------------------------------------------------

class GetPostRequest extends ModelTargetType<Post> {
  final JsonPlaceholderTarget _target;
  final int postId;

  GetPostRequest(this._target, this.postId)
      : super(decoder: Post.fromJson);

  @override
  String get baseURL => _target.kBaseURL;

  @override
  String get requestPath => 'posts/$postId';

  @override
  HTTPMethod get requestMethod => HTTPMethod.get;
}

// ---------------------------------------------------------------------------
// App
// ---------------------------------------------------------------------------

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'BM Flutter Networking Example',
      home: PostPage(),
    );
  }
}

class PostPage extends StatefulWidget {
  const PostPage({super.key});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  final _target = JsonPlaceholderTarget();
  Post? _post;
  String? _error;
  bool _loading = false;

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final post = await GetPostRequest(_target, 1).performAsync<Post>();
      setState(() => _post = post);
    } on APIError catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BM Flutter Networking')),
      body: Center(
        child: _loading
            ? const CircularProgressIndicator()
            : _error != null
                ? Text(_error!)
                : _post == null
                    ? const SizedBox.shrink()
                    : Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _post!.title,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(_post!.body),
                          ],
                        ),
                      ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _load,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
