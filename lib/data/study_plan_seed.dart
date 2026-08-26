import '../models/study_area.dart';

/// The study plan for one specific posting: Platform Engineer, Global Banking
/// and Markets (Data & AI Platform), Dallas.
///
/// Every area and subtopic traces back to a line in that job description, and
/// the ordering follows how hard the posting leans on each rather than how
/// interesting the topic is. `AreaWeight.critical` means the posting names it
/// in both "What You'll Do" and "What You'll Bring"; `support` means it
/// appears once, usually as a responsibility rather than a requirement.
///
/// Each card is two things and nothing else: the question as an interviewer
/// would ask it, and the answer to say back. The answer is written to be
/// spoken — short sentences, no stacked subordinate clauses, and a concrete
/// detail near the end so it lands as experience rather than as a definition
/// read back.
///
/// Subtopic ids are stable and area-prefixed. Progress is keyed on them, so
/// rewording a title or reordering the list never loses a tick.

typedef _Card = (String question, String answer);
typedef _Sub = (String id, String title, String summary, List<_Card> cards);
typedef _Area = (
  String id,
  String title,
  String focus,
  AreaWeight weight,
  List<_Sub> subs,
);

List<StudyArea> buildStudyPlan() {
  var order = 0;
  return _plan.map((a) {
    final (id, title, focus, weight, subs) = a;
    return StudyArea(
      id: id,
      title: title,
      focus: focus,
      weight: weight,
      order: order++,
      subtopics: subs
          .map(
            (s) => StudySubtopic(
              id: '$id.${s.$1}',
              title: s.$2,
              summary: s.$3,
              cards: s.$4
                  .map((c) => StudyCard(question: c.$1, answer: c.$2))
                  .toList(),
            ),
          )
          .toList(),
    );
  }).toList();
}

const _plan = <_Area>[
  (
    'intro',
    'Introduce Yourself',
    'The first five minutes decide the tone of everything after. These answers are scripted for a reason — fluency here buys you patience later.',
    AreaWeight.critical,
    [
      (
        'tell-me',
        'Tell me about yourself',
        'The opening question. Ninety seconds, rehearsed until it is boring to you.',
        [
          (
            'Tell me about yourself.',
            'I am a platform and cloud engineer with about eight years in IT. Most of that was cloud engineering at scale — I ran infrastructure across more than two hundred AWS accounts, which meant working every day with IAM, networking and security teams on governance, access and guardrails rather than one application. I took a career break for family reasons, and over the past several months I have been rebuilding deliberately and specifically toward Azure data platform work. I have built a lakehouse on Databricks with Unity Catalog, Auto Loader, streaming and Delta Live Tables, an Azure governance lab with VNets, subnets, NSGs, RBAC and resource locks, and a GitHub Actions pipeline with per-pull-request preview environments. That is why this role stood out — it is the same platform engineering discipline I already did at scale, on the Azure and Databricks side, in a regulated environment.',
          ),
        ],
      ),
      (
        'gap',
        'The career break',
        'It will come up in the first five minutes. Handle it in twenty seconds and it stops being the topic.',
        [
          (
            'I see a gap in your resume. What happened?',
            'I took a three-year career break for family reasons. I came back to it deliberately rather than casually — I picked a target role, worked out exactly what it needed, and built toward it. In the last few months that has meant a Databricks lakehouse with Unity Catalog and Delta Live Tables, an Azure governance lab in infrastructure as code, and a CI/CD pipeline I run myself. I am current on what changed while I was out, and where something is newer than my catch-up I will tell you rather than guess.',
          ),
        ],
      ),
      (
        'aws-azure',
        'AWS depth, Azure preference',
        'Your experience is AWS and the posting says Azure preferred. Get in front of it.',
        [
          (
            'Most of your experience is AWS. This role is Azure.',
            'That is fair, and it is the reason I built Azure evidence rather than just claiming transferability. The concepts map directly — a VPC is a VNet, a security group is an NSG, an IAM role is a managed identity, and the governance problem of two hundred accounts is the same problem as a subscription hierarchy with management groups and policy. What I have actually built on Azure is a governance lab with VNets, subnets, NSGs, RBAC assignments and resource locks in infrastructure as code, plus a deployment pipeline. So the platform thinking came from AWS at real scale, and the Azure fluency is current and hands-on.',
          ),
        ],
      ),
      (
        'why-role',
        'Why this role',
        'Why platform engineering, and why this posting specifically.',
        [
          (
            'Why are you interested in this role?',
            'Two reasons. First, the work itself lines up almost exactly with what I have done and what I have been rebuilding — Azure networking and IAM, Databricks clusters and Unity Catalog, Terraform modules, pipelines in GitHub Actions and Azure DevOps, and observability with Azure Monitor. Second, the shape of the role. It is explicitly working under senior engineers and platform leads, contributing to a platform other teams depend on. That is the kind of team environment I want coming back in — a real platform at scale with people to learn the house standards from.',
          ),
        ],
      ),
      (
        'why-scotia',
        'Why Scotiabank',
        'Prove you read past the job title.',
        [
          (
            'Why Scotiabank, and why Global Banking and Markets?',
            'Global Banking and Markets is a capital markets and investment banking business with a footprint across Canada, the US and Latin America, and this team runs the Data and AI platform underneath it. What attracts me is that it is regulated and multi-geography. My AWS work was governance across two hundred accounts — controls, access, guardrails, and cross-team dependencies — and that experience is worth much more in a bank than it is somewhere with no compliance surface. I would rather do platform engineering where the controls matter than somewhere they are optional.',
          ),
        ],
      ),
      (
        'strongest',
        'Your strongest card',
        'When they ask what you are best at, lead with Databricks.',
        [
          (
            'What is your strongest technical area?',
            'On the data platform side, Databricks. I have built an end-to-end lakehouse — Unity Catalog for governance, Auto Loader with checkpointing for incremental ingestion, MERGE with slowly changing dimensions and change data feed, Delta Live Tables with quality constraints, and structured streaming with watermarks. On the platform engineering side, it is governance at scale — running two hundred plus AWS accounts taught me to think in guardrails and standards rather than one-off fixes, which is the same instinct this role is asking for with reusable Terraform modules.',
          ),
        ],
      ),
      (
        'weakness',
        'Weakness and gaps',
        'Name a real one, with the work already underway.',
        [
          (
            'What is your biggest weakness or gap for this role?',
            'Terraform depth is the honest one. My infrastructure as code background is CloudFormation on AWS and Bicep on Azure, so I understand state, drift and module design as concepts, but I have less Terraform mileage than someone who has run it in production for three years. I have been closing it deliberately — porting my Azure governance lab from Bicep to Terraform, with remote state in a storage account with locking, modules with proper inputs and outputs, and plan and apply through a pipeline. I would rather tell you that straight than have it surface in week two.',
          ),
        ],
      ),
      (
        'oncall',
        'After-hours and on-call',
        'The posting says rotational after-hours and weekends when required.',
        [
          (
            'This role includes after-hours support on a rotational basis. Is that a problem?',
            'No, that is fine. On-call is part of owning a platform, and I would rather be on the rotation than be the person who only sees the platform when it is working. What I care about is that on-call is sustainable — a reasonable rotation size, runbooks that mean the person paged can actually act, and alerts that fire on things a human needs to do something about. If any of that is thin when I join, that is useful work I would be glad to pick up.',
          ),
        ],
      ),
      (
        'questions',
        'Questions to ask them',
        'Have five ready. Asking nothing reads as no interest.',
        [
          (
            'Do you have any questions for us?',
            'A few. How is the platform team structured, and where would this role sit within it? What does it look like today when a new Databricks workload gets onboarded — is that self-service or does it come through the team? What is the biggest source of toil or repeat incidents right now? And how much of the estate is in Terraform today versus still managed by hand, because that tells me a lot about where the first six months would go.',
          ),
        ],
      ),
    ],
  ),
  (
    'azure-network',
    'Azure Networking',
    'The posting names VNets, NSGs, route tables and private endpoints explicitly. In a bank this is usually the first technical screen.',
    AreaWeight.critical,
    [
      (
        'topology',
        'Network topology',
        'How the VNets are arranged, and why a bank picks hub-and-spoke.',
        [
          (
            'What are the main Azure network topologies and when would you use each?',
            'For a bank I would use hub and spoke. It gives centralised traffic control through Azure Firewall, shared services like Private DNS and the ExpressRoute gateway in one place, and isolated spokes per environment. Virtual WAN is a fair option at global scale, but hub and spoke gives more direct control over routing, which matters when you have to evidence it to an auditor.',
          ),
        ],
      ),
      (
        'vnet',
        'VNets and subnets',
        'The private address space and how it is segmented.',
        [
          (
            'How do you design a VNet and its subnets?',
            'I plan the address space up front, because resizing a subnet that already has resources in it is genuinely painful. Then I split by function rather than by convenience — one subnet for private endpoints, one for compute, one delegated to Databricks — so each one can carry its own NSG and route table. And I remember Azure reserves five addresses per subnet, which matters when someone asks for a /29.',
          ),
        ],
      ),
      (
        'nsg',
        'Network Security Groups',
        'Stateful allow and deny rules on subnets and NICs.',
        [
          (
            'How do NSGs work and what trips people up?',
            'An NSG is a stateful firewall I attach to a subnet or a NIC. Rules are evaluated by priority, lowest first, and the first match wins, so I leave gaps between priorities to make room later. The thing that trips people up is the default rules — outbound to the internet and traffic inside the VNet are already allowed, so if I want a deny posture I have to write it explicitly.',
          ),
        ],
      ),
      (
        'udr',
        'Route tables and UDRs',
        'Overriding Azure default routing to force traffic through inspection.',
        [
          (
            'Why would you use a user-defined route?',
            'The usual reason is forced tunnelling — I want all outbound traffic going through Azure Firewall so egress is inspected and logged, which in a bank is normally mandatory. I attach the route table to the workload subnet with the next hop set to the firewall private IP. The mistake to avoid is applying that same route table to the firewall subnet itself, because you route the firewall through itself and take the whole thing down.',
          ),
        ],
      ),
      (
        'private-endpoint',
        'Private endpoints and Private Link',
        'Giving a PaaS service a private IP inside your VNet.',
        [
          (
            'What is a private endpoint, and how is it different from a service endpoint?',
            'A private endpoint puts the service on a private IP inside my VNet, so traffic never touches the public internet, and I can then disable the public endpoint entirely. A service endpoint keeps traffic on the Azure backbone but the resource still has a public IP that I filter by subnet. In a regulated environment I default to private endpoints, because "there is no public IP at all" is a far easier control to evidence. The part people get wrong is DNS — without the privatelink zone linked to the VNet, the name still resolves to the public address.',
          ),
        ],
      ),
      (
        'private-dns',
        'Private DNS zones',
        'Making private endpoint names resolve to private IPs.',
        [
          (
            'A private endpoint was created but the app still cannot reach the service. What do you check?',
            'DNS, almost every time. The private endpoint exists, but the name still resolves to the public IP because the privatelink zone is not linked to that VNet. I would run a resolve from inside the subnet first — if it comes back with a public address, that is the answer and I have not had to touch the network at all.',
          ),
        ],
      ),
      (
        'peering',
        'VNet peering',
        'Connecting VNets privately, and why it is not transitive.',
        [
          (
            'How does VNet peering work and what is its main limitation?',
            'Peering connects two VNets over the backbone with private addressing and no gateway in the path. The key limitation is that it is not transitive — if two spokes are both peered to the hub, they still cannot reach each other directly. You route them through a firewall in the hub with a UDR. That limitation is actually why hub and spoke works as a security model: everything between spokes is inspected by design.',
          ),
        ],
      ),
      (
        'firewall',
        'Azure Firewall and egress control',
        'Centralised outbound inspection and exfiltration control.',
        [
          (
            'How do you control what a workload can reach on the internet?',
            'I centralise egress through Azure Firewall in the hub, with route tables on the workload subnets sending everything to it. Application rules restrict outbound by FQDN, network rules by port and address. The reason this matters in a bank is exfiltration — if a workload is compromised, I want it unable to reach an arbitrary endpoint, and I want a log of it trying.',
          ),
        ],
      ),
      (
        'lb',
        'Load balancing options',
        'Picking between Load Balancer, Application Gateway and Front Door.',
        [
          (
            'When would you use Load Balancer versus Application Gateway versus Front Door?',
            'I pick by layer and by scope. Load Balancer is layer four and regional, so it just distributes traffic. Application Gateway is layer seven and regional, which is what I want when I need path-based routing, TLS termination, and the web application firewall. Front Door is layer seven and global, so it is the answer when I need edge presence and failover between regions.',
          ),
        ],
      ),
      (
        'hybrid',
        'ExpressRoute and VPN',
        'How the bank connects on-premises to Azure.',
        [
          (
            'How does on-premises connectivity work in an enterprise Azure estate?',
            'A bank this size will be on ExpressRoute — a private circuit into Azure with no internet transit — usually with a site-to-site VPN as the failover path. Both terminate on a gateway in the hub, and the spokes reach them through gateway transit. From a platform point of view the thing I watch is the interaction between BGP route propagation and my own route tables, because that is where on-premises routes quietly get blackholed.',
          ),
        ],
      ),
      (
        'troubleshoot',
        'Diagnosing connectivity',
        'A fixed order for working a network problem.',
        [
          (
            'A service is unreachable. Walk me through how you diagnose it.',
            'I work the path in a fixed order rather than guessing. DNS first, because a wrong resolution looks exactly like a network outage. Then effective NSG rules, then effective routes — a UDR pointing at a firewall that is denying the traffic is a very common cause. Then the resource firewall itself, which is a separate layer people forget. Network Watcher tells me which hop actually dropped it, so I am arguing from evidence rather than theory.',
          ),
        ],
      ),
    ],
  ),
  (
    'azure-identity',
    'Identity, RBAC and Secrets',
    'Named as "IAM/RBAC, Key Vault", and reinforced by working alongside a separate IAM team. Least privilege is what they are testing.',
    AreaWeight.critical,
    [
      (
        'rbac',
        'Azure RBAC',
        'Role, scope and assignment — and why you always assign to groups.',
        [
          (
            'How does Azure RBAC work?',
            'An assignment is three things — a principal, a role definition and a scope — and scope inherits downward, so Reader at subscription level is Reader on everything inside it. It is additive with no deny, so effective access is the union of every assignment. In practice I assign to groups rather than individuals and at the narrowest scope that actually works, because individual assignments at subscription scope are what audit findings are made of. The distinction I always make explicit is that Contributor can manage a resource but cannot grant access — granting is User Access Administrator.',
          ),
        ],
      ),
      (
        'managed-identity',
        'Managed identities',
        'Service principals Azure creates and rotates for you.',
        [
          (
            'What is a managed identity and when do you use system versus user assigned?',
            'A managed identity is a service principal that Azure creates and rotates for me, so there is no secret to store anywhere. System-assigned is tied to one resource and dies with it; user-assigned is standalone and shareable. For platform work I lean toward user-assigned, because if Terraform recreates a VM I do not want its role assignments silently disappearing with it. The code side is just DefaultAzureCredential picking up a token from the metadata endpoint.',
          ),
        ],
      ),
      (
        'oidc',
        'Workload identity federation',
        'Removing stored secrets from pipelines and clusters entirely.',
        [
          (
            'How does your pipeline authenticate to Azure without a stored secret?',
            'Workload identity federation. I put a federated credential on the identity that trusts the GitHub or Azure DevOps OIDC issuer, scoped to a specific repository and environment, so the pipeline presents its own token and exchanges it for an Azure token. There is no client secret anywhere — nothing to rotate and nothing to leak. It is the same mechanism on AKS, where the cluster publishes an OIDC issuer and a pod uses its projected service account token, so one concept covers both.',
          ),
        ],
      ),
      (
        'keyvault',
        'Key Vault',
        'Where secrets, keys and certificates live, and how access is granted.',
        [
          (
            'How do you manage secrets on Azure?',
            'Key Vault, behind a private endpoint with public access off, and access granted through Azure RBAC rather than the legacy access policy model so it is consistent with everything else in the subscription. Applications resolve secrets at runtime using their managed identity, which means rotating a secret is a vault-side operation with no redeploy. The gotcha worth knowing is purge protection — it is a good control, but it is also why a Terraform destroy and recreate on the same vault name fails.',
          ),
        ],
      ),
      (
        'pim-sod',
        'PIM and segregation of duties',
        'Time-boxed privilege, and separating who writes from who approves.',
        [
          (
            'How do you enforce least privilege and segregation of duties?',
            'Standing privilege is the thing I try to remove. Elevated roles sit behind PIM as eligible rather than active, so people activate for a few hours with a justification, and access reviews recertify what is left. For segregation of duties I lean on the pipeline: a developer opens the pull request, a different person approves the environment gate, and the apply runs as a federated deployment identity that no human can use directly. Humans are read-only in production, which is both a better control and much easier to evidence to audit.',
          ),
        ],
      ),
    ],
  ),
  (
    'azure-resources',
    'Azure Resource Platform',
    'The posting names Storage Accounts, Key Vault, Event Hub and Azure SQL as things you will build and support with Terraform.',
    AreaWeight.critical,
    [
      (
        'hierarchy',
        'Subscriptions and governance',
        'The scope hierarchy, and how a bank enforces standards across it.',
        [
          (
            'How do you govern a large Azure estate?',
            'Through the hierarchy plus policy. Management groups carry the standards, subscriptions are the isolation and billing boundary, and resource groups hold things with a shared lifecycle. Azure Policy is what makes the standards real — deny effects for allowed regions and no public endpoints, audit for things you are still remediating, and deployIfNotExists for diagnostic settings. This is exactly the shape of what I did on AWS across two hundred accounts with service control policies and guardrails, just with different names.',
          ),
        ],
      ),
      (
        'storage',
        'Storage Accounts and ADLS',
        'The lake underneath Databricks, and how it is secured.',
        [
          (
            'How would you configure a storage account for a Databricks lakehouse?',
            'Hierarchical namespace on, so it is ADLS Gen2 with real directories rather than flat blob semantics. Access through Entra ID and RBAC rather than account keys, public blob access disabled, and a private endpoint with the account firewall denying public network access. Redundancy is a conversation about the recovery objective rather than a default — zone redundant within a region, geo redundant if the requirement is regional failure. Then Unity Catalog external locations point at it through a storage credential, so grants govern the data rather than anyone holding keys.',
          ),
        ],
      ),
      (
        'eventhub',
        'Event Hubs',
        'Streaming ingestion, and the words that show you have used it.',
        [
          (
            'How does Event Hubs work?',
            'Event Hubs is high-throughput ingestion where partitions set parallelism and consumer groups let independent readers track their own offset. The two things I would flag on design are that partition count is fixed at creation, so you size for the consumers you expect, and that ordering is only guaranteed within a partition — so the partition key matters if order is meaningful. Capture is worth turning on in a bank because it lands raw events in storage for replay and audit without writing any code.',
          ),
        ],
      ),
      (
        'azuresql',
        'Azure SQL',
        'The managed relational database and its resilience story.',
        [
          (
            'What do you know about Azure SQL?',
            'It is the managed relational option — single database, elastic pool or managed instance depending on how much SQL Server surface you need. I would use vCore for predictable workloads and serverless where usage is intermittent, authenticate through Entra ID rather than SQL logins, and put it behind a private endpoint. For resilience the two things I check are that point-in-time restore covers the retention we actually need, and that failover groups are configured if the requirement is regional rather than just zonal.',
          ),
        ],
      ),
      (
        'cost',
        'Cost management',
        'Spend as a monitored signal, not a quarterly surprise.',
        [
          (
            'How do you keep cloud cost under control?',
            'I treat cost as a monitored signal rather than a monthly surprise. Tagging enforced by policy so spend attributes to an owner, budgets with alerts and anomaly detection, and reservations for anything genuinely steady-state. On the Databricks side specifically the levers are job clusters instead of all-purpose, aggressive auto-termination, spot workers for interruptible work, and cluster policies so people cannot spin up something enormous by accident. A cost regression gets an owner and a fix, the same as a reliability regression.',
          ),
        ],
      ),
    ],
  ),
  (
    'databricks',
    'Databricks',
    'Named in the team mandate, the responsibilities and the requirements. This is your strongest card — make it unmistakable.',
    AreaWeight.critical,
    [
      (
        'architecture',
        'Control plane and data plane',
        'The split that answers most security questions.',
        [
          (
            'How is Databricks architected on Azure?',
            'There are two planes. The control plane is Databricks-managed and holds the workspace, the job scheduler and metadata. The data plane runs in my own Azure subscription — the clusters are VMs in my VNet and the data sits in my storage account. That split is usually the first thing a bank security team asks about, and the answer is that with VNet injection and Private Link the compute is in my subnets under my NSGs and route tables, and the data never leaves the tenant.',
          ),
        ],
      ),
      (
        'clusters',
        'Clusters',
        'All-purpose versus job clusters, and the cost consequence.',
        [
          (
            'What is the difference between an all-purpose cluster and a job cluster?',
            'All-purpose clusters are interactive and shared, which is right for development. Job clusters are created for a single run and terminate when it finishes, so they are cheaper and isolated from other work. For anything scheduled I default to job clusters — running production jobs on a shared all-purpose cluster is the most common way a Databricks bill gets out of hand, and it couples unrelated workloads together. The other setting I always check is access mode, because shared mode is what actually enforces Unity Catalog governance when several people use the same cluster.',
          ),
        ],
      ),
      (
        'policies',
        'Cluster policies and pools',
        'How a platform team caps what users can create.',
        [
          (
            'How do you stop users creating oversized or untagged clusters?',
            'Cluster policies. They are admin-defined templates that constrain what a user can create — node types, worker counts, autoscaling bounds, auto-termination, and mandatory tags. That gives self-service within limits rather than either a free-for-all or a ticket queue, which is the balance a platform team wants. Tags enforced by policy are also how cluster spend attributes back to a team, so cost conversations have data behind them.',
          ),
        ],
      ),
      (
        'sqlwh',
        'SQL warehouses',
        'The BI and ad-hoc query compute, and its cost levers.',
        [
          (
            'What is a SQL warehouse and how do the types differ?',
            'A SQL warehouse is SQL-optimised compute for BI tools and analysts rather than notebook workloads. Serverless starts in seconds but the compute runs in the Databricks account, which in a bank often pushes you to pro or classic so the compute stays in your own subscription and network. Sizing is a t-shirt size for query complexity plus a scaling range for concurrency, and the single biggest cost lever is auto-stop — an idle warehouse left running overnight is pure waste.',
          ),
        ],
      ),
      (
        'unity-catalog',
        'Unity Catalog',
        'Centralised governance — your deepest evidenced area.',
        [
          (
            'Explain Unity Catalog.',
            'Unity Catalog is the governance layer that sits above workspaces. One metastore per region, a three-level namespace of catalog, schema and table, and SQL-style grants that inherit down the hierarchy. The part I would highlight for a platform role is external locations — a storage credential wraps a managed identity that can reach ADLS, an external location binds it to a path, and then grants on that location are how you control who can touch raw storage. Once data is governed by Unity Catalog you also get lineage and audit for free, which in a bank is worth as much as the access control.',
          ),
        ],
      ),
      (
        'jobs',
        'Jobs and workflows',
        'The scheduled work you will be asked to monitor.',
        [
          (
            'How do you build and operate Databricks workflows?',
            'A workflow is a multi-task job with dependencies, so ingestion, transformation and quality checks run in order with retries and timeouts on each. I use job clusters per run rather than a shared interactive cluster. Operationally what matters is the run history — I alert on failed runs, but I also watch duration, because a job that still succeeds while taking three times as long is usually the earliest signal that something upstream changed.',
          ),
        ],
      ),
      (
        'delta',
        'Delta Lake',
        'The table format underneath everything.',
        [
          (
            'What is Delta Lake and why does it matter?',
            'Delta is Parquet with a transaction log on top, and the log is what gives you ACID guarantees, so a reader never sees a half-written table. Practically the features I use are time travel for recovering from a bad write and for audit, schema enforcement so a malformed upstream change fails loudly instead of corrupting the table, and MERGE for upserts and slowly changing dimensions. The operational side is OPTIMIZE to fix small file problems and VACUUM to expire old versions — with the caveat that VACUUM removes your time travel window.',
          ),
        ],
      ),
      (
        'autoloader',
        'Auto Loader and streaming',
        'Incremental ingestion — you have built this.',
        [
          (
            'How do you ingest new files incrementally?',
            'Auto Loader. It uses the cloudFiles source to track which files have already been processed in a checkpoint, so a scheduled run only picks up what is new rather than rescanning the whole path. I run it with trigger availableNow when the workload is really scheduled batch rather than continuous. For streaming aggregations I set watermarks so late-arriving data is bounded and state does not grow without limit — and I treat the checkpoint location as production state, because deleting it means reprocessing everything.',
          ),
        ],
      ),
      (
        'bundles',
        'Databricks Asset Bundles',
        'Named explicitly in the posting — Databricks own IaC.',
        [
          (
            'What are Databricks Asset Bundles?',
            'Bundles are Databricks own infrastructure as code — a databricks.yml that declares jobs, workflows and notebooks with per-environment targets, deployed from CI with validate then deploy. The value is that a production workflow stops being something someone edited in the UI and becomes a reviewed, versioned artefact. The way I think about the split is that Terraform provisions the workspace, the clusters policies and the Unity Catalog objects, and bundles deploy the work that runs inside it.',
          ),
        ],
      ),
      (
        'secrets-net',
        'Secret scopes and networking',
        'Keeping credentials out of notebooks.',
        [
          (
            'How do you handle credentials in a Databricks notebook?',
            'Secret scopes, backed by Key Vault so rotation happens in one place, and read with dbutils.secrets so values are redacted from notebook output. But the better answer for storage access specifically is not to have a secret at all — Unity Catalog storage credentials wrap a managed identity, so access to ADLS is governed by grants rather than by a key anyone could fetch. A hardcoded key in a notebook cell is the thing I would flag immediately in a review.',
          ),
        ],
      ),
      (
        'monitor',
        'Monitoring Databricks',
        'What you watch, and where the evidence lives.',
        [
          (
            'How would you monitor the Databricks platform?',
            'Three layers. Job level, which is run history — failures obviously, but also duration and queue time, because degradation shows up there before it shows up as failure. Cluster level, which is event logs and driver logs when something dies. And platform level, which is system tables and audit logs for who ran what and who granted access to what. Then I split alerting by what a human should actually do: a failed production run pages, a cost anomaly or a slow trend files a ticket.',
          ),
        ],
      ),
    ],
  ),
  (
    'terraform',
    'Terraform and IaC',
    'Named five separate times in the posting. It is your biggest gap and the highest-leverage thing to close — expect deep questions.',
    AreaWeight.critical,
    [
      (
        'workflow',
        'The core workflow',
        'init, plan, apply — and what each actually does.',
        [
          (
            'Walk me through the Terraform workflow.',
            'init pulls providers and modules and wires up the backend, plan refreshes state and computes the diff, and apply executes it. The detail I would add for a pipeline is that plan should write a plan file and apply should consume that exact file, so what a reviewer approved is literally what gets applied — otherwise something can change between the two steps and the approval means less than it looks. The plan output is the artefact a human reviews, so I treat it as the deliverable of the CI stage.',
          ),
        ],
      ),
      (
        'state',
        'State and remote backends',
        'The guaranteed interview question.',
        [
          (
            'How do you manage Terraform state in a team?',
            'Remote state in an Azure Storage account, with the blob lease providing locking so two engineers cannot apply at the same time. State is sensitive — it contains resource attributes including secrets in plaintext — so the container has restricted RBAC, versioning enabled, and no public access. And I keep state separate per environment, either separate backends or separate keys, so there is no path by which a dev apply reaches production. Shared local state is the failure mode I would flag if I saw it.',
          ),
        ],
      ),
      (
        'modules',
        'Modules',
        'The reusable modules this posting explicitly asks you to build.',
        [
          (
            'How do you design a reusable Terraform module?',
            'A module is a thing with a clean interface — typed variables with validation coming in, outputs going out, and nothing environment-specific hardcoded inside. I version them and consume by source and version, so a module change never silently reaches production the next time someone runs apply. The example I would give from this posting is three teams copy-pasting a storage account definition: I would turn that into one module that bakes in the private endpoint, the diagnostic settings and the tagging standard, so the standard is the default rather than something people have to remember.',
          ),
        ],
      ),
      (
        'iteration',
        'count, for_each and lifecycle',
        'The details that separate reading Terraform from writing it.',
        [
          (
            'When do you use count versus for_each?',
            'for_each almost always. count indexes by position, so removing the second item in a list of five re-creates the three after it — which on storage accounts or databases is a genuine outage rather than an inconvenience. for_each keys by a stable string, so adding and removing is safe. I keep count for the simple case of a resource that either exists or does not. And on critical resources I add prevent_destroy, because a plan that proposes destroying production should fail rather than wait for someone to read it carefully.',
          ),
        ],
      ),
      (
        'drift',
        'Drift, import and refactoring',
        'Reconciling Terraform with a world people changed by hand.',
        [
          (
            'Someone changed a resource in the portal. What happens and what do you do?',
            'The next plan shows it, because Terraform refreshes state and sees the difference — that is drift detection working, not a problem in itself. Then it is a decision: if the manual change was correct I codify it and apply, and if it was not I let Terraform revert it. For a resource that was created by hand and needs bringing under management, import does that without recreating it, and moved lets me refactor module structure without a destroy. But the real fix is preventive — humans read-only in production so the portal is not a write path.',
          ),
        ],
      ),
      (
        'pipeline',
        'Terraform in CI/CD',
        'Plan on PR, apply on merge, behind an approval.',
        [
          (
            'How do you run Terraform through a pipeline?',
            'Plan on the pull request with the output posted for review, and apply on merge behind an environment approval — which is also how segregation of duties gets enforced and evidenced. Authentication is OIDC federation to a deployment identity per environment, so there is no client secret in a variable group. The detail I would raise unprompted for a bank is agents: if the backend storage and the target resources are behind private endpoints, Microsoft-hosted runners cannot reach them, so you need self-hosted runners inside the VNet.',
          ),
        ],
      ),
      (
        'databricks-provider',
        'Terraform for Databricks',
        'The exact combination this posting asks for.',
        [
          (
            'How would you manage Databricks with Terraform?',
            'Two providers with two authentication scopes — azurerm creates the workspace, and the Databricks provider manages what lives inside it, which means you have to handle the ordering so workspace-level resources come after the workspace exists. I would put the platform-shaped things in Terraform: cluster policies, pools, Unity Catalog catalogs and external locations, and permissions. Jobs and notebooks I would leave to Asset Bundles, because they change with the application rather than with the platform, and mixing the two lifecycles in one state makes both harder to move.',
          ),
        ],
      ),
    ],
  ),
  (
    'cicd',
    'CI/CD and Release',
    'Both toolchains are named — Azure DevOps and GitHub Actions — plus artifact repositories and deployment templates. You have real evidence here.',
    AreaWeight.critical,
    [
      (
        'git',
        'Git and branching',
        'How work actually reaches main.',
        [
          (
            'What branching strategy do you use?',
            'Trunk-based with short-lived feature branches and pull requests into a protected main. Required reviews and required status checks, no direct pushes. I keep branches short because a two-week branch is a merge conflict with a deadline attached. In a bank there is a second reason for that setup — branch protection with a required reviewer is the control that evidences someone other than the author approved the change.',
          ),
        ],
      ),
      (
        'gha',
        'GitHub Actions',
        'You have a working pipeline — describe it concretely.',
        [
          (
            'Tell me about a pipeline you have built.',
            'I built a GitHub Actions workflow that builds and deploys to Azure Static Web Apps, with a preview environment created per pull request and torn down automatically when the PR closes, and a concurrency group so a new push cancels the superseded run instead of racing it. Authentication is federated rather than a stored secret. It is a small application, but the pipeline patterns are the same ones I would apply to a Terraform plan and apply flow — ephemeral environments, cancellation, and no long-lived credentials.',
          ),
        ],
      ),
      (
        'ado',
        'Azure Pipelines',
        'The other named toolchain and its vocabulary.',
        [
          (
            'How do Azure Pipelines differ from GitHub Actions?',
            'Conceptually they are the same thing with different nouns. Azure Pipelines has stages, jobs and steps with templates for reuse, variable groups linked to Key Vault, service connections for Azure authentication, and environments carrying the approval gates. GitHub Actions has workflows, jobs and reusable workflows, with environments doing the same gating job. I have run both — the transferable parts are the pipeline design and the identity model, and the rest is syntax.',
          ),
        ],
      ),
      (
        'artifacts',
        'Artifact repositories',
        'Named in the posting — build once, promote, never rebuild.',
        [
          (
            'How do you manage build artifacts across environments?',
            'Build once and promote the same artefact through environments rather than rebuilding per environment — if you rebuild, you tested something that is not what you shipped. Packages go to Azure Artifacts or GitHub Packages, container images to ACR, and everything is tagged with the commit SHA rather than a floating tag so anything running traces back to a commit and a pipeline run. Retention policies keep it from growing forever.',
          ),
        ],
      ),
      (
        'quality',
        'Quality gates',
        'What the pipeline blocks on.',
        [
          (
            'What checks run in your pipeline before something ships?',
            'Format and lint, unit tests, then the infrastructure-specific ones — validate, tflint, and a security scanner like Checkov. Plus dependency, secret and container image scanning. The principle I hold to is that these fail closed: a check that emits a warning nobody reads is not a control, it is decoration. Then a human approval on the production environment, which is deliberately the only manual step.',
          ),
        ],
      ),
    ],
  ),
  (
    'observability',
    'Monitoring and Observability',
    'Named in three separate bullets — observability tooling, monitoring, and reliability. It carries more weight than its one requirements line suggests.',
    AreaWeight.high,
    [
      (
        'signals',
        'Metrics, logs and traces',
        'Which signal answers which question.',
        [
          (
            'What is the difference between metrics, logs and traces?',
            'They answer different questions. Metrics are cheap numeric series so they are what I alert on and what I trend. Logs are detailed and expensive so they are what I diagnose with once an alert has fired. Traces follow a single request across components, which is how you find which hop the latency is actually in. In practice the cost conversation is almost always about log ingestion, so I am deliberate about what gets ingested at full fidelity versus what goes to a cheaper tier or gets sampled.',
          ),
        ],
      ),
      (
        'law-kql',
        'Log Analytics and KQL',
        'Be able to write a query live.',
        [
          (
            'Write me a query to find failed jobs in the last hour.',
            'I would filter first, then aggregate. Something like: take the table, where TimeGenerated is greater than ago one hour and the status is failed, summarize count by bin of TimeGenerated five minutes and by job name, then order by the count descending. The habit I keep is filtering on time first and projecting only the columns I need before any join, because in a busy workspace that is the difference between a query that returns and one that times out.',
          ),
        ],
      ),
      (
        'alerts',
        'Alert design',
        'The difference between monitoring and being woken up for nothing.',
        [
          (
            'How do you decide what to alert on?',
            'I alert on symptoms rather than causes — the thing a user or a downstream team actually feels — because cause-based alerting produces a page for every internal hiccup and trains people to ignore the channel. Every alert needs an owner and a runbook, and a route that matches its severity: page for something needing action now, ticket for something needing action this week. And I review the ones that keep firing and getting closed with no action, because a noisy alert is a reliability problem in its own right.',
          ),
        ],
      ),
      (
        'dashboards',
        'Dashboards and ingestion',
        'What the posting calls "monitoring dashboards" and "log ingestion pipelines".',
        [
          (
            'How would you build observability for a new platform component?',
            'First get the data in — diagnostic settings on every resource pointing at the Log Analytics workspace, data collection rules for anything agent-based, and an Event Hub route if a SIEM needs a copy. Then the dashboard, and I try to keep it answering two questions: is this healthy right now, and what changed. A dashboard with forty tiles is one nobody reads during an incident. Retention I split — interactive for the recent window people query, archive for whatever compliance requires.',
          ),
        ],
      ),
      (
        'slo',
        'SLIs, SLOs and error budgets',
        'Turning reliability into a number.',
        [
          (
            'What is an SLO and why does it matter?',
            'An SLI is the thing you measure, the SLO is the target on it, and the error budget is the failure you have agreed is acceptable. What makes it useful is that it turns an argument about whether the platform is reliable enough into a number, and it also governs release pace — if the budget is spent, the next work is reliability rather than features. For a data platform I would push for freshness and completeness as SLIs rather than pure uptime, because a pipeline that is up but six hours late is still an outage to the people using it.',
          ),
        ],
      ),
    ],
  ),
  (
    'reliability',
    'Reliability and Incidents',
    'Several bullets: troubleshooting sessions, SLOs, incident response, gathering diagnostics, communicating updates, and after-hours rotation.',
    AreaWeight.high,
    [
      (
        'incident',
        'Handling an incident',
        'The single most likely scenario question.',
        [
          (
            'A critical pipeline is failing in production. Walk me through what you do.',
            'First I establish blast radius — is it one job, one workspace, or the platform — because that sets severity and who needs to know. Then I communicate early, even before I know the cause, with a time for the next update so nobody has to chase me. Then I look at what changed in the last few hours, because most incidents are a deploy, a config change or something expiring. Restoring service comes before understanding it, so I will roll back and diagnose afterwards — but I capture logs and state first, because a restart destroys the only evidence of why it broke. Then a blameless postmortem with actions that have owners and dates.',
          ),
        ],
      ),
      (
        'comms',
        'Communicating during an incident',
        'The posting names this explicitly.',
        [
          (
            'How do you communicate during an incident?',
            'Fixed cadence updates in plain language, covering three things: what the impact is, what is being done right now, and when the next update will come. I avoid technical narration because the audience often includes people who just need to know whether to tell a client. And I would rather say we do not know the cause yet than speculate, because a wrong cause stated confidently costs you credibility for the rest of the incident. Good updates also stop five people messaging the person who is actually fixing it.',
          ),
        ],
      ),
      (
        'runbooks',
        'Runbooks and SOPs',
        'A named responsibility — creating SOPs and onboarding guides.',
        [
          (
            'What makes a good runbook?',
            'I write it for someone at three in the morning with no context. Symptom at the top so they know they are in the right document, then the checks in order, then the actual remediation commands rather than "investigate the issue", then a clear line for when to stop and escalate. It should be linked directly from the alert that fires it, and it gets updated as part of whatever change made it stale — a runbook nobody trusts is worse than none, because people waste time reading it first.',
          ),
        ],
      ),
      (
        'postmortem',
        'Blameless postmortems',
        'How you talk about failure.',
        [
          (
            'Tell me about a time something broke because of something you did.',
            'I would name it in the first sentence without softening it, then spend most of the answer on what happened next — how it was detected, how fast it was mitigated, and specifically what changed afterwards so the same mistake could not have the same consequence. That last part is the whole point. A blameless postmortem is not about being nice to the person, it is about accepting that people will make mistakes and asking why the system let a mistake become an outage.',
          ),
        ],
      ),
      (
        'change',
        'Change and patching',
        'Working inside a bank control framework.',
        [
          (
            'How do you handle change management and patching in a regulated environment?',
            'Every production change has a record, an approver and a window, and I want the pipeline producing that evidence automatically rather than someone assembling it later for an audit. Patching runs on a cycle, and risk and audit findings get tracked with owners and due dates like any other backlog. The attitude I would bring is that these controls are part of the engineering job — an unapproved production change is a bigger problem in a bank than the outage it was trying to prevent, and I would rather design the pipeline so the compliant path is also the easy path.',
          ),
        ],
      ),
    ],
  ),
  (
    'containers',
    'Docker and Kubernetes',
    '"Containers (Docker) and basic Kubernetes concepts" — one line, well below Terraform and Databricks. The bar is fluency, not depth.',
    AreaWeight.high,
    [
      (
        'docker',
        'Docker images',
        'Layers, caching, and why the Dockerfile order matters.',
        [
          (
            'Explain how a Docker image is built.',
            'An image is a stack of read-only layers, one per instruction, and the build cache is invalidated from the first changed layer onward. So I order the Dockerfile with the things that change least at the top — copy the dependency manifest and install before copying the source, otherwise every code change reinstalls every package. I use multi-stage builds so the compiler and build tooling stay in the build stage and only the artefact ships. And I never put a secret in any layer, because deleting it in a later layer does not remove it from the image.',
          ),
        ],
      ),
      (
        'registry',
        'Registries and image security',
        'ACR, tagging, and scanning.',
        [
          (
            'How do you manage container images in production?',
            'Private ACR with managed identity authentication so there is no pull secret to manage, and images tagged with the commit SHA rather than latest so whatever is running traces back to a commit. Base images are minimal and pinned, and scanning runs in the pipeline and fails the build on high severity rather than warning. At runtime the container runs as a non-root user with a read-only root filesystem — most of container security is just not giving the process privileges it never needed.',
          ),
        ],
      ),
      (
        'k8s-arch',
        'Kubernetes architecture',
        'The control plane, the nodes, and who does what.',
        [
          (
            'Explain Kubernetes architecture.',
            'The control plane holds desired state — the API server is the front door, etcd stores it, the scheduler decides placement, and the controller manager runs the reconciliation loops. On each node the kubelet starts and supervises containers through containerd, and kube-proxy programs the routing rules for Services. The mental model underneath is that you never tell Kubernetes to do something, you declare what should be true and controllers close the gap continuously — which is why deleting a pod owned by a Deployment just gets you a new pod. On AKS Microsoft runs the control plane and I own the node pools and everything above the API.',
          ),
        ],
      ),
      (
        'k8s-objects',
        'Core objects',
        'Pods, Deployments, Services, ConfigMaps.',
        [
          (
            'What are the main Kubernetes objects and when do you use each?',
            'Pod is the smallest unit and it is disposable — it never gets repaired, only replaced, which is why Services exist. Deployment is the default for stateless work because it gives rolling updates and rollback. StatefulSet when replicas are not interchangeable and each needs its own identity and storage, like a database. DaemonSet when the workload is per-node rather than per-application, like a log agent. And a Service is the stable virtual IP in front of whichever pods currently match its label selector.',
          ),
        ],
      ),
      (
        'k8s-trouble',
        'Troubleshooting pods',
        'The most likely practical Kubernetes question.',
        [
          (
            'A pod is not running. How do you debug it?',
            'I start with get pods to see the state, because the state tells me which tool to use. If it is Pending there are no logs to read — it never ran — so I describe it and read the events for insufficient resources, a taint, or an unbound volume. If it is CrashLoopBackOff it did run, so logs with the previous flag gets me the dead container output. ImagePullBackOff is almost always a tag typo or registry auth. The rule I keep is that describe tells you why something will not start and logs tell you why something running is wrong.',
          ),
        ],
      ),
      (
        'aks',
        'AKS specifics',
        'The Azure-managed version and its responsibility split.',
        [
          (
            'What does AKS manage for you and what do you own?',
            'Microsoft runs and patches the control plane, and there is an SLA on it in the Standard tier. I own the node pools — including deciding when Kubernetes version and node image upgrades happen — plus the workloads, the networking configuration and the identity integration. The part that catches people is that node upgrades are still my decision and my maintenance window even though the control plane is not. And an over-strict PodDisruptionBudget is the usual reason an AKS upgrade hangs, because the drain cannot proceed without violating it.',
          ),
        ],
      ),
    ],
  ),
  (
    'scripting',
    'Python, Bash and PowerShell',
    '"Good skills in scripting languages" plus basic automation scripts. You have Python and Bash evidence; PowerShell is the thin one.',
    AreaWeight.high,
    [
      (
        'python',
        'Python for automation',
        'What they actually mean by scripting.',
        [
          (
            'How do you use Python in platform work?',
            'Mostly operational automation rather than application development — reporting on resources, reconciling configuration, and driving APIs. I use DefaultAzureCredential so the same script works locally with my own identity and in a pipeline with a federated one, without a code change. For Databricks I use the SDK or the REST API for jobs and permissions. I have written export and deployment scripts in Python, and the thing I care about is that they are readable, log what they did, and fail with a non-zero exit rather than half-succeeding quietly.',
          ),
        ],
      ),
      (
        'bash',
        'Bash',
        'The one every platform engineer is assumed to have.',
        [
          (
            'What makes a Bash script safe to run in production?',
            'set -euo pipefail on the first line, so it exits on an error, on an undefined variable, and on a failure anywhere in a pipe rather than silently continuing with bad state. Beyond that: idempotent so re-running is safe, a dry-run flag for anything destructive, and non-zero exit codes so a pipeline actually fails instead of going green. I have written deploy and teardown scripts this way — the teardown one especially, because a destructive script that half-runs is worse than one that does not run at all.',
          ),
        ],
      ),
      (
        'powershell',
        'PowerShell and Azure CLI',
        'Your thinnest area — be honest and show the adjacent skill.',
        [
          (
            'How comfortable are you with PowerShell?',
            'PowerShell is the least-used of the three for me — I have done more in Python and Bash. What I would say is that the mental shift is the pipeline being object-based rather than text-based, so you are filtering properties instead of parsing strings, and the Az module follows a consistent verb-noun pattern that makes it fairly discoverable. Most of what I would reach for it for I have done with the Azure CLI and JMESPath queries. It is a short ramp rather than a new concept, and I would rather tell you that than overstate it.',
          ),
        ],
      ),
    ],
  ),
  (
    'practice',
    'Standards and Documentation',
    'A whole responsibility block: coding standards, Terraform best practices, platform validation procedures, SOPs and onboarding guides.',
    AreaWeight.support,
    [
      (
        'validation',
        'Platform validation procedures',
        'The posting names this phrase directly.',
        [
          (
            'What does "platform validation" mean to you?',
            'To me it is the set of checks a change has to pass before we call it delivered. Before: the plan is reviewed, the scans are clean, and it has been applied in a lower environment first. After: a smoke test that proves the thing actually works, because a successful apply only tells you the API accepted the change. And a rollback path defined before we start rather than improvised at the point we need it. Done means deployed and verified, not deployed.',
          ),
        ],
      ),
      (
        'review',
        'Code review',
        'Both giving and receiving.',
        [
          (
            'What do you look for in a code review?',
            'Correctness first, then blast radius — with infrastructure I read the plan output as carefully as the code, because the interesting question is what it destroys, not what it creates. Then whether it is the fourth copy of something that should be a module. And readability, specifically whether someone will understand it during an incident. When I am the author the main thing I can do is keep the diff small, because a thousand-line pull request gets approved rather than reviewed.',
          ),
        ],
      ),
      (
        'docs',
        'Documentation and onboarding',
        'A named deliverable in the posting.',
        [
          (
            'How do you approach documentation?',
            'I write it for the person who is new and stuck rather than for someone who already understands the system, and I keep it next to the code so it gets updated in the same pull request as the change. The test I like is watching a new joiner actually follow it, because every assumption you did not know you were making shows up in the first ten minutes. And I would rather delete a stale page than leave it, because documentation people cannot trust costs more time than none at all.',
          ),
        ],
      ),
      (
        'reuse',
        'Standardisation',
        'Turning copy-paste into a module.',
        [
          (
            'The posting asks for reusable modules and standardised configurations. How do you approach that?',
            'I wait for the third copy before abstracting, because a module built from one example usually encodes the wrong assumptions. Once it is clearly a pattern, I put the standard inside it — the private endpoint, the diagnostic settings, the tagging — so doing the compliant thing is also the least work. Then version it, so a team upgrades when they choose rather than being surprised by a change. The adoption strategy is making it the easiest path rather than mandating it, because a mandate produces copies with the mandate worked around.',
          ),
        ],
      ),
    ],
  ),
  (
    'banking',
    'Working in a Regulated Bank',
    '"5+ years of IT experience in big organizations operating in various geographies/regulations" — they are testing whether you can operate inside controls.',
    AreaWeight.support,
    [
      (
        'attitude',
        'Attitude to controls',
        'Half of what this question is actually screening for.',
        [
          (
            'How do you feel about working in a heavily controlled environment?',
            'It suits how I already work. Running governance across two hundred plus AWS accounts, the controls were the job rather than an overhead on it — guardrails, access boundaries, and standards that let a lot of teams move without stepping on each other. My view is that if people are routing around a control, the control is badly designed rather than the people being careless, so I try to make the compliant path also the easiest one. That is why I care about things like pipelines producing audit evidence automatically.',
          ),
        ],
      ),
      (
        'audit',
        'Audit and evidence',
        'What an auditor asks for and where it comes from.',
        [
          (
            'How do you produce evidence for an audit?',
            'The goal is that evidence is a by-product of how we work rather than a project every quarter. Every production change traces to a commit, a reviewer and a pipeline run, so "who changed this and who approved it" is a query rather than an investigation. Access is recertified through reviews, and privileged activations are logged. Audit logs go to Log Analytics with a retention tier that matches the requirement. And findings get owners and due dates like anything else on the backlog.',
          ),
        ],
      ),
      (
        'data',
        'Data governance',
        'Directly relevant to a Data and AI platform.',
        [
          (
            'What data governance concerns matter on a data platform?',
            'Classification first, because everything else follows from it — what is sensitive determines who can see it, where it can live and how long you keep it. Residency matters specifically because the posting mentions multiple geographies, so data may not be allowed to leave a region. Unity Catalog does a lot of the heavy lifting here: grants control access and lineage answers where a column came from and who consumed it, which is exactly what a regulator asks. And lower environments should not have real production data in them.',
          ),
        ],
      ),
      (
        'crossteam',
        'Cross-functional working',
        'The posting names five teams you will depend on.',
        [
          (
            'This role works with IAM, Network, Cloud Ops and Security. How do you work across teams?',
            'Early and with context. In the AWS role those teams were daily counterparties, and the thing that made it work was going to them at design time with the requirement and a couple of options rather than at the point I was already blocked. I try to understand why a control exists before asking for an exception, because usually there is a way to meet the intent that I had not thought of. And I track the dependency myself rather than assuming it is moving — a request sitting in someone else queue is still my delivery date.',
          ),
        ],
      ),
    ],
  ),
];
