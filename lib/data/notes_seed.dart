import '../models/note.dart';

/// Reference notes pointing each learning path at its full study-guide
/// artifact (diagrams, code, exam-day checklists). Seeded once per note —
/// safe to re-run since each note has a fixed id and is just overwritten,
/// so it never duplicates or clobbers notes you write yourself.
List<Note> buildSeedGuideNotes() {
  final raw = <(String pathId, String pathTitle, String examCode, String url)>[
    ('path_01', 'AI Fundamentals (AI-901)', 'AI-901',
        'https://claude.ai/code/artifact/9d2d7c9e-7afa-470f-b933-17985c8cdaa8'),
    ('path_02', 'Data Fundamentals (DP-900, optional)', 'DP-900',
        'https://claude.ai/code/artifact/e95ca055-edae-4de4-97d4-1889e7cc3654'),
    ('path_03', 'Python & Data Science Foundations', 'Foundations',
        'https://claude.ai/code/artifact/778cc77e-44e0-4749-9085-b71ec1caf887'),
    ('path_04', 'Databricks & SQL (Data Engineer Associate)', 'DEA',
        'https://claude.ai/code/artifact/9e6694c5-8609-437d-a9d3-11e5f8df37a7'),
    ('path_05', 'Core Machine Learning', 'Foundations',
        'https://claude.ai/code/artifact/c42ad2dd-f415-4dd9-906b-a5006ee84b9b'),
    ('path_06', 'MLOps Engineer Associate (AI-300)', 'AI-300',
        'https://claude.ai/code/artifact/0846e3d9-13bd-4b87-9143-7df36ca0f8fd'),
    ('path_07', 'Docker & Containerization', 'Foundations',
        'https://claude.ai/code/artifact/d7fee4c1-9c16-4b57-bc9d-ad9469d24e3c'),
    ('path_08', 'Kubernetes Fundamentals (CKA path)', 'CKA',
        'https://claude.ai/code/artifact/05bc46c8-1a30-405a-984c-cf8659077bd4'),
    ('path_09', 'Kubernetes for ML Workloads', 'Foundations',
        'https://claude.ai/code/artifact/9cef6357-1cf6-424e-a8ab-4385c1882e56'),
    ('path_10', 'CI/CD & DevOps (AZ-400)', 'AZ-400',
        'https://claude.ai/code/artifact/87c9265b-f7a5-4da2-b68a-4371b83ad05b'),
    ('path_11', 'MLOps on Azure (Expert)', 'Expert',
        'https://claude.ai/code/artifact/0261c147-dad7-4d0b-a584-d659be6c9c04'),
    ('path_12', 'Azure AI App and Agent Developer (AI-103, optional)', 'AI-103',
        'https://claude.ai/code/artifact/72f71fb9-d364-4a49-ba07-ff9040ad0593'),
  ];

  final now = DateTime.now();
  return raw.map((entry) {
    final (pathId, pathTitle, examCode, url) = entry;
    return Note(
      id: 'note_guide_$pathId',
      title: 'Study Guide — $examCode',
      body: 'Full reference guide for this path, with diagrams, code, and an exam-day checklist:\n\n$url',
      learningPathId: pathId,
      learningPathTitle: pathTitle,
      createdAt: now,
      updatedAt: now,
    );
  }).toList();
}
