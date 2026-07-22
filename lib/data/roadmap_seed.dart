import '../models/roadmap.dart';

/// Seed roadmaps for every certification-bearing path in the curriculum.
/// Each is a short, hands-on, week-by-week route to exam day. Seeded once
/// into Firestore when the roadmaps collection is empty. Freely editable
/// afterwards (progress toggles) from the app itself.
List<RoadmapPlan> buildSeedRoadmaps() {
  final raw = <(
    String pathTitle,
    String examCode,
    String summary,
    List<(String weekLabel, String eyebrow, String title, String goal, List<String> tasks, String? lab, String? checkpoint, bool milestone)> stops,
  )>[
    (
      'AI Fundamentals',
      'AI-901',
      'Responsible AI, how generative models work, and hands-on building in Microsoft Foundry.',
      [
        (
          'Start', 'Setup', 'Get a Foundry project running',
          'You cannot learn a platform you have not opened. Twenty minutes, not a study session.',
          ['Create an Azure free account', 'Open Microsoft Foundry and deploy one small chat model', 'Send it one prompt and read the response'],
          null, 'You have deployed and talked to a model — that is the whole platform in miniature.', false,
        ),
        (
          'Week 1', 'Domain 1 · Concepts', 'Responsible AI & how models work',
          'Memorize the six principles cold, and understand the token-by-token mechanics behind generation.',
          ['Write all six Responsible AI principles from memory, twice', 'Explain tokenization and next-token prediction in your own words', 'Match each of the five workload categories to a one-line scenario'],
          'Tokenize a sentence by hand (split into words, then guess sub-word splits) before checking a real tokenizer.',
          'Can you state all six principles without looking?', false,
        ),
        (
          'Week 2', 'Domain 2 · Build', 'Build with Foundry',
          'Move from reading about prompts and agents to actually shipping one.',
          ['Write a system prompt and a user prompt for the same model, compare outputs', 'Deploy a model and test it in the Foundry portal playground', 'Build one single-agent solution with at least one tool'],
          'Build a two-turn agent that calls one custom function, even a fake weather lookup.',
          'Can you explain the difference between a plain chat call and an agent?', false,
        ),
        (
          'Week 3', 'Domain 2 · Practice', 'Vision, text, extraction — then the exam',
          'Cover the remaining implementation areas, then test yourself under real time pressure.',
          ['Run one multimodal image+text prompt', 'Run one text analysis task via Foundry Tools', 'Extract structured fields from a sample document with Content Understanding', 'Take a full-length practice exam'],
          null, 'Score 80%+ on a practice exam before booking the real one.', true,
        ),
      ],
    ),
    (
      'Data Fundamentals',
      'DP-900',
      'Core data concepts, relational and non-relational data, and analytics workloads on Azure.',
      [
        (
          'Start', 'Setup', 'Open the two database types once',
          'Get a free-tier Azure SQL Database and Cosmos DB account running before studying either.',
          ['Create an Azure free account', 'Create an Azure SQL Database and run one query', 'Create a Cosmos DB account and browse its API options'],
          null, 'Both databases are open in a browser tab — that is enough for today.', false,
        ),
        (
          'Week 1', 'Domain 1 · Concepts', 'Core data concepts',
          'The vocabulary domain: data shapes and workload types, over-learned.',
          ['Classify five real datasets you know as structured, semi-structured, or unstructured', 'Write one-line examples of OLTP and OLAP workloads', 'Learn the three data roles: DBA, data engineer, data analyst'],
          null, 'Can you sort a scenario into OLTP or OLAP in under five seconds?', false,
        ),
        (
          'Week 2', 'Domains 2–3 · Relational & non-relational', 'Model the same data two ways',
          'See the same information as a relational table and as a document — the differences stop being abstract.',
          ['Run a basic T-SQL query with a JOIN against your Azure SQL Database', 'Pick a Cosmos DB API and insert one document', 'Explain PaaS vs. IaaS using Azure SQL Database vs. SQL Server on a VM'],
          'Model one small dataset as a relational table and as a Cosmos DB document — notice what changes.',
          'Know which Cosmos DB API fits key-value, document, and graph shapes.', false,
        ),
        (
          'Week 3', 'Domain 4 · Analytics', 'Analytics workloads — then the exam',
          'Warehousing concepts and the pipeline services, finished with a full practice run.',
          ['Sketch a star schema for a dataset you know: one fact table, three dimension tables', 'Explore Synapse Analytics and Data Factory in the portal once each', 'Build one simple Power BI report from sample data', 'Take a full-length practice exam'],
          null, 'Score 80%+ on a practice exam before booking the real one.', true,
        ),
      ],
    ),
    (
      'Databricks & SQL',
      'DEA',
      'Lakehouse architecture, ingestion, SQL/PySpark transforms, orchestration, and governance.',
      [
        (
          'Start', 'Setup', 'Get a workspace running',
          'Twenty minutes of logistics, not a study session.',
          ['Sign up for Databricks Free Edition', 'Open a SQL editor and a notebook once each', 'Skim the official exam guide once, cover to cover, no note-taking'],
          null, 'Run one cell in a notebook and one query in the SQL editor before moving on.', false,
        ),
        (
          'Week 1', 'Domain 1 · Platform', 'Learn the shape of the platform',
          'The workspace, Delta Lake, Unity Catalog, and the three compute types.',
          ['Create one all-purpose cluster and one SQL warehouse; compare startup time and cost', 'Create a catalog and schema in Unity Catalog, once via UI and once via SQL', 'Read the Domain 1 section of your Databricks guide'],
          'Run CREATE CATALOG, CREATE SCHEMA, and CREATE TABLE for a throwaway table, then query it from both the SQL editor and a notebook.',
          'Explain out loud why a job cluster is cheaper for a nightly pipeline than an all-purpose cluster.', false,
        ),
        (
          'Week 2', 'Domain 2 · Ingestion', 'Get real data into a governed table',
          'COPY INTO and Auto Loader stop being syntax and become something you have actually run.',
          ['Upload a small CSV or JSON dataset into cloud storage or a Databricks volume', 'Load it with COPY INTO into a Unity Catalog table', 'Rebuild the same load with Auto Loader and force a schema change to see evolution happen live'],
          'Load the same dataset twice with COPY INTO and confirm row counts do not double.',
          'Given a one-line scenario, can you say COPY INTO or Auto Loader in under five seconds?', false,
        ),
        (
          'Week 3', 'Domain 3 · Transformation', 'Build bronze → silver → gold',
          'The medallion architecture stops being a diagram and becomes three tables you built yourself.',
          ['Turn last week\'s raw table into a cleaned, deduped, correctly-typed silver table', 'Practice inner, left, and one broadcast join', 'Write a gold aggregate or ranking as a view'],
          'Write one query using ROW_NUMBER() OVER (PARTITION BY ... ORDER BY ...) to deduplicate.',
          'Explain in one sentence why your gold view is cheaper to query than re-aggregating bronze every time.', false,
        ),
        (
          'Week 4', 'Domains 4–5 · Orchestration & CI/CD', 'Stop running cells by hand',
          'Turn the three-table pipeline into something that runs on its own, and lives in Git.',
          ['Wire bronze → silver → gold into a single Lakeflow Job with explicit dependencies', 'Set a schedule trigger, then try a file-arrival trigger instead', 'Connect a Git folder and open one pull request end to end'],
          'Break the job on purpose — feed it bad data — and read the failure through the Jobs UI before fixing it.',
          'Your pipeline should run without you opening a notebook — if you are still clicking Run All, this is not done.', false,
        ),
        (
          'Week 5', 'Domains 6–7 · Troubleshooting & Governance', 'Break things, then lock them down',
          'Know what a problem looks like in the Spark UI, and who is allowed to see what.',
          ['Deliberately cause a skewed join and find it in the Spark UI stage metrics', 'Create a low-privilege principal and use GRANT/REVOKE to control what it can see', 'Add a simple column mask or row filter to one table'],
          'Query a table as your low-privilege principal after applying a row filter — confirm you see fewer rows than the owner does.',
          'Can you tell from a Spark UI screenshot alone whether the problem is skew, undersized cluster, or a bad join?', false,
        ),
        (
          'Week 6', 'Exam', 'Prove it under time pressure',
          'Everything above was open-book, no clock. This week is neither.',
          ['Take a full-length practice exam: 45 questions, 90 minutes, no notes', 'For every missed question, trace it back to a domain and reread that section', 'Redo one lab from your weakest domain from memory'],
          null, 'Schedule the real exam once two consecutive practice runs clear 80%.', true,
        ),
      ],
    ),
    (
      'MLOps Engineer Associate',
      'AI-300',
      'MLOps and GenAIOps infrastructure, the ML lifecycle, and RAG optimization on Azure.',
      [
        (
          'Start', 'Setup', 'Stand up a workspace and a Foundry project',
          'Both platforms side by side before studying either in depth.',
          ['Create an Azure Machine Learning workspace', 'Create a Microsoft Foundry project', 'Connect a GitHub repo to both'],
          null, 'Both are visible in the Azure portal — logistics done.', false,
        ),
        (
          'Week 1', 'Domain 1 · MLOps infra', 'Provision infrastructure as code',
          'Stop clicking through the portal and start deploying with Bicep.',
          ['Provision your ML workspace resources with a Bicep template instead of the portal', 'Create a compute instance and a compute cluster', 'Configure GitHub Actions to redeploy the workspace on push'],
          null, 'Can you redeploy your workspace from the Bicep file alone?', false,
        ),
        (
          'Week 2', 'Domain 2 · ML lifecycle', 'Track, register, deploy a model',
          'The largest domain — trace one model end to end.',
          ['Log a training run with MLflow tracking', 'Register the model and promote it through staging to production', 'Deploy it as a real-time endpoint, then as a batch endpoint'],
          'Deliberately deploy a bad model version, then roll back using the registry.',
          'Trace one model from MLflow run to production endpoint without gaps.', false,
        ),
        (
          'Week 3', 'Domain 2 · Monitoring', 'Watch it in production',
          'Deployment isn\'t the finish line — monitoring is what makes it MLOps.',
          ['Set up a basic data drift check against the deployed model', 'Configure an alert for when a performance metric crosses a threshold', 'Practice a progressive rollout (canary-style) for a new version'],
          null, 'Explain what would actually trigger a retrain in your setup.', false,
        ),
        (
          'Week 4', 'Domain 3 · GenAIOps infra', 'Deploy and version a foundation model',
          'The same operational discipline as Weeks 1–3, now applied to generative AI.',
          ['Deploy a foundation model via Foundry using a serverless endpoint', 'Version two prompt variants in Git and compare their outputs', 'Configure provisioned throughput for one deployment and compare cost to serverless'],
          null, 'Explain when you would choose provisioned throughput over serverless.', false,
        ),
        (
          'Week 5', 'Domains 4–5 · Quality & RAG', 'Evaluate, observe, tune — then the exam',
          'Close the loop on generative AI operations, then test under time pressure.',
          ['Run an evaluation for groundedness and relevance on one prompt', 'Set up basic tracing and token-cost tracking', 'Tune chunk size on a small RAG pipeline and compare retrieval quality', 'Take a full-length practice exam'],
          null, 'Score 80%+ on a practice exam before booking the real one.', true,
        ),
      ],
    ),
    (
      'Kubernetes Fundamentals',
      'CKA',
      'Cluster architecture, workloads, networking, storage, and troubleshooting — hands-on with kubectl.',
      [
        (
          'Start', 'Setup', 'Get a cluster to break',
          'A local kind/minikube cluster or a free-tier AKS cluster — either works.',
          ['Install kubectl and a local cluster tool (kind or minikube)', 'Run kubectl get nodes and kubectl get pods -A once', 'Confirm you can edit and reapply a YAML manifest'],
          null, 'You have a cluster running and can talk to it with kubectl.', false,
        ),
        (
          'Week 1', 'Domain 1 · 25%', 'Cluster architecture',
          'What actually makes up a cluster, before touching anything else.',
          ['Identify each control-plane component running in your cluster', 'Practice switching kubeconfig contexts', 'Install a Helm chart for a simple app'],
          null, 'Name all four control-plane components without looking.', false,
        ),
        (
          'Week 2', 'Domain 2 · 15%', 'Workloads & scheduling',
          'The objects you deploy, and how the scheduler decides where they land.',
          ['Create a Deployment, scale it, and trigger a rolling update', 'Add a taint to a node and a matching toleration to a pod', 'Create a ConfigMap and a Secret and mount both into a pod'],
          'Break a Deployment\'s image tag on purpose, then fix it with kubectl edit.',
          'Explain the difference between a Deployment, a DaemonSet, and a StatefulSet.', false,
        ),
        (
          'Week 3', 'Domain 3 · 20%', 'Services & networking',
          'Pods are ephemeral — this is how something stable gets to talk to them.',
          ['Expose one Deployment as ClusterIP, then as NodePort', 'Install an Ingress controller and route two paths to two services', 'Write one NetworkPolicy that blocks traffic between two namespaces'],
          null, 'Explain why Ingress needs a controller installed but a Service does not.', false,
        ),
        (
          'Week 4', 'Domain 4 · 10%', 'Storage',
          'The smallest domain by weight, critical the moment anything stateful runs.',
          ['Create a PVC and watch a PV get dynamically provisioned', 'Explain the difference between ReadWriteOnce and ReadWriteMany', 'Delete a pod using a PVC and confirm the data survives'],
          null, 'Trace a PVC to the PV it is bound to, and explain the StorageClass in between.', false,
        ),
        (
          'Week 5', 'Domain 5 · 30%', 'Troubleshooting — then the exam',
          'The single largest domain, and the one worth over-practicing.',
          ['Diagnose a CrashLoopBackOff, an ImagePullBackOff, and a Pending pod you cause yourself', 'Use kubectl auth can-i to test RBAC permissions for a service account', 'Take a full timed practice exam in a real terminal'],
          null, 'Fix all three induced failures in under ten minutes combined.', true,
        ),
      ],
    ),
    (
      'DevOps Engineer Expert',
      'AZ-400',
      'Processes, source control, pipelines (over half the exam), security, and instrumentation.',
      [
        (
          'Start', 'Setup', 'Connect one repo to both toolchains',
          'GitHub Actions and Azure Pipelines, wired to the same repo.',
          ['Create a sample repo and enable GitHub Actions on it', 'Connect the same repo to an Azure DevOps project and Azure Pipelines', 'Run one trivial pipeline in each'],
          null, 'A green checkmark exists in both GitHub Actions and Azure Pipelines.', false,
        ),
        (
          'Week 1', 'Domains 1–2', 'Processes & source control',
          'How work flows, and how branches are protected before pipelines even start.',
          ['Set up branch protection rules requiring a review before merge', 'Practice a full feature-branch pull-request workflow', 'Set up one webhook or Teams integration for pipeline events'],
          null, 'Explain the difference between lead time and cycle time with your own example.', false,
        ),
        (
          'Weeks 2–3', 'Domain 3 · 50–55%', 'Build & release pipelines',
          'The dominant domain — worth two weeks, not one.',
          ['Write a multi-stage YAML pipeline: build, test, deploy', 'Add a manual approval gate before a production stage', 'Define infrastructure as code for one resource with Bicep inside the pipeline', 'Create a reusable YAML template shared by two pipelines'],
          'Implement one deployment strategy (blue-green or canary) against a demo app, even a trivial one.',
          'Explain canary vs. ring vs. blue-green deployment with one sentence each.', false,
        ),
        (
          'Week 4', 'Domain 4', 'Security & compliance',
          'Keeping secrets out of pipelines entirely, not just hiding them better.',
          ['Set up workload identity federation instead of a stored secret for one pipeline', 'Enable a dependency or code scan (Dependabot or CodeQL) on a repo', 'Configure one Key Vault-backed secret reference in a pipeline'],
          null, 'Explain why workload identity federation beats "just put it in Key Vault."', false,
        ),
        (
          'Week 5', 'Domain 5', 'Instrumentation — then the exam',
          'Closing the loop: knowing whether everything above actually worked.',
          ['Wire Application Insights into a sample app', 'Write one basic KQL query against the collected logs', 'Take a full-length practice exam'],
          null, 'Score 80%+ before booking — remember pipelines alone are over half the exam.', true,
        ),
      ],
    ),
    (
      'Azure AI App and Agent Developer',
      'AI-103',
      'Planning Foundry solutions, generative AI apps and multi-agent systems, vision, text, and extraction.',
      [
        (
          'Start', 'Setup', 'Get the Foundry SDK running locally',
          'Python, one deployed model, one successful local call.',
          ['Install the Foundry SDK in a fresh Python environment', 'Deploy a small chat model in the Foundry portal', 'Call it once from a local Python script'],
          null, 'A local script successfully prints a model response.', false,
        ),
        (
          'Week 1', 'Domain 1', 'Plan & manage',
          'Architecture decisions before code: model choice, security, guardrails.',
          ['Choose an appropriate model (LLM vs. small vs. multimodal) for three different sample scenarios', 'Configure managed identity auth instead of an API key', 'Set up one content-safety filter on a deployment'],
          null, 'Justify a model choice against a stated latency or cost constraint.', false,
        ),
        (
          'Weeks 2–3', 'Domain 2 · 30–35%', 'Generative AI & agents',
          'The largest domain — build past a single chatbot into real orchestration.',
          ['Build a RAG-backed chat app with the Foundry SDK', 'Build one agent with a custom function tool', 'Build a second specialist agent and orchestrate both from a simple router', 'Add basic tracing and token observability'],
          'Make your two agents disagree on a task, then add logic to reconcile them.',
          'Explain the difference between a single agent with many tools and true multi-agent orchestration.', false,
        ),
        (
          'Week 4', 'Domains 3–5', 'Vision, text, extraction — then the exam',
          'The remaining implementation domains, finished with a full practice run.',
          ['Generate an image from a prompt, then edit it with inpainting', 'Run a text extraction prompt returning structured JSON', 'Extract fields from a sample document with Content Understanding', 'Take a full-length practice exam'],
          null, 'Score 80%+ on a practice exam before booking the real one.', true,
        ),
      ],
    ),
  ];

  var order = 0;
  return raw.map((entry) {
    final (pathTitle, examCode, summary, stopTuples) = entry;
    order += 1;
    final planId = 'roadmap_${examCode.toLowerCase().replaceAll('-', '')}';
    var stopOrder = 0;
    return RoadmapPlan(
      id: planId,
      order: order,
      pathTitle: pathTitle,
      examCode: examCode,
      summary: summary,
      stops: stopTuples.map((s) {
        final (weekLabel, eyebrow, title, goal, tasks, lab, checkpoint, milestone) = s;
        stopOrder += 1;
        return RoadmapStop(
          id: '${planId}_stop_$stopOrder',
          order: stopOrder,
          weekLabel: weekLabel,
          eyebrow: eyebrow,
          title: title,
          goal: goal,
          tasks: tasks,
          lab: lab,
          checkpoint: checkpoint,
          milestone: milestone,
        );
      }).toList(),
    );
  }).toList();
}
