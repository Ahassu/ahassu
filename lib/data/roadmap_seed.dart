import '../models/roadmap.dart';

/// Seed roadmaps for every certification-bearing path in the Platform
/// Engineer curriculum: AZ-900 -> AZ-104 -> Terraform -> CKA -> AZ-400,
/// plus Databricks DEA. Each is a short, hands-on, week-by-week route to
/// exam day, sized for someone with prior cloud/ops depth rather than a
/// beginner. Seeded and re-synced by FirestoreService; progress toggles
/// are preserved across re-syncs.
List<RoadmapPlan> buildSeedRoadmaps() {
  final raw = <(
    String pathTitle,
    String examCode,
    String summary,
    List<(String weekLabel, String eyebrow, String title, String goal, List<String> tasks, String? lab, String? checkpoint, bool milestone)> stops,
  )>[
    (
      'Azure Fundamentals',
      'AZ-900',
      'Cloud concepts, the Azure service catalogue, and governance — fast, because the concepts are already familiar from AWS.',
      [
        (
          'Start', 'Setup', 'Get a subscription and the CLI',
          'You already know cloud. What you need is the portal, the vocabulary, and the CLI in your hands.',
          ['Create an Azure free account and note the credit expiry date', 'Install the Azure CLI and run az login, then az account show', 'Create one resource group and delete it again from the CLI'],
          null, 'You can create and destroy a resource group without opening the portal.', false,
        ),
        (
          'Week 1', 'Domain 1 · 25–30%', 'Cloud concepts & Azure architecture',
          'Map every AWS concept you already own onto its Azure name — this is translation work, not learning from zero.',
          ['Write the AWS→Azure mapping table from memory: EC2, S3, IAM, VPC, Route 53, CloudFormation, CloudWatch, Organizations', 'Explain the shared responsibility model for IaaS vs. PaaS vs. SaaS in one sentence each', 'Draw the scope hierarchy: management group → subscription → resource group → resource', 'Compare regions, region pairs, and availability zones to AWS regions and AZs'],
          'Deploy one VM and one storage account into a resource group, then delete the resource group and watch both disappear — that cascade is the difference from AWS.',
          'Can you explain why a resource group has no AWS equivalent, and what that changes about how you organize things?', false,
        ),
        (
          'Week 2', 'Domain 2 · 35–40%', 'The service catalogue, hands-on',
          'The biggest domain. Touch one service in each family so the names stop being abstract.',
          ['Create a VM, an App Service web app, and a Container Instance; note what you had to manage in each', 'Create a storage account and upload a blob into hot, then move it to cool', 'Create a VNet with two subnets and an NSG rule between them', 'Compare Load Balancer, Application Gateway, and Front Door in one line each'],
          'Peer two VNets and prove connectivity between a VM in each — this is the VPC-peering muscle you already have, in Azure syntax.',
          'For any workload description, can you name the right compute service in under five seconds?', false,
        ),
        (
          'Week 3', 'Domain 3 · 30–35% + Exam', 'Governance, cost — then the exam',
          'The domain where your multi-account AWS background is worth the most: this is Organizations and SCPs by another name.',
          ['Assign one Azure Policy at a resource group and watch a non-compliant deployment get denied', 'Apply a resource lock and a tag policy, then try to violate both', 'Open Cost Management, set a budget with an alert, and read the cost analysis view', 'Take a full-length practice exam'],
          'Compare an Azure Policy deny rule to an AWS SCP out loud — where each is evaluated, and what each cannot do.',
          'Score 85%+ on a practice exam before booking. AZ-900 is not hard; it is broad, and the trap is speed, not depth.', true,
        ),
      ],
    ),
    (
      'Azure Administrator Associate',
      'AZ-104',
      'The core platform-engineering cert: identity, governance, storage, compute, networking, and monitoring — all hands-on.',
      [
        (
          'Start', 'Setup', 'Set up a working environment',
          'Everything after this is done from the CLI or Bicep, not by clicking.',
          ['Confirm Azure CLI and PowerShell Az module both work against your subscription', 'Install the Bicep CLI and deploy one trivial template', 'Create a dedicated resource group for lab work so cleanup is one command'],
          null, 'You can deploy and tear down a resource from a Bicep file.', false,
        ),
        (
          'Week 1', 'Domain 1 · 20–25%', 'Identity & governance',
          'Your 200-account AWS governance experience maps directly here — learn the Azure names for what you already ran.',
          ['Create users and groups in Entra ID and assign a built-in role at three different scopes', 'Write one custom role definition and assign it', 'Build a management group hierarchy and inherit a policy down to a subscription', 'Test what happens when a deny at a parent scope conflicts with an allow at a child'],
          'Reproduce a small version of your AWS account structure as management groups and subscriptions, then explain the differences out loud.',
          'Explain RBAC inheritance and why deny assignments beat role assignments.', false,
        ),
        (
          'Week 2', 'Domain 2 · 15–20%', 'Storage',
          'Storage accounts carry more configuration surface than S3 buckets — the exam lives in that surface.',
          ['Create a storage account and change its redundancy from LRS to GRS', 'Generate a SAS token, use it, then revoke it via the stored access policy', 'Configure a lifecycle rule moving blobs hot → cool → archive', 'Mount an Azure Files share and configure a private endpoint'],
          'Lock a storage account down to a VNet-only private endpoint, then prove public access fails.',
          'Explain the difference between a SAS token, an access key, and Entra-based access — and which you would ever ship to production.', false,
        ),
        (
          'Week 3', 'Domain 3 · 20–25%', 'Compute',
          'VMs, scale sets, App Service, and containers — the workload-hosting domain.',
          ['Deploy a VM from a Bicep template, then capture it as a custom image', 'Create a VM Scale Set with an autoscale rule and trigger a scale-out', 'Deploy an App Service app with a deployment slot and swap it', 'Create an AKS cluster with two node pools and deploy one workload'],
          'Deliberately place two VMs in an availability set and two in availability zones, then explain the different failure domains each protects against.',
          'Choose correctly between VM, Scale Set, App Service, Container Apps, and AKS for five different scenarios.', false,
        ),
        (
          'Week 4', 'Domain 4 · 15–20%', 'Virtual networking',
          'The domain most like AWS VPC work, with enough naming differences to lose marks on.',
          ['Build a hub-and-spoke topology with VNet peering', 'Write NSG rules and use effective security rules to debug a blocked flow', 'Configure a private DNS zone and resolve a private endpoint by name', 'Put an Application Gateway in front of two backend VMs with path-based routing'],
          'Break connectivity on purpose with an NSG rule, then find it using Network Watcher connection troubleshoot instead of guessing.',
          'Trace a packet from the internet to a backend VM, naming every component it passes through.', false,
        ),
        (
          'Week 5', 'Domain 5 · 10–15%', 'Monitor, back up, maintain',
          'The smallest domain by weight, the one interviewers ask about most.',
          ['Send VM and platform logs to a Log Analytics workspace', 'Write three KQL queries: failures over time, top talkers, a specific error', 'Create an alert rule with an action group that actually emails you', 'Configure a backup policy and perform one real restore'],
          'Restore a file from a backup you took, not just a backup you configured — the restore is the part people skip.',
          'Write a KQL query from scratch without copying an example.', false,
        ),
        (
          'Week 6', 'Exam', 'Prove it under time pressure',
          'AZ-104 has case studies and hands-on-style questions — practice under a clock.',
          ['Take a full-length practice exam under exam conditions', 'For every miss, trace it to a domain and redo that week\'s lab', 'Redo the networking lab from memory, no notes'],
          null, 'Book the real exam once two consecutive practice runs clear 80%.', true,
        ),
      ],
    ),
    (
      'Infrastructure as Code',
      'TF-003',
      'Terraform Associate (003): the workflow, HCL, state, modules, and HCP Terraform — practiced against real Azure resources.',
      [
        (
          'Start', 'Setup', 'First apply on real infrastructure',
          'Twenty minutes. Install, authenticate, create one thing, destroy it.',
          ['Install Terraform and confirm terraform version', 'Write a three-line azurerm config creating one resource group', 'Run init, plan, apply, then destroy'],
          null, 'You created and destroyed real Azure infrastructure from a file.', false,
        ),
        (
          'Week 1', 'Objectives 1–4', 'Concepts, workflow, and HCL',
          'The vocabulary and the core loop, over-learned — most exam questions live here.',
          ['Explain declarative vs. imperative and idempotency using your own apply output', 'Use variables, locals, outputs, and a data source in one config', 'Read a plan output and identify every create, update, replace, and destroy', 'Trigger a forced replacement on purpose and understand why it happened'],
          'Change a property that forces replacement vs. one that updates in place — predict which before running plan, then check.',
          'Read a plan and say exactly what will happen before you type yes.', false,
        ),
        (
          'Week 2', 'Objectives 5–6', 'State and modules',
          'State is where real Terraform pain and most exam depth actually is.',
          ['Move local state to a remote backend on Azure Storage with locking enabled', 'Inspect state with terraform state list and terraform state show', 'Import an existing manually-created resource into state', 'Refactor a config into a module with inputs and outputs, then version it'],
          'Cause a state lock collision by running two applies at once, then resolve it properly rather than with force-unlock.',
          'Explain what breaks when two engineers share local state, and why sensitive values still land in state files.', false,
        ),
        (
          'Week 3', 'Objectives 7–8', 'Real Azure infrastructure and CI',
          'Stop writing toy configs — build something you would actually keep.',
          ['Provision a VNet, subnet, NSG, and VM entirely in Terraform using for_each', 'Add terraform fmt, validate, and tflint to a GitHub Actions workflow', 'Make plan run automatically on a pull request and post its output', 'Authenticate the pipeline with OIDC instead of a stored service principal secret'],
          'Manually change a resource in the portal, then run plan and watch Terraform detect the drift.',
          'Explain drift, how you detect it, and why a pipeline-only apply policy fixes it.', false,
        ),
        (
          'Week 4', 'Objective 9 + Exam', 'HCP Terraform — then the exam',
          'The last objective, then a timed run. The exam is 57 questions in 60 minutes.',
          ['Create an HCP Terraform workspace and run a plan from it', 'Compare local, remote, and VCS-driven workflows', 'Understand what Sentinel/policy checks add over plain CI', 'Take a full-length practice exam under time'],
          null, 'Score 85%+ before booking — the exam is short and fast, so hesitation costs more than gaps.', true,
        ),
      ],
    ),
    (
      'Kubernetes Administrator',
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
