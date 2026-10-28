import 'package:flutter/material.dart';

import 'eras_data.dart';
import 'main.dart';
import 'old_pictures.dart';
import 'vocab_page.dart' show openWords, kWordsTitle, kWordsSub;
import 'orienteering.dart' show tr;
import 'roots_data.dart';
import 'stories_data.dart';

/// Roots tab, mirroring the site's History page: Island stories (expandable
/// theme cards with chapters) → the timeline → the album on its own page.
class RootsPage extends StatelessWidget {
  const RootsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final pt = locale.value == 'pt';
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(t('roots_h1'),
            style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: kTerracotta)),
        const SizedBox(height: 4),
        Text(t('roots_sub'),
            style: const TextStyle(fontSize: 13, color: Colors.grey)),
        const SizedBox(height: 20),

        Text(t('stories'),
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: context.cTitle)),
        Text(t('stories_sub'),
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 12),

        for (final s in stories) _StoryCard(story: s, pt: pt),

        const SizedBox(height: 20),
        Text(t('timeline'),
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: context.cTitle)),
        Text(t('timeline_sub'),
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 12),

        for (final e in eras)
          Container(
            margin: const EdgeInsets.only(bottom: 18),
            decoration: BoxDecoration(
              color: context.cSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: context.cHairline, width: 0.5),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                histImage(e.img),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _yearsPill(context, e.years),
                      const SizedBox(height: 8),
                      Text(pt && e.titlePt.isNotEmpty ? e.titlePt : e.titleEn,
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: context.cTitle)),
                      const SizedBox(height: 8),
                      Text(pt && e.bodyPt.isNotEmpty ? e.bodyPt : e.bodyEn,
                          style:
                              const TextStyle(fontSize: 13.5, height: 1.5)),
                    ],
                  ),
                ),
              ],
            ),
          ),

        Card(
          color: context.cTerraTint,
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          child: ListTile(
            leading: const Text('🎨', style: TextStyle(fontSize: 22)),
            title: Text(tr(kOldPicturesTitle),
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600)),
            subtitle: Text(tr(kOldPicturesSub),
                style: const TextStyle(fontSize: 12)),
            trailing: Icon(Icons.chevron_right, color: context.cTerraText),
            onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const OldPicturesPage())),
          ),
        ),
        // Madeiran words (1950 dictionary), beside the old pictures
        // (Kirill, 28.10.2026).
        Card(
          color: context.cTerraTint,
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          child: ListTile(
            leading: const Text('🗣', style: TextStyle(fontSize: 22)),
            title: Text(tr(kWordsTitle),
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600)),
            subtitle: Text(tr(kWordsSub),
                style: const TextStyle(fontSize: 12)),
            trailing: Icon(Icons.chevron_right, color: context.cTerraText),
            onTap: () => openWords(context),
          ),
        ),
        Card(
          color: context.cTerraTint,
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          child: ListTile(
            leading: Text('🖼', style: TextStyle(fontSize: 22)),
            title: Text(t('album'),
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600)),
            subtitle: Text(t('album_sub'),
                style: const TextStyle(fontSize: 12)),
            trailing: Icon(Icons.chevron_right, color: context.cTerraText),
            onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AlbumPage())),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

Widget _yearsPill(BuildContext context, String years) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: context.cTerraTint,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(years,
        style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: context.cTerraText)),
  );
}

class _StoryCard extends StatelessWidget {
  final Story story;
  final bool pt;
  const _StoryCard({required this.story, required this.pt});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: context.cSurface,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: context.cHairline, width: 0.5),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Text(story.emoji, style: const TextStyle(fontSize: 24)),
          title: Text(pt ? story.titlePt : story.titleEn,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: context.cTitle)),
          subtitle: Text(story.years,
              style: TextStyle(fontSize: 12, color: context.cTerraText)),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          children: [
            for (final c in story.chapters) ...[
              if (c.years.isNotEmpty || c.titleEn.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6, bottom: 8),
                  child: Row(
                    children: [
                      if (c.years.isNotEmpty) _yearsPill(context, c.years),
                      if (c.titleEn.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(pt ? c.titlePt : c.titleEn,
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: context.cTitle)),
                        ),
                      ],
                    ],
                  ),
                ),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: histImage('history/${c.img}', height: 170),
              ),
              if (c.capEn.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(pt && c.capPt.isNotEmpty ? c.capPt : c.capEn,
                      style: TextStyle(
                          fontSize: 11.5,
                          height: 1.35,
                          fontStyle: FontStyle.italic,
                          color: context.cSubtle)),
                ),
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 10),
                child: Text(pt && c.bodyPt.isNotEmpty ? c.bodyPt : c.bodyEn,
                    style: const TextStyle(fontSize: 13.5, height: 1.5)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// The photo album, on its own page like on the site.
class AlbumPage extends StatelessWidget {
  const AlbumPage({super.key});

  @override
  Widget build(BuildContext context) {
    final pt = locale.value == 'pt';
    return Scaffold(
      appBar: AppBar(title: Text(t('album'))),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: rootsItems.length,
        itemBuilder: (_, i) {
          final it = rootsItems[i];
          return Card(
            color: context.cSurface,
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 14),
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: context.cHairline, width: 0.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                histImage('history/${it.img}'),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(it.year,
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: context.cTerraText)),
                      const SizedBox(height: 4),
                      Text(
                          pt && it.captionPt.isNotEmpty
                              ? it.captionPt
                              : it.caption,
                          style: const TextStyle(fontSize: 13, height: 1.4)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
