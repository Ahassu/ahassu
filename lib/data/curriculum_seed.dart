import '../models/learning_path.dart';
import '../models/topic.dart';

/// The Azure Platform Engineer curriculum, fundamentals -> expert: AZ-900,
/// AZ-104 and AZ-400 as the Azure spine, with Linux/networking, Terraform,
/// Docker, Kubernetes, observability and Databricks around it, finishing
/// with interview prep and a capstone that productionizes a real app.
///
/// Path ids are semantic (path_az900, not path_01) so the seed can be
/// re-synced in place without renumbering when paths are added or removed.
/// Seeded and re-synced by FirestoreService; freely editable from the app
/// afterwards.
List<LearningPath> buildSeedLearningPaths() {
  final raw = <(String key, String title, String? examCode, List<String> topics)>[
    (
      'az900',
      'Azure Fundamentals (AZ-900)',
      'AZ-900',
      [
        'Cloud concepts: IaaS, PaaS, SaaS and the shared responsibility model',
        'Capex vs. opex, consumption pricing, and the Azure free tier',
        'Azure architecture: regions, availability zones, resource groups',
        'Management groups, subscriptions, and scope inheritance',
        'Compute: VMs, Scale Sets, App Service, Container Apps, AKS, Functions',
        'Networking: VNets, subnets, NSGs, VPN Gateway, ExpressRoute',
        'Storage: Blob tiers, Files, Disks, and redundancy (LRS/ZRS/GRS)',
        'Identity: Microsoft Entra ID, RBAC, MFA, Conditional Access',
        'Governance: Azure Policy, resource locks, tags, Cost Management',
        'Monitoring: Azure Monitor, Log Analytics, Service Health, Advisor',
        'AWS-to-Azure service mapping (EC2/S3/IAM/VPC and friends)',
      ],
    ),
    (
      'linux',
      'Linux, Networking & Git Foundations',
      null,
      [
        'Linux filesystem layout, permissions, and ownership',
        'Process management and systemd units',
        'Shell scripting and text processing (grep, sed, awk, jq)',
        'SSH, key management, and remote troubleshooting',
        'TCP/IP, CIDR, and subnetting by hand',
        'The DNS resolution path and the records that matter',
        'TLS handshake, certificates, and expiry troubleshooting',
        'Git branching, rebase vs. merge, and the pull-request workflow',
      ],
    ),
    (
      'az104',
      'Azure Administrator Associate (AZ-104)',
      'AZ-104',
      [
        'Entra ID: users, groups, administrative units, and role assignment',
        'RBAC scope inheritance and custom role definitions',
        'Governance: management groups, Azure Policy, tags, cost controls',
        'Storage accounts: redundancy, lifecycle rules, SAS, private endpoints',
        'Azure Files and blob access tiers in practice',
        'VMs: sizing, availability sets vs. zones, Scale Sets, images',
        'App Service and Container Instances/Apps for PaaS workloads',
        'AKS basics: cluster creation, node pools, and scaling',
        'Virtual networking: VNets, subnets, NSGs, peering, private DNS',
        'Load balancing: Load Balancer vs. Application Gateway vs. Front Door',
        'Hybrid connectivity: VPN Gateway and ExpressRoute',
        'Backup, restore, and Azure Site Recovery',
        'Monitoring: Azure Monitor, Log Analytics, KQL, alert rules',
        'Deployment: Azure CLI, PowerShell, ARM templates and Bicep',
      ],
    ),
    (
      'terraform',
      'Infrastructure as Code (Terraform Associate 003)',
      'TF-003',
      [
        'IaC concepts: declarative vs. imperative, drift, idempotency',
        'The core workflow: init, plan, apply, destroy',
        'HCL: providers, resources, data sources, variables, locals, outputs',
        'State: remote backends, locking, and keeping secrets out of it',
        'Modules: authoring, versioning, and consuming from the registry',
        'Resource lifecycle: depends_on, count, for_each, import, moved',
        'Provisioners and why they are the last resort',
        'HCP Terraform workflows: workspaces, runs, and policy checks',
        'The azurerm provider: authentication and subscription targeting',
        'Terraform in CI: fmt, validate, tflint, and plan as a PR gate',
      ],
    ),
    (
      'docker',
      'Docker & Containerization',
      null,
      [
        'Docker fundamentals: images, layers, containers, volumes',
        'Writing Dockerfiles for application services',
        'Container registries (ACR, Docker Hub) and image scanning',
        'Multi-stage builds and image slimming',
        'Docker Compose for local multi-service stacks',
        'Container security: non-root users, minimal base images, SBOMs',
      ],
    ),
    (
      'cka',
      'Kubernetes Administrator (CKA)',
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
        'Troubleshooting: CrashLoopBackOff, ImagePullBackOff, Pending pods',
      ],
    ),
    (
      'az400',
      'CI/CD & Platform Delivery (AZ-400)',
      'AZ-400',
      [
        'Azure DevOps and GitHub Actions pipelines',
        'Multi-stage YAML: build, test, deploy',
        'Source control strategy and branch protection',
        'Infrastructure as Code inside the pipeline (Bicep/Terraform)',
        'Secrets: Key Vault and workload identity federation (OIDC)',
        'Deployment strategies: blue-green, canary, ring, feature flags',
        'Release gates, approvals, and environments',
        'Artifact and package management',
        'Security scanning: dependency, code, secret, container',
        'Instrumentation: Application Insights and KQL',
      ],
    ),
    (
      'observability',
      'Observability & SRE Practices',
      null,
      [
        'The three signals: metrics, logs, and traces',
        'Azure Monitor, Log Analytics workspaces, and writing KQL',
        'Prometheus and Grafana on Kubernetes',
        'SLIs, SLOs, and error budgets',
        'Alerting that pages a human vs. alerting that files a ticket',
        'Incident response, on-call, and blameless postmortems',
        'Capacity planning and cost observability',
      ],
    ),
    (
      'databricks',
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
      'interview',
      'Interview Preparation — Platform Engineer',
      null,
      [
        'Platform system design: landing zones, subscriptions, multi-tenancy',
        'Translating AWS experience into Azure equivalents out loud',
        'Terraform deep-dives: state, modules, drift, blast radius',
        'Kubernetes deep-dives: scheduling, networking, failure modes',
        'Troubleshooting scenarios: "the deploy is broken, walk me through it"',
        'Behavioral / STAR stories, including the career-break narrative',
        'Speak for 2–5 minutes on any core concept, unprepared',
      ],
    ),
    (
      'capstone',
      'Capstone: Productionize PurpleQueue',
      null,
      [
        'Containerize the app and push images to ACR',
        'Provision the Azure footprint with Terraform',
        'Deploy to AKS with a Helm chart',
        'Wire CI/CD in GitHub Actions using OIDC, no stored secrets',
        'Add monitoring, alerting, and one real SLO',
        'Load-test it and document what broke first',
        'Write the architecture up as a portfolio piece',
      ],
    ),
  ];

  var order = 0;
  return raw.map((entry) {
    final (key, title, examCode, topicTitles) = entry;
    order += 1;
    return LearningPath(
      id: 'path_$key',
      order: order,
      title: title,
      examCode: examCode,
      topics: topicTitles.asMap().entries.map((e) {
        return Topic(id: 'topic_${key}_${e.key}', title: e.value);
      }).toList(),
    );
  }).toList();
}
