import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/news_model.dart';

class NewsDetailScreen extends StatelessWidget {
  final Article article;

  const NewsDetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final hasUrl = article.url != null && article.url!.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
        title: const Text('Chi tiết bài báo'),
        actions: [
          if (hasUrl)
            IconButton(
              tooltip: 'Mở trang gốc',
              onPressed: () => _openOriginalUrl(context, article.url!),
              icon: const Icon(Icons.open_in_new),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
                child: _DetailImage(imageUrl: article.urlToImage),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${article.sourceName ?? 'Unknown source'} • ${_formatPublishedAt(article.publishedAt)}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    article.content?.trim().isNotEmpty == true
                        ? article.content!
                        : (article.description?.trim().isNotEmpty == true
                              ? article.description!
                              : 'Không có nội dung chi tiết cho bài báo này.'),
                    style: const TextStyle(fontSize: 16, height: 1.7),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: hasUrl
          ? FloatingActionButton.extended(
              onPressed: () => _openOriginalUrl(context, article.url!),
              backgroundColor: const Color(0xFF0D47A1),
              foregroundColor: Colors.white,
              icon: const Icon(Icons.language),
              label: const Text('Xem trên web'),
            )
          : null,
    );
  }

  Future<void> _openOriginalUrl(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      _showCannotOpenMessage(context);
      return;
    }

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      _showCannotOpenMessage(context);
    }
  }

  void _showCannotOpenMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Không thể mở liên kết bài báo.')),
    );
  }

  String _formatPublishedAt(String? publishedAt) {
    if (publishedAt == null || publishedAt.isEmpty) return '--';
    try {
      final date = DateTime.parse(publishedAt).toLocal();
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '--';
    }
  }
}

class _DetailImage extends StatelessWidget {
  final String? imageUrl;

  const _DetailImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.trim().isEmpty) {
      return Container(
        color: Colors.grey[300],
        alignment: Alignment.center,
        child: const Icon(Icons.image, size: 48, color: Colors.black45),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl!,
      fit: BoxFit.cover,
      placeholder: (_, __) => Container(
        color: Colors.grey[300],
        alignment: Alignment.center,
        child: const Icon(Icons.image, size: 48, color: Colors.black45),
      ),
      errorWidget: (_, __, ___) => Container(
        color: Colors.grey[300],
        alignment: Alignment.center,
        child: const Icon(Icons.broken_image, size: 48, color: Colors.black45),
      ),
    );
  }
}
