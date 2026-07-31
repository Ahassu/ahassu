import '../models/note.dart';

/// The long-form interview prep note, attached to the Interview Preparation
/// path in the curriculum. Upserted on every launch by a fixed id, same
/// idempotent pattern as the guide notes below — safe to re-run, and
/// content edits here always win.
Note buildInterviewPrepPlatformNote() {
  final now = DateTime.now();
  return Note(
    id: 'note_interview_prep_platform',
    title: 'Interview Prep — Platform Engineering & AWS',
    body: _interviewPrepPlatform.trim(),
    learningPathId: 'path_interview',
    learningPathTitle: 'Interview Preparation — Platform Engineer',
    createdAt: now,
    updatedAt: now,
  );
}

/// Full detailed study notes for every learning path that has a guide —
/// the actual content (domains, concepts, code, traps, glossary,
/// checklist), not just a link out. Seeded once per note, using fixed ids
/// so re-running never duplicates or clobbers notes you write yourself.
/// Where an artifact link exists it is kept at the bottom of the note for
/// the diagram/visual version; newer guides are in-app only.
List<Note> buildSeedGuideNotes() {
  final raw = <(String pathKey, String pathTitle, String label, String? url, String content)>[
    ('az900', 'Azure Fundamentals (AZ-900)', 'AZ-900', null, _az900),
    ('linux', 'Linux, Networking & Git Foundations', 'Linux & Networking', null, _linuxNetGit),
    ('az104', 'Azure Administrator Associate (AZ-104)', 'AZ-104', null, _az104),
    ('terraform', 'Infrastructure as Code (Terraform Associate 003)', 'Terraform', null, _terraform),
    ('docker', 'Docker & Containerization', 'Docker',
        'https://claude.ai/code/artifact/d7fee4c1-9c16-4b57-bc9d-ad9469d24e3c', _docker),
    ('cka', 'Kubernetes Administrator (CKA)', 'CKA',
        'https://claude.ai/code/artifact/05bc46c8-1a30-405a-984c-cf8659077bd4', _cka),
    ('az400', 'CI/CD & Platform Delivery (AZ-400)', 'AZ-400',
        'https://claude.ai/code/artifact/87c9265b-f7a5-4da2-b68a-4371b83ad05b', _az400),
    ('observability', 'Observability & SRE Practices', 'Observability & SRE', null, _observability),
    ('databricks', 'Databricks & SQL (Data Engineer Associate)', 'DEA',
        'https://claude.ai/code/artifact/9e6694c5-8609-437d-a9d3-11e5f8df37a7', _databricks),
    ('capstone', 'Capstone: Productionize PurpleQueue', 'Capstone', null, _capstone),
  ];

  final now = DateTime.now();
  return raw.map((entry) {
    final (pathKey, pathTitle, label, url, content) = entry;
    return Note(
      id: 'note_guide_path_$pathKey',
      title: 'Study Guide — $label',
      body: url == null
          ? content.trim()
          : '${content.trim()}\n\n'
              '────────────────────\n'
              'Full visual guide with diagrams: $url',
      learningPathId: 'path_$pathKey',
      learningPathTitle: pathTitle,
      createdAt: now,
      updatedAt: now,
    );
  }).toList();
}

/// Guide-note ids written by earlier versions of this seed, when paths were
/// numbered (path_01…path_12) and the curriculum was the MLOps track. Kept
/// so the re-sync can delete them; notes written by hand use uuid ids and
/// are never touched.
const retiredGuideNoteIds = <String>[
  'note_guide_path_01',
  'note_guide_path_02',
  'note_guide_path_03',
  'note_guide_path_04',
  'note_guide_path_05',
  'note_guide_path_06',
  'note_guide_path_07',
  'note_guide_path_08',
  'note_guide_path_09',
  'note_guide_path_10',
  'note_guide_path_11',
  'note_guide_path_12',
];

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

const _interviewPrepPlatform = '''
INTERVIEW PREP — PLATFORM ENGINEERING & AWS
27 chapters across 10 parts. Built from an actual interview transcript covering
five domains: AWS Infrastructure, Enterprise Platform Engineering, Networking,
Security (IAM), and Infrastructure as Code. Every chapter pairs the concept
with how to actually say it out loud so the interviewer hears a senior
platform engineer, not a flashcard.

OPENING PITCH — how to frame yourself in 60 seconds
"I work at the layer between raw cloud infrastructure and the product teams
that consume it — designing multi-account AWS landing zones, the networking
and security guardrails inside them, and the Terraform modules that let
other teams self-serve infrastructure safely. My job isn't to provision one
VPC, it's to make sure the 50th team that needs a VPC gets one that's secure,
routable, and consistent with every other one — without filing a ticket to me."
That one paragraph signals: enterprise scale (not single-account toy setups),
platform-as-product thinking (not just ticket-taking ops), and IaC as the
delivery mechanism (not console clicking). Reuse pieces of it whenever a
question lets you zoom out from the specific answer to the "why it matters
at scale" framing — that zoom-out is what separates senior from mid-level
in an interview.

────────────────────────────────────────
QUICK-READ SUMMARY — THE 7-CHAPTER VERSION
────────────────────────────────────────
A fast re-read for the morning of the interview. Same material as the full
27-chapter reference below, compressed to the narrative arc so you can
re-load the whole shape of it in five minutes. Go to the full chapters
(cross-referenced below) when you want the "SAY IT LIKE THIS" phrasing and
the traps.

1 — Understanding an AWS Data Lake Platform (full detail: Ch1–2)
A data lake platform is a centralized environment where data produced by
many applications and business units is collected, stored, governed, and
made available for analytics. The platform team maintains this shared
environment rather than building the business applications that sit on
top of it — their daily work is provisioning AWS infrastructure,
onboarding new teams, enforcing security, monitoring reliability, and
troubleshooting production issues. That's the mental shift an interviewer
is listening for: not "how do I build a server," but "how do hundreds of
internal teams securely consume this platform, how is infrastructure
standardized, and how are deployments automated across many AWS
accounts." It's building and operating cloud infrastructure as a product,
not just writing deployment scripts.

2 — Enterprise AWS Architecture (full detail: Ch3)
Large organizations rarely operate in a single AWS account. Instead they
separate workloads into dedicated accounts for development, testing,
production, networking, logging, security, and shared services. This
separation improves security, simplifies billing, reduces blast radius,
and lets teams operate independently. Platform engineers automate
deployments across these accounts with Infrastructure as Code while
keeping governance centralized — this is exactly why an interviewer keeps
steering the conversation toward "how do you manage multiple AWS
accounts" instead of "how do you launch an EC2 instance": the account
boundary, not the individual resource, is where enterprise AWS thinking
actually lives.

3 — Infrastructure as Code and Terraform (full detail: Ch18–19)
Infrastructure as Code means infrastructure is described using
version-controlled code instead of manual console operations. Terraform
lets you define cloud resources declaratively and deploy identical
environments repeatedly. In enterprise environments it's normally
organized into reusable modules, remote state storage, environment-
specific variables, and automated CI/CD pipelines. The real benefit is
consistency — every environment is created from the same templates,
which reduces configuration drift and makes infrastructure reproducible
instead of hand-built and slightly different every time.

4 — AWS Networking Fundamentals (full detail: Ch4–9)
A VPC provides an isolated virtual network inside AWS, and the first
architectural decision is picking a CIDR block, which determines the
available IP address range. The VPC is divided into subnets across
multiple Availability Zones for resilience. Public subnets hold resources
that need direct internet access, like load balancers; private subnets
hold application servers and databases. Route tables determine where
traffic flows: Internet Gateways provide direct internet connectivity,
while NAT Gateways let private resources initiate outbound connections
without ever being reachable from inbound traffic. Understanding how
these pieces interact matters because networking problems are among the
most common production issues in AWS — this is foundational, not
decorative, knowledge.

5 — DNS and Request Flow (full detail: Ch10)
When a user types a website into a browser, far more happens than a
single HTTP request. The browser checks its own cache first, then the OS
cache; if there's still no answer, the request goes to a recursive DNS
resolver, which queries the root DNS servers, the top-level domain
servers, and finally the authoritative DNS server for that domain. Once
the IP address comes back, the browser opens a TCP connection, negotiates
TLS if it's HTTPS, sends the HTTP request, gets a response back through
the load balancer and application servers, and renders the page.
Narrating this entire flow — unprompted, in order — demonstrates systems
thinking; reciting isolated networking terms doesn't.

6 — IAM and Security (full detail: Ch16–17)
IAM is the security foundation of AWS. IAM users are long-term identities;
IAM roles are temporary identities that can be assumed by users, services,
or applications. Policies define permissions and decide which actions are
allowed or denied. Temporary credentials issued through AWS STS reduce the
need for long-lived access keys and are used heavily in enterprise
environments. Any security discussion should keep coming back to least
privilege, role assumption, temporary credentials, and centralized access
management — that combination is the actual answer underneath almost
every IAM question a senior interview asks.

7 — Amazon S3 Security (full detail: Ch14–15)
S3 stores objects inside buckets, and security is implemented through
identity-based IAM policies plus resource-based bucket policies. An IAM
policy describes what an identity may do; a bucket policy describes who
may access a specific bucket. Bucket policies become especially valuable
for cross-account access, organization-wide restrictions, and explicit
deny rules. Enterprise environments routinely combine IAM roles, bucket
policies, encryption, lifecycle management, and versioning together to
protect critical business data — no single one of those five is "the"
answer on its own.

CONCLUSION OF THE QUICK-READ VERSION
The interview consistently rewards architecture over memorization. Every
technical topic above ultimately comes back to production operations,
scalability, automation, and security. Prepare by understanding why each
AWS service exists, how services work together, what the real
architectural trade-offs are, and how they get used at large-enterprise
scale — not by memorizing service definitions in isolation. (This is the
same thesis as Chapter 27 below, just stated up front.)

────────────────────────────────────────
PART 1 — PLATFORM ENGINEERING FUNDAMENTALS
────────────────────────────────────────

CHAPTER 1 — What is Platform Engineering?
Evolution: traditional infra (racked servers, manual provisioning, ticket-driven)
→ cloud (on-demand APIs, still ticket-driven if nobody automates the org layer)
→ DevOps (dev teams own their own ops, but every team reinvents the wheel)
→ platform engineering (a dedicated team builds the paved road so product
teams don't have to become infra experts).
DevOps vs SRE vs Platform Engineering — the distinction interviewers probe:
• DevOps is a culture/practice: developers and ops collaborate, own the
  pipeline end to end.
• SRE is a discipline: apply software engineering to operations, with error
  budgets, SLOs, and toil reduction as the measurable core.
• Platform engineering is a team and a product: it builds the internal
  developer platform (IDP) that makes DevOps and SRE practices achievable
  without every team rebuilding CI/CD, networking, and IAM from scratch.
SAY IT LIKE THIS: "DevOps is the philosophy, platform engineering is how you
scale that philosophy past the point where every team can own its own
infrastructure expertise. Once you have 30 product teams, you either build
a platform or you build 30 slightly-different snowflake infrastructures."
Why platform teams exist: cognitive load. A product engineer who has to
understand VPC peering, IAM trust policies, and Terraform state locking
before they can ship a feature is a product engineer who ships slower.
Internal Developer Platform (IDP): the self-service layer — golden-path
Terraform modules, a service catalog, standardized CI/CD templates — that
lets a team provision a compliant environment without knowing the
underlying AWS primitives.
Shared Platform Model: one team owns the platform; many teams consume it as
a service, with clear ownership boundaries (platform owns the paved road
and its guardrails; product teams own what runs on top).
Platform as a Product: treat internal teams as customers — you gather
requirements, version your modules, deprecate with notice, and measure
adoption/satisfaction, rather than dictating from a policy document nobody
reads.
Platform Team Responsibilities: landing zone architecture, account
provisioning, network design, IAM guardrails, IaC module authorship, CI/CD
tooling, cost guardrails, and being the "on-call for the on-call" when a
foundational service (DNS, IAM, networking) breaks under everyone at once.
TRAP: don't describe platform engineering as "we do DevOps for other teams"
— that undersells it as ticket-taking. The differentiator is self-service
and paved roads, not being a faster help desk.

CHAPTER 2 — Big Data & the Data Lake (why platform teams end up owning this too)
What is Big Data: data characterized by volume, velocity, and variety large
enough that a single relational database can't reasonably ingest, store, or
query it — the reason specialized storage/processing systems exist at all.
What is a Data Lake: centralized storage (on AWS, S3) holding raw data in
its native format — structured, semi-structured, unstructured — without
forcing a schema at write time.
Data Lake vs Data Warehouse: a lake stores raw data cheaply and defers
schema until read time (schema-on-read); a warehouse stores curated,
modeled data optimized for known queries (schema-on-write). Lakes serve
data scientists and exploratory analytics; warehouses serve BI dashboards
and known reporting.
Why organizations build data lakes: to decouple ingestion from
consumption — land everything once, in one place, and let many downstream
tools (ML, BI, ad hoc query engines) read it independently instead of each
building its own ingestion pipeline.
The pipeline platform teams enable end to end:
• Data ingestion — batch or streaming intake into the lake
• Storage — S3 with lifecycle policies and storage-class tiering
• Data catalog — a metadata layer (e.g. Glue Data Catalog) so query engines
  know what schema/partitions exist without scanning everything
• Query engines — Athena/Redshift Spectrum query the lake directly without
  a separate load step
• Governance — access control, lineage, PII classification over lake data
• Data consumers — analysts, ML pipelines, downstream applications
SAY IT LIKE THIS: "As a platform engineer I don't own the data models, but
I own the account boundaries, the bucket policies, the KMS keys, and the
cross-account access patterns that let the data team build that pipeline
safely — the lake is a networking and IAM problem as much as it's a data
problem."

CHAPTER 3 — Enterprise Account Architecture
Why companies don't use one AWS account: blast radius and blame radius. One
account means one team's mistake (an open S3 bucket, a runaway EC2 fleet)
is everyone's incident, and one IAM policy mistake can touch production and
sandbox workloads alike. Multi-account isolates failure domains, billing,
and compliance boundaries at the account level — the strongest isolation
AWS offers.
AWS Organizations: the root construct that groups many AWS accounts under
one management entity for consolidated billing, centralized policy (SCPs),
and centralized logging/security tooling.
Organizational Units (OUs): folders of accounts inside Organizations —
group accounts by function or environment (e.g. Security OU, Workloads OU,
Sandbox OU) so a policy applied to the OU applies to every account inside
it without per-account configuration.
Landing Zone: the automated, opinionated baseline (via AWS Control Tower or
custom Terraform) that provisions new accounts with the guardrails already
applied — logging, SCPs, network baseline — before a single workload is
deployed into them.
Standard account layout in an enterprise landing zone:
• Management account — Organizations root, consolidated billing, nothing
  else runs here
• Security account — aggregates GuardDuty/Security Hub findings,
  centralized CloudTrail/Config, security tooling has read access to every
  account from here
• Logging account — centralized, immutable log storage (CloudTrail, VPC
  Flow Logs, ALB logs) that even account admins in other accounts can't
  delete
• Networking/Shared Services account — Transit Gateway, shared VPC
  endpoints, central DNS — the hub other accounts' VPCs attach to
• Production account(s) — customer-facing workloads, tightest change
  control
• Development/Sandbox account(s) — loose guardrails for experimentation,
  isolated so a sandbox mistake can't touch production
SCPs (Service Control Policies): org-level guardrails attached to an
account or OU that set the maximum available permissions — even an account
admin with AdministratorAccess cannot exceed what the SCP allows. This is
the enforcement mechanism that makes "guardrails, not gates" real: SCPs
deny entire categories of action (e.g. leaving a region, disabling
CloudTrail) org-wide, while IAM policies inside the account still grant
the day-to-day permissions.
SAY IT LIKE THIS: "SCPs are how we make security non-optional. An IAM
policy is something a team can write for themselves; an SCP is the ceiling
platform sets above every IAM policy in that account, so 'someone
accidentally granted too much' stops being a single point of failure."
TRAP: SCPs never grant permissions by themselves — they only restrict.
Forgetting this in an interview answer ("we use SCPs to give teams access
to...") is a quick tell that the concept isn't solid.

────────────────────────────────────────
PART 2 — NETWORKING
────────────────────────────────────────

CHAPTER 4 — Why VPC Exists & How AWS Networking Works
A VPC (Virtual Private Cloud) is an isolated, logically-defined network
inside AWS — your own private slice of the AWS network, with its own IP
address range, route tables, and gateways, that no other customer's
traffic can see or reach unless you explicitly connect it.
CIDR blocks: the IP address range assigned to a VPC/subnet, written as
address/prefix (e.g. 10.0.0.0/16 = ~65,536 addresses). The prefix length
determines how many addresses are usable — smaller number, bigger range.
IPv4 vs IPv6: IPv4 is the standard 32-bit addressing most VPCs still run on
and the one CIDR planning is usually about; IPv6 is 128-bit, effectively
unlimited address space, and increasingly offered as a dual-stack option to
sidestep IPv4 exhaustion inside very large enterprises.
Elastic Network Interface (ENI): the actual virtual network card attached
to an EC2 instance — it's the thing that actually holds the private IP,
security groups, and MAC address; an instance can have more than one.
DHCP: how instances automatically receive their IP address, DNS servers,
and other network config on boot, rather than static configuration.
DNS Hostnames / DNS Resolution (VPC-level settings): two VPC attributes —
enableDnsHostnames assigns instances a resolvable DNS name, enableDnsSupport
turns on the Route 53 Resolver inside the VPC so instances can resolve
names at all. Both must be on for private DNS features (like VPC endpoint
private hostnames) to work.
SAY IT LIKE THIS: "CIDR planning is the one decision in networking that's
genuinely hard to undo — resizing a VPC's CIDR after 200 subnets are carved
out of it is a migration project, not a config change. So the first
question I ask before any new environment is 'what's our IP budget for the
next three years,' not 'what do we need this quarter.'"

CHAPTER 5 — Subnets
A subnet is a subdivision of a VPC's CIDR range, tied to exactly one
Availability Zone, that groups resources sharing the same routing and
reachability characteristics.
• Public subnet — its route table has a route to an Internet Gateway;
  resources can have a public IP and be directly reachable from the
  internet.
• Private subnet — no route to an Internet Gateway; outbound internet
  access (if any) is via a NAT Gateway/Instance in a public subnet; not
  directly reachable from outside the VPC.
• Isolated subnet — no route out of the VPC at all, not even via NAT; used
  for databases and anything that should never dial out to the internet.
Route Tables: per-subnet (or VPC-default) rules mapping destination CIDR →
target (local, IGW, NAT, peering connection, Transit Gateway attachment).
Route propagation: routes learned automatically from an attached gateway
(e.g. a VPN or Transit Gateway attachment) instead of being added by hand.
Local route: the implicit route every route table has for the VPC's own
CIDR, so all subnets in the VPC can reach each other by default.
Default route: 0.0.0.0/0 — "everything else" — pointed at an IGW (public
subnet) or NAT (private subnet) to define where non-local traffic goes.
CIDR planning / production subnet design: carve subnets per AZ per tier —
e.g. a /24 public subnet and a /20 private subnet per AZ, across 3 AZs —
sized generously up front since resizing later is disruptive; keep tiers
(public/private/isolated) consistent across every VPC in the org so
Terraform modules can be reused unchanged.
SAY IT LIKE THIS: "We standardize subnet tiers across every VPC — public,
private, isolated, same relative sizing — so a Terraform module written
once for 'give me a 3-tier VPC' works whether it's deployed in the
networking account or spun up for a new product team. Consistency at the
subnet layer is what makes the IaC module reusable at all."

CHAPTER 6 — Internet Connectivity
Internet Gateway (IGW): attached to the VPC, it's what makes a public
subnet public — it provides the route (and the 1:1 NAT) between a public
IP and an instance's private IP.
NAT Gateway: a managed, AWS-operated service in a public subnet that lets
instances in a private subnet initiate outbound internet connections
(e.g. pulling OS patches, calling an external API) without being reachable
from the internet themselves. Highly available within its AZ, scales
automatically, billed per hour + per GB processed.
NAT Instance: a self-managed EC2 instance doing the same job — cheaper at
very low traffic, but you patch it, scale it, and it's a single point of
failure unless you build HA yourself. In an enterprise interview, NAT
Gateway is almost always the "correct" answer unless the question is
explicitly about legacy or extreme cost sensitivity.
Elastic IP: a static, account-owned public IPv4 address you attach to a
resource (NAT Gateway, EC2, IGW-facing resource) so its public address
survives instance replacement.
Egress-Only Internet Gateway: the IPv6 equivalent of a NAT Gateway — allows
outbound-only IPv6 traffic from a subnet without giving it inbound
reachability.
Public IP vs Private IP: a private IP is only reachable inside the VPC (and
whatever it's peered/connected to); a public IP is internet-routable and
mapped via 1:1 NAT to the instance's private IP by the IGW.
SAY IT LIKE THIS — the classic "how does a private-subnet app reach the
internet" answer: "Traffic leaves the instance on its private IP, the
subnet's route table sends anything not local to the NAT Gateway sitting
in a public subnet, the NAT Gateway translates it to its own Elastic IP,
and the Internet Gateway hands it off externally. The response retraces
that path back through the same NAT Gateway because NAT keeps the
connection state — that's also why the private instance was never directly
reachable from outside in the first place."

CHAPTER 7 — Availability Zones
Region: a geographic area (e.g. us-east-1) containing multiple, isolated
data-center clusters.
Availability Zone (AZ): one or more discrete data centers within a region,
each with independent power, cooling, and networking, connected to other
AZs in the region by low-latency links — the unit of physical fault
isolation AWS exposes to you.
Fault Domains: designing so that one AZ's failure (power, network,
hardware) can't take down the whole application — achieved by spreading
resources (subnets, instances, NAT Gateways, RDS standby) across at least
two, ideally three, AZs.
High Availability: no single component failure causes an outage — usually
achieved via redundancy across AZs plus automated failover/health checks.
Multi-AZ: a specific pattern (most commonly discussed for RDS) where a
synchronous standby replica lives in a second AZ and is promoted
automatically on primary failure.
Disaster Recovery: the plan for failure at a larger blast radius than a
single AZ — an entire region going down — measured by RTO (how long to
recover) and RPO (how much data loss is acceptable), and implemented via
strategies from backup-and-restore up through active-active multi-region.
SAY IT LIKE THIS: "Multi-AZ protects you from a data center problem; it
does nothing for a regional problem. I size the DR strategy to the actual
RTO/RPO the business needs — pilot light or warm standby for most
production systems, not a blanket 'let's go active-active everywhere' that
nobody's budget or ops maturity actually supports."

CHAPTER 8 — Security Groups
Security Groups are a stateful, instance/ENI-level virtual firewall: you
define allow rules only (no explicit deny), and because they're stateful,
a response to allowed inbound traffic is automatically allowed back out
(and vice versa) without a matching outbound rule.
Inbound rules: source (CIDR or another security group) + port/protocol
that's allowed in.
Outbound rules: destination + port/protocol allowed out; default is
allow-all-outbound until you lock it down.
Security Group referencing: instead of allowing a CIDR range, you allow
traffic from another security group directly (e.g. "allow port 5432 from
the app-tier SG") — this is the enterprise-grade pattern because it
survives instances being replaced/rescaled; the rule tracks the role
(the SG), not a fragile IP address.
Best practices: least-privilege ports only, reference SGs instead of wide
CIDRs wherever the source is other AWS resources, never open management
ports (22/3389) to 0.0.0.0/0, and treat SGs as the primary segmentation
control since NACLs are usually left permissive.
SAY IT LIKE THIS: "I basically never write a CIDR into a security group
rule if the source is another one of our own resources — I reference the
source security group. That way when the app tier autoscales or gets
replaced, the rule is still correct; it was never tied to an IP in the
first place."

CHAPTER 9 — Network ACLs
A Network ACL is a stateless, subnet-level firewall: rules are evaluated in
number order, first match wins, and because it's stateless you must
explicitly allow both the inbound and the return outbound traffic —
nothing is remembered between directions.
Evaluation order: rules are numbered (e.g. 100, 110, 120); AWS evaluates
from lowest to highest and stops at the first rule that matches the
traffic, so ordering (not just presence) of a rule matters.
Allow / Deny: unlike security groups, NACLs support explicit deny rules —
this is the only native way to blackhole a specific CIDR at the network
layer without touching every security group in the subnet.
Difference from Security Groups: SG = stateful, instance-level,
allow-only, all rules evaluated together. NACL = stateless, subnet-level,
allow + deny, first-match-wins ordering. In practice: security groups do
almost all of the real segmentation work day to day; NACLs are the
break-glass tool for "block this one CIDR from this one subnet, right
now, without hunting down every SG that might allow it."
SAY IT LIKE THIS: "If I need to block a specific bad-actor CIDR right now
across an entire subnet, I reach for a NACL deny rule — it's one rule in
one place instead of finding every security group that might reference
that range. Day to day, though, security groups do the actual access
control; NACLs stay permissive by default and exist as the blunt
instrument for exactly that kind of emergency."

CHAPTER 10 — DNS
This is the exact resolution flow an interviewer asked for — know it well
enough to narrate every hop without hesitating, because it's the single
best "walk me through what happens when..." answer available: it touches
DNS, TCP, TLS, HTTP, load balancing, and application architecture in one
story.

Browser
  → Browser Cache — has this exact hostname been resolved recently? If so,
    skip everything below and use the cached IP (subject to its TTL).
  → OS Cache — the operating system keeps its own resolver cache,
    checked next.
  → Hosts File — a static, manually-maintained local override
    (/etc/hosts) checked before any network resolver is contacted at all —
    this is how local dev environments fake production hostnames.
  → Recursive Resolver — (e.g. Route 53 Resolver, your ISP's resolver, or
    8.8.8.8) does the actual legwork on your behalf, walking the DNS
    hierarchy and caching the answer for other clients until its TTL
    expires.
  → Root DNS — the recursive resolver asks a root server "who's
    authoritative for .com?" (there are 13 logical root server addresses
    globally).
  → TLD (Top-Level Domain) server — the root points it to the .com (or
    .org/.net/etc.) TLD server, which answers "here's the authoritative
    name server for this specific domain."
  → Authoritative DNS — (e.g. Route 53 hosted zone) holds the actual
    records for the domain and returns the real answer — the IP address
    (A/AAAA record) or another name to keep chasing (CNAME).
  → IP — the recursive resolver now has an IP address and hands it back
    to the browser; this whole chain is skipped entirely on the next
    request until caches expire.
  → TCP — the browser opens a TCP connection to that IP: the 3-way
    handshake (SYN, SYN-ACK, ACK) establishes a reliable, ordered
    byte stream before any data is exchanged.
  → TLS — the TLS handshake negotiates encryption: certificate exchange,
    validation against a trusted CA, and key exchange, so everything after
    this point on the connection is encrypted.
  → HTTP — the actual request (method, path, headers, body) is sent over
    the now-encrypted connection.
  → Load Balancer — the request lands on an ALB/NLB, which terminates
    (or passes through) TLS, evaluates listener rules, and picks a
    healthy target from a target group.
  → Application — the request reaches actual application code running on
    EC2/ECS/EKS/Lambda behind that target group.
  → Database — the application queries its data store (RDS, DynamoDB,
    etc.) to fulfill the request.
  → Response — the answer travels back up through the exact same chain in
    reverse: app → LB → (already-established TLS/TCP connection, so no
    re-handshake) → browser renders it.
SAY IT LIKE THIS: "I'd walk it top to bottom: the browser checks its own
cache, then the OS, then the hosts file, before it ever asks a resolver.
The recursive resolver walks root to TLD to the authoritative zone,
caches the answer for its TTL, and hands back an IP. From there it's a
TCP handshake, a TLS handshake, then the actual HTTP request — which is
where our infrastructure, the load balancer, target groups, and the app,
takes over." Narrating it exactly in this order, unprompted, is what
signals genuine operational familiarity rather than memorized trivia.
TRAP: don't skip the caching layers (browser/OS/hosts) — interviewers
listening for depth specifically notice whether you mention them, because
they're the layers that explain "why didn't my DNS change take effect
immediately" in real incidents (stale local cache + TTL, not a broken
record).
Also worth a sentence each: TTL controls how long every layer is allowed
to cache an answer before re-checking; a CNAME points one name at another
name (chases another lookup); an A record maps a name directly to an
IPv4 address; alias records (Route 53-specific) act like a CNAME but are
usable at a zone apex and don't incur an extra lookup.

────────────────────────────────────────
PART 3 — AWS COMPUTE
────────────────────────────────────────

CHAPTER 11 — EC2
Instance Types: families tuned for different resource ratios — general
purpose (balanced, e.g. M-series), compute-optimized (C-series, CPU-bound
workloads), memory-optimized (R-series, in-memory caches/databases),
storage-optimized (I-series, high IOPS local storage). Picking the wrong
family is a cost and performance conversation, not just a spec sheet one.
AMI (Amazon Machine Image): the template (OS + preinstalled software +
config) an instance boots from; golden AMIs baked with hardening and
required agents already applied are a core platform-engineering deliverable
so every team's instances start from the same known-good baseline.
EBS (Elastic Block Store): persistent, network-attached block storage that
survives instance stop/terminate (unless explicitly configured otherwise)
and can be detached/reattached to another instance.
Instance Store: ephemeral, physically-attached storage that's lost on
stop/terminate — fine for cache/scratch space, never for anything you need
to survive a replacement.
User Data: a bootstrap script that runs once on first boot — used to pull
config, register with a service, or run a configuration-management agent,
so an instance self-configures instead of needing manual setup.
Placement Groups: control physical placement — cluster (pack tightly for
low-latency inter-instance networking, e.g. HPC), spread (max separation
across distinct hardware, for a small number of critical instances), and
partition (grouped-but-isolated partitions, for distributed systems like
Kafka/Cassandra that handle their own replication).
Auto Recovery: CloudWatch-triggered automatic recovery of an instance onto
new underlying hardware if AWS detects a hardware/hypervisor failure,
without needing an Auto Scaling group.
SAY IT LIKE THIS: "Golden AMIs are one of the highest-leverage things a
platform team ships — bake hardening, the CloudWatch agent, and required
security tooling into the image once, and every downstream team's
instances inherit it automatically instead of every team remembering to
install it themselves."

CHAPTER 12 — Auto Scaling
Scaling Policies: the rules that decide when to add/remove instances.
Target Tracking: the most common policy — pick a metric (e.g. average CPU
at 60%) and Auto Scaling continuously adds/removes instances to hold that
target, similar to a thermostat.
Scheduled Scaling: capacity changes on a known schedule (e.g. scale up
before a known Monday-morning traffic spike) instead of reacting to
a metric.
Health Checks: Auto Scaling can use EC2 status checks or (better, for
web-facing fleets) ELB health checks, so an instance that's running but
failing application-level health checks still gets replaced.
SAY IT LIKE THIS: "I default target-tracking Auto Scaling groups to ELB
health checks, not just EC2 status checks — an instance can be 'running'
by EC2's definition while the application inside it is deadlocked and
failing every request. ELB health checks catch that; EC2 status checks
don't."

CHAPTER 13 — Elastic Load Balancer
ALB (Application Load Balancer): Layer 7, HTTP/HTTPS-aware — routes on
path, host header, or headers, terminates TLS, and is the default choice
for web applications and microservices.
NLB (Network Load Balancer): Layer 4, extremely high throughput/low
latency, preserves the client's source IP, and is the choice for
non-HTTP protocols or when you need a static IP per AZ.
Gateway Load Balancer: transparently inserts third-party network
appliances (firewalls, IDS/IPS) inline in the traffic path — used at the
platform/security level, not by individual product teams.
Classic LB: the legacy Layer 4/7 hybrid predating ALB/NLB — correct
interview answer is "we don't provision new ones, only exists on
old accounts."
Listener: the configured port + protocol the LB listens on, with rules
that decide which target group handles a given request.
Target Groups: the pool of registered targets (instances, IPs, or Lambda
functions) a listener rule routes to, each with its own health check
configuration.
Health Checks: periodic requests (HTTP path, TCP connect) the LB uses to
decide whether a target is eligible to receive traffic — a failing target
is pulled out of rotation without any Auto Scaling action needed.
SAY IT LIKE THIS: "ALB versus NLB is really a question of what layer you
need to make a decision at. If I'm routing based on path or host header,
or need TLS termination, that's Layer 7 — ALB. If I need to preserve the
client's real source IP, or I'm not even doing HTTP, that's NLB."

────────────────────────────────────────
PART 4 — STORAGE
────────────────────────────────────────

CHAPTER 14 — Amazon S3
Buckets: the top-level, globally-named container; all objects live inside
one, and the bucket itself carries region, versioning, and policy config.
Objects: the actual data + metadata stored, addressed by key (which acts
like a path, though S3 is fundamentally a flat key-value store, not a real
filesystem).
Versioning: once enabled, every PUT to the same key creates a new version
instead of overwriting — protects against accidental overwrite/delete
(a delete just adds a "delete marker," the prior version is still
recoverable).
Lifecycle: rules that automatically transition objects between storage
classes or expire them by age — e.g. move to Infrequent Access at 30 days,
Glacier at 90, delete at 365 — without any application code involved.
Storage Classes: Standard (frequent access) → Standard-IA/One Zone-IA
(infrequent access, cheaper storage, retrieval fee) → Glacier/Glacier Deep
Archive (archival, minutes-to-hours retrieval, cheapest storage) →
Intelligent-Tiering (automatically moves objects between tiers based on
observed access patterns, no ops effort).
Replication: Cross-Region Replication (CRR) and Same-Region Replication
(SRR) asynchronously copy objects to another bucket — used for DR,
latency (serve from the nearest region), or compliance (a second copy in
a different jurisdiction/account).
Multipart Upload: splits a large object into independently-uploaded parts
(required above 5GB, recommended well below that), improving throughput
and letting a failed part retry without re-uploading the whole object.
Encryption: SSE-S3 (S3-managed keys, simplest), SSE-KMS (customer-managed
KMS key, gives you access logging and key rotation control, the
enterprise-standard choice), SSE-C (customer-supplied key, S3 never
stores it), and client-side encryption (encrypted before it ever reaches
S3).
SAY IT LIKE THIS: "For anything with a compliance requirement I default to
SSE-KMS over SSE-S3 — same encryption-at-rest guarantee, but a
customer-managed key gives you an audit trail of every decrypt via
CloudTrail, and the ability to revoke access by disabling the key, neither
of which SSE-S3 gives you."

CHAPTER 15 — S3 Security (the chapter the interviewer called out as
important — know this cold)
IAM Policy: identity-based — attached to a user/group/role, defines what
that identity can do across resources, evaluated at the requester's side.
Bucket Policy: resource-based — attached directly to the bucket, defines
who (including principals in other accounts) can do what to that bucket;
this is the only mechanism that can grant cross-account access without
the other account assuming a role first.
ACL (Access Control List): the legacy, object/bucket-level permission
mechanism predating IAM policies — AWS now recommends disabling ACLs
entirely (bucket owner enforced setting) in favor of policies; correct
interview answer is "we turn these off, not on."
Resource Policy: the general term for any policy attached to the resource
itself (bucket policy is S3's specific example) rather than to an
identity.
Identity Policy: the general term for a policy attached to a principal
(user/role) — the IAM Policy above is S3's instance of this.
Explicit Deny: a Deny statement anywhere in the evaluated policy set —
SCP, bucket policy, or identity policy — always wins, full stop, regardless
of any Allow anywhere else. This is the mechanism for "no one, under any
circumstance, should touch this prefix" — e.g. a Deny on a
"finance/payroll/" prefix scoped to everyone except one specific role.
Policy Evaluation: the actual order AWS applies, and the order that
matters in an interview answer: 1) explicit Deny anywhere → immediate
deny, no further evaluation needed. 2) Otherwise, is there an applicable
Allow (from an SCP AND an identity policy AND, for cross-account, a
resource policy)? If every layer that applies says Allow and none says
Deny, access is granted. Default is always implicit deny — nothing is
allowed unless something explicitly allows it.
Cross Account Access: the enterprise pattern is bucket policy in the
resource-owning account naming the other account's role ARN as principal,
PLUS an identity policy in the requesting account's role allowing the
action on that bucket ARN — both sides have to agree; either side alone
is insufficient. This double-opt-in is exactly why cross-account S3 access
is safe by construction: the bucket owner can't be silently exposed by
someone else's IAM policy alone, and the requester can't reach a bucket
whose owner didn't explicitly name them.
SAY IT LIKE THIS — the "protect a sensitive folder" scenario the
interviewer raised: "If I need to lock down a specific prefix — say,
payroll data inside a shared bucket everyone else can read — I add an
explicit Deny statement on that prefix, scoped to everyone except the one
role that legitimately needs it, using a NotPrincipal or condition-based
deny. Because explicit deny always wins the evaluation regardless of any
other Allow in an identity policy, SCP, or the bucket policy itself, this
is airtight even if someone later, mistakenly, grants s3:* to the whole
bucket at the IAM layer — the deny on that one prefix still holds."
TRAP: ACLs are a "we're actively moving away from these" answer, not a
"here's how we use them" answer — leading with ACLs as your access-control
strategy reads as outdated.

────────────────────────────────────────
PART 5 — IDENTITY & SECURITY
────────────────────────────────────────

CHAPTER 16 — IAM
Authentication: proving who you are (a valid IAM user's credentials, a
role's trust policy being satisfied, federated SSO).
Authorization: given you are who you say you are, what are you actually
allowed to do — governed by the policies attached to that identity.
IAM User: a long-lived identity with its own credentials — enterprise
practice is to minimize these to near-zero (favor federation/SSO for
humans, roles for workloads) since long-lived credentials are the highest
standing risk in an account.
IAM Group: a named collection of users that policies can be attached to
once instead of per-user — groups cannot be assumed by roles/services,
purely a user-management convenience.
IAM Role: an identity with no long-lived credentials of its own — instead,
anything (a user, a service, another account) that satisfies the role's
trust policy can assume it and receive short-lived temporary credentials.
This is the backbone of least-privilege at scale: EC2 instances, Lambda
functions, and cross-account access should all use roles, never embedded
access keys.
STS (Security Token Service): the service that actually issues the
temporary credentials (access key, secret key, session token) when a role
is assumed — every AssumeRole call is an STS API call under the hood.
AssumeRole: the action of a principal exchanging its own identity's
permission to assume a role for a fresh set of temporary credentials
scoped to that role's permission policy, valid for a bounded session
(commonly 15 minutes to 12 hours).
Temporary Credentials: expire automatically, can't be reused after
expiry, and (because they're generated per-session) don't need manual
rotation the way a long-lived access key does — this is why "roles over
users" is a security best practice, not just a style preference.
Trust Policy: attached to the role itself, defines WHO is allowed to
assume it (which principal — a specific role ARN, account, or service).
Permission Policy: attached to the role, defines WHAT the role can do
once assumed — a completely separate document from the trust policy, and
mixing the two up is a common interview stumble.
SAY IT LIKE THIS: "A role has two separate documents doing two separate
jobs — the trust policy answers 'who can become this role,' the
permission policy answers 'what can this role do once someone becomes
it.' Cross-account access is just: their role's trust policy names our
account/role as a trusted principal, and our side has an identity policy
allowing sts:AssumeRole on that role's ARN. Neither one alone is enough."

CHAPTER 17 — AWS Security (broader practices)
Least Privilege: grant only the permissions required for the task, nothing
ambient "just in case" — the organizing principle behind every other
concept in this chapter, and the answer to almost any "how would you
design access for X" question if you can't think of anything more
specific.
Cross Account Access: (see Ch16 AssumeRole/trust policy — same mechanism,
this is the security-strategy framing of it) the default enterprise
pattern for letting the security or platform account read/act across every
workload account without duplicating IAM users everywhere.
Federation: authenticating externally (a corporate identity provider) and
mapping that identity to temporary AWS credentials, instead of creating
IAM users per employee.
SAML: the specific federation protocol enterprises commonly use to
connect an on-prem/corporate IdP (e.g. Okta, Azure AD) to AWS, so
employees log into AWS with their existing corporate credentials via SSO
rather than a separate AWS-specific password.
MFA (Multi-Factor Authentication): a second factor beyond password —
should be enforced on every human identity, especially anything with
elevated (admin, billing) access; enforced via SCP/IAM condition in a
mature org rather than left to individual discipline.
IAM Identity Center (formerly AWS SSO): the AWS-native service for
federating human access to potentially hundreds of accounts through one
login and permission sets, rather than managing IAM users/roles per
account by hand — this is what a real landing zone uses for human access,
with workload roles (Ch16) handling machine-to-machine access separately.
Secrets Manager: stores and (optionally) automatically rotates
credentials (DB passwords, API keys) — applications retrieve them at
runtime via IAM permission instead of the secret living in code,
environment variables, or a config file in source control.
KMS (Key Management Service): manages encryption keys used across S3,
EBS, RDS, Secrets Manager, etc. — access to the key itself is governed by
a key policy (separate from, and evaluated alongside, IAM), and every
use of the key is logged in CloudTrail, which is what gives KMS-based
encryption a real audit trail that SSE-S3 alone doesn't have.
SAY IT LIKE THIS: "Human access goes through Identity Center federated
off our corporate IdP via SAML, with MFA enforced at the identity provider
— nobody has a standing IAM user. Machine access goes through roles that
workloads assume via STS. Secrets never live in code or env vars — they're
in Secrets Manager, pulled at runtime, and rotated automatically where the
service supports it. That's the whole human/machine access story in one
breath, and it's the answer to almost any 'how do you handle access for
X' question this domain throws at you."

────────────────────────────────────────
PART 6 — INFRASTRUCTURE AS CODE
────────────────────────────────────────

CHAPTER 18 — Terraform
Why Terraform: declarative (you describe the desired end state, not the
steps to get there), cloud-agnostic (one tool/workflow across AWS/Azure/GCP
and even non-cloud resources), and it maintains a state file so it knows
what it already created versus what a plan would still need to change.
Providers: plugins that translate Terraform's resource blocks into actual
API calls against a specific platform (the AWS provider, the Kubernetes
provider, etc.) — declared and version-pinned per project.
Resources: the actual infrastructure objects being declared
(aws_vpc, aws_iam_role, etc.) — the core building block of every
Terraform config.
Variables: parameterize a configuration (environment name, CIDR block,
instance size) so the same module produces different, environment-specific
output without editing the module's code.
Outputs: values a module/root config exposes for other configs (or for
humans, or CI) to consume — e.g. a VPC module outputting its subnet IDs
for a compute module to reference.
Modules: a reusable, versioned package of resources with its own
variables/outputs — the actual unit of reuse a platform team ships as its
"paved road" (e.g. a "3-tier-vpc" module every product team calls
identically).
Workspaces: a lightweight way to reuse one config across multiple state
files (e.g. dev/staging) — deliberately not the enterprise answer for
account/region separation (see Ch19), since workspaces share the same
backend config and code path in a way that's easy to accidentally cross.
State File: Terraform's record of every resource it manages and its last
known attributes — this is the single most operationally sensitive
artifact in the whole system, since it can contain secrets in plaintext
and is the source of truth Terraform diffs reality against.
Remote State: storing the state file in a shared backend (S3, Terraform
Cloud) instead of a local laptop file, so a team can collaborate on the
same infrastructure without stepping on each other's local copy.
Backend: the configuration block that says where state lives and how it's
locked — e.g. S3 for storage plus DynamoDB for locking, or Terraform
Cloud managing both natively.
Provider Alias: lets one config reference the same provider configured
multiple ways (e.g. two AWS regions, or two accounts via different
assumed roles) inside a single apply.
SAY IT LIKE THIS: "The state file is the thing I'm most careful about
operationally — it's the map between our Terraform code and real
resources, it can contain secrets in plaintext, and losing or corrupting
it is far more painful than losing the code itself, since the code is
just in git. Remote state with locking isn't optional at any real scale."

CHAPTER 19 — Enterprise Terraform (this is where "have you actually run
this at scale" gets tested)
Folder Structure: separate root configurations per account/environment
(not one giant config with conditionals), each root composed from shared,
versioned modules — this keeps a mistake in one environment's apply from
touching another's state, and keeps blast radius aligned with account
boundaries already established at the AWS Organizations layer.
Multiple Accounts: each root config assumes a role into its target account
via provider configuration (often combined with provider aliases) rather
than each engineer holding standing credentials in every account — ties
directly back to the AssumeRole pattern in Ch16.
Multiple Regions: handled via provider aliases within a config when
resources genuinely need to coexist (e.g. an ACM cert for CloudFront must
be in us-east-1 regardless of where everything else lives), or via
entirely separate root configs per region when regions are meant to be
independent blast-radius units.
Remote Backend: S3 + DynamoDB (or Terraform Cloud) per environment, often
one state bucket per account so state access itself follows the same
account-isolation boundary as the resources it describes.
Locking: DynamoDB (for S3 backends) or the native locking in Terraform
Cloud prevents two applies from racing against the same state
concurrently — without it, two simultaneous applies can corrupt state or
apply conflicting changes.
CI/CD (for Terraform specifically): plan runs automatically on every pull
request (posted as a comment for review, never silently applied), apply
runs only after human approval and only on merge to the main branch —
nobody runs terraform apply from a laptop against a production account.
Git Workflow: infrastructure changes go through the same PR/review process
as application code — the module/root config diff is the review artifact,
not a ticket description of the intended change.
Drift Detection: scheduled terraform plan runs (with no apply) against
production state, alerting if real infrastructure has diverged from what
Terraform thinks it manages — usually caused by a manual console change,
which is exactly the failure mode enterprise IaC discipline exists to
catch before it compounds.
SAY IT LIKE THIS: "At scale, the folder structure question is really an
account-and-blast-radius question — one root config per account, composed
from shared modules, with its own state file and its own remote backend.
That way a bad apply in the sandbox account can't even physically touch
production's state, because they're not the same state file, backend, or
even the same assumed role. Drift detection runs on a schedule against
production specifically, because that's the account where an
out-of-band console change is most expensive to discover late."
TRAP: if asked "how do you manage Terraform across hundreds of accounts,"
resist the urge to describe one giant clever config with loops over an
account list — the enterprise answer is boring on purpose: repeated,
composed, per-account root configs from shared modules, because boring
and isolated beats clever and coupled when blast radius is the top
concern.

CHAPTER 20 — CloudFormation
Templates: JSON/YAML documents declaring AWS resources, AWS's own
native IaC format (no external state file — AWS itself tracks state).
Stacks: a deployed instance of a template — the unit CloudFormation
creates, updates, and deletes as a whole.
StackSets: deploy the same stack across multiple accounts/regions from one
definition — CloudFormation's answer to the same multi-account problem
Terraform solves with per-account root configs and remote state.
Change Sets: a preview of exactly what a stack update would do before you
actually apply it — CloudFormation's equivalent of terraform plan.
Drift Detection: CloudFormation has this natively built in (same purpose
as the Terraform pattern in Ch19) — detects when a resource has been
manually changed outside the stack's own update process.
Custom Resources: let a template invoke a Lambda function to manage
something CloudFormation has no native resource type for — the escape
hatch for gaps in AWS's own IaC coverage.
Limitations — the chapter's real interview content: CloudFormation support
for brand-new AWS services and features consistently lags behind the
service's actual GA release, sometimes by months, because the
CloudFormation resource type has to be built and shipped separately from
the service itself. Terraform's AWS provider is community/HashiCorp
maintained and, in practice, often catches up faster for specific
new resource types, though it depends on provider contribution activity.
This lag is a real, recurring operational problem for a platform team:
you cannot always adopt a just-launched AWS feature in CloudFormation on
day one, and the workaround (Custom Resources backed by Lambda calling
the raw API) is real ongoing engineering effort, not a one-time fix.
SAY IT LIKE THIS — this was called out directly as an interview scenario:
"We hit this with [a recently-launched AWS feature] — the CloudFormation
resource type wasn't available yet, only the raw API and console support
existed. Our options were: wait for AWS to ship the resource type, write
and maintain a Custom Resource backed by a Lambda function calling the
API directly, or provision that one piece out-of-band and import it later
once the native resource type shipped. We went with [pick one and justify
it based on how long the feature was needed and how stable the API
looked] — the point is recognizing this as a structural limitation of
CloudFormation's release model, not a one-off bug to route around."
TRAP: don't frame this as "CloudFormation is bad" — frame it as a known,
managed tradeoff of the tool, and be ready to discuss why some enterprises
still choose it anyway (no separate state file to secure/lock, native AWS
support, StackSets for multi-account deploys without needing to build that
tooling yourself).

────────────────────────────────────────
PART 7 — CI/CD
────────────────────────────────────────

CHAPTER 21 — Jenkins
Pipelines: defined as code (Jenkinsfile, declarative or scripted syntax)
checked into the same repo as the code it builds, rather than configured
by hand through the UI — this is what makes a pipeline reviewable,
versioned, and reproducible.
Agents: the actual machines (or containers) that execute pipeline steps —
a platform team typically provides a pool of standardized, pre-hardened
agent images rather than every pipeline provisioning its own.
Shared Libraries: reusable Groovy code (common stages like "deploy to
EKS," "run security scan") imported into many teams' Jenkinsfiles — the
Jenkins-specific version of the same "paved road" idea as Terraform
modules.
Parameters: let a pipeline run be customized at trigger time (which
environment, which version) without editing the pipeline definition
itself.
Credentials: stored in Jenkins' credential store (or better, pulled from
Secrets Manager/Vault at runtime) and referenced by ID in the
pipeline — never hardcoded in the Jenkinsfile.
Enterprise Pipeline Design: centrally-maintained shared libraries so a
security or process change (e.g. adding a mandatory SAST scan stage) is
one library update instead of editing every team's Jenkinsfile
individually; standardized stage names/structure across teams so
dashboards and alerting can be built generically instead of per-pipeline.
SAY IT LIKE THIS: "Shared libraries are the CI/CD version of a Terraform
module — if security mandates a new scanning stage, I want to add it once
to a shared library and have every pipeline that imports it pick it up,
not go edit forty Jenkinsfiles by hand."

CHAPTER 22 — Git
Git Flow: a branching model with long-lived develop/main branches plus
feature/release/hotfix branches — heavier process, common in enterprises
with scheduled release trains rather than continuous deployment.
Branching: the lighter-weight enterprise-common alternative is trunk-based
development — short-lived feature branches merged frequently back to a
single main branch — favored specifically because it keeps CI/CD flowing
continuously instead of batching changes into infrequent releases.
Pull Requests: the review/gate mechanism before code merges — for
infrastructure repos specifically, this is also where a Terraform plan
output gets posted for human review (Ch19).
Merge Strategies: merge commit (preserves full history, noisier),
squash (one clean commit per PR, common default for feature branches),
rebase (linear history, no merge commits, requires more git discipline
from contributors).
Tagging: marks a specific commit as a release point (e.g. v1.4.0) —
what CI/CD artifacts and deployments should trace back to.
Release Management: the process around when/how tagged versions actually
roll out — coordinated release trains, or continuous per-merge deploys,
depending on the org's risk tolerance and Git Flow vs trunk-based choice
above.
SAY IT LIKE THIS: "For infrastructure repos specifically, squash merges
keep the history clean enough that 'what changed in this apply' maps to
exactly one PR, which matters a lot more for a Terraform repo than for
application code, since that PR is also the thing that was reviewed
alongside its plan output."

CHAPTER 23 — DevOps Pipeline
Build: compile/package source into a deployable artifact.
Test: automated unit/integration tests gate the pipeline before anything
downstream runs — for infrastructure, this includes `terraform validate`/
`plan` and policy checks (e.g. Sentinel/OPA), not just application tests.
Package: produce the final deployable unit (container image, AMI,
Lambda zip) tagged with a traceable version.
Artifact: the packaged output stored in a registry (ECR, artifact
repository) — immutable and referenced by digest/tag for every subsequent
stage, so "what's actually running in prod" is always traceable to an
exact artifact.
Deploy: promote the artifact through environments (dev → staging → prod),
typically with a manual approval gate before production specifically.
Rollback: the ability to redeploy the previous known-good artifact
quickly — this needs to be a rehearsed, fast path, not an improvised
one, especially for infrastructure changes where "rollback" might mean
re-applying a previous Terraform state rather than just redeploying a
container.
Monitoring: post-deploy health checks and alerting that confirm the new
version is actually healthy — feeding back into automated rollback
triggers in a mature pipeline, rather than relying on someone noticing.
SAY IT LIKE THIS: "The pipeline stages matter less than the property they
add up to: anything running in production is traceable back to an exact
artifact, which is traceable back to an exact commit, which passed an
exact set of automated checks before a human ever approved the prod
promotion. That traceability is what actually gets tested in an incident
— 'what changed and can we get back to before it' — not the stage names
themselves."

────────────────────────────────────────
PART 8 — KUBERNETES
────────────────────────────────────────
(The interviewer didn't dwell here — keep these answers crisp rather than
deep; this domain is a lower priority than the five listed at the top.)

CHAPTER 24 — EKS
Control Plane: the Kubernetes API server, scheduler, and etcd — on EKS,
AWS runs and manages this for you across multiple AZs; you never SSH into
it or patch it directly.
Worker Nodes: the EC2 instances (or Fargate, for serverless pods) that
actually run your pods — you manage these (or use Managed Node Groups so
AWS handles provisioning/lifecycle for you).
Pods: the smallest deployable unit — one or more tightly-coupled
containers sharing network namespace and storage.
Services: a stable network identity/load-balancing layer in front of a
set of pods, since individual pod IPs are ephemeral and get replaced
constantly.
Networking: EKS uses the VPC CNI plugin by default, meaning pods get real
VPC IP addresses directly (not an overlay network) — this is why VPC
subnet sizing (Ch5) directly constrains how many pods a cluster can run,
a very real capacity-planning trap in production EKS clusters.
IAM Roles for Service Accounts (IRSA): lets a specific Kubernetes pod
assume a specific IAM role via a Kubernetes service account, rather than
every pod on a node inheriting the node's own (broader) instance role —
the Kubernetes-native application of the least-privilege/role-based
access principle from Ch16 and Ch17.
SAY IT LIKE THIS: "IRSA is the same least-privilege principle as
everything else in IAM, just scoped down to pod granularity instead of
node granularity — without it, every pod on a node effectively shares
whatever permissions the node's instance role has, which is usually far
broader than any single pod actually needs."

────────────────────────────────────────
PART 9 — PRODUCTION ENGINEERING
────────────────────────────────────────

CHAPTER 25 — Production Architecture
High Availability: no single point of failure — redundancy across AZs at
minimum (Ch7), health-checked and automatically failed-over.
Fault Tolerance: the system keeps functioning correctly even while a
component has failed, not just "comes back quickly after" (that's more
HA/DR) — usually achieved through redundancy plus graceful degradation
(e.g. serving stale cache instead of an error when a backend is down).
Scalability: capacity grows (usually horizontally, via Auto Scaling/more
pods/more shards) to meet load without a redesign.
Reliability: the system does what it's supposed to, consistently, over
time — the umbrella property HA/fault tolerance/scalability all serve.
Security: threaded through every other property, not a separate bolt-on —
the theme of Parts 5 and 6 above.
Observability: the ability to answer novel questions about system
behavior from its outputs (metrics, logs, traces) without shipping new
code to add instrumentation for that specific question — a stronger bar
than "we have monitoring."
Disaster Recovery: see Ch7 — the plan and mechanism for surviving loss of
an entire region, sized to an actual RTO/RPO requirement.
SAY IT LIKE THIS: "These properties aren't independent checkboxes — they
trade off against each other and against cost. I'd rather size each one
(what RTO/RPO does this system actually need, what's the real blast
radius of losing an AZ) to the business requirement than default to
maximum HA/DR everywhere, which usually just means the budget owner
questions the platform team's judgment later."

CHAPTER 26 — Real Production Scenarios (straight from the interview —
practice narrating each of these as a full story: symptom → diagnosis →
fix → prevention)
• VPC running out of IP addresses: symptom is failed instance/pod launches
  with "insufficient IPs" errors. Root cause is usually undersized
  subnets from initial CIDR planning (Ch4/Ch5) colliding with actual
  growth (often EKS pods eating IPs fast under the VPC CNI, Ch24).
  Short-term fix: add a secondary CIDR block to the VPC and new subnets
  from it. Long-term prevention: size CIDR blocks generously up front and
  monitor IP utilization as a capacity metric, the same way you'd monitor
  disk space.
• Application in a private subnet needs internet access: this is the
  NAT Gateway narrative from Ch6 — private subnet route table's default
  route points at a NAT Gateway in a public subnet, which is what
  actually reaches the Internet Gateway.
• Designing secure multi-account S3 access: bucket policy naming the
  other account's role ARN plus that account's identity policy allowing
  the action — the Ch15/Ch16 cross-account double-opt-in pattern.
• Protecting sensitive folders with explicit deny: the Ch15 payroll-prefix
  scenario — explicit Deny on the prefix, scoped to everyone except one
  legitimate role, wins regardless of any broader Allow elsewhere.
• CloudFormation support lagging behind new AWS services: the Ch20
  scenario — recognize it as a structural tooling limitation and know the
  three real options (wait, Custom Resource + Lambda, or provision
  out-of-band and import later).
• Managing infrastructure consistently across hundreds of AWS accounts:
  the Ch19 answer — per-account root Terraform configs composed from
  shared, versioned modules, not one clever mega-config; StackSets is the
  CloudFormation-native equivalent if that's the org's chosen tool.
• Designing secure IAM role assumption patterns: the Ch16/17 trust-policy
  plus permission-policy split, STS-issued temporary credentials, roles
  over long-lived users everywhere.
• Troubleshooting DNS resolution issues: narrate the Ch10 flow and use it
  diagnostically — is the browser/OS cache stale (check TTL), is the
  recursive resolver returning the wrong answer, is the authoritative
  zone record itself wrong, or did the problem never leave DNS at all
  (TCP/TLS/app-layer failure that just looks like a DNS problem from the
  user's chair)?
• Scaling infrastructure without manual intervention: target-tracking
  Auto Scaling (Ch12) tied to the right metric and ELB health checks, so
  capacity and health both self-correct without a human paging in.
SAY IT LIKE THIS (general pattern for any of these): "Walk the symptom to
the layer it actually lives at, fix the immediate instance, then say what
you changed structurally so the same class of incident doesn't recur." An
interviewer asking a production scenario is testing whether you reach for
root cause and prevention, or just the fastest patch — always land on the
"and here's what changed after" sentence.

────────────────────────────────────────
PART 10 — PLATFORM ENGINEERING MINDSET
────────────────────────────────────────

CHAPTER 27 — Thinking Like a Senior Platform Engineer
This is the single biggest lesson from the interview transcript this
whole handbook was built from: everything above is trivia unless it's
delivered through this mindset. An interviewer who has heard the correct
facts from twenty candidates is listening for how you reason about them.

How senior engineers think about infrastructure: as a product with
customers (other engineering teams), not as a set of tickets to close —
every answer above that mentions "so every team doesn't have to solve
this themselves" is this mindset in action.
Architectural trade-offs: there is no universally correct answer to
"should this be multi-region," "should this use NAT Gateway or NAT
instance," "Terraform or CloudFormation" — there is only the right answer
for this team's actual constraints (cost, team maturity, compliance,
timeline). Naming the trade-off explicitly, even when you have a clear
recommendation, is what reads as senior.
Operational excellence: the measure of good infrastructure isn't "it
works," it's "it keeps working, and when it doesn't, we find out from our
own monitoring before a customer tells us" — observability and
automated recovery aren't optional extras, they're the actual deliverable.
Automation-first mindset: if you did something manually twice, the third
time should be automated — every console click a platform team performs
by hand is a paved road not yet built, and a source of the exact
inconsistency multi-account/Terraform/golden-AMI patterns exist to
prevent.
Security by design: security guardrails (SCPs, explicit denies, least
privilege, encryption defaults) are built into the platform/module so
teams get them for free by using the paved road, not layered on
afterward as a checklist someone has to remember to complete.
Infrastructure as products: versioned, documented, with a deprecation
policy and a feedback loop from the teams consuming them — literally
Chapter 1's Platform-as-a-Product idea, restated as the closing thesis.
Supporting internal developer teams: the platform team's success metric
is how fast and safely OTHER teams can ship, not how much infrastructure
the platform team personally built.
Production troubleshooting: methodical, layer-by-layer (exactly the DNS
flow in Ch10, or the scenario walkthroughs in Ch26) rather than
guess-and-check — narrating the method, not just the eventual answer, is
what interviewers are actually scoring.
Designing for scale: design the paved road for the 50th team, not just
the first one that asked for it — this is the thread running through
account architecture (Ch3), subnet standardization (Ch5), Terraform
modules (Ch18/19), and shared CI/CD libraries (Ch21).
Communicating technical decisions effectively: state the recommendation,
then the trade-off you're accepting, in one or two sentences — not a
wall of caveats, and not a bare answer with no reasoning shown. Every
"SAY IT LIKE THIS" line throughout this note is modeling exactly that
shape: recommendation, then the one sentence of why.
CLOSING SAY IT LIKE THIS — if asked "why should we hire you for this
role" directly: "Because I don't think about infrastructure as
individual resources I provision — I think about it as a product other
engineers consume, which means every decision I make gets evaluated
against 'does this scale to the 50th team, not just the first,' and 'did
I build the guardrail into the platform so no one has to remember it
manually.' That's the lens behind every answer I gave you today."

FINAL CHECKLIST — before the interview
☐ Can narrate the full DNS resolution flow (Ch10) unprompted, in order
☐ Can explain the S3 explicit-deny-on-a-prefix scenario end to end (Ch15)
☐ Can explain a role's trust policy vs permission policy without mixing
  them up (Ch16)
☐ Can explain cross-account access as a two-sided agreement, not a
  one-sided grant (Ch15/16)
☐ Can explain why SCPs only restrict and never grant (Ch3)
☐ Can describe enterprise Terraform folder/state structure without
  reaching for "one clever config with loops" (Ch19)
☐ Can discuss the CloudFormation lag-behind-new-services limitation as a
  known tradeoff, not a complaint (Ch20)
☐ Has at least one real "symptom → root cause → fix → prevention" story
  ready for a production-scenario question (Ch26)
☐ Can zoom out to the platform-as-product framing at least once per
  major answer, unprompted (Ch1, Ch27)
''';

const _az900 = '''
AZURE FUNDAMENTALS — AZ-900
Entry-level, 45–50 questions, pass 700/1000, no prerequisites. Three domains. If you have run AWS in production, this exam is a vocabulary test, not a knowledge test — the concepts transfer, the names do not.

DOMAIN 1 — Cloud concepts (25–30%)
Service models: IaaS (you manage OS upward — VMs) · PaaS (you manage app + data only — App Service, Azure SQL Database) · SaaS (you manage nothing but your data — Microsoft 365). Shared responsibility shifts left as you move IaaS → PaaS → SaaS; the customer always owns data, identities, and access, in every model.
Economics: capex (buy hardware up front, depreciate) vs. opex (pay per consumption, no asset). Benefits vocabulary the exam grades on: high availability, scalability (vertical = bigger, horizontal = more), elasticity (automatic), reliability, predictability, security, governance, manageability.
Cloud models: public, private, hybrid. Azure Arc extends Azure management to on-prem and other clouds — this is the "manage my AWS/on-prem estate from Azure" answer.
TRAP: scalability vs. elasticity — scaling is the capability, elasticity is doing it automatically in response to demand.

DOMAIN 2 — Azure architecture & services (35–40%)
Hierarchy, top down: management group → subscription → resource group → resource. RBAC and Policy assigned at any level inherit downward. There is no AWS equivalent of a resource group — it is a lifecycle boundary, and deleting it deletes everything inside.
Geography: region (like an AWS region) · availability zone (like an AWS AZ, physically separate datacenters in one region) · region pair (paired for platform-managed replication, no AWS equivalent) · sovereign regions (Azure Government, Azure China).
Compute: Virtual Machines (EC2) · VM Scale Sets (Auto Scaling groups) · App Service (Elastic Beanstalk/App Runner) · Azure Functions (Lambda) · Container Instances (Fargate task) · Container Apps (App Runner/ECS-serverless) · AKS (EKS) · Azure Virtual Desktop (WorkSpaces).
Networking: Virtual Network (VPC) · subnet · Network Security Group (security group + NACL combined) · VNet peering (VPC peering) · VPN Gateway (Site-to-Site VPN) · ExpressRoute (Direct Connect) · Azure DNS (Route 53) · Load Balancer (NLB, layer 4) · Application Gateway (ALB, layer 7, includes WAF) · Front Door (CloudFront + global routing) · Traffic Manager (Route 53 latency/geo routing).
Storage: Blob (S3) with hot/cool/cold/archive tiers · Files (EFS/FSx, SMB and NFS) · Disks (EBS) · Queues (SQS) · Tables (DynamoDB-ish key-value). Redundancy: LRS (3 copies, one datacenter) · ZRS (across zones) · GRS (to the paired region, read only on failover) · GZRS (both). AzCopy, Storage Explorer, and Azure Migrate move data in.
Identity: Microsoft Entra ID (formerly Azure AD) is the identity plane — it is not IAM. IAM's closest equivalent is Entra ID plus Azure RBAC together. Authentication vs. authorization, SSO, MFA, Conditional Access, passwordless. External Identities covers B2B guests.
TRAP: Entra ID is not a directory service for VMs — domain-joining VMs is Entra Domain Services, a separate offering.

DOMAIN 3 — Management & governance (30–35%)
Cost: Total Cost of Ownership calculator (before migrating) vs. Pricing calculator (before deploying) vs. Cost Management + Billing (after spending). Cost drivers: resource type, region, egress bandwidth, and reservations/spot/hybrid-benefit discounts. Tags drive cost allocation and are enforceable through Policy.
Governance: Azure Policy evaluates deployments against rules and can deny, audit, or remediate — the closest AWS analogue is SCPs plus Config rules, evaluated at deployment time. Resource locks (CanNotDelete, ReadOnly) stop accidental destruction and survive RBAC. Microsoft Purview covers data governance. The Trust Center, Service Trust Portal, and compliance offerings cover the paperwork questions.
Tooling: portal · Azure CLI · Azure PowerShell · Cloud Shell · ARM templates and Bicep (CloudFormation/CDK) · Azure Arc for hybrid.
Monitoring: Azure Monitor is the umbrella (metrics + logs); Log Analytics workspace stores logs and is queried with KQL; Application Insights is APM; Service Health is platform-side incidents; Azure Advisor recommends across cost, security, reliability, performance, operational excellence.
TRAP: Advisor recommends, Policy enforces, Service Health tells you Microsoft broke something. Exam questions hinge on which of those three a scenario is actually asking for.

REAL WORLD: the resource-group cascade is the single biggest behavioral difference from AWS. Group by lifecycle, not by service type — everything that gets deleted together belongs in the same resource group.

GLOSSARY
Resource group — lifecycle and deletion boundary for resources, no AWS equivalent
Management group — container above subscriptions, roughly an AWS Organizations OU
Region pair — Microsoft-designated partner region for platform-managed replication
Conditional Access — policy engine deciding when MFA or block applies to a sign-in
Azure Arc — projects non-Azure servers and clusters into Azure management

READINESS CHECK
☐ Recite the AWS→Azure mapping for compute, storage, network, identity, and IaC
☐ Explain the four-level scope hierarchy and what inherits down it
☐ Pick the right redundancy option (LRS/ZRS/GRS/GZRS) from a stated requirement
☐ Say which of TCO calculator / Pricing calculator / Cost Management fits a scenario
☐ Distinguish Advisor vs. Policy vs. Service Health in one sentence each
☐ Know that customers always own data and identity, in every service model
''';

const _linuxNetGit = '''
LINUX, NETWORKING & GIT FOUNDATIONS
No certification. The layer underneath every Azure, Terraform, and Kubernetes topic — and where platform-engineering interviews go when they want to find the bottom of your knowledge.

MODULE 1 — Linux filesystem and permissions
Layout: /etc config · /var/log logs · /usr/bin binaries · /opt third-party · /proc kernel and process state. Permissions are three triads (user, group, other) over read(4)/write(2)/execute(1); 644 is a normal file, 755 an executable or directory, 600 a private key. Ownership via chown, group membership via usermod -aG. Special bits: setuid, setgid, sticky bit on /tmp.
TRAP: a directory needs execute (x) to be traversed at all — read alone lets you list names and nothing else.

MODULE 2 — Processes and systemd
ps, top, htop for what is running; kill/kill -9 for stopping it; nice for priority. systemd is the init system: unit files in /etc/systemd/system, managed with systemctl start/stop/enable/status, logs read with journalctl -u name -f. A service that dies on logout is a service you forgot to daemonize.
Troubleshooting order that actually works: is the process running (systemctl status) → is it listening (ss -tulpn) → can something reach it (curl localhost) → can something remote reach it (firewall/NSG).

MODULE 3 — Shell and text processing
grep for lines, sed for substitution, awk for columns, jq for JSON, xargs for turning output into arguments. Pipes and redirection: stdout is 1, stderr is 2, 2>&1 merges them. Scripting essentials: set -euo pipefail at the top of every script, quote every variable expansion, and prefer explicit exit codes.
  ss -tulpn | grep :443
  journalctl -u nginx --since "10 min ago" | grep -i error
  az vm list -o json | jq -r ".[].name"

MODULE 4 — SSH and keys
Key pair auth: private key stays on your machine at 600, public key goes into authorized_keys. Agent forwarding vs. ProxyJump for bastion hops — prefer ProxyJump. Config lives in ~/.ssh/config and is worth using: aliases, jump hosts, key selection per host. Debug with ssh -vvv, which will name the exact auth step that failed.

MODULE 5 — TCP/IP and subnetting
CIDR: /24 = 256 addresses, /25 = 128, /26 = 64, /27 = 32. Azure reserves five addresses per subnet (AWS reserves five too, slightly differently) — a /29 gives you three usable. Private ranges: 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16. Non-overlapping ranges matter the moment you peer two networks or connect on-prem.
TCP handshake (SYN, SYN-ACK, ACK) and where it fails: no SYN-ACK means blocked or nothing listening; RST means something actively refused. Layer 4 vs. layer 7 load balancing is the difference between routing a connection and routing a request.

MODULE 6 — DNS
Resolution path: hosts file → stub resolver → recursive resolver → root → TLD → authoritative. Record types that matter: A/AAAA (address), CNAME (alias, cannot coexist with other records at the same name), MX, TXT (verification/SPF), NS, SOA, and SRV. TTL controls cache lifetime — lower it before a migration, not during one.
TRAP: "DNS propagation" is not a thing; it is caches expiring on their own TTL schedule. Plan cutovers around the TTL you set 48 hours earlier.

MODULE 7 — TLS and certificates
Handshake: client hello → server certificate → key exchange → encrypted session. The chain matters: leaf → intermediate → root; missing intermediates are the most common "works in my browser, fails from curl" bug. Check expiry and chain with openssl s_client -connect host:443 -showcerts. SAN, not CN, is what modern clients validate.

MODULE 8 — Git for teams
Branching: short-lived feature branches off main, rebase to keep history linear, merge commits when you want the merge recorded. rebase rewrites history and is unsafe on shared branches; merge is always safe. Recovery: git reflog finds anything you think you lost; git revert undoes a commit publicly, git reset moves your branch privately. Conflict resolution is reading both sides, not accepting theirs by reflex.
REAL WORLD: a secret committed once is committed forever — rotate the credential first, scrub history second. Never the other way round.

GLOSSARY
Unit file — systemd's declarative definition of a service
CIDR — network prefix notation, where the number is how many bits are fixed
Recursive vs. authoritative resolver — one asks on your behalf, one holds the answer
SAN — Subject Alternative Name, the certificate field browsers actually check
Reflog — local log of every position HEAD has held, your undo history

READINESS CHECK
☐ Read and set permissions without reaching for a chmod calculator
☐ Debug a dead service through systemctl, ss, and journalctl in that order
☐ Subnet a /24 into usable ranges on a whiteboard, from memory
☐ Trace a DNS lookup end to end and name what each step returns
☐ Explain a TLS chain failure and how you would confirm it with openssl
☐ Recover a "lost" commit with reflog and explain rebase vs. merge safety
''';

const _az104 = '''
AZURE ADMINISTRATOR ASSOCIATE — AZ-104
The core platform-engineering certification and the prerequisite for AZ-400. 40–60 questions including case studies, pass 700/1000. Five domains, all hands-on. This is where AWS multi-account governance experience converts directly into Azure credibility.

DOMAIN 1 — Identity & governance (20–25%)
Entra ID objects: users (member vs. guest), groups (assigned vs. dynamic membership), administrative units for scoping admin rights, service principals and managed identities for workloads. Self-service password reset, MFA, and Conditional Access policies gate sign-in.
Azure RBAC: role definition (what actions) + security principal (who) + scope (where) = role assignment. Scope inherits management group → subscription → resource group → resource. Built-in roles to know cold: Owner, Contributor, Reader, User Access Administrator. Custom roles are JSON with Actions, NotActions, DataActions, and AssignableScopes.
Governance: management groups mirror an AWS Organizations OU tree. Azure Policy definitions and initiatives with effects deny, audit, append, modify, deployIfNotExists. Resource locks (CanNotDelete, ReadOnly) apply regardless of RBAC. Tags for cost allocation, enforced by Policy. Cost Management budgets and alerts.
TRAP: RBAC is additive — there is no deny in a role assignment. An explicit deny assignment (created by Azure Blueprints or Managed Apps) is the only thing that overrides an allow. Policy denies at deployment time, which is a different mechanism entirely.

DOMAIN 2 — Storage (15–20%)
Storage account is the boundary for redundancy, firewall, and access keys — everything (blob, file, queue, table) lives inside one. Performance tiers standard vs. premium; access tiers hot, cool, cold, archive with rehydration latency on archive. Redundancy LRS, ZRS, GRS, GZRS, and RA-GRS for readable secondary.
Access control, in order of preference: Entra ID + RBAC (best) → stored access policy backed SAS (revocable) → ad-hoc SAS → account keys (worst, rotate them). Network access: service endpoints vs. private endpoints — private endpoint gives the account a private IP inside your VNet and is the answer whenever "no public access" appears in the requirement.
Azure Files supports SMB and NFS, with AD or Entra Domain Services auth for SMB. AzCopy and Storage Explorer for data movement; lifecycle management rules automate tiering and deletion.

DOMAIN 3 — Compute (20–25%)
VMs: sizing families, availability sets (fault/update domains within a datacenter) vs. availability zones (across datacenters) — zones give the stronger SLA. Custom images and the Azure Compute Gallery for image distribution. Disks: OS vs. data vs. temp; the temp disk is not persistent and will lose data on deallocation.
VM Scale Sets: uniform vs. flexible orchestration, autoscale rules on metric or schedule.
App Service: plans determine cost and scale; deployment slots enable swap-based blue-green; scale up (bigger plan) vs. scale out (more instances).
Containers: Container Instances for single tasks, Container Apps for serverless microservices, AKS for full orchestration with node pools, cluster autoscaler, and integrated ACR.
TRAP: resizing a VM restarts it; adding a data disk does not. Deallocating stops compute billing but keeps disk billing — stopping from inside the guest OS does neither.

DOMAIN 4 — Virtual networking (15–20%)
VNets and subnets, address spaces that must not overlap with anything you will ever peer. NSGs are stateful and apply at subnet or NIC, evaluated by priority with default rules at the bottom; application security groups let rules target workload labels instead of IPs. Effective security rules is the tool that ends most "why is this blocked" arguments.
Peering is non-transitive — hub-and-spoke needs a gateway, route server, or firewall in the hub to route between spokes. User-defined routes override system routes and are how traffic gets forced through a firewall appliance.
Name resolution: Azure-provided DNS, private DNS zones linked to VNets, and the private endpoint DNS records that make them resolvable.
Load balancing: Load Balancer (layer 4, regional) · Application Gateway (layer 7, path/host routing, WAF) · Front Door (global, edge) · Traffic Manager (DNS-based). Hybrid: VPN Gateway (site-to-site, point-to-site) and ExpressRoute for private circuits.

DOMAIN 5 — Monitor & maintain (10–15%)
Azure Monitor collects platform metrics automatically; logs need a diagnostic setting pointing at a Log Analytics workspace before anything is queryable. KQL is the query language, alert rules fire action groups, and Network Watcher provides connection troubleshoot, NSG flow logs, and next-hop diagnostics.
  AzureDiagnostics | where TimeGenerated > ago(1h) | summarize count() by Resource, ResultType
Backup and recovery: Recovery Services vault, backup policies, soft delete, and Azure Site Recovery for replication and failover. Restore is the part that must be rehearsed — a backup you have never restored is a hypothesis.
TRAP: no diagnostic setting means no logs, retroactively. You cannot query what was never collected, and the exam loves that scenario.

REAL WORLD: the three things that break real Azure estates are overlapping address spaces chosen early, RBAC granted at subscription scope out of convenience, and storage accounts left open to public network access. All three are cheap to prevent and expensive to unwind.

GLOSSARY
Managed identity — Entra identity assigned to a resource so it authenticates without a secret
Effective security rules — computed view of every NSG rule applying to a NIC
Private endpoint — private IP in your VNet for a PaaS service, replacing public access
User-defined route — custom route table entry that overrides Azure system routing
Recovery Services vault — container for backups and Site Recovery replication

EXAM-DAY CHECKLIST
☐ Explain RBAC inheritance and why role assignments are additive
☐ Choose between service endpoint and private endpoint from a requirement
☐ Pick availability set vs. availability zone and justify the SLA difference
☐ Debug a blocked flow using effective security rules and Network Watcher
☐ Know that VNet peering is non-transitive and what to put in the hub
☐ Write a KQL query without a template, and know a diagnostic setting must exist first
☐ Perform a restore, not just configure a backup
''';

const _terraform = '''
INFRASTRUCTURE AS CODE — HASHICORP TERRAFORM ASSOCIATE (003)
57 questions, 60 minutes, multiple choice, valid two years. The exam is broad and shallow; real competence is in state and modules. Free study path: HashiCorp tutorials plus your own Azure free-tier subscription.

OBJECTIVE 1–2 — IaC concepts and Terraform's purpose
Declarative (describe the end state, Terraform computes the diff) vs. imperative (describe the steps). Benefits: version control, review, repeatability, drift detection, and a plan you can read before anything changes. Terraform is cloud-agnostic and provider-based; ARM/Bicep and CloudFormation are single-cloud. State is what makes Terraform different from a shell script — it maps config to real resource ids.

OBJECTIVE 3 — Core workflow
write → init (download providers, configure backend) → plan (compute diff, change nothing) → apply (execute) → destroy. terraform fmt formats, validate checks syntax and internal consistency without touching the cloud. Read every plan: + create, ~ update in place, -/+ replace (destroy then create), - destroy. The -/+ marker is the one that causes outages.
  terraform init -backend-config=backend.hcl
  terraform plan -out=tfplan
  terraform apply tfplan

OBJECTIVE 4 — HCL and the language
Blocks: terraform (version constraints, backend) · provider · resource · data (read-only lookup) · variable · local · output · module. Variable precedence, lowest to highest: default → environment TF_VAR_ → terraform.tfvars → -var-file → -var on the command line. Types and validation blocks catch bad input early; sensitive = true keeps values out of CLI output (but not out of state). Expressions: for_each, count, conditionals, dynamic blocks, and the splat operator.
TRAP: count uses positional indexes, so removing the middle element renumbers and recreates everything after it. for_each keys by a string and is stable — prefer it for anything you care about.

OBJECTIVE 5 — State
Local state is a JSON file; remote state (Azure Storage, S3, HCP Terraform) adds shared access and locking. Locking prevents two concurrent applies corrupting state; force-unlock is a last resort, not a workflow. Commands: state list, state show, state mv (rename without recreating), state rm (forget without destroying), import (adopt an existing resource), and the newer moved block that records refactors in code instead of in CLI history.
State contains every attribute, including secrets, in plaintext. Encrypt the backend, restrict access to it, and never commit it.
TRAP: terraform destroy deletes what state knows about. If state is lost, Terraform will happily try to create duplicates of resources that already exist — recovery is import, one resource at a time.

OBJECTIVE 6 — Modules
A module is any directory of .tf files. Root module calls child modules; inputs are variables, outputs are how a parent reads values back. Source can be a local path, a Git URL, or a registry reference — pin registry modules by version, always. Good module design: one logical unit, no hardcoded environment values, outputs for everything a caller might need.

OBJECTIVE 7 — Terraform on Azure in practice
The azurerm provider authenticates by Azure CLI (local), service principal, managed identity, or OIDC federation (pipelines — no stored secret). Pin the provider version. Standard layout: separate state per environment, a backend in Azure Storage with a lock, and plan-on-pull-request with apply gated behind approval.
REAL WORLD: humans should not run apply against production. Once plan runs in CI and apply is pipeline-only, drift becomes visible instead of normal.

OBJECTIVE 8–9 — HCP Terraform and workflows
Workspaces isolate state; runs execute plan/apply remotely with a shared log. VCS-driven workflow triggers on push. Private registry hosts internal modules. Sentinel and OPA add policy-as-code gates that run between plan and apply — the "prevent anyone deploying an untagged resource" answer.

GLOSSARY
Drift — real infrastructure diverging from what state and config describe
Backend — where state is stored and locked
Provider — plugin translating Terraform resources into an API's calls
moved block — declares a refactor so Terraform renames instead of destroy/create
Plan file — saved, reviewable diff that apply can execute unchanged

EXAM-DAY CHECKLIST
☐ Read a plan and predict create vs. update vs. replace before running it
☐ Explain variable precedence in order without hesitating
☐ Know when to use import, state mv, state rm, and moved
☐ Explain why for_each beats count for stable resources
☐ Say what is in state, why it is sensitive, and how locking protects it
☐ Authenticate a pipeline with OIDC rather than a stored service principal secret
''';

const _observability = '''
OBSERVABILITY & SRE PRACTICES
No certification, and the topic that separates "can deploy it" from "can run it." Interviewers use this section to find out whether you have carried a pager.

MODULE 1 — The three signals
Metrics: numeric, cheap, aggregated, good for alerting and trends, bad for explaining a single request. Logs: high cardinality, expensive at volume, good for forensics. Traces: one request across services, the only signal that answers "which hop was slow." Monitoring tells you something is wrong; observability lets you ask why without shipping new code.
TRAP: cardinality kills. A metric label containing user id or request id will bankrupt the metrics backend — that data belongs in logs or traces.

MODULE 2 — Azure Monitor and KQL
Platform metrics are automatic; logs require a diagnostic setting routed to a Log Analytics workspace. Application Insights gives request/dependency/exception telemetry plus distributed tracing. Alert rules attach to action groups (email, webhook, runbook, ITSM).
  requests
  | where timestamp > ago(1h)
  | summarize total=count(), failed=countif(success==false) by name
  | extend errorRate = round(100.0 * failed / total, 2)
  | where total > 100
  | order by errorRate desc
Workspace design decides cost: retention period, daily cap, and which tables you actually query. Basic logs cost less and query less.

MODULE 3 — Prometheus and Grafana on Kubernetes
Prometheus scrapes /metrics endpoints on an interval and stores time series; exporters cover things that cannot expose their own. PromQL for querying, Alertmanager for routing and deduplication, Grafana for dashboards. Azure Monitor managed Prometheus and managed Grafana remove the operational burden if you want them.
The four golden signals: latency, traffic, errors, saturation. The USE method for resources (utilization, saturation, errors); the RED method for services (rate, errors, duration).

MODULE 4 — SLIs, SLOs, and error budgets
SLI is the measurement (percentage of requests under 300 ms). SLO is the target (99.5% over 28 days). Error budget is the allowed failure (0.5%), and it is a decision-making tool: budget remaining means ship faster; budget exhausted means stop feature work and fix reliability. An SLA is the contractual version with money attached — always looser than your internal SLO.
Choose SLIs from the user's perspective. Nobody outside the team cares about CPU utilization.

MODULE 5 — Alerting that respects humans
Page only on symptoms that are user-visible and need action now. Everything else is a ticket or a dashboard. Every alert needs an owner, a runbook link, and a clear "what do I do at 3 a.m." Alert fatigue is a reliability problem — an ignored page and no page are the same page.
TRAP: alerting on cause (CPU is high) instead of symptom (requests are failing) generates noise during normal load and silence during real outages.

MODULE 6 — Incident response
Roles: incident commander (decides, does not debug), communications lead, subject matter experts. Sequence: detect → triage → mitigate → resolve → review. Mitigate before you diagnose — roll back first, understand later. Blameless postmortem asks what made the mistake easy to make, and every action item needs an owner and a date. Track MTTD and MTTR, not blame.

MODULE 7 — Capacity and cost observability
Cost is an operational signal. Tag everything, alert on budget burn as well as error budget burn, watch egress and log ingestion — the two bills that surprise people. Right-size from observed usage, not from the size someone picked at launch.

GLOSSARY
Cardinality — number of distinct label combinations in a metric series
Golden signals — latency, traffic, errors, saturation
Error budget — allowed unreliability implied by an SLO
Runbook — the documented steps for handling a specific alert
Blameless postmortem — review focused on systems and conditions, not individuals

READINESS CHECK
☐ Explain metrics vs. logs vs. traces and when each is the wrong tool
☐ Write a KQL query computing an error rate, from scratch
☐ Define an SLI, SLO, and error budget for one real service you have run
☐ Justify why an alert should page rather than file a ticket
☐ Describe an incident you would mitigate before diagnosing, and why
☐ Name the two cloud bills that grow silently: egress and log ingestion
''';

const _capstone = '''
CAPSTONE — PRODUCTIONIZE PURPLEQUEUE
The portfolio piece. Every certification above is theory until one real application is containerized, provisioned by code, deployed by a pipeline, and observable in production. Use PurpleQueue rather than a tutorial app — an interviewer can tell the difference immediately.

STAGE 1 — Containerize
Write a multi-stage Dockerfile: build stage compiles, runtime stage carries only the artifact. Run as a non-root user. Add a .dockerignore. Build, tag with the commit SHA (never only latest), push to Azure Container Registry. Scan the image and fix what the scan finds.
Checkpoint: the image runs identically on your machine and in ACR, and is under a size you can defend.

STAGE 2 — Provision with Terraform
Resource group, VNet and subnets, ACR, AKS cluster with a small node pool, Log Analytics workspace, and Key Vault. State in Azure Storage with locking enabled. Separate variables per environment. No portal clicks — if it exists and is not in Terraform, it does not count.
Checkpoint: terraform destroy then terraform apply rebuilds the entire environment from nothing.

STAGE 3 — Deploy on Kubernetes
Helm chart with values per environment. Deployment with resource requests and limits, liveness and readiness probes, and at least two replicas. Service plus Ingress with TLS. Secrets from Key Vault via the CSI driver or workload identity — never a Secret manifest in Git.
Checkpoint: kill a pod and watch traffic keep flowing; roll out a bad image and roll it back.

STAGE 4 — CI/CD
GitHub Actions: on pull request run lint, tests, terraform plan, and a container build. On merge to main, build and push the image, then deploy. Authenticate to Azure with OIDC workload identity federation — no stored credentials anywhere in the repo. Protect main with required checks and a review.
Checkpoint: a merged pull request reaches production with no manual step, and a failed test stops it.

STAGE 5 — Observability
Container Insights or managed Prometheus for cluster metrics, Application Insights for app telemetry, one Grafana or Azure dashboard that answers "is it healthy" in five seconds. Define one real SLO with an error budget. One alert that pages, wired to an action group, with a runbook.
Checkpoint: break something on purpose and let the alert find it before you do.

STAGE 6 — Prove it and write it up
Load-test until something degrades and record what failed first — saturation, a missing limit, a database connection pool. Fix one of them. Then write the README an interviewer will actually read: architecture diagram, the decisions and their tradeoffs, what you would do differently at ten times the scale, and the cost per month.
Checkpoint: you can walk through the whole system in five minutes without opening the code.

COST DISCIPLINE
Everything above fits inside free tiers and small SKUs if you are deliberate: smallest AKS node pool, Basic ACR, free-tier Log Analytics ingestion, and terraform destroy at the end of every session. Set a budget alert on day one. Leaving an AKS cluster running overnight is the classic way to lose a month of budget to nothing.

INTERVIEW ANGLES THIS UNLOCKS
• "Walk me through a deployment" — you have a real pipeline to describe
• "How do you handle secrets" — OIDC and Key Vault, demonstrated, not asserted
• "How do you know it is healthy" — an SLO you defined and an alert that fired
• "Tell me about something that broke" — the load test result, with a real fix
• "How would you scale this" — you have measured where it bends first

READINESS CHECK
☐ Image builds reproducibly and is tagged by commit SHA
☐ The whole environment rebuilds from terraform apply alone
☐ A pod can die without user-visible impact
☐ A merge reaches production with zero manual steps
☐ One SLO, one paging alert, one runbook exist and have been tested
☐ The README explains tradeoffs, not just commands
''';
