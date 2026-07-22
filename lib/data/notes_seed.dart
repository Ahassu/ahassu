import '../models/note.dart';

/// Full detailed study notes for every learning path that has a guide —
/// the actual content (domains, concepts, code, traps, glossary,
/// checklist), not just a link out. Seeded once per note, using fixed ids
/// so re-running never duplicates or clobbers notes you write yourself.
/// The original artifact link is kept at the top of each note for the
/// diagram/visual version.
List<Note> buildSeedGuideNotes() {
  final raw = <(String pathId, String pathTitle, String examCode, String url, String content)>[
    ('path_01', 'AI Fundamentals (AI-901)', 'AI-901',
        'https://claude.ai/code/artifact/9d2d7c9e-7afa-470f-b933-17985c8cdaa8', _ai901),
    ('path_02', 'Data Fundamentals (DP-900, optional)', 'DP-900',
        'https://claude.ai/code/artifact/e95ca055-edae-4de4-97d4-1889e7cc3654', _dp900),
    ('path_03', 'Python & Data Science Foundations', 'Foundations',
        'https://claude.ai/code/artifact/778cc77e-44e0-4749-9085-b71ec1caf887', _pythonDs),
    ('path_04', 'Databricks & SQL (Data Engineer Associate)', 'DEA',
        'https://claude.ai/code/artifact/9e6694c5-8609-437d-a9d3-11e5f8df37a7', _databricks),
    ('path_05', 'Core Machine Learning', 'Foundations',
        'https://claude.ai/code/artifact/c42ad2dd-f415-4dd9-906b-a5006ee84b9b', _coreMl),
    ('path_06', 'MLOps Engineer Associate (AI-300)', 'AI-300',
        'https://claude.ai/code/artifact/0846e3d9-13bd-4b87-9143-7df36ca0f8fd', _ai300),
    ('path_07', 'Docker & Containerization', 'Foundations',
        'https://claude.ai/code/artifact/d7fee4c1-9c16-4b57-bc9d-ad9469d24e3c', _docker),
    ('path_08', 'Kubernetes Fundamentals (CKA path)', 'CKA',
        'https://claude.ai/code/artifact/05bc46c8-1a30-405a-984c-cf8659077bd4', _cka),
    ('path_09', 'Kubernetes for ML Workloads', 'Foundations',
        'https://claude.ai/code/artifact/9cef6357-1cf6-424e-a8ab-4385c1882e56', _k8sMl),
    ('path_10', 'CI/CD & DevOps (AZ-400)', 'AZ-400',
        'https://claude.ai/code/artifact/87c9265b-f7a5-4da2-b68a-4371b83ad05b', _az400),
    ('path_11', 'MLOps on Azure (Expert)', 'Expert',
        'https://claude.ai/code/artifact/0261c147-dad7-4d0b-a584-d659be6c9c04', _mlopsExpert),
    ('path_12', 'Azure AI App and Agent Developer (AI-103, optional)', 'AI-103',
        'https://claude.ai/code/artifact/72f71fb9-d364-4a49-ba07-ff9040ad0593', _ai103),
  ];

  final now = DateTime.now();
  return raw.map((entry) {
    final (pathId, pathTitle, examCode, url, content) = entry;
    return Note(
      id: 'note_guide_$pathId',
      title: 'Study Guide — $examCode',
      body: '${content.trim()}\n\n'
          '────────────────────\n'
          'Full visual guide with diagrams: $url',
      learningPathId: pathId,
      learningPathTitle: pathTitle,
      createdAt: now,
      updatedAt: now,
    );
  }).toList();
}

const _ai901 = '''
AZURE AI FUNDAMENTALS — AI-901
Replaces the retired AI-900. Two domains: theory (40–45%), hands-on building in Microsoft Foundry (55–60%). Passing score 700/1000. Assumes basic Python — AI-900 didn't.

DOMAIN 1 — Identify AI concepts & capabilities (40–45%)

Responsible AI — six principles:
• Fairness — treat all groups equitably; watch for training-data bias
• Reliability & safety — consistent behavior, fails gracefully
• Privacy & security — data protected, used only as consented
• Inclusiveness — works across abilities, languages, backgrounds
• Transparency — people understand why a decision was made
• Accountability — humans stay responsible for the system

How generative models work:
A transformer predicts the next token repeatedly, conditioned on everything before it, until a stop condition. Tokenization splits text into sub-word units. Deployment parameters: temperature (randomness), max tokens (output cap), top_p (nucleus sampling).

AI workload categories:
• Generative & agentic AI — new content, or multi-step autonomous action
• Text analysis — keyword extraction, entity detection, sentiment, summarization
• Speech — recognition (speech-to-text) and synthesis (text-to-speech)
• Computer vision — image understanding + image-generation models
• Information extraction — structured data from text/image/audio/video

TRAP: "Agentic AI" means an agent plans and takes a sequence of actions (often calling tools) toward a goal — not just a single chat reply.

DOMAIN 2 — Implement with Microsoft Foundry (55–60%)

Generative AI apps & agents:
• System prompt sets persistent behavior; user prompt is the actual request
• Deploy and test a model in the Foundry portal playground before writing code
• Foundry SDK builds a lightweight chat client programmatically
• An agent = model + instructions + tools + optional knowledge sources
• Lightweight client apps call an agent instead of a raw model endpoint

Text, speech, vision:
• Text analysis via Foundry Tools; translation via Azure Translator or LLM flows
• Speech-to-text/text-to-speech wired directly into agentic interactions
• Multimodal models take image + text together and reason about both
• Image generation + editing (inpainting, mask-based modification)

Information extraction:
• Azure Content Understanding — the Foundry tool for structured extraction
• Works across documents/forms, images, and audio/video

TRAP: "Extract vendor, total, due date from scanned invoices" = Content Understanding, not Document Intelligence by name (though it descends from it).

GLOSSARY
Microsoft Foundry — unified portal + SDK for AI apps/agents, successor to Azure AI Studio
Agent — model + instructions + tools + knowledge, capable of multi-step action
Multimodal model — accepts more than one input type (text/image/audio) at once
Content Understanding — Foundry tool for structured extraction
Temperature — inference param controlling output randomness
Context window — max tokens a model can consider at once

EXAM-DAY CHECKLIST
☐ State all six Responsible AI principles from memory
☐ Explain how a transformer generates text token by token
☐ Comfortable with basic Python syntax
☐ Know the difference between a plain chat call and an agent
☐ Have actually deployed a model and chatted with it in Foundry
☐ Content Understanding = the answer for "extract structured data from X"
''';

const _dp900 = '''
AZURE DATA FUNDAMENTALS — DP-900
Four domains, ~60 min, 40–60 questions, pass 700/1000, no coding required.

DOMAIN 1 — Core data concepts (25–30%)
Data shapes: structured (fixed schema, rows/columns) · semi-structured (tagged, no fixed schema — JSON/XML) · unstructured (no predefined model — images, audio, free text).
Workload types: OLTP = many small fast transactions, powers live apps. OLAP = large complex queries over historical data for reporting. Batch = scheduled chunks; streaming = continuous.
Data roles: DBA (provisions/secures databases) · data engineer (builds pipelines) · data analyst (reports/dashboards).
TRAP: "fast, frequent, small transactions" = OLTP; "historical trends across years" = OLAP.

DOMAIN 2 — Relational data on Azure (20–25%)
Primary key uniquely identifies a row; foreign key references another table's primary key. Normalization reduces redundancy. ACID = Atomicity, Consistency, Isolation, Durability. T-SQL queries with SELECT/JOIN/etc.
Services: Azure SQL Database (PaaS, least admin) · Azure SQL Managed Instance (PaaS, near-full compatibility, for lift-and-shift) · SQL Server on Azure VMs (IaaS, most admin) · Azure Database for PostgreSQL/MySQL.
TRAP: PaaS vs IaaS hinges on "who patches the OS" — SQL DB/Managed Instance = Microsoft patches; VM = you patch.

DOMAIN 3 — Non-relational data on Azure (15–20%)
NoSQL models: key-value (simplest) · document (JSON-like, self-contained) · column-family (dynamic columns per row, sparse data) · graph (nodes + edges for relationships).
Services: Azure Cosmos DB (globally distributed, multi-model via SQL/Mongo/Cassandra/Gremlin/Table APIs) · Blob Storage (hot/cool/archive tiers) · Table Storage (lightweight key-value) · Azure Files (SMB/NFS shares).
TRAP: "globally distributed, low-latency, multi-model" always = Cosmos DB, whatever the data shape.

DOMAIN 4 — Analytics workloads on Azure (25–30%)
Data warehouse = structured, OLAP-optimized, usually a star schema (central fact table of measures + surrounding dimension tables of descriptive attributes). Data lake = raw data, native format, pre-shaping. ETL transforms before loading; ELT loads raw first, transforms inside the target store.
Services: Azure Synapse Analytics (warehousing + Spark) · Azure Data Factory (orchestrates ETL/ELT) · Azure Databricks (Spark platform) · Data Lake Storage Gen2 · Power BI.
Power BI vocabulary: dataset = connected data; report = multi-page visuals over a dataset; dashboard = single-page pinned tiles from one or more reports.

GLOSSARY
Fact table — central star-schema table with numeric measures
Dimension table — descriptive attributes joined to a fact table
Partition key — field distributing data across Cosmos DB partitions
Request unit (RU) — Cosmos DB's cost currency per operation
Data mart — subset of a warehouse scoped to one business area
Schema-on-read vs schema-on-write — lake vs relational table

EXAM-DAY CHECKLIST
☐ Classify structured/semi-structured/unstructured on sight
☐ OLTP vs OLAP with one-line examples
☐ PaaS (Azure SQL DB) vs IaaS (SQL Server on VM)
☐ Match NoSQL shape to the right Cosmos DB API
☐ Star schema: fact vs dimension tables
☐ Power BI dataset vs report vs dashboard
''';

const _pythonDs = '''
PYTHON & DATA SCIENCE FOUNDATIONS
No certification — the toolkit everything after this leans on.

MODULE 1 — Python essentials
Core types: lists, dicts, tuples, sets. Comprehensions build a list/dict in one expression. Functions with *args/**kwargs (mirrors sklearn/matplotlib call style). Virtual environments (venv/conda) isolate project dependencies. Reading tracebacks: read the last line first, then work upward.

MODULE 2 — NumPy & Pandas
ndarray = contiguous fixed-type memory block; operations run vectorized, not in a Python loop — this is why for-loops over a DataFrame are a red flag. Broadcasting stretches smaller arrays automatically. DataFrame/Series = labeled 2D table / 1D column. .loc = label-based indexing, .iloc = position-based. groupby = split-apply-combine.
TRAP: chained indexing like df[df.x>0]['y']=1 can silently write to a copy — use .loc[df.x>0,'y']=1 instead.

MODULE 3 — Statistics & probability for ML
Mean/median/mode: median resists outliers, mean doesn't. Variance/std = spread. Skew = long tail pulls mean from median. ~68% of values fall within 1 std of the mean, ~95% within 2 (normal distribution rule of thumb). Correlation ranges -1 to 1; correlation ≠ causation. Bayes' theorem underlies naive Bayes classifiers. Hypothesis testing/p-values decide if an effect is real or noise. Confidence intervals give a range, not a point estimate.

MODULE 4 — Data visualization
Matplotlib = low-level engine; Seaborn = statistically-aware layer on top. Pick the chart from the question, not the data you have open: bar = compare categories, line = trend over time, scatter = relationship between two variables, heatmap = correlation grid across many variables.

MODULE 5 — SQL for data analysis
Logical execution order: FROM → WHERE → GROUP BY → SELECT → ORDER BY (opposite of how it's typed). INNER JOIN drops unmatched rows either side; LEFT JOIN keeps every row from the left table. Window functions (ROW_NUMBER, RANK, LAG/LEAD) compute per-group values without collapsing rows. CTEs (WITH clause) name intermediate queries for readability. COALESCE for defaults; remember NULL = NULL is never true.
TRAP: more rows than expected after a JOIN usually means a hidden one-to-many relationship duplicating rows before your GROUP BY — check row counts before/after the join.

GLOSSARY
Vectorization — apply an operation to a whole array at once
dtype — fixed data type of a NumPy array/Pandas column
Outlier — value far from the rest of the distribution, investigate before dropping
Normalization — rescale numeric features to a common range
Cardinality — distinct-value count in a column
Long vs wide format — one row per observation vs one column per variable

READINESS CHECK
☐ Write a list/dict comprehension without looking it up
☐ Know when NumPy beats a Python list, and why
☐ Compute and explain mean/median/std, describe skew in your own data
☐ Pick the right chart type for a question
☐ Write a JOIN + GROUP BY query and explain a row-count change
''';

const _databricks = '''
DATABRICKS & SQL — DATA ENGINEER ASSOCIATE (DEA)
Official May 2026 exam guide: 45 questions, 90 min, \$200, 7 domains (no published % weights — study all seven).

DOMAIN 1 — Databricks Intelligence Platform
Delta Lake = open storage format adding ACID transactions, schema enforcement, time travel on top of Parquet. Unity Catalog = single metastore for permissions/lineage/discovery across workspaces. Lakehouse = one copy of data serving both BI and AI workloads.
Compute: all-purpose cluster (interactive dev, higher idle cost) · job cluster (spins up for one scheduled run, terminates) · SQL warehouse (high-concurrency, autoscaling, many analysts).
TRAP: "many simultaneous analysts" always = high-concurrency SQL warehouse, not a fixed all-purpose cluster.

DOMAIN 2 — Data ingestion & loading
COPY INTO — SQL command, incremental, idempotent load from cloud storage. Auto Loader — scalable streaming/batch ingestion with schema inference/enforcement/evolution. Lakeflow Connect — standard/managed connectors for enterprise sources.
  COPY INTO main.sales.raw_orders FROM 's3://raw-bucket/orders/' FILEFORMAT=JSON COPY_OPTIONS('mergeSchema'='true');
TRAP: continuous/unknown-volume/evolving-schema files = Auto Loader; a known simple batch = COPY INTO.

DOMAIN 3 — Data transformation & modeling
Medallion architecture: bronze (raw, as-ingested) → silver (cleaned, deduped, typed) → gold (aggregated, BI-ready views/materialized views).
Joins: inner, left, broadcast (small table vs huge one), multi-key, cross, union/union all. Dedup/aggregation: count, approx_count_distinct, window functions. Tuning: spark.sql.shuffle.partitions, spark.sql.autoBroadcastJoinThreshold, executor/driver memory.
  CREATE OR REPLACE TABLE main.sales.silver_orders AS SELECT order_id, customer_id, CAST(order_ts AS TIMESTAMP) AS order_ts, amount FROM main.sales.raw_orders WHERE amount IS NOT NULL QUALIFY ROW_NUMBER() OVER (PARTITION BY order_id ORDER BY order_ts DESC)=1;
REAL WORLD: a slow join is almost always a shuffle problem — check if the smaller side should be broadcast before reaching for a bigger cluster.

DOMAIN 4 — Working with Lakeflow Jobs
Task types: notebook, SQL query, dashboard, pipeline — wired into a DAG. Control flow: retries, conditional branching/looping. Triggers: scheduled, file arrival, table update.

DOMAIN 5 — Implementing CI/CD
Git Folders (formerly Repos): branch/commit/PR from the workspace UI. Databricks Asset Bundles (DABs) package Jobs/pipelines as code with per-environment variables. Databricks CLI validates/deploys bundles from automated pipelines.
  databricks bundle validate -t prod
  databricks bundle deploy -t prod

DOMAIN 6 — Troubleshooting, monitoring, optimization
Data skew = one partition holds disproportionate data, one task lags the rest — visible as one wildly outlying task duration vs. a field of fast ones in the Spark UI. Fix with adaptive query execution skew-join handling, or salt the join key. Shuffling/spilling = data movement/disk spill, visible in stage metrics. Liquid Clustering adapts file layout automatically. Cluster failures: startup, library conflicts, OOM — distinct log signatures.

DOMAIN 7 — Governance & security
Permissions cascade: Metastore → Catalog → Schema → Table. Managed tables: Unity Catalog owns the data lifecycle (dropping deletes data). External tables: you own storage (dropping only removes the catalog reference).
  GRANT SELECT ON SCHEMA main.sales TO `analysts`;
  REVOKE MODIFY ON TABLE main.sales.silver_orders FROM `contractors`;
Row/column-level security via masking functions and row filters; ABAC policies manage this centrally across many tables at once.

GLOSSARY
Time travel — query a Delta table as of a past version/timestamp
Broadcast join — send a small table to every executor, avoid shuffling the large one
Idempotent load — re-running ingestion doesn't duplicate data (COPY INTO default)
DAG — task-dependency structure behind a Lakeflow Job
Bundle target — an environment (dev/test/prod) a DAB deploys to
Materialized view — precomputed, incrementally refreshed query result

EXAM-DAY CHECKLIST
☐ Choose the right compute type from a one-line scenario
☐ COPY INTO vs. Auto Loader — know the trigger words
☐ Write joins/window functions/dedup logic in SQL and PySpark
☐ Read a Spark UI stage summary and diagnose skew vs spill vs undersized cluster
☐ Write GRANT/REVOKE and explain permission cascade
☐ Know what a Databricks Asset Bundle promotes across dev/test/prod
''';

const _coreMl = '''
CORE MACHINE LEARNING
No certification — the modeling foundation AI-300 and every MLOps topic after it assume you already have.

MODULE 1 — Supervised learning
Linear/logistic regression — always fit first as a baseline. Decision trees & random forests — trees split on feature thresholds, forests average many trees to cut variance. Gradient boosting (XGBoost/LightGBM) — trees built sequentially correcting prior errors, usually the strongest tabular baseline. SVMs maximize the margin between classes. k-NN classifies by majority vote among nearest neighbors.
REAL WORLD: start with logistic regression or a small gradient-boosted tree before reaching for anything fancier — you need that baseline number to know if complexity is earning its keep.

MODULE 2 — Unsupervised learning
k-means partitions into k clusters via nearest-centroid assignment. Hierarchical clustering builds nested clusters, no need to pick k upfront. DBSCAN clusters by density, naturally finds outliers. PCA projects high-dimensional data onto fewer variance-capturing axes. t-SNE/UMAP = nonlinear reduction mainly for 2D visualization.

MODULE 3 — Model evaluation & metrics
Train/validation/test split: fit on train, tune on validation, test touched once. k-fold cross-validation rotates the held-out slice k times, averages results — better for small datasets. Data leakage: fit scalers/encoders on training data ONLY, then transform validation/test.
Classification metrics: accuracy, precision (TP/(TP+FP), "of what I flagged, how much was right"), recall (TP/(TP+FN), "of what was true, how much did I catch"), F1, ROC-AUC, confusion matrix. Regression: MAE, MSE, RMSE, R².
Bias-variance: underfitting = too simple, high bias; overfitting = memorized noise, high variance; the sweet spot follows the trend without chasing every point.
REAL WORLD: fraud detection wants high recall (catch it all); spam filtering wants high precision (don't bury the inbox) — the tradeoff is a business decision, not math.

MODULE 4 — Feature engineering
Encode categoricals: one-hot for low cardinality, target/embedding encoding for high. Scale (standardize or min-max) for distance/gradient-based models. Impute missing values with mean/median/mode, or add a "was missing" indicator when missingness is informative itself. Derived features (ratios, date parts) expose structure raw columns hide.
  preprocess = ColumnTransformer([("scale", StandardScaler(), ["age","income"]), ("encode", OneHotEncoder(handle_unknown="ignore"), ["region"])])
  X_train_ready = preprocess.fit_transform(X_train); X_test_ready = preprocess.transform(X_test)

MODULE 5 — Deep learning fundamentals
CNNs: convolutions detect local patterns (edges/textures), pooling shrinks and generalizes, dense layers make the final call. RNNs process sequences step by step carrying hidden state; LSTM/GRU fight vanishing gradients over long sequences. Transformers replace recurrence with self-attention — every position looks at every other position at once; the architecture behind modern LLMs and increasingly vision too. ReLU = default hidden-layer activation; softmax turns final scores into class probabilities.

MODULE 6 — Frameworks
scikit-learn — tabular data, classical algorithms, consistent .fit()/.predict() API. PyTorch — custom architectures, dynamic graphs, default for most current deep learning. TensorFlow/Keras — production pipelines, mobile/edge export (TF Lite).

GLOSSARY
Hyperparameter — set before training (learning rate, tree depth), not learned
Epoch — one full pass through the training dataset
Regularization — penalizing complexity (L1/L2, dropout) to reduce overfitting
Class imbalance — one label vastly outnumbers another; accuracy becomes misleading

READINESS CHECK
☐ Explain bias-variance tradeoff with your own example
☐ Know which metric to lead with for an imbalanced classification problem
☐ Build a leakage-free preprocessing pipeline in scikit-learn
☐ Describe what a convolution and an attention layer are each doing
☐ Choose between scikit-learn, PyTorch, TensorFlow for a given project
''';

const _ai300 = '''
MLOPS ENGINEER ASSOCIATE — AI-300
Replaces the retired DP-100. The most directly relevant Microsoft exam to this whole app. 40–60 questions, 150 min, pass 700/1000. Five domains.

DOMAIN 1 — Design & implement MLOps infrastructure (15–20%)
Workspace resources: datastores, compute targets (instance = dev, cluster = training, inference cluster), environments (versioned Docker/conda), components (reusable pipeline steps), registries (share across workspaces).
IaC: Bicep + Azure CLI to deploy the workspace declaratively. GitHub Actions automates provisioning + CI/CD triggers. Network restriction via private endpoints. Managed identities + RBAC scoped tightly.
TRAP: "repeatable, auditable, version-controlled infrastructure" = Bicep + GitHub Actions, not manual portal clicks.

DOMAIN 2 — ML model lifecycle & operations (25–30%, largest)
Orchestrate training: MLflow tracking logs params/metrics/artifacts; AutoML/notebooks/training scripts are three entry points into the same tracking; HyperDrive = automated hyperparameter sweep; training pipelines chain data prep → train → evaluate.
  with mlflow.start_run(): mlflow.log_param("n_estimators",200); model.fit(...); mlflow.log_metric("f1", f1_score(...)); mlflow.sklearn.log_model(model,"model",registered_model_name="churn-predictor")
Register/deploy/monitor: register an MLflow model with its artifact + feature spec; run Responsible AI checks before promotion; real-time endpoints = low-latency single predictions, batch endpoints = large offline scoring; progressive rollout with safe rollback; data drift detection + retraining triggers.
TRAP: real-time endpoints answer "predict this row now" (a live app); batch answers "score this file overnight" — scenario keywords tell you which.

DOMAIN 3 — Design & implement GenAIOps infrastructure (20–25%)
Foundry projects provisioned via Bicep/CLI like everything else. Deployment options: serverless API (pay-per-call) vs managed compute (dedicated). Provisioned throughput units (PTUs) = reserved capacity for predictable latency at volume. Prompts versioned in Git like code — commit, compare variants, promote the winner.
TRAP: "high-volume, predictable-latency production" = provisioned throughput; "sporadic, low-volume, cost-sensitive" = serverless.

DOMAIN 4 — GenAI quality assurance & observability (10–15%)
Four core metrics: groundedness (backed by retrieved facts?), relevance (answers the question?), coherence (logical, ordered?), fluency (natural language?) — scored against a curated test dataset, plus a separate risk/safety pass. Foundry continuous monitoring watches production traffic, not just pre-release. Track latency/throughput and token cost per feature/customer. Logging/tracing gives step-by-step visibility into what an agent or RAG pipeline did.
REAL WORLD: instrument token cost from day one — a RAG feature fine in testing can quietly become the biggest line item in the Azure bill once traffic ramps.

DOMAIN 5 — Optimize generative AI systems (10–15%)
RAG tuning knobs: chunk size, similarity threshold, embedding model choice, hybrid search (semantic + keyword). A/B test RAG changes against real traffic, not just offline metrics. Fine-tuning + synthetic data adapts a foundation model to a narrow domain.
TRAP: right documents retrieved but answer still vague = a generation/prompt problem, not a retrieval problem — diagnose which half of RAG is actually failing.

GLOSSARY
MLOps vs GenAIOps — traditional models vs generative AI apps/agents, together "AIOps"
Data drift — production input diverging from training distribution
Canary deployment — small traffic slice to a new model version first
PTU — provisioned throughput unit
Groundedness — how well an answer is supported by retrieved source material
Top-k — number of retrieved chunks passed to the generation model

EXAM-DAY CHECKLIST
☐ Provision an ML workspace with Bicep + wire into GitHub Actions
☐ Trace the full lifecycle: MLflow run → monitored production endpoint
☐ Know real-time vs batch endpoints, serverless vs provisioned throughput
☐ Name all four GenAI quality metrics and what each measures
☐ Comfortable with RAG tuning knobs: chunk size, top-k, hybrid search
☐ Hands-on time in Microsoft Foundry, not just Azure ML
''';

const _docker = '''
DOCKER & CONTAINERIZATION
No certification — the packaging skill every deployment step after this assumes.

MODULE 1 — Images, containers, volumes
Image = read-only, layered template (one layer per Dockerfile instruction). Container = a running instance of an image, with its own writable layer. Volume = storage outside the writable layer, survives container removal. Registry = where built images live (Docker Hub, ACR).
  docker build -t churn-model:v1 .
  docker run -p 8000:8000 -v ./data:/app/data churn-model:v1
  docker ps ; docker logs <container-id>
TRAP: anything written inside a container but not in a mounted volume disappears when the container is removed — never store checkpoints/logs you care about only in the writable layer.

MODULE 2 — Dockerfiles for ML serving
Order matters: put what changes least at the top so a code edit doesn't force a full dependency reinstall — FROM, then COPY requirements + RUN pip install (cached), then COPY app code last. EXPOSE documents the port (doesn't publish it — that's -p at runtime). CMD = default overridable command; ENTRYPOINT = fixed, CMD becomes its args. .dockerignore keeps the build context small.
REAL WORLD: a serving image should never bundle the training dataset — copy in only the trained artifact + inference code, keeping training and serving concerns in separate images.

MODULE 3 — Container registries
  docker tag churn-model:v1 myregistry.azurecr.io/churn-model:v1
  az acr login --name myregistry
  docker push myregistry.azurecr.io/churn-model:v1
ACR = private, integrated with AKS/Azure RBAC, default for Azure deployments. Docker Hub = public/private, default registry for base images you build FROM.

MODULE 4 — Multi-stage builds for lean ML images
Stage 1 (builder): full toolchain, compiles/trains, ~2GB. Stage 2 (runtime): starts fresh from a minimal base, COPY --from=builder only the artifact, ~150MB. Smaller image = smaller attack surface + faster deploys/autoscaling.
REAL WORLD: check image size with `docker images` after every meaningful Dockerfile change — a training library leaking into the runtime stage is one of the most common silent regressions.

GLOSSARY
Layer — one cached, immutable filesystem diff from a single Dockerfile instruction
Build context — the directory sent to the Docker daemon at build time
Tag — a human-readable pointer to a specific image (v1, latest)
Base image — what a Dockerfile's FROM builds on top of
Bind mount — mapping a host directory directly into a container (local dev)

READINESS CHECK
☐ Explain image vs. container vs. volume without hesitating
☐ Order Dockerfile instructions to maximize cache reuse
☐ Push and pull an image from Azure Container Registry
☐ Write a multi-stage Dockerfile shipping only the trained artifact
☐ Know why training data and serving code belong in separate images
''';

const _cka = '''
KUBERNETES FUNDAMENTALS — CKA
CNCF/Linux Foundation, vendor-neutral, performance-based (real kubectl against real clusters, no multiple choice). ~2 hrs, pass 66%, docs allowed open-book. Five domains.

DOMAIN 1 — Cluster architecture, installation & config (25%)
Control plane: API server (front door, everything talks to it) · etcd (key-value source of truth, back it up, never edit directly) · scheduler (decides node placement) · controller manager (reconciliation loops). Worker nodes: kubelet, kube-proxy, container runtime. kubeadm bootstraps a cluster. kubeconfig/contexts control which cluster/identity kubectl uses. Helm = package manager (chart bundles manifests + templating). AKS: Microsoft manages the control plane, you manage node pools + workloads.
TRAP: "who patches the control plane" — AKS = Microsoft; self-managed cluster = you.

DOMAIN 2 — Workloads & scheduling (15%)
Pod = smallest deployable unit. DaemonSet = one pod per node. StatefulSet = stable identity/storage per replica (databases). ConfigMaps/Secrets inject config without baking into the image — Secrets are base64, not encrypted by default. Scheduling: nodeSelector (simple), taints/tolerations (repel unless allowed), affinity/anti-affinity (richer co-location rules).
TRAP: base64 ≠ encrypted — anyone with API access can decode a Secret; real protection = RBAC restricting who can read it, plus encryption at rest on etcd.

DOMAIN 3 — Services & networking (20%)
ClusterIP = internal-only, default. NodePort = static port on every node. LoadBalancer = provisions a cloud LB. Ingress = Layer-7 host/path routing, needs an Ingress controller installed (NGINX etc.) — it's a routing rule, not a load balancer by itself. CoreDNS = in-cluster service discovery by name. NetworkPolicy = firewall between pods; without one, all pods can reach all pods.

DOMAIN 4 — Storage (10%)
PersistentVolume (PV) = actual provisioned storage. PersistentVolumeClaim (PVC) = a pod's request for storage. StorageClass = defines dynamic provisioning. Access modes: ReadWriteOnce, ReadOnlyMany, ReadWriteMany.

DOMAIN 5 — Troubleshooting (30%, the biggest single domain)
Pod failures: ImagePullBackOff (bad image/auth), CrashLoopBackOff (app exits immediately), Pending (unschedulable — check resources/taints). kubectl describe = why something won't start; kubectl logs = why something running is misbehaving.
  kubectl get pods -o wide
  kubectl describe pod my-pod
  kubectl logs my-pod --previous
  kubectl auth can-i create pods --as=system:serviceaccount:default:my-sa
Network troubleshooting: confirm DNS resolution inside a pod, check NetworkPolicies, verify Service selector labels actually match pod labels.
REAL WORLD: most "the API is down" pages trace to one of three things — a bad rollout, a Service/Pod label-selector mismatch, or a too-tight resource limit triggering OOMKills. Check those three first.

GLOSSARY
Reconciliation loop — controller continuously correcting actual state toward desired state
Namespace — virtual cluster-within-a-cluster
Liveness vs readiness probe — liveness restarts unhealthy containers; readiness controls traffic routing
OOMKilled — container terminated for exceeding memory limit
RBAC — Roles/ClusterRoles define permissions, bound via RoleBindings

EXAM-DAY CHECKLIST
☐ Comfortable in a real terminal, no IDE autocomplete
☐ Diagnose CrashLoopBackOff, ImagePullBackOff, Pending without lookup
☐ Know when to use Deployment vs DaemonSet vs StatefulSet
☐ Trace a PVC to its PV, explain the StorageClass in between
☐ Write a NetworkPolicy and a basic RBAC Role/RoleBinding from scratch
☐ Practice fast — troubleshooting alone is 30% of the score
''';

const _k8sMl = '''
KUBERNETES FOR ML WORKLOADS
No certification — the Kubernetes layer specific to serving/orchestrating ML, on top of CKA fundamentals.

MODULE 1 — Kubeflow pipelines
A component = one containerized, reusable step with typed inputs/outputs. A pipeline = a DAG of components, defined in Python via the Kubeflow Pipelines SDK. A run = one execution with lineage tracked automatically. Conditional/recurring runs: branch on a metric (only deploy if accuracy clears a bar), or schedule re-runs.
REAL WORLD: Kubeflow's real value isn't the DAG syntax — every run's inputs, code version, and outputs are captured automatically, so "which data trained the production model" stays answerable months later.

MODULE 2 — Model serving with KServe / Seldon
KServe = a CRD (InferenceService) standardizing serving across frameworks. Seldon Core = similar, strong focus on complex inference graphs (pre/post-processing, A/B tests, bandits). Scale-to-zero: idle pods scale to nothing, cold-start on next request, saves GPU cost for spiky traffic. Canary rollout routes a slice of traffic to a new version first.
  apiVersion: serving.kserve.io/v1beta1
  kind: InferenceService
  metadata: {name: churn-predictor}
  spec: {predictor: {sklearn: {storageUri: "gs://my-bucket/churn-model", minReplicas: 0}}}

MODULE 3 — GPU scheduling in Kubernetes
The NVIDIA device plugin advertises nvidia.com/gpu as a schedulable resource on GPU nodes — without it running, a node's GPUs are invisible to Kubernetes entirely. GPU requests are whole-unit only (unlike fractional CPU). Node taints commonly keep GPU nodes reserved for GPU workloads. Time-slicing/MIG share one physical GPU across multiple pods.
TRAP: requesting nvidia.com/gpu: 0.5 doesn't work like CPU fractional requests — standard scheduling is whole-unit; fractional sharing needs MIG or time-slicing configured separately.

MODULE 4 — Autoscaling inference workloads
HPA (built-in) scales replica count on CPU/memory (or custom metrics), minimum 1 replica. KEDA (add-on) scales on external events — queue depth, request rate — and can scale to zero, which HPA cannot. Cluster Autoscaler adds/removes nodes when pods can't be scheduled on existing capacity. Cold start = latency penalty loading a model into a freshly scaled pod — a real tradeoff, not free.
REAL WORLD: a GPU-backed service idle most of the day suits KEDA + scale-to-zero; a latency-sensitive endpoint under constant traffic doesn't — the cold start alone could blow an SLA.

GLOSSARY
CRD — Custom Resource Definition, how KServe/Seldon extend Kubernetes
Cold start — latency loading a model into a freshly scaled pod
MIG — Multi-Instance GPU, NVIDIA hardware partitioning
ScaledObject — the KEDA resource defining what metric drives scaling

READINESS CHECK
☐ Describe a Kubeflow pipeline as a DAG of independently-logged components
☐ Write a minimal KServe InferenceService manifest from memory
☐ Explain why GPU requests are whole-unit and what a device plugin does
☐ Explain when KEDA's scale-to-zero helps vs. hurts a workload
☐ Know the difference between HPA, KEDA, and the Cluster Autoscaler
''';

const _az400 = '''
DEVOPS ENGINEER EXPERT — AZ-400
Expert level, pass 700/1000. Not retiring — refreshed July 27, 2026 (content below already reflects that version). Five domains, one dominant.

DOMAIN 1 — Processes & communications (10–15%)
Flow of work: GitHub Flow, work-item tracking (GitHub Issues/Projects or Azure Boards), traceability from bug to fix commit. Dashboards: cycle time, lead time, MTTR. Documentation as code: wikis, Markdown, Mermaid diagrams versioned with the project.
TRAP: lead time = idea-to-production; cycle time = start-of-work-to-production — not the same metric.

DOMAIN 2 — Source control strategy (10–15%)
Branching: trunk-based (short-lived branches, needs strong CI gates), feature branch (isolation until PR merge), release branch (stabilize before shipping). Branch policies/protection rules: required reviewers, required checks. Git LFS for large files. Recovery: git reflog/fsck; git filter-repo to permanently scrub sensitive data.

DOMAIN 3 — Build & release pipelines (50–55%, dominant)
Package management: GitHub Packages / Azure Artifacts, SemVer or CalVer versioning. Testing: unit/integration/load tests as pipeline tasks, code coverage tracked, quality/release gates before promotion. GitHub Actions vs Azure Pipelines — both YAML CI/CD, choice depends on where source lives. Multi-stage pipelines with parallelism where independent. Reusable YAML templates/variable groups. YAML environments for checks/approvals.
Deployment strategies: blue-green (two environments, instant cutover/rollback) · canary (gradual traffic shift) · ring (progressively wider user groups) · feature flags (decouple deploy from release) · hotfix path (shorter pipeline for urgent fixes, safety gates intact).
IaC: Bicep/ARM/Azure Machine Configuration for desired state, version-controlled and tested like app code. Azure Deployment Environments for self-service on-demand environments.
Maintenance: track pipeline health (failure rate, duration trend, flaky tests); balance concurrency against cost; migrate classic pipelines to YAML.
TRAP: "avoid a stored long-lived credential in the pipeline" = workload identity federation (OIDC), not just "put it in Key Vault instead."

DOMAIN 4 — Security & compliance (10–15%)
Identity: Microsoft Entra service principals vs managed identities (system/user-assigned). Secrets: Azure Key Vault + workload identity federation/OIDC to avoid long-lived secrets. Access scoped to minimum needed (stakeholder access, outside collaborator access). Automated scanning: dependency (Dependabot), code (CodeQL), secret, license — wired in as gates. Microsoft Defender for Cloud DevOps Security centralizes findings across GitHub Advanced Security + Azure DevOps.

DOMAIN 5 — Instrumentation strategy (5–10%)
Telemetry: Application Insights (app-level), VM/Container Insights, all feeding Azure Monitor. Distributed tracing follows one request across services. KQL queries Azure Monitor Logs directly.
  requests | where timestamp > ago(1h) | summarize total=count(), failed=countif(success==false) by cloud_RoleName | extend errorRate = round(100.0*failed/total,2)

GLOSSARY
MTTR — mean time to recovery
OIDC / workload identity federation — short-lived token exchange, no stored secret
Blast radius — how much of the system a failed change can affect
Feature flag — runtime toggle separating "deployed" from "enabled"
SemVer vs CalVer — version tied to change type vs. release date

EXAM-DAY CHECKLIST
☐ Comfortable in both GitHub Actions and Azure Pipelines YAML
☐ Explain blue-green, canary, ring with one tradeoff each
☐ Workload identity federation as the default "no stored secrets" answer
☐ Know where each scan type (dependency/code/secret/container) plugs into a pipeline
☐ Read a basic KQL query against Application Insights data
☐ Remember: pipelines alone are over half the exam
''';

const _mlopsExpert = '''
MLOPS ON AZURE — EXPERT
No single certifying exam — the architectural/organizational layer AI-300 assumes a mature team already has.

MODULE 1 — MLOps maturity model
Level 0 manual (notebooks, manual handoffs) → 1 tracked (MLflow logging, still manual deploy) → 2 automated training (scheduled/triggered retraining) → 3 automated deployment (CI/CD promotes without manual steps) → 4 full CI/CD/CT (production monitoring auto-triggers retraining).
REAL WORLD: jumping straight to Level 4 before 1–2 are solid is a classic failure — automating retraining around untracked, unreliable experiments just ships bad models faster.

MODULE 2 — End-to-end CI/CD/CT pipelines
CI = test code + data validation before training starts. CD = promotes a model through stages gated by evaluation metrics, not just "it compiled." CT (continuous training) = the loop closes: a trigger (schedule, drift signal, new data volume) kicks off retraining automatically. CT is the piece most teams skip — without it, "MLOps" is DevOps applied to a model artifact that never updates itself.

MODULE 3 — Model monitoring & data drift detection
Data drift = input distribution shifts from training. Concept drift = the input-output relationship changes even if inputs look the same (fraud patterns evolve). PSI (Population Stability Index) and KL divergence quantify "how different." Ground-truth lag means monitoring often works with proxy signals for days/weeks before real outcomes are known.
REAL WORLD: a drift alert doesn't automatically mean retrain — it means go look; sometimes it's a real but temporary anomaly (a holiday spike) that shouldn't be trained in.

MODULE 4 — Feature stores
Solves training-serving skew: a feature computed one way in a notebook, subtly differently in the serving path. One feature definition feeds both an offline store (bulk/historical, training) and an online store (low-latency, serving). Point-in-time correctness prevents future data leaking into training. Feast is the common open-source option; Azure ML has a managed feature store on the same split.

MODULE 5 — Model governance & lineage
Lineage: an unbroken, queryable chain from raw data → features → training run → model version → deployment. Model cards document intended use, training data summary, limitations, evaluation results. Approval workflows require recorded sign-off tied to evidence. Audit trail: who deployed what, when, why.
REAL WORLD: "why did the model deny this loan application" needs an answer traced through lineage to a specific model version's documented behavior — not a shrug.

MODULE 6 — A/B testing & canary deployments
Canary answers "is it safe?" (small slice, watched for errors/latency). A/B test answers "is it actually better?" (deliberate, longer-running, measures a business metric with statistical rigor). Statistical significance needs enough traffic/time — peeking early inflates false positives. Guardrail metrics (latency, error rate) catch a hidden regression behind an apparent "win."

MODULE 7 — Cost optimization for ML workloads
Spot/low-priority compute for interruptible, checkpointable training. Right-sizing — an oversized always-on inference cluster is pure waste. Autoscaling/scale-to-zero — pay for GPU capacity only when there's traffic. Model compression (quantization, distillation) shrinks footprint with minimal accuracy loss. Batch vs real-time: don't pay for a live endpoint when a nightly job would do. Track token/compute cost per feature/customer for GenAI specifically.
REAL WORLD: the highest-leverage cost fix in most platforms isn't a smarter model — it's noticing an endpoint left running for a project that shipped six months ago.

MODULE 8 — MLflow integration
Tracking server = central store for every run's params/metrics/artifacts. Model registry = versioned models with stage transitions (staging → production → archived) and approval gates. Model flavors decouple storage from deployment target. Projects package code + environment for reproducibility.
  client.transition_model_version_stage(name="churn-predictor", version=7, stage="Production", archive_existing_versions=True)

GLOSSARY
Training-serving skew — feature computed differently at train vs. inference time
PSI — Population Stability Index, a drift metric
Model card — standardized doc of a model's use/data/limitations
Guardrail metric — secondary metric watched during an experiment
Quantization — reduced numeric precision to shrink/speed up a model
CT — continuous training, automated retraining triggered by schedule/drift/data

READINESS CHECK
☐ Place a real team on the 0–4 maturity ladder and name the next step
☐ Explain data drift vs. concept drift with a distinct example of each
☐ Understand why a feature store exists, in terms of the bug it prevents
☐ Trace a hypothetical production model back through full lineage
☐ Know when a canary is enough vs. when a full A/B test is warranted
☐ Name three concrete cost levers beyond "use a smaller model"
''';

const _ai103 = '''
AZURE AI APP AND AGENT DEVELOPER — AI-103
Replaces the retired AI-102. Where AI-901 is conceptual, this is hands-on building: agents, RAG, multimodal generation, in Python. Pass 700/1000. Five domains.

DOMAIN 1 — Plan & manage an Azure AI solution (25–30%)
Model choice: LLM (complex reasoning) · small model (low latency/cost, edge) · multimodal (image/audio/video input) · Foundry Tools (prebuilt capability like Speech/Search/Content Understanding). Setup: Foundry project structure, deployment options, CI/CD integration. Quotas/cost, monitoring (performance, drift, safety events, grounding quality, search index health). Security: managed identity, private networking, keyless credentials, RBAC — no long-lived secrets by default. Responsible AI: safety filters/guardrails, evaluators, trace logging + provenance metadata for auditing, agent governance via oversight modes/constraints/tool-access controls.
TRAP: "keyless" means managed identity/workload identity federation, not "no identity at all."

DOMAIN 2 — Implement generative AI & agentic solutions (30–35%, largest)
Building apps: deploy/consume LLMs, small, code, multimodal models via Foundry SDKs; implement RAG; tool-augmented multistep reasoning pipelines; evaluate for fabrication/relevance/quality/safety.
Building agents: define role/goal/conversation-tracking/tool schema; integrate function-calling + conversation memory; tools = APIs, knowledge stores, search, Content Understanding, custom functions; multi-agent orchestration (an orchestrator delegates to specialist agents, each with its own tools); autonomous/semi-autonomous workflows keep an approval step for high-stakes actions.
Optimize: prompt engineering + parameters (temperature, top_p, max tokens); self-critique/chain-of-thought reflection loops; observability (tracing, token analytics, safety signals, latency); hybrid orchestration mixing models with a rules engine where deterministic logic is more reliable.
  tools = [{"type":"function","function":{"name":"lookup_order",...}}]
  response = client.chat.completions.create(model="gpt-4o-mini", messages=messages, tools=tools, tool_choice="auto")
  if response.choices[0].message.tool_calls: result = lookup_order(**args)
TRAP: multiple specialized agents coordinating on one task = multi-agent orchestration; a single agent with many tools is a different pattern even though both use tool-calling.

DOMAIN 3 — Implement computer vision solutions (10–15%)
Generate/edit: text-to-image/video, inpainting, mask-based prompt-driven edits. Multimodal understanding: visual context analysis, captions, visual Q&A, accessibility alt-text. Content Understanding for vision: single-task vs pro-mode pipelines, object/region identification. Responsible AI: filter unsafe visual content, detect indirect prompt injection (malicious text embedded inside an uploaded image).
TRAP: text embedded in an image trying to redirect a multimodal model = indirect prompt injection, distinct from a user directly typing a bad prompt.

DOMAIN 4 — Implement text analysis solutions (10–15%)
Entity/topic/summary extraction and structured JSON output via generative prompting + Foundry Tools. Sentiment/tone/safety detection. Translation via Azure Translator or LLM-powered flows. Speech as an agent modality: speech-to-text/text-to-speech wired directly in, plus multimodal reasoning straight from audio.
  system = "Extract vendor, total, and due_date as JSON. No prose."
  response = client.chat.completions.create(model="gpt-4o-mini", messages=[...], response_format={"type":"json_object"})

DOMAIN 5 — Implement information extraction solutions (10–15%)
Ingest/index documents, images, audio, video. Search modes: semantic, hybrid, vector — chosen by how well pure keyword matching would serve the query. Enrichment skills extract structure from text/images/layout during ingestion. Content Understanding analyzers produce clean structured/markdown output specifically shaped for downstream agent reasoning — retrieval pipelines are wired in as a callable tool an agent reaches for mid-conversation, not just a chat backend.

GLOSSARY
Orchestration — coordinating multiple agents/tool calls toward one goal
Indirect prompt injection — malicious instructions hidden in retrieved/uploaded content
Hybrid search — vector/semantic similarity + keyword matching in one query
Function-calling — a model requesting execution of a defined tool mid-response
Groundedness — how well an answer is supported by retrieved content, not just memory
Provenance metadata — records of what data/tool call produced an agent action

EXAM-DAY CHECKLIST
☐ Justify a model choice against a stated latency/cost constraint
☐ Have built a multi-agent flow with distinct tool schemas per agent
☐ Comfortable writing Python against the Foundry SDK for models and agents
☐ Explain indirect prompt injection and name a mitigation
☐ Know when hybrid search beats pure vector or pure keyword search
☐ Describe how Content Understanding output is shaped for agent/RAG use
''';
