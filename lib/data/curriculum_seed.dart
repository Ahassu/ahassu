import '../models/learning_path.dart';
import '../models/topic.dart';

/// The full Azure MLOps curriculum, fundamentals -> expert, plus Kubernetes,
/// interview prep, and a capstone project. Seeded once into Firestore when
/// the learningPaths collection is empty. Freely editable afterwards from
/// the app itself.
List<LearningPath> buildSeedLearningPaths() {
  final raw = <(String, String?, List<String>)>[
    (
      'AI Fundamentals (AI-901)',
      'AI-901',
      [
        'Responsible AI principles',
        'How generative AI models work',
        'AI workload categories (generative, agentic, text, speech, vision, extraction)',
        'Prompts and agents in Microsoft Foundry',
        'Text and speech implementation with Foundry',
        'Computer vision and image generation with Foundry',
        'Information extraction with Content Understanding',
      ],
    ),
    (
      'Data Fundamentals (DP-900, optional)',
      'DP-900',
      [
        'Core data concepts: relational vs non-relational',
        'Relational data on Azure (SQL Database, SQL Managed Instance)',
        'Non-relational data on Azure (Cosmos DB, Blob/Table storage)',
        'Analytics workloads (Synapse, Data Factory, Databricks)',
      ],
    ),
    (
      'Python & Data Science Foundations',
      null,
      [
        'Python programming essentials',
        'NumPy and Pandas for data wrangling',
        'Statistics and probability for ML',
        'Data visualization (Matplotlib/Seaborn)',
        'SQL for data analysis',
      ],
    ),
    (
      'Databricks & SQL (Data Engineer Associate)',
      'DEA',
      [
        'Lakehouse architecture: Delta Lake and Unity Catalog',
        'Compute: all-purpose, job, and SQL warehouse clusters',
        'Data ingestion: Auto Loader, COPY INTO, Lakeflow Connect',
        'Medallion architecture: bronze, silver, gold layers',
        'SQL and PySpark: joins, dedup, aggregations, window functions',
        'Orchestration with Lakeflow Jobs',
        'CI/CD with Databricks Asset Bundles and Git folders',
        'Performance troubleshooting in the Spark UI',
        'Governance: GRANT/REVOKE, row/column masking in Unity Catalog',
      ],
    ),
    (
      'Core Machine Learning',
      null,
      [
        'Supervised learning: regression and classification',
        'Unsupervised learning: clustering and dimensionality reduction',
        'Model evaluation and metrics',
        'Feature engineering',
        'Deep learning fundamentals (CNN, RNN, Transformers)',
        'Scikit-learn, TensorFlow and PyTorch basics',
      ],
    ),
    (
      'MLOps Engineer Associate (AI-300)',
      'AI-300',
      [
        'MLOps infrastructure as code (Bicep, GitHub Actions)',
        'Experiment tracking with MLflow',
        'Training pipelines and hyperparameter tuning',
        'Model registration and versioning',
        'Real-time and batch endpoint deployment',
        'Data drift detection and retraining triggers',
        'GenAIOps infrastructure with Microsoft Foundry',
        'Prompt versioning and source control',
        'GenAI quality metrics and observability',
        'RAG tuning and fine-tuning',
      ],
    ),
    (
      'Docker & Containerization',
      null,
      [
        'Docker fundamentals: images, containers, volumes',
        'Writing Dockerfiles for ML model serving',
        'Container registries (ACR, Docker Hub)',
        'Multi-stage builds for lean ML images',
      ],
    ),
    (
      'Kubernetes Fundamentals (CKA path)',
      'CKA',
      [
        'Kubernetes architecture: control plane and nodes',
        'Pods, Deployments, Services',
        'ConfigMaps and Secrets',
        'Networking and Ingress',
        'Storage: PersistentVolumes and PVCs',
        'RBAC and cluster security',
        'Helm charts',
        'Azure Kubernetes Service (AKS)',
      ],
    ),
    (
      'Kubernetes for ML Workloads',
      null,
      [
        'Kubeflow pipelines',
        'Model serving with KServe / Seldon',
        'GPU scheduling in Kubernetes',
        'Autoscaling inference workloads (HPA, KEDA)',
      ],
    ),
    (
      'CI/CD & DevOps (AZ-400)',
      'AZ-400',
      [
        'Azure DevOps and GitHub Actions pipelines',
        'CI/CD stages for ML: validate data, train, test, deploy',
        'Infrastructure as Code (Bicep/Terraform)',
        'Release management and approvals',
        'Artifact management',
      ],
    ),
    (
      'MLOps on Azure (Expert)',
      null,
      [
        'MLOps maturity model',
        'End-to-end CI/CD/CT pipelines',
        'Model monitoring and data drift detection',
        'Feature stores',
        'Model governance and lineage',
        'A/B testing and canary deployments',
        'Cost optimization for ML workloads',
        'MLflow integration',
      ],
    ),
    (
      'Azure AI App and Agent Developer (AI-103, optional)',
      'AI-103',
      [
        'Choosing and deploying Foundry models',
        'Building generative AI apps with RAG',
        'Building and orchestrating multi-agent solutions',
        'Computer vision: image/video generation and editing',
        'Text analysis and speech in Foundry',
        'Information extraction with Content Understanding',
        'Responsible AI and agent governance',
      ],
    ),
    (
      'Interview Preparation',
      null,
      [
        'ML system design case studies',
        'Coding rounds: Python, SQL, algorithms',
        'ML theory deep-dives (bias-variance, regularization, etc.)',
        'Behavioral / STAR stories',
        'Mock interview: whiteboard an MLOps pipeline end to end',
      ],
    ),
    (
      'Capstone: End-to-End MLOps Project',
      null,
      [
        'Frame the problem and collect data',
        'Prototype the model in a notebook',
        'Wrap training in a DP-100 pipeline',
        'Containerize with Docker',
        'Deploy to AKS',
        'Set up CI/CD with an AZ-400 pipeline',
        'Add monitoring and alerting',
        'Write up the project as a portfolio piece',
      ],
    ),
  ];

  var order = 0;
  return raw.map((entry) {
    final (title, examCode, topicTitles) = entry;
    order += 1;
    return LearningPath(
      id: 'path_${order.toString().padLeft(2, '0')}',
      order: order,
      title: title,
      examCode: examCode,
      topics: topicTitles.asMap().entries.map((e) {
        return Topic(id: 'topic_${order}_${e.key}', title: e.value);
      }).toList(),
    );
  }).toList();
}
