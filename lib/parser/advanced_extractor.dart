/// The extra token steps of design section 7.15: subtasks, file name
/// pattern, links, email, submission method, `@wadah` and `#tag` tokens,
/// `!` priority markers, estimates and an inline note in brackets.
///
/// Every function is pure: it takes the text left by the previous step and
/// returns the text for the next one plus whatever it found, so the order
/// of the steps stays visible in `ParserService.parse` and each one can be
/// tested on its own.
library;

/// Tidies text after a token was cut out of it. Newlines survive, so a
/// list that arrives on separate lines can still be read line by line
/// before the normalizer folds them (design section 7.15).
String _tidy(String text) =>
    text.replaceAll(RegExp(r'[^\S\n]+'), ' ').trim();

/// Cuts one match out, leaving a single space behind so neighbouring
/// words never fuse together.
String _cut(String text, Match match) =>
    _tidy('${text.substring(0, match.start)} ${text.substring(match.end)}');

/// Removes every match of [matches] from [text] in a single pass.
///
/// The matches have to come from [text] itself. Cutting them one after the
/// other shifted the offsets of everything in front of the cut, so a second
/// `!` marker landed outside the shortened string and threw a RangeError,
/// and a message that started with spaces came back with pieces of words
/// glued together. Walking forward over the original text instead keeps
/// every offset honest and reads the text once.
String _removeMatches(String text, Iterable<Match> matches) {
  final buffer = StringBuffer();
  var cursor = 0;
  for (final match in matches) {
    // Two matches cannot share characters; the first one owns them.
    if (match.start < cursor) continue;
    buffer.write(text.substring(cursor, match.start));
    buffer.write(' ');
    cursor = match.end;
  }
  buffer.write(text.substring(cursor));
  return _tidy(buffer.toString());
}

/// Removes every occurrence of [pattern].
String _cutAll(String text, RegExp pattern) =>
    _removeMatches(text, pattern.allMatches(text));

/// The numbered or bulleted items of a shared message (design section
/// 7.15). Lines that start with "1.", "1)", "-" or "3." are taken as
/// subtasks; a run of "2. x" inside one line counts as well. The markers
/// never reach the title, and a list with a title in front of it keeps the
/// title where it is.
({String remainingText, List<String> subtasks}) extractSubtasks(String text) {
  final subtasks = <String>[];
  var work = text;

  // Full lines: the whole line becomes one subtask.
  final line = RegExp(
    r'(?:^|\n)\s*(?:\d{1,2}[.)]|[-•*])\s+([^\n]+)',
    caseSensitive: false,
  );
  while (true) {
    final match = line.firstMatch(work);
    if (match == null) break;
    final item = _tidy(match.group(1)!);
    if (item.isEmpty) break;
    subtasks.add(item);
    work = _cut(work, match);
  }

  // One line carrying the whole list: "1. x 2. y 3. z".
  final inline = RegExp(r'(?:^|\s)(\d{1,2})[.)]\s+');
  final markers = inline.allMatches(work).toList();
  if (markers.length >= 2) {
    for (var i = 0; i < markers.length - 1; i++) {
      final start = markers[i].end;
      final end = markers[i + 1].start;
      final item = _tidy(work.substring(start, end));
      if (item.isNotEmpty) subtasks.add(item);
    }
    final last = markers.last;
    final tail = _tidy(work.substring(last.end));
    if (tail.isNotEmpty) subtasks.add(tail);
    // Everything in front of the first marker is the title; the markers
    // and their items are gone.
    work = _tidy(work.substring(0, markers.first.start));
  }

  return (remainingText: work, subtasks: subtasks);
}

/// Everything after "format nama file", "penamaan" or the English spellings
/// is stored untouched as the file name pattern, with a chip asking the user
/// to check it (design section 7.15). It stops at a newline or at the next
/// sentence.
({String remainingText, String? filenamePattern}) extractFilenamePattern(
    String text) {
  final match = RegExp(
    r'(?:format\s+nama\s+file|penamaan(?:\s+file)?|file\s+name\s+format|'
    r'filename\s+format|naming\s+convention)'
    r'\s*(?:adalah|is|:\s*)?\s*([^\n]+?)(?=\s+[.!?](?:\s|$)|\n|$)',
    caseSensitive: false,
  ).firstMatch(text);
  if (match == null) return (remainingText: text, filenamePattern: null);

  final pattern = _tidy(match.group(1)!);
  if (pattern.isEmpty) return (remainingText: text, filenamePattern: null);
  return (
    remainingText: _cut(text, match),
    filenamePattern: pattern,
  );
}

/// The links of a shared message, kept in the order they appear. They
/// become link attachments (design section 6.2) instead of words in the
/// title.
({String remainingText, List<String> links}) extractLinks(String text) {
  final links = <String>[];
  final cut = <Match>[];
  final pattern =
      RegExp(r"""\b(?:https?://|www\.)[^\s,;"']+""", caseSensitive: false);
  for (final match in pattern.allMatches(text)) {
    var link = match.group(0)!;
    while (link.isNotEmpty && '.,;:!?)]'.contains(link[link.length - 1])) {
      link = link.substring(0, link.length - 1);
    }
    if (link.isEmpty) continue;
    links.add(link.startsWith('http') ? link : 'https://$link');
    cut.add(match);
  }
  return (remainingText: _removeMatches(text, cut), links: links);
}

/// The email address in the text (design section 7.15): it becomes the
/// target of the `email` submission method.
({String remainingText, String? email}) extractEmail(String text) {
  final match = RegExp(
    r'[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}',
    caseSensitive: false,
  ).firstMatch(text);
  if (match == null) return (remainingText: text, email: null);
  return (
    remainingText: _cut(text, match),
    email: match.group(0)!.toLowerCase(),
  );
}

/// How the work has to be handed in (design section 7.15). An email in the
/// text wins, then the words that name a channel, then the words that mean
/// a printed copy. An address without any of those words still counts.
({String remainingText, String? submitMethod}) extractSubmitMethod(
  String text, {
  required String? email,
}) {
  const channels = ['lms', 'e-learning', 'elearning', 'classroom', 'drive', 'gdrive', 'schoology', 'moodle'];
  const paperWords = ['dicetak', 'hardcopy', 'printout', 'diprint', 'printed', 'hard copy'];

  for (final word in channels) {
    if (RegExp('\\b${RegExp.escape(word)}\\b', caseSensitive: false)
        .hasMatch(text)) {
      return (
        remainingText: _cutAll(
            text, RegExp('\\b${RegExp.escape(word)}\\b', caseSensitive: false)),
        submitMethod: 'lms',
      );
    }
  }
  for (final word in paperWords) {
    if (RegExp('\\b${RegExp.escape(word)}\\b', caseSensitive: false)
        .hasMatch(text)) {
      return (
        remainingText: _cutAll(
            text, RegExp('\\b${RegExp.escape(word)}\\b', caseSensitive: false)),
        submitMethod: 'paper',
      );
    }
  }
  if (email != null) {
    return (remainingText: text, submitMethod: 'email');
  }
  return (remainingText: text, submitMethod: null);
}

/// `@basdat` names a space and `#kelompok` a tag (design section 7.15).
/// The space token is only a seed: the matcher still decides whether the
/// name really exists, so an unknown `@name` falls back to the normal
/// title text. The tag is always kept.
({String remainingText, String? spaceToken, String? tag}) extractContainerTag(
    String text) {
  String? spaceToken;
  String? tag;
  var work = text;

  final space =
      RegExp(r'(?:^|\s)@([a-z0-9][a-z0-9_-]*)', caseSensitive: false)
          .firstMatch(work);
  if (space != null) {
    spaceToken = space.group(1)!;
    work = _cut(work, space);
  }

  final hash =
      RegExp(r'(?:^|\s)#([a-z0-9][a-z0-9_-]*)', caseSensitive: false)
          .firstMatch(work);
  if (hash != null) {
    tag = hash.group(1)!;
    work = _cut(work, hash);
  }

  return (remainingText: _tidy(work), spaceToken: spaceToken, tag: tag);
}

/// The `!`, `!tinggi` and `!rendah` markers (design section 7.15). The old
/// word check could never see them because `\b` does not stand between a
/// letter and `!`, so they are matched as markers of their own. Only a
/// marker with a known word is removed.
({String remainingText, int priority, bool seen}) extractPriorityMarkers(
    String text) {
  const levels = {
    '': 2,
    'tinggi': 3,
    'high': 3,
    'rendah': 0,
    'low': 0,
    'sedang': 1,
    'normal': 1,
  };

  final matches = RegExp(r'(?:^|\s)!([a-z]*)', caseSensitive: false)
      .allMatches(text)
      .toList();
  final cut = <Match>[];
  var priority = 1;
  var seen = false;

  // The first marker that names a known level decides, and every known
  // marker leaves the text. The decisions run over the untouched text so
  // cutting one marker cannot move the next one.
  for (final match in matches) {
    final word = match.group(1)!.toLowerCase();
    if (!levels.containsKey(word)) continue;
    if (!seen) priority = levels[word]!;
    seen = true;
    cut.add(match);
  }
  return (remainingText: _removeMatches(text, cut), priority: priority, seen: seen);
}

/// The priority words of design section 7.15: "penting", "urgent" and
/// "wajib" raise the priority, "santai" and "kalau sempat" lower it. Both
/// in one sentence is a conflict the user has to settle on the chip, so
/// neither side wins.
({String remainingText, int priority, bool conflict}) extractPriorityWords(
  String text, {
  required bool isIndonesian,
}) {
  final high = isIndonesian
      ? const ['penting', 'urgent', 'mendesak', 'wajib', 'prioritas']
      : const ['important', 'urgent', 'critical', 'high priority'];
  final low = isIndonesian
      ? const ['santai', 'kalau sempat', 'kapan saja', 'opsional', 'tenang']
      : const ['relaxed', 'whenever', 'optional', 'low priority'];

  var work = text;
  var priority = 1;
  var conflict = false;

  for (final word in high) {
    final pattern = RegExp('\\b${RegExp.escape(word)}\\b', caseSensitive: false);
    if (pattern.hasMatch(work)) {
      work = _cutAll(work, pattern);
      if (priority == 1) priority = 2;
    }
  }
  for (final word in low) {
    final pattern = RegExp('\\b${RegExp.escape(word)}\\b', caseSensitive: false);
    if (pattern.hasMatch(work)) {
      work = _cutAll(work, pattern);
      if (priority == 1) {
        priority = 0;
      } else if (priority == 2) {
        conflict = true;
      }
    }
  }
  if (conflict) priority = 1;
  return (remainingText: _tidy(work), priority: priority, conflict: conflict);
}

/// The effort estimate (design section 7.15): `~2j`, `~45m`, "estimasi 2
/// jam" and "sekitar 30 menit", all in minutes. The relative moment "3
/// jam lagi" is never an estimate, so a candidate right in front of
/// "lagi" is left alone for the time extractor.
({String remainingText, int? minutes}) extractEstimate(String text) {
  int? minutes;
  var work = text;

  final short = RegExp(r'~\s*(\d+)\s*(j|jam|menit|m)\b', caseSensitive: false)
      .firstMatch(text);
  final natural = RegExp(
    r'(?:perkiraan|estimasi|sekitar|butuh(?:\s+waktu)?|kurang lebih|about|around|estimate[ds]?|takes?|needs?)'
    r'\s+(\d+)\s*(j|jam|menit|m|hour|hours|hrs|hr|min|mins|minutes)\b',
    caseSensitive: false,
  ).firstMatch(text);

  final match = short ?? natural;
  if (match != null) {
    // "3 jam lagi" stays a relative moment (design section 7.15).
    final after = text.substring(match.end);
    final isRelative = RegExp(r'^\s+(lagi|dari\s+sekarang)\b', caseSensitive: false)
        .hasMatch(after);
    if (!isRelative) {
      final value = int.parse(match.group(1)!);
      final unit = match.group(2)!.toLowerCase();
      final isHours = unit.startsWith('j') || unit.startsWith('h');
      minutes = isHours ? value * 60 : value;
      work = _cut(text, match);
    }
  }
  return (remainingText: _tidy(work), minutes: minutes);
}

/// A note in round brackets, "(kirim ke Bu Sari)", becomes a note on the
/// task instead of a lump at the end of the title (design section 7.15).
({String remainingText, String? note}) extractInlineNote(String text) {
  final match = RegExp(r'\(([^()]{2,})\)').firstMatch(text);
  if (match == null) return (remainingText: text, note: null);
  final note = _tidy(match.group(1)!);
  if (note.isEmpty) return (remainingText: text, note: null);
  return (remainingText: _cut(text, match), note: note);
}
