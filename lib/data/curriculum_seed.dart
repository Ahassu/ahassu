import '../models/learning_path.dart';
import '../models/topic.dart';

/// The full Azure MLOps curriculum, fundamentals -> expert, plus Kubernetes,
/// interview prep, and a capstone project. Seeded once into Firestore when
/// the learningPaths collection is empty. Freely editable afterwards from
/// the app itself.
List<LearningPath> buildSeedLearningPaths() {
  final raw = <(String, String?, List<String>)>[
    (
      'AI Fundamentals (AI-900)',
      'AI-900',
      [
        'AI workloads and considerations',
        'Responsible AI principles',
        'Machine learning concepts (regression, classification, clustering)',
        'Computer vision workloads',
        'Natural language processing workloads',
        'Generative AI workloads',
        'Azure AI services overview',
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
      'Azure Data Scientist Associate (DP-100)',
      'DP-100',
      [
        'Azure Machine Learning workspace setup',
        'Data assets and datastores',
        'Compute instances and compute clusters',
        'Designer, AutoML and notebooks',
        'Training and hyperparameter tuning (HyperDrive)',
        'Azure ML pipelines',
        'Model registration and versioning',
        'Responsible AI dashboard',
        'Deploying managed online and batch endpoints',
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
      'Azure AI Engineer Associate (AI-102, optional)',
      'AI-102',
      [
        'Implementing Azure AI services',
        'Knowledge mining',
        'Conversational AI (Bot Framework)',
        'Implementing Responsible AI',
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
