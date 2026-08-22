import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../core/theme/finora_theme.dart';

/// Renders an AI Copilot assistant message as a ChatGPT-style Markdown card.
///
/// The backend response may contain a mix of:
///   * Markdown headings, bold, italic
///   * Bullet and numbered lists
///   * Pipe tables (sometimes un-fenced)
///   * Stray HTML such as `<br>`, `<br/>`, `<br />`
///   * Lone `---` / `***` / `___` horizontal rules
///
/// This widget normalises that payload before handing it to [MarkdownBody] so
/// the user never sees raw `**`, `|`, `---`, or `<br>` artefacts in the chat.
class AiMarkdownView extends StatelessWidget {
  const AiMarkdownView({
    super.key,
    required this.content,
    required this.isUser,
  });

  final String content;
  final bool isUser;

  static final RegExp _brTag = RegExp(r'<br\s*/?>', caseSensitive: false);
  static final RegExp _hrRule = RegExp(
    r'^[ \t]*(?:---|\*\*\*|___)[ \t]*$',
    multiLine: true,
  );

  /// A row that looks like a Markdown table line: contains at least two `|`
  /// characters and at least one non-pipe, non-space character.
  static final RegExp _tableRow = RegExp(r'^\s*\|?.+\|.+\|?\s*$');

  /// The classic separator row under a table header (e.g. `|---|---|`).
  static final RegExp _tableSeparator = RegExp(
    r'^\s*\|?\s*:?-{2,}:?\s*(\|\s*:?-{2,}:?\s*)+\|?\s*$',
  );

  /// Normalises the assistant payload into something a Markdown renderer can
  /// safely consume without leftover HTML / Markdown artefacts.
  static String normalise(String input) {
    var text = input;

    // 1) Replace any HTML-ish line break first.
    text = text.replaceAll(_brTag, '\n');

    // 2) Drop lone horizontal rules — they add noise in chat context.
    text = text.replaceAll(_hrRule, '');

    // 3) Collapse 3+ blank lines into a single blank line.
    text = text.replaceAll(RegExp(r'\n{3,}'), '\n\n');

    // 4) Trim trailing whitespace per line.
    text = text.split('\n').map((line) => line.trimRight()).join('\n');

    // 5) Detect loose pipe-tables (header line + separator + body rows) and
    //    fence them so `flutter_markdown` renders them as a proper table.
    text = _fenceLooseTables(text);

    return text.trim();
  }

  /// Walks the normalised text, finds blocks of consecutive lines that look
  /// like Markdown tables (header, separator, body rows), and wraps the body
  /// rows with leading/ trailing blank lines so the renderer treats them as
  /// a table block.
  ///
  /// We also normalise the separator row so even slightly malformed ones
  /// (`--|---|` rather than `|---|---|`) are recognised.
  static String _fenceLooseTables(String input) {
    final lines = input.split('\n');
    final out = <String>[];

    var i = 0;
    while (i < lines.length) {
      final line = lines[i];

      // Look for: current line is a table row, and the next line is a
      // separator. If so we are at the start of a table.
      final isTableStart =
          _tableRow.hasMatch(line) &&
          i + 1 < lines.length &&
          _tableSeparator.hasMatch(lines[i + 1]);

      if (!isTableStart) {
        out.add(line);
        i++;
        continue;
      }

      // Normalise the header so it always starts and ends with `|`.
      out.add(_ensureTableEdges(line));
      // Normalise the separator to the canonical `| --- | --- |` form.
      out.add(_normaliseSeparator(lines[i + 1]));

      var j = i + 2;
      while (j < lines.length && _tableRow.hasMatch(lines[j])) {
        out.add(_ensureTableEdges(lines[j]));
        j++;
      }

      // Make sure tables are surrounded by blank lines so the parser picks
      // them up as block elements.
      if (out.isNotEmpty && out.last.isNotEmpty) {
        out.add('');
      }
      if (i > 0 && out.length >= 2 && out[out.length - 2].isNotEmpty) {
        out.insert(out.length - 1, '');
      }

      i = j;
    }

    return out.join('\n');
  }

  static String _ensureTableEdges(String line) {
    var trimmed = line.trim();
    if (!trimmed.startsWith('|')) trimmed = '| $trimmed';
    if (!trimmed.endsWith('|')) trimmed = '$trimmed |';
    return trimmed;
  }

  static String _normaliseSeparator(String separator) {
    // Split on `|`, keep only the non-empty cells, and rebuild.
    final cells = separator
        .split('|')
        .map((c) => c.trim())
        .where((c) => c.isNotEmpty)
        .toList();
    if (cells.isEmpty) return '| --- |';
    return '| ${cells.map((_) => '---').join(' | ')} |';
  }

  @override
  Widget build(BuildContext context) {
    final fg = isUser ? Colors.white : FinoraColors.textPrimary;
    final muted = isUser ? Colors.white70 : FinoraColors.textSecondary;
    final codeBg = isUser
        ? Colors.white.withValues(alpha: 0.15)
        : FinoraColors.surfaceAlt;
    final codeBorder = isUser ? Colors.white24 : FinoraColors.outline;

    final source = normalise(content);

    if (source.isEmpty) {
      return Text(
        '(empty response)',
        style: TextStyle(color: muted, fontStyle: FontStyle.italic),
      );
    }

    return MarkdownBody(
      data: source,
      selectable: true,
      shrinkWrap: true,
      fitContent: false,
      softLineBreak: true,
      styleSheet: MarkdownStyleSheet(
        p: TextStyle(color: fg, height: 1.45, fontSize: 14.5),
        h1: TextStyle(
          color: fg,
          fontSize: 19,
          fontWeight: FontWeight.w800,
          height: 1.3,
        ),
        h2: TextStyle(
          color: fg,
          fontSize: 17,
          fontWeight: FontWeight.w800,
          height: 1.3,
        ),
        h3: TextStyle(
          color: fg,
          fontSize: 15.5,
          fontWeight: FontWeight.w700,
          height: 1.3,
        ),
        h4: TextStyle(
          color: fg,
          fontSize: 14.5,
          fontWeight: FontWeight.w700,
          height: 1.3,
        ),
        strong: TextStyle(color: fg, fontWeight: FontWeight.w800),
        em: TextStyle(color: fg, fontStyle: FontStyle.italic),
        del: TextStyle(color: muted, decoration: TextDecoration.lineThrough),
        a: const TextStyle(
          color: FinoraColors.brandPrimary,
          decoration: TextDecoration.underline,
        ),
        listBullet: TextStyle(color: fg, fontSize: 14.5, height: 1.45),
        listIndent: 20,
        blockquote: TextStyle(color: muted, height: 1.4),
        blockquotePadding: const EdgeInsets.fromLTRB(12, 4, 8, 4),
        blockquoteDecoration: BoxDecoration(
          color: muted.withValues(alpha: 0.08),
          border: Border(
            left: BorderSide(color: muted.withValues(alpha: 0.5), width: 3),
          ),
        ),
        code: TextStyle(
          color: fg,
          fontFamily: 'monospace',
          fontSize: 13.5,
          backgroundColor: codeBg,
        ),
        codeblockDecoration: BoxDecoration(
          color: codeBg,
          border: Border.all(color: codeBorder),
          borderRadius: BorderRadius.circular(8),
        ),
        codeblockPadding: const EdgeInsets.all(10),
        tableHead: TextStyle(color: fg, fontWeight: FontWeight.w800),
        tableBody: TextStyle(color: fg),
        tableBorder: TableBorder.all(color: codeBorder, width: 0.6),
        tableCellsPadding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 6,
        ),
        horizontalRuleDecoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: muted.withValues(alpha: 0.4), width: 0.5),
          ),
        ),
      ),
      onTapLink: (text, href, title) {
        // Leave URLs as readable text; no host browser integration required.
      },
    );
  }
}
