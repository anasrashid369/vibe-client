import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/usecases/semantic_search.dart';
import '../../vibe_search_providers.dart';

class VibeSearchPage extends ConsumerStatefulWidget {
  const VibeSearchPage({super.key});

  @override
  ConsumerState<VibeSearchPage> createState() => _VibeSearchPageState();
}

class _VibeSearchPageState extends ConsumerState<VibeSearchPage> {
  final _controller = TextEditingController();
  List<SemanticSearchResult>? _results;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final query = _controller.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final results = await ref.read(semanticSearchProvider).call(query);
      setState(() {
        _results = results;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vibe Search')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Describe a mood, e.g. "tense and atmospheric"',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _loading ? null : _search,
                ),
              ),
              onSubmitted: (_) => _search(),
            ),
          ),
          if (_loading) const Expanded(child: Center(child: CircularProgressIndicator())),
          if (_error != null)
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text('Search failed: $_error', textAlign: TextAlign.center),
                ),
              ),
            ),
          if (!_loading && _error == null && _results != null)
            Expanded(
              child: _results!.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text(
                          'No matches yet -- browse a few more movies first so there is something to search.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _results!.length,
                      itemBuilder: (context, index) {
                        final r = _results![index];
                        return ListTile(
                          leading: SizedBox(
                            width: 48,
                            height: 72,
                            child: r.posterPath != null
                                ? Image.network(
                                    'https://image.tmdb.org/t/p/w185${r.posterPath}',
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.movie),
                                  )
                                : const Icon(Icons.movie),
                          ),
                          title: Text(r.title),
                          subtitle: Text(r.genres.join(', ')),
                          trailing: Text('${(r.score * 100).toStringAsFixed(0)}%'),
                        );
                      },
                    ),
            ),
        ],
      ),
    );
  }
}
