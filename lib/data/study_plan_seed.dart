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
/// Each card is shaped the way the answer actually gets used in the room:
///   Q          — the question as an interviewer would ask it.
///   points     — the breakdown, as recallable pairs rather than prose.
///   bestAnswer — the sentences to say out loud, first person, role-specific.
///   hint       — a short hook to recall in the pause before answering.
///
/// The best-answer text is written to be spoken: short sentences, no stacked
/// subordinate clauses, and a concrete detail near the end so it lands as
/// experience rather than as a definition read back.
///
/// Subtopic ids are stable and area-prefixed. Progress is keyed on them, so
/// rewording a title or reordering the list never loses a tick.

typedef _Card = (
  String question,
  List<(String, String)> points,
  String best,
  String hint,
);
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
                  .map(
                    (c) => StudyCard(
                      question: c.$1,
                      points: c.$2,
                      bestAnswer: c.$3,
                      hint: c.$4,
                    ),
                  )
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
            [
              (
                'Structure',
                'Present anchor, then past proof, then why this role — in that order',
              ),
              (
                'Length',
                '60 to 90 seconds. Longer reads as nervous, shorter reads as unprepared',
              ),
              (
                'Content',
                'Professional only. No childhood, no hobbies, no life story',
              ),
              (
                'Ending',
                'Hand the conversation back: end on why you are sitting in this interview',
              ),
              (
                'Trap',
                'Do not narrate your resume top to bottom — they have already read it',
              ),
            ],
            'I am a platform and cloud engineer with about eight years in IT. Most of that was cloud engineering at scale — I ran infrastructure across more than two hundred AWS accounts, which meant working every day with IAM, networking and security teams on governance, access and guardrails rather than one application. I took a career break for family reasons, and over the past several months I have been rebuilding deliberately and specifically toward Azure data platform work. I have built a lakehouse on Databricks with Unity Catalog, Auto Loader, streaming and Delta Live Tables, an Azure governance lab with VNets, subnets, NSGs, RBAC and resource locks, and a GitHub Actions pipeline with per-pull-request preview environments. That is why this role stood out — it is the same platform engineering discipline I already did at scale, on the Azure and Databricks side, in a regulated environment.',
            'Anchor, proof, why here. Eight years, 200+ accounts, Databricks lakehouse, now Azure.',
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
            [
              ('Name it', 'One sentence, plainly, no flinching'),
              ('Reason', 'One clause. You owe no medical or personal detail'),
              (
                'Do not',
                'Apologise, over-explain, or fill silence after you finish',
              ),
              (
                'Pivot',
                'Straight to what you rebuilt — evidence, not intention',
              ),
              (
                'Their real question',
                'Not "why did you leave" but "are you current"',
              ),
            ],
            'I took a three-year career break for family reasons. I came back to it deliberately rather than casually — I picked a target role, worked out exactly what it needed, and built toward it. In the last few months that has meant a Databricks lakehouse with Unity Catalog and Delta Live Tables, an Azure governance lab in infrastructure as code, and a CI/CD pipeline I run myself. I am current on what changed while I was out, and where something is newer than my catch-up I will tell you rather than guess.',
            'Three years, family, came back deliberately. Then list the three things you built. Then stop.',
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
            [
              (
                'The posting says',
                '"Azure preferred" — a preference, not a requirement',
              ),
              (
                'What transfers',
                'Networking, IAM, IaC, CI/CD, governance at multi-account scale',
              ),
              (
                'The map',
                'VPC to VNet, security group to NSG, IAM role to managed identity, CloudFormation to Bicep',
              ),
              (
                'Show, do not claim',
                'Name the Azure things you have actually built',
              ),
              (
                'Tone',
                'Confident, not defensive. Multi-cloud is an asset in a bank',
              ),
            ],
            'That is fair, and it is the reason I built Azure evidence rather than just claiming transferability. The concepts map directly — a VPC is a VNet, a security group is an NSG, an IAM role is a managed identity, and the governance problem of two hundred accounts is the same problem as a subscription hierarchy with management groups and policy. What I have actually built on Azure is a governance lab with VNets, subnets, NSGs, RBAC assignments and resource locks in infrastructure as code, plus a deployment pipeline. So the platform thinking came from AWS at real scale, and the Azure fluency is current and hands-on.',
            'The concepts transfer; I built the Azure proof anyway. VPC to VNet, IAM role to managed identity.',
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
            [
              (
                'Be specific',
                'Quote the posting back — Terraform, Databricks, Azure networking, observability',
              ),
              (
                'Show the read',
                'It is a data platform role, not an AI research role',
              ),
              (
                'Seniority',
                'The posting says "under the guidance of Sr Engineers" — that suits a return',
              ),
              (
                'Avoid',
                'Generic answers about "great company" or "exciting technology"',
              ),
            ],
            'Two reasons. First, the work itself lines up almost exactly with what I have done and what I have been rebuilding — Azure networking and IAM, Databricks clusters and Unity Catalog, Terraform modules, pipelines in GitHub Actions and Azure DevOps, and observability with Azure Monitor. Second, the shape of the role. It is explicitly working under senior engineers and platform leads, contributing to a platform other teams depend on. That is the kind of team environment I want coming back in — a real platform at scale with people to learn the house standards from.',
            'The work matches, and the team shape suits a return. Quote their own bullets back.',
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
            [
              (
                'GBM',
                'Capital markets and investment banking arm, 100+ years, growing US and LatAm footprint',
              ),
              (
                'The team',
                'Data and AI platform — internal platform serving trading and banking businesses',
              ),
              (
                'Why it suits you',
                'Regulated, multi-geography, governance-heavy — matches your AWS background',
              ),
              ('Honest framing', 'Say what attracts you, not flattery'),
            ],
            'Global Banking and Markets is a capital markets and investment banking business with a footprint across Canada, the US and Latin America, and this team runs the Data and AI platform underneath it. What attracts me is that it is regulated and multi-geography. My AWS work was governance across two hundred accounts — controls, access, guardrails, and cross-team dependencies — and that experience is worth much more in a bank than it is somewhere with no compliance surface. I would rather do platform engineering where the controls matter than somewhere they are optional.',
            'Regulated and multi-geography is where my governance background is worth most.',
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
            [
              (
                'Lead with',
                'Databricks — it is your deepest evidenced skill and central to this team',
              ),
              (
                'Evidence',
                'Unity Catalog, Auto Loader, MERGE/SCD2/CDF, DLT, streaming with watermarks',
              ),
              (
                'Scale',
                'Around 127k rows across 10 datasets — small, so lead with the patterns not the volume',
              ),
              (
                'Back it with',
                'The AWS multi-account governance experience for platform judgement',
              ),
            ],
            'On the data platform side, Databricks. I have built an end-to-end lakehouse — Unity Catalog for governance, Auto Loader with checkpointing for incremental ingestion, MERGE with slowly changing dimensions and change data feed, Delta Live Tables with quality constraints, and structured streaming with watermarks. On the platform engineering side, it is governance at scale — running two hundred plus AWS accounts taught me to think in guardrails and standards rather than one-off fixes, which is the same instinct this role is asking for with reusable Terraform modules.',
            'Databricks for depth, multi-account governance for judgement.',
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
            [
              (
                'Pick a real one',
                'A fake weakness reads as evasive and everyone recognises it',
              ),
              (
                'Honest gaps',
                'Terraform depth, PowerShell, production Azure Monitor at scale',
              ),
              (
                'The structure',
                'Name it, say what you are doing about it, give the current state',
              ),
              ('Never say', '"I work too hard" or "I am a perfectionist"'),
            ],
            'Terraform depth is the honest one. My infrastructure as code background is CloudFormation on AWS and Bicep on Azure, so I understand state, drift and module design as concepts, but I have less Terraform mileage than someone who has run it in production for three years. I have been closing it deliberately — porting my Azure governance lab from Bicep to Terraform, with remote state in a storage account with locking, modules with proper inputs and outputs, and plan and apply through a pipeline. I would rather tell you that straight than have it surface in week two.',
            'Terraform mileage, not Terraform concepts. Say what you are doing about it.',
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
            [
              ('Answer', 'No — plainly, without a long qualification after it'),
              ('Add value', 'Show you know what good on-call looks like'),
              (
                'Reasonable to ask',
                'Rotation size, escalation path, runbook maturity',
              ),
              (
                'Do not',
                'Sound reluctant or negotiate it in the first interview',
              ),
            ],
            'No, that is fine. On-call is part of owning a platform, and I would rather be on the rotation than be the person who only sees the platform when it is working. What I care about is that on-call is sustainable — a reasonable rotation size, runbooks that mean the person paged can actually act, and alerts that fire on things a human needs to do something about. If any of that is thin when I join, that is useful work I would be glad to pick up.',
            'Yes, plainly. Then talk about what makes on-call sustainable.',
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
            [
              (
                'Team',
                'How is the platform team structured, and where would I sit in it?',
              ),
              (
                'Work',
                'What does onboarding a new Databricks workload look like today?',
              ),
              (
                'Pain',
                'What is the biggest reliability or toil problem the team has right now?',
              ),
              (
                'IaC',
                'How much of the estate is in Terraform today versus click-ops?',
              ),
              (
                'On-call',
                'How large is the rotation, and how mature are the runbooks?',
              ),
              ('Avoid', 'Salary and time off in a first technical interview'),
            ],
            'A few. How is the platform team structured, and where would this role sit within it? What does it look like today when a new Databricks workload gets onboarded — is that self-service or does it come through the team? What is the biggest source of toil or repeat incidents right now? And how much of the estate is in Terraform today versus still managed by hand, because that tells me a lot about where the first six months would go.',
            'Team shape, onboarding flow, biggest toil, Terraform coverage.',
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
            [
              (
                'Hub and spoke',
                'Enterprise, banking, regulated — centralised control and shared services',
              ),
              (
                'Full mesh',
                'Low-latency peer-to-peer workloads, every VNet peered to every other',
              ),
              (
                'Single VNet',
                'Small team, proof of concept, simple workload — no peering needed',
              ),
              (
                'Virtual WAN',
                'Global enterprise across many regions — Microsoft-managed backbone',
              ),
            ],
            'For a bank I would use hub and spoke. It gives centralised traffic control through Azure Firewall, shared services like Private DNS and the ExpressRoute gateway in one place, and isolated spokes per environment. Virtual WAN is a fair option at global scale, but hub and spoke gives more direct control over routing, which matters when you have to evidence it to an auditor.',
            'Hub and spoke = enterprise default. Virtual WAN = global scale. Single VNet = proof of concept only.',
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
            [
              (
                'VNet',
                'Regional, isolated private address space — the outer boundary',
              ),
              (
                'Subnet',
                'Segment of that space; where NSGs, route tables and delegations attach',
              ),
              (
                'Reserved IPs',
                'Azure takes 5 per subnet, so usable space is smaller than the mask',
              ),
              (
                'Sizing',
                'Plan CIDR up front — resizing a subnet already in use is painful',
              ),
            ],
            'I plan the address space up front, because resizing a subnet that already has resources in it is genuinely painful. Then I split by function rather than by convenience — one subnet for private endpoints, one for compute, one delegated to Databricks — so each one can carry its own NSG and route table. And I remember Azure reserves five addresses per subnet, which matters when someone asks for a /29.',
            'Segment by function, not by team. Five IPs always gone.',
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
            [
              (
                'Stateful',
                'Return traffic for an allowed flow needs no separate rule',
              ),
              (
                'Priority',
                'Lowest number evaluated first, first match wins — leave gaps',
              ),
              (
                'Attach point',
                'Subnet and NIC both apply; inbound is subnet then NIC',
              ),
              (
                'Defaults',
                'VNet-to-VNet and outbound internet are already allowed',
              ),
              (
                'ASG',
                'Reference a named group of NICs instead of raw IP ranges',
              ),
            ],
            'An NSG is a stateful firewall I attach to a subnet or a NIC. Rules are evaluated by priority, lowest first, and the first match wins, so I leave gaps between priorities to make room later. The thing that trips people up is the default rules — outbound to the internet and traffic inside the VNet are already allowed, so if I want a deny posture I have to write it explicitly.',
            'Lowest priority wins. Defaults already say yes.',
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
            [
              ('Purpose', 'Override Azure system routes for a subnet'),
              (
                'Main use',
                'Forced tunnelling — send egress through a firewall for inspection',
              ),
              (
                'Next hop',
                'Virtual appliance, gateway, VNet, internet, or none',
              ),
              (
                'Precedence',
                'UDR beats BGP beats system route; longest prefix first',
              ),
              (
                'Classic mistake',
                'Routing the firewall subnet back through the firewall',
              ),
            ],
            'The usual reason is forced tunnelling — I want all outbound traffic going through Azure Firewall so egress is inspected and logged, which in a bank is normally mandatory. I attach the route table to the workload subnet with the next hop set to the firewall private IP. The mistake to avoid is applying that same route table to the firewall subnet itself, because you route the firewall through itself and take the whole thing down.',
            'UDR = force egress through the firewall. Never route the firewall through itself.',
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
            [
              (
                'Private endpoint',
                'PaaS service gets a real private IP in your subnet',
              ),
              (
                'Service endpoint',
                'Traffic stays on the backbone but the resource keeps a public IP',
              ),
              (
                'Reach',
                'Private endpoint works over peering and ExpressRoute; service endpoint does not',
              ),
              (
                'Cost',
                'Private endpoint bills per hour plus data; service endpoint is free',
              ),
              (
                'Catch',
                'Needs a privatelink DNS zone or the name still resolves publicly',
              ),
            ],
            'A private endpoint puts the service on a private IP inside my VNet, so traffic never touches the public internet, and I can then disable the public endpoint entirely. A service endpoint keeps traffic on the Azure backbone but the resource still has a public IP that I filter by subnet. In a regulated environment I default to private endpoints, because "there is no public IP at all" is a far easier control to evidence. The part people get wrong is DNS — without the privatelink zone linked to the VNet, the name still resolves to the public address.',
            'Private endpoint = private IP. Service endpoint = public IP, filtered. DNS is always the bug.',
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
            [
              ('Zone', 'privatelink.<service>.core.windows.net must exist'),
              (
                'Record',
                'An A record for the endpoint, usually auto-created by the integration',
              ),
              (
                'VNet link',
                'The zone must be linked to every VNet that needs to resolve it',
              ),
              (
                'Hybrid',
                'On-premises clients need a forwarder or Azure DNS Private Resolver',
              ),
            ],
            'DNS, almost every time. The private endpoint exists, but the name still resolves to the public IP because the privatelink zone is not linked to that VNet. I would run a resolve from inside the subnet first — if it comes back with a public address, that is the answer and I have not had to touch the network at all.',
            'Endpoint created, still broken? Resolve the name first.',
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
            [
              (
                'What it does',
                'Private, low-latency connection over the Azure backbone',
              ),
              (
                'Not transitive',
                'Spoke A cannot reach spoke B through the hub by peering alone',
              ),
              (
                'Gateway transit',
                'Lets spokes use the hub ExpressRoute or VPN gateway',
              ),
              ('Constraint', 'Address spaces must not overlap'),
              (
                'Workaround',
                'UDR pointing at a hub firewall gives you transitivity',
              ),
            ],
            'Peering connects two VNets over the backbone with private addressing and no gateway in the path. The key limitation is that it is not transitive — if two spokes are both peered to the hub, they still cannot reach each other directly. You route them through a firewall in the hub with a UDR. That limitation is actually why hub and spoke works as a security model: everything between spokes is inspected by design.',
            'Peering is not transitive — and that is a feature, not a bug.',
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
            [
              ('Placement', 'Dedicated AzureFirewallSubnet in the hub'),
              (
                'Getting traffic there',
                'UDR on each workload subnet, next hop the firewall',
              ),
              (
                'Rule types',
                'DNAT, then network rules, then application rules on FQDNs',
              ),
              ('Premium', 'Adds TLS inspection and IDPS'),
              (
                'Why',
                'A compromised workload should not be able to call an arbitrary endpoint',
              ),
            ],
            'I centralise egress through Azure Firewall in the hub, with route tables on the workload subnets sending everything to it. Application rules restrict outbound by FQDN, network rules by port and address. The reason this matters in a bank is exfiltration — if a workload is compromised, I want it unable to reach an arbitrary endpoint, and I want a log of it trying.',
            'Egress is a control, not a convenience. FQDN rules plus logs.',
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
            [
              (
                'Load Balancer',
                'Layer 4, regional — plain TCP/UDP distribution',
              ),
              (
                'Application Gateway',
                'Layer 7, regional — host/path routing, TLS termination, WAF',
              ),
              (
                'Front Door',
                'Layer 7, global — edge presence, caching, cross-region failover',
              ),
              (
                'Traffic Manager',
                'DNS-level global routing, the older simpler option',
              ),
            ],
            'I pick by layer and by scope. Load Balancer is layer four and regional, so it just distributes traffic. Application Gateway is layer seven and regional, which is what I want when I need path-based routing, TLS termination, and the web application firewall. Front Door is layer seven and global, so it is the answer when I need edge presence and failover between regions.',
            'Layer and scope. L4 regional, L7 regional, L7 global.',
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
            [
              (
                'ExpressRoute',
                'Private dedicated circuit, never touches the public internet',
              ),
              (
                'VPN Gateway',
                'Encrypted tunnels over the internet — usually the backup path',
              ),
              (
                'Where it lands',
                'A gateway in the hub, shared with spokes via gateway transit',
              ),
              (
                'Routing',
                'BGP; reconcile route propagation with your UDRs or you blackhole traffic',
              ),
            ],
            'A bank this size will be on ExpressRoute — a private circuit into Azure with no internet transit — usually with a site-to-site VPN as the failover path. Both terminate on a gateway in the hub, and the spokes reach them through gateway transit. From a platform point of view the thing I watch is the interaction between BGP route propagation and my own route tables, because that is where on-premises routes quietly get blackholed.',
            'ExpressRoute primary, VPN backup, both in the hub.',
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
            [
              (
                '1. DNS',
                'Does the name resolve, and to the address you expect?',
              ),
              (
                '2. NSG',
                'Effective security rules on source and destination NICs',
              ),
              (
                '3. Routes',
                'Effective routes — is a UDR sending it to a firewall that denies it?',
              ),
              (
                '4. Resource firewall',
                'PaaS services have their own firewall, separate from the NSG',
              ),
              (
                'Tools',
                'Network Watcher connection troubleshoot, IP flow verify, NSG flow logs',
              ),
            ],
            'I work the path in a fixed order rather than guessing. DNS first, because a wrong resolution looks exactly like a network outage. Then effective NSG rules, then effective routes — a UDR pointing at a firewall that is denying the traffic is a very common cause. Then the resource firewall itself, which is a separate layer people forget. Network Watcher tells me which hop actually dropped it, so I am arguing from evidence rather than theory.',
            'DNS, NSG, routes, resource firewall. In that order, every time.',
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
            [
              (
                'Assignment',
                'Principal + role definition + scope. That is the whole model',
              ),
              (
                'Scopes',
                'Management group, subscription, resource group, resource — inherits downward',
              ),
              (
                'Additive',
                'No deny rules; effective permission is the union of all assignments',
              ),
              (
                'Contributor',
                'Can manage resources but cannot grant access — that is User Access Administrator',
              ),
              (
                'Practice',
                'Assign to groups, at the narrowest scope that works',
              ),
            ],
            'An assignment is three things — a principal, a role definition and a scope — and scope inherits downward, so Reader at subscription level is Reader on everything inside it. It is additive with no deny, so effective access is the union of every assignment. In practice I assign to groups rather than individuals and at the narrowest scope that actually works, because individual assignments at subscription scope are what audit findings are made of. The distinction I always make explicit is that Contributor can manage a resource but cannot grant access — granting is User Access Administrator.',
            'Principal, role, scope. Additive, no deny. Contributor cannot grant.',
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
            [
              (
                'What it is',
                'A service principal with no credential for you to store or rotate',
              ),
              (
                'System-assigned',
                'Tied to one resource lifecycle — dies when the resource does',
              ),
              (
                'User-assigned',
                'Standalone, shareable across resources, survives recreation',
              ),
              (
                'How it works',
                'Token from the instance metadata endpoint, via DefaultAzureCredential',
              ),
              (
                'Platform preference',
                'User-assigned, so Terraform recreating a resource does not drop its access',
              ),
            ],
            'A managed identity is a service principal that Azure creates and rotates for me, so there is no secret to store anywhere. System-assigned is tied to one resource and dies with it; user-assigned is standalone and shareable. For platform work I lean toward user-assigned, because if Terraform recreates a VM I do not want its role assignments silently disappearing with it. The code side is just DefaultAzureCredential picking up a token from the metadata endpoint.',
            'No stored secret. User-assigned survives recreation.',
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
            [
              (
                'Mechanism',
                'Federated credential on the identity trusting an external OIDC issuer',
              ),
              (
                'Scope',
                'Subject encodes repo, branch or environment — trust is narrow',
              ),
              (
                'Flow',
                'Workload presents its own token, Azure validates and issues an access token',
              ),
              (
                'Same idea on AKS',
                'Cluster OIDC issuer plus a projected service account token',
              ),
              (
                'Why',
                'Nothing long-lived to rotate, leak, or find in a variable group',
              ),
            ],
            'Workload identity federation. I put a federated credential on the identity that trusts the GitHub or Azure DevOps OIDC issuer, scoped to a specific repository and environment, so the pipeline presents its own token and exchanges it for an Azure token. There is no client secret anywhere — nothing to rotate and nothing to leak. It is the same mechanism on AKS, where the cluster publishes an OIDC issuer and a pod uses its projected service account token, so one concept covers both.',
            'Federate the issuer, scope the subject, no secret exists.',
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
            [
              (
                'Store',
                'Key Vault, behind a private endpoint, public access disabled',
              ),
              (
                'Access model',
                'Azure RBAC preferred over legacy access policies',
              ),
              (
                'Retrieval',
                'At runtime via managed identity — never copied in at deploy time',
              ),
              (
                'Protection',
                'Soft delete always on; purge protection blocks permanent deletion',
              ),
              (
                'Gotcha',
                'Purge protection is why a Terraform destroy fails to recreate a vault name',
              ),
            ],
            'Key Vault, behind a private endpoint with public access off, and access granted through Azure RBAC rather than the legacy access policy model so it is consistent with everything else in the subscription. Applications resolve secrets at runtime using their managed identity, which means rotating a secret is a vault-side operation with no redeploy. The gotcha worth knowing is purge protection — it is a good control, but it is also why a Terraform destroy and recreate on the same vault name fails.',
            'RBAC not access policies. Resolve at runtime. Purge protection bites Terraform.',
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
            [
              (
                'PIM',
                'Elevated roles are eligible, not standing — activate with justification and approval',
              ),
              (
                'Access reviews',
                'Recertify periodically so access does not accumulate',
              ),
              (
                'SoD',
                'Author, approver and applier are three different identities',
              ),
              (
                'In the pipeline',
                'Branch protection + environment approval + federated deploy identity',
              ),
              (
                'Result',
                'Humans have read-only in production; only the pipeline writes',
              ),
            ],
            'Standing privilege is the thing I try to remove. Elevated roles sit behind PIM as eligible rather than active, so people activate for a few hours with a justification, and access reviews recertify what is left. For segregation of duties I lean on the pipeline: a developer opens the pull request, a different person approves the environment gate, and the apply runs as a federated deployment identity that no human can use directly. Humans are read-only in production, which is both a better control and much easier to evidence to audit.',
            'No standing privilege. Author, approver, applier are three identities.',
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
            [
              (
                'Hierarchy',
                'Management group, subscription, resource group, resource',
              ),
              (
                'Azure Policy',
                'deny, audit, deployIfNotExists — enforce without relying on review',
              ),
              (
                'Common policies',
                'Allowed regions, required tags, no public endpoints, allowed SKUs',
              ),
              ('Locks', 'CanNotDelete and ReadOnly on production resources'),
              (
                'Landing zones',
                'Standardised subscription patterns rather than ad-hoc creation',
              ),
            ],
            'Through the hierarchy plus policy. Management groups carry the standards, subscriptions are the isolation and billing boundary, and resource groups hold things with a shared lifecycle. Azure Policy is what makes the standards real — deny effects for allowed regions and no public endpoints, audit for things you are still remediating, and deployIfNotExists for diagnostic settings. This is exactly the shape of what I did on AWS across two hundred accounts with service control policies and guardrails, just with different names.',
            'Hierarchy carries standards, Policy enforces them, locks protect production.',
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
            [
              (
                'ADLS Gen2',
                'Hierarchical namespace on — real directories and POSIX-like ACLs',
              ),
              (
                'Redundancy',
                'LRS, ZRS, GRS — a cost versus durability decision',
              ),
              (
                'Access tiers',
                'Hot, cool, archive for lifecycle cost management',
              ),
              (
                'Security',
                'Entra ID and RBAC over account keys; disable public blob access',
              ),
              (
                'Network',
                'Private endpoint, and firewall denying public network access',
              ),
            ],
            'Hierarchical namespace on, so it is ADLS Gen2 with real directories rather than flat blob semantics. Access through Entra ID and RBAC rather than account keys, public blob access disabled, and a private endpoint with the account firewall denying public network access. Redundancy is a conversation about the recovery objective rather than a default — zone redundant within a region, geo redundant if the requirement is regional failure. Then Unity Catalog external locations point at it through a storage credential, so grants govern the data rather than anyone holding keys.',
            'HNS on, RBAC not keys, private endpoint, then UC external location on top.',
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
            [
              (
                'Partitions',
                'Set parallelism — fixed at creation, so size for peak consumers',
              ),
              (
                'Consumer groups',
                'Independent readers, each tracking its own offset',
              ),
              (
                'Capture',
                'Writes raw events to storage automatically for replay and audit',
              ),
              ('Scale', 'Throughput units, or processing units on Premium'),
              ('Ordering', 'Guaranteed within a partition, not across them'),
            ],
            'Event Hubs is high-throughput ingestion where partitions set parallelism and consumer groups let independent readers track their own offset. The two things I would flag on design are that partition count is fixed at creation, so you size for the consumers you expect, and that ordering is only guaranteed within a partition — so the partition key matters if order is meaningful. Capture is worth turning on in a bank because it lands raw events in storage for replay and audit without writing any code.',
            'Partitions = parallelism and ordering. Consumer groups = independent offsets. Capture for audit.',
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
            [
              ('Models', 'Single database, elastic pool, managed instance'),
              (
                'Purchasing',
                'DTU or vCore; serverless auto-pauses for intermittent workloads',
              ),
              (
                'Auth',
                'Entra ID authentication rather than SQL logins where possible',
              ),
              (
                'Resilience',
                'Automated backups with point-in-time restore, failover groups for regions',
              ),
              ('Network', 'Private endpoint, public access disabled'),
            ],
            'It is the managed relational option — single database, elastic pool or managed instance depending on how much SQL Server surface you need. I would use vCore for predictable workloads and serverless where usage is intermittent, authenticate through Entra ID rather than SQL logins, and put it behind a private endpoint. For resilience the two things I check are that point-in-time restore covers the retention we actually need, and that failover groups are configured if the requirement is regional rather than just zonal.',
            'Entra auth, private endpoint, PITR for accidents, failover groups for regions.',
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
            [
              (
                'Attribution',
                'Tags enforced by policy, so every resource has an owner',
              ),
              (
                'Budgets',
                'Budget alerts and anomaly detection per subscription or tag',
              ),
              (
                'Commit',
                'Reserved instances or savings plans for steady-state compute',
              ),
              (
                'Databricks',
                'Job clusters over all-purpose, auto-termination, spot workers, cluster policies',
              ),
              (
                'Culture',
                'Treat a cost regression as an incident with an owner',
              ),
            ],
            'I treat cost as a monitored signal rather than a monthly surprise. Tagging enforced by policy so spend attributes to an owner, budgets with alerts and anomaly detection, and reservations for anything genuinely steady-state. On the Databricks side specifically the levers are job clusters instead of all-purpose, aggressive auto-termination, spot workers for interruptible work, and cluster policies so people cannot spin up something enormous by accident. A cost regression gets an owner and a fix, the same as a reliability regression.',
            'Tag, budget, commit, and cap Databricks with cluster policies.',
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
            [
              (
                'Control plane',
                'Databricks-managed: workspace UI, job scheduler, notebooks, metadata',
              ),
              (
                'Data plane',
                'Your subscription: clusters run on your VMs, data stays in your storage',
              ),
              (
                'Why it matters',
                'Your data never leaves your tenant — the first thing security asks',
              ),
              (
                'VNet injection',
                'Clusters deployed into your own subnets so NSGs and routes apply',
              ),
              (
                'Private Link',
                'Removes public exposure of the workspace and the control plane',
              ),
            ],
            'There are two planes. The control plane is Databricks-managed and holds the workspace, the job scheduler and metadata. The data plane runs in my own Azure subscription — the clusters are VMs in my VNet and the data sits in my storage account. That split is usually the first thing a bank security team asks about, and the answer is that with VNet injection and Private Link the compute is in my subnets under my NSGs and route tables, and the data never leaves the tenant.',
            'Control plane theirs, data plane mine. VNet injection plus Private Link.',
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
            [
              (
                'All-purpose',
                'Interactive, shared, long-lived — for development and exploration',
              ),
              (
                'Job cluster',
                'Created for a run, terminates after — cheaper and isolated',
              ),
              (
                'Default',
                'Job clusters for anything scheduled. This is the cost answer',
              ),
              ('Autoscaling', 'Min and max workers; auto-termination on idle'),
              (
                'Access modes',
                'Shared mode is what enforces Unity Catalog for multiple users',
              ),
            ],
            'All-purpose clusters are interactive and shared, which is right for development. Job clusters are created for a single run and terminate when it finishes, so they are cheaper and isolated from other work. For anything scheduled I default to job clusters — running production jobs on a shared all-purpose cluster is the most common way a Databricks bill gets out of hand, and it couples unrelated workloads together. The other setting I always check is access mode, because shared mode is what actually enforces Unity Catalog governance when several people use the same cluster.',
            'Job clusters for scheduled work. Shared access mode for UC enforcement.',
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
            [
              (
                'Cluster policies',
                'Admin-defined templates constraining node types, size, autoscale, tags',
              ),
              (
                'Enforce',
                'Fixed values, allow-lists, and ranges on any cluster attribute',
              ),
              (
                'Instance pools',
                'Pre-warmed VMs to cut start latency, at the cost of idle spend',
              ),
              (
                'Tags',
                'Policy-enforced tags are how cluster cost attributes to a team',
              ),
              (
                'Platform framing',
                'This is guardrails, not gatekeeping — self-service within limits',
              ),
            ],
            'Cluster policies. They are admin-defined templates that constrain what a user can create — node types, worker counts, autoscaling bounds, auto-termination, and mandatory tags. That gives self-service within limits rather than either a free-for-all or a ticket queue, which is the balance a platform team wants. Tags enforced by policy are also how cluster spend attributes back to a team, so cost conversations have data behind them.',
            'Policies are guardrails for self-service. Mandatory tags make cost attributable.',
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
            [
              (
                'Purpose',
                'SQL-optimised compute for BI tools and ad-hoc analysts',
              ),
              (
                'Serverless',
                'Starts in seconds, compute in the Databricks account',
              ),
              (
                'Pro / classic',
                'Compute in your subscription — required when network isolation is mandatory',
              ),
              ('Sizing', 'T-shirt sizes plus a scaling range for concurrency'),
              (
                'Cost lever',
                'Auto-stop. An idle warehouse left running is pure waste',
              ),
            ],
            'A SQL warehouse is SQL-optimised compute for BI tools and analysts rather than notebook workloads. Serverless starts in seconds but the compute runs in the Databricks account, which in a bank often pushes you to pro or classic so the compute stays in your own subscription and network. Sizing is a t-shirt size for query complexity plus a scaling range for concurrency, and the single biggest cost lever is auto-stop — an idle warehouse left running overnight is pure waste.',
            'Serverless is fast but off-tenant. Auto-stop is the cost lever.',
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
            [
              (
                'Metastore',
                'One per region, attached to workspaces — governance above the workspace',
              ),
              ('Namespace', 'Three levels: catalog.schema.table'),
              (
                'Managed vs external',
                'Managed lives in UC storage; external points at your own path',
              ),
              (
                'Storage credential',
                'Wraps a managed identity with access to ADLS',
              ),
              (
                'External location',
                'Binds that credential to a path; grants control raw storage access',
              ),
              (
                'Free with it',
                'Lineage, audit, and search across every workspace on the metastore',
              ),
            ],
            'Unity Catalog is the governance layer that sits above workspaces. One metastore per region, a three-level namespace of catalog, schema and table, and SQL-style grants that inherit down the hierarchy. The part I would highlight for a platform role is external locations — a storage credential wraps a managed identity that can reach ADLS, an external location binds it to a path, and then grants on that location are how you control who can touch raw storage. Once data is governed by Unity Catalog you also get lineage and audit for free, which in a bank is worth as much as the access control.',
            'Metastore, three-level namespace, credential plus location, grants inherit. Lineage is free.',
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
            [
              ('Structure', 'Multi-task jobs with dependencies between tasks'),
              (
                'Reliability',
                'Retries with limits, timeouts, and failure notifications',
              ),
              (
                'Compute',
                'Per-task job clusters, or a shared job cluster across tasks',
              ),
              ('Triggers', 'Schedule, file arrival, or continuous'),
              (
                'Ops',
                'Run history is your reliability data — alert on failures and on duration drift',
              ),
            ],
            'A workflow is a multi-task job with dependencies, so ingestion, transformation and quality checks run in order with retries and timeouts on each. I use job clusters per run rather than a shared interactive cluster. Operationally what matters is the run history — I alert on failed runs, but I also watch duration, because a job that still succeeds while taking three times as long is usually the earliest signal that something upstream changed.',
            'Tasks with dependencies. Alert on failure and on duration drift.',
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
            [
              ('What it is', 'Parquet plus a transaction log'),
              (
                'Gives you',
                'ACID transactions, so concurrent reads and writes are safe',
              ),
              (
                'Time travel',
                'Query or restore a previous version — genuine audit value in a bank',
              ),
              ('Schema', 'Enforcement by default, evolution when you opt in'),
              (
                'Maintenance',
                'OPTIMIZE and Z-ORDER for file sizing, VACUUM to expire old files',
              ),
            ],
            'Delta is Parquet with a transaction log on top, and the log is what gives you ACID guarantees, so a reader never sees a half-written table. Practically the features I use are time travel for recovering from a bad write and for audit, schema enforcement so a malformed upstream change fails loudly instead of corrupting the table, and MERGE for upserts and slowly changing dimensions. The operational side is OPTIMIZE to fix small file problems and VACUUM to expire old versions — with the caveat that VACUUM removes your time travel window.',
            'Parquet plus a log. ACID, time travel, MERGE. VACUUM ends time travel.',
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
            [
              (
                'Auto Loader',
                'cloudFiles source that tracks which files it has already processed',
              ),
              (
                'Checkpoint',
                'Where that progress lives — delete it and you reprocess everything',
              ),
              (
                'Schema evolution',
                'Inferred and tracked, with rescue column for unexpected fields',
              ),
              (
                'Watermarks',
                'Bound state in streaming aggregations so memory does not grow forever',
              ),
              (
                'Trigger',
                'availableNow for batch-style incremental runs on a schedule',
              ),
            ],
            'Auto Loader. It uses the cloudFiles source to track which files have already been processed in a checkpoint, so a scheduled run only picks up what is new rather than rescanning the whole path. I run it with trigger availableNow when the workload is really scheduled batch rather than continuous. For streaming aggregations I set watermarks so late-arriving data is bounded and state does not grow without limit — and I treat the checkpoint location as production state, because deleting it means reprocessing everything.',
            'cloudFiles plus checkpoint. Watermarks bound state. The checkpoint is production state.',
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
            [
              (
                'What',
                'A databricks.yml declaring jobs, notebooks and configuration as code',
              ),
              (
                'Targets',
                'Per-environment targets — dev, staging, prod — from one definition',
              ),
              (
                'Workflow',
                'bundle validate, then bundle deploy, then bundle run',
              ),
              (
                'Why',
                'Workflows are reviewed and versioned in Git instead of edited in the UI',
              ),
              (
                'Fits with',
                'Terraform provisions the workspace; bundles deploy what runs inside it',
              ),
            ],
            'Bundles are Databricks own infrastructure as code — a databricks.yml that declares jobs, workflows and notebooks with per-environment targets, deployed from CI with validate then deploy. The value is that a production workflow stops being something someone edited in the UI and becomes a reviewed, versioned artefact. The way I think about the split is that Terraform provisions the workspace, the clusters policies and the Unity Catalog objects, and bundles deploy the work that runs inside it.',
            'Terraform builds the workspace, bundles deploy what runs in it.',
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
            [
              ('Secret scopes', 'Databricks-backed or Key Vault-backed'),
              (
                'Access',
                'dbutils.secrets.get — values are redacted in output automatically',
              ),
              (
                'Preferred',
                'Key Vault-backed, so rotation happens in one place',
              ),
              (
                'Better still',
                'Unity Catalog storage credentials, so no key exists to fetch',
              ),
              (
                'Never',
                'Hardcoded keys in a notebook cell, or in cluster environment variables',
              ),
            ],
            'Secret scopes, backed by Key Vault so rotation happens in one place, and read with dbutils.secrets so values are redacted from notebook output. But the better answer for storage access specifically is not to have a secret at all — Unity Catalog storage credentials wrap a managed identity, so access to ADLS is governed by grants rather than by a key anyone could fetch. A hardcoded key in a notebook cell is the thing I would flag immediately in a review.',
            'Key Vault-backed scopes. Better: UC storage credentials, no key at all.',
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
            [
              (
                'Job health',
                'Run history — failures, duration trend, queue time',
              ),
              (
                'Cluster health',
                'Event logs, driver and executor logs, node failures',
              ),
              (
                'Audit',
                'System tables and audit logs — who ran what, who granted what',
              ),
              (
                'Usage',
                'System tables for DBU consumption by workspace, job and user',
              ),
              (
                'Alerts',
                'Failed runs page someone; slow runs and cost anomalies file a ticket',
              ),
            ],
            'Three layers. Job level, which is run history — failures obviously, but also duration and queue time, because degradation shows up there before it shows up as failure. Cluster level, which is event logs and driver logs when something dies. And platform level, which is system tables and audit logs for who ran what and who granted access to what. Then I split alerting by what a human should actually do: a failed production run pages, a cost anomaly or a slow trend files a ticket.',
            'Job runs, cluster logs, system tables. Page on failure, ticket on drift.',
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
            [
              (
                'init',
                'Downloads providers and modules, configures the backend',
              ),
              (
                'validate / fmt',
                'Syntax and formatting — cheap, runs first in CI',
              ),
              (
                'plan',
                'Refreshes state, computes a diff, outputs the change set',
              ),
              (
                'apply',
                'Executes the plan; in CI, apply a saved plan file so nothing drifts between',
              ),
              (
                'destroy',
                'Tears down what the state knows about — nothing else',
              ),
            ],
            'init pulls providers and modules and wires up the backend, plan refreshes state and computes the diff, and apply executes it. The detail I would add for a pipeline is that plan should write a plan file and apply should consume that exact file, so what a reviewer approved is literally what gets applied — otherwise something can change between the two steps and the approval means less than it looks. The plan output is the artefact a human reviews, so I treat it as the deliverable of the CI stage.',
            'Plan is the artefact. Apply the saved plan file, not a fresh one.',
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
            [
              (
                'What state is',
                'The map from config to real resources, plus attribute values',
              ),
              (
                'Backend',
                'Azure Storage container — never local, never committed to Git',
              ),
              ('Locking', 'Blob lease prevents two applies at once'),
              (
                'Sensitive',
                'State holds secrets in plaintext — lock the container down',
              ),
              (
                'Isolation',
                'Separate state per environment so dev can never touch prod',
              ),
            ],
            'Remote state in an Azure Storage account, with the blob lease providing locking so two engineers cannot apply at the same time. State is sensitive — it contains resource attributes including secrets in plaintext — so the container has restricted RBAC, versioning enabled, and no public access. And I keep state separate per environment, either separate backends or separate keys, so there is no path by which a dev apply reaches production. Shared local state is the failure mode I would flag if I saw it.',
            'Storage backend, blob lease locking, state is a secret, separate per environment.',
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
            [
              (
                'Interface',
                'Variables in with types, validation and sensible defaults; outputs out',
              ),
              (
                'No environment values',
                'Nothing hardcoded — the caller supplies environment specifics',
              ),
              (
                'Versioned',
                'Consume by source and version so upgrades are deliberate',
              ),
              (
                'Scope',
                'One logical thing — a storage account with its diagnostics, not "all networking"',
              ),
              (
                'Docs',
                'README with an example invocation; tfdocs generated from the variables',
              ),
            ],
            'A module is a thing with a clean interface — typed variables with validation coming in, outputs going out, and nothing environment-specific hardcoded inside. I version them and consume by source and version, so a module change never silently reaches production the next time someone runs apply. The example I would give from this posting is three teams copy-pasting a storage account definition: I would turn that into one module that bakes in the private endpoint, the diagnostic settings and the tagging standard, so the standard is the default rather than something people have to remember.',
            'Typed inputs, clean outputs, versioned, one logical thing. Standards become defaults.',
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
            [
              (
                'count',
                'Indexes by position — removing an item recreates everything after it',
              ),
              ('for_each', 'Keys by a stable string — safe add and remove'),
              (
                'Rule',
                'for_each for sets of named things; count only for a simple on/off toggle',
              ),
              (
                'prevent_destroy',
                'Guards resources that must never be accidentally removed',
              ),
              (
                'ignore_changes',
                'Tolerates attributes mutated outside Terraform',
              ),
            ],
            'for_each almost always. count indexes by position, so removing the second item in a list of five re-creates the three after it — which on storage accounts or databases is a genuine outage rather than an inconvenience. for_each keys by a stable string, so adding and removing is safe. I keep count for the simple case of a resource that either exists or does not. And on critical resources I add prevent_destroy, because a plan that proposes destroying production should fail rather than wait for someone to read it carefully.',
            'count re-creates on removal. for_each is safe. prevent_destroy on anything critical.',
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
            [
              (
                'Detection',
                'plan shows the drift — Terraform wants to put it back',
              ),
              (
                'Decide',
                'Was the manual change right? Codify it. Wrong? Let apply revert it',
              ),
              (
                'import',
                'Brings an existing unmanaged resource under Terraform without recreating it',
              ),
              (
                'moved',
                'Refactor addresses or module structure with no destroy and create',
              ),
              (
                'Prevention',
                'Humans read-only in production; changes go through the pipeline',
              ),
            ],
            'The next plan shows it, because Terraform refreshes state and sees the difference — that is drift detection working, not a problem in itself. Then it is a decision: if the manual change was correct I codify it and apply, and if it was not I let Terraform revert it. For a resource that was created by hand and needs bringing under management, import does that without recreating it, and moved lets me refactor module structure without a destroy. But the real fix is preventive — humans read-only in production so the portal is not a write path.',
            'Plan detects drift. Codify or revert. import to adopt, moved to refactor.',
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
            [
              (
                'On PR',
                'fmt, validate, tflint, security scan, then plan — output posted for review',
              ),
              (
                'On merge',
                'apply the saved plan, behind an environment approval',
              ),
              (
                'Auth',
                'OIDC federation to a deployment identity — no stored client secret',
              ),
              ('Isolation', 'Separate backend and identity per environment'),
              (
                'Agents',
                'Self-hosted runners inside the VNet to reach private endpoints',
              ),
            ],
            'Plan on the pull request with the output posted for review, and apply on merge behind an environment approval — which is also how segregation of duties gets enforced and evidenced. Authentication is OIDC federation to a deployment identity per environment, so there is no client secret in a variable group. The detail I would raise unprompted for a bank is agents: if the backend storage and the target resources are behind private endpoints, Microsoft-hosted runners cannot reach them, so you need self-hosted runners inside the VNet.',
            'Plan on PR, apply on merge with approval, OIDC auth, self-hosted runners for private endpoints.',
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
            [
              (
                'Two auth scopes',
                'azurerm for the workspace, databricks provider for what is inside it',
              ),
              (
                'Ordering',
                'Workspace must exist before workspace-level resources can be created',
              ),
              (
                'Good candidates',
                'Cluster policies, instance pools, Unity Catalog objects, permissions',
              ),
              (
                'Leave to bundles',
                'Jobs and notebooks — code that changes with the application',
              ),
              (
                'Why split',
                'Platform lifecycle and application lifecycle move at different speeds',
              ),
            ],
            'Two providers with two authentication scopes — azurerm creates the workspace, and the Databricks provider manages what lives inside it, which means you have to handle the ordering so workspace-level resources come after the workspace exists. I would put the platform-shaped things in Terraform: cluster policies, pools, Unity Catalog catalogs and external locations, and permissions. Jobs and notebooks I would leave to Asset Bundles, because they change with the application rather than with the platform, and mixing the two lifecycles in one state makes both harder to move.',
            'Terraform for the platform, bundles for the workload. Two providers, mind the ordering.',
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
            [
              (
                'Trunk-based',
                'Short-lived feature branches, frequent merges to main',
              ),
              (
                'Protection',
                'Required reviews, required status checks, no direct pushes to main',
              ),
              (
                'Commits',
                'Small and readable — the diff is the thing being reviewed',
              ),
              (
                'Conflicts',
                'Rebase small and often rather than merging a two-week branch',
              ),
              (
                'Why it matters here',
                'Branch protection is half of segregation of duties',
              ),
            ],
            'Trunk-based with short-lived feature branches and pull requests into a protected main. Required reviews and required status checks, no direct pushes. I keep branches short because a two-week branch is a merge conflict with a deadline attached. In a bank there is a second reason for that setup — branch protection with a required reviewer is the control that evidences someone other than the author approved the change.',
            'Short branches, protected main, required review. It is also an audit control.',
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
            [
              ('Trigger', 'Push and pull request events'),
              (
                'Preview environments',
                'Per-PR deployment, torn down automatically when the PR closes',
              ),
              (
                'Concurrency',
                'Concurrency group cancels superseded runs on the same branch',
              ),
              ('Auth', 'OIDC federation to Azure — no stored credential'),
              (
                'Reuse',
                'Reusable workflows and composite actions instead of copy-paste',
              ),
            ],
            'I built a GitHub Actions workflow that builds and deploys to Azure Static Web Apps, with a preview environment created per pull request and torn down automatically when the PR closes, and a concurrency group so a new push cancels the superseded run instead of racing it. Authentication is federated rather than a stored secret. It is a small application, but the pipeline patterns are the same ones I would apply to a Terraform plan and apply flow — ephemeral environments, cancellation, and no long-lived credentials.',
            'Per-PR preview, auto teardown, concurrency cancellation, OIDC auth.',
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
            [
              (
                'Structure',
                'Stages, jobs, steps in YAML — templates for reuse',
              ),
              ('Variables', 'Variable groups, optionally linked to Key Vault'),
              (
                'Auth',
                'Service connections; workload identity federation instead of a secret',
              ),
              (
                'Gates',
                'Environments with approvals and checks before a stage runs',
              ),
              (
                'Agents',
                'Microsoft-hosted or self-hosted; self-hosted for private network access',
              ),
            ],
            'Conceptually they are the same thing with different nouns. Azure Pipelines has stages, jobs and steps with templates for reuse, variable groups linked to Key Vault, service connections for Azure authentication, and environments carrying the approval gates. GitHub Actions has workflows, jobs and reusable workflows, with environments doing the same gating job. I have run both — the transferable parts are the pipeline design and the identity model, and the rest is syntax.',
            'Same concepts, different nouns. Stages/jobs/steps, variable groups, service connections, environments.',
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
            [
              (
                'Build once',
                'Produce the artefact once and promote the same one through environments',
              ),
              (
                'Where',
                'Azure Artifacts or GitHub Packages for packages, ACR for container images',
              ),
              (
                'Tagging',
                'Immutable, tagged with the commit SHA — never a floating tag',
              ),
              (
                'Retention',
                'Retention policies so the registry does not grow without limit',
              ),
              (
                'Why',
                'Rebuilding per environment means you tested something you did not ship',
              ),
            ],
            'Build once and promote the same artefact through environments rather than rebuilding per environment — if you rebuild, you tested something that is not what you shipped. Packages go to Azure Artifacts or GitHub Packages, container images to ACR, and everything is tagged with the commit SHA rather than a floating tag so anything running traces back to a commit and a pipeline run. Retention policies keep it from growing forever.',
            'Build once, promote the same artefact, tag by SHA, never latest.',
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
            [
              ('Static', 'Format, lint, unit tests'),
              ('IaC', 'terraform validate, tflint, Checkov or tfsec'),
              (
                'Security',
                'Dependency scanning, secret scanning, container image scanning',
              ),
              ('Gate', 'Fail closed — a warning nobody reads is not a control'),
              ('Human', 'Environment approval before production apply'),
            ],
            'Format and lint, unit tests, then the infrastructure-specific ones — validate, tflint, and a security scanner like Checkov. Plus dependency, secret and container image scanning. The principle I hold to is that these fail closed: a check that emits a warning nobody reads is not a control, it is decoration. Then a human approval on the production environment, which is deliberately the only manual step.',
            'Fail closed. A warning nobody reads is not a control.',
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
            [
              (
                'Metrics',
                'Cheap numeric time series — good for alerting and trends',
              ),
              (
                'Logs',
                'Expensive and detailed — good for diagnosing a specific failure',
              ),
              (
                'Traces',
                'Follow one request across services — good for finding where latency lives',
              ),
              (
                'Rule of thumb',
                'Alert on metrics, diagnose with logs, locate with traces',
              ),
              (
                'Cost',
                'Log ingestion is usually the biggest line — sample and tier deliberately',
              ),
            ],
            'They answer different questions. Metrics are cheap numeric series so they are what I alert on and what I trend. Logs are detailed and expensive so they are what I diagnose with once an alert has fired. Traces follow a single request across components, which is how you find which hop the latency is actually in. In practice the cost conversation is almost always about log ingestion, so I am deliberate about what gets ingested at full fidelity versus what goes to a cheaper tier or gets sampled.',
            'Alert on metrics, diagnose with logs, locate with traces.',
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
            [
              ('Shape', 'Table, then where, then summarize, then order'),
              ('Time', 'where TimeGenerated > ago(1h)'),
              ('Group', 'summarize count() by bin(TimeGenerated, 5m), Status'),
              ('Reduce', 'project only the columns you need before joining'),
              ('Render', 'render timechart for a quick visual'),
            ],
            'I would filter first, then aggregate. Something like: take the table, where TimeGenerated is greater than ago one hour and the status is failed, summarize count by bin of TimeGenerated five minutes and by job name, then order by the count descending. The habit I keep is filtering on time first and projecting only the columns I need before any join, because in a busy workspace that is the difference between a query that returns and one that times out.',
            'Filter on time first, project narrow, then summarize by bin.',
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
            [
              (
                'Symptoms not causes',
                'Alert on what a user feels, not on every internal condition',
              ),
              (
                'Actionable',
                'Every alert needs a runbook and a thing the person should do',
              ),
              (
                'Route by severity',
                'Page for now, ticket for later — not everything is a page',
              ),
              (
                'Ownership',
                'An alert with no owner gets ignored and trains people to ignore alerts',
              ),
              (
                'Review',
                'Alerts that fire and get closed with no action get deleted or fixed',
              ),
            ],
            'I alert on symptoms rather than causes — the thing a user or a downstream team actually feels — because cause-based alerting produces a page for every internal hiccup and trains people to ignore the channel. Every alert needs an owner and a runbook, and a route that matches its severity: page for something needing action now, ticket for something needing action this week. And I review the ones that keep firing and getting closed with no action, because a noisy alert is a reliability problem in its own right.',
            'Symptoms, not causes. Owner plus runbook. Page versus ticket.',
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
            [
              (
                'Ingestion',
                'Diagnostic settings to Log Analytics; DCRs and the Azure Monitor Agent for VMs',
              ),
              ('Routing', 'Event Hub as the path to an external SIEM'),
              ('Dashboards', 'Azure Workbooks or Managed Grafana'),
              (
                'Content',
                'Is it healthy, and what changed — not every metric you collect',
              ),
              (
                'Retention',
                'Interactive tier for recent, archive for compliance',
              ),
            ],
            'First get the data in — diagnostic settings on every resource pointing at the Log Analytics workspace, data collection rules for anything agent-based, and an Event Hub route if a SIEM needs a copy. Then the dashboard, and I try to keep it answering two questions: is this healthy right now, and what changed. A dashboard with forty tiles is one nobody reads during an incident. Retention I split — interactive for the recent window people query, archive for whatever compliance requires.',
            'Get data in, then answer two questions: healthy now, and what changed.',
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
            [
              ('SLI', 'The measurement — success rate, latency, freshness'),
              ('SLO', 'The target on that measurement over a window'),
              ('Error budget', 'The allowed failure — one minus the objective'),
              (
                'Use',
                'Budget spent means slow down and fix; budget healthy means ship',
              ),
              (
                'For data platforms',
                'Freshness and completeness are often better SLIs than uptime',
              ),
            ],
            'An SLI is the thing you measure, the SLO is the target on it, and the error budget is the failure you have agreed is acceptable. What makes it useful is that it turns an argument about whether the platform is reliable enough into a number, and it also governs release pace — if the budget is spent, the next work is reliability rather than features. For a data platform I would push for freshness and completeness as SLIs rather than pure uptime, because a pipeline that is up but six hours late is still an outage to the people using it.',
            'Measure, target, budget. For data platforms: freshness beats uptime.',
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
            [
              (
                '1. Scope',
                'What is broken, who is affected, how bad — set severity from impact',
              ),
              (
                '2. Communicate',
                'Say it is being worked, and when the next update comes',
              ),
              (
                '3. What changed',
                'Most incidents are a deploy, a config change, or an expiry',
              ),
              (
                '4. Mitigate',
                'Restore service first — roll back before you fully understand it',
              ),
              (
                '5. Preserve',
                'Capture logs and state before restarting anything',
              ),
              (
                '6. Review',
                'Blameless postmortem with owned actions and dates',
              ),
            ],
            'First I establish blast radius — is it one job, one workspace, or the platform — because that sets severity and who needs to know. Then I communicate early, even before I know the cause, with a time for the next update so nobody has to chase me. Then I look at what changed in the last few hours, because most incidents are a deploy, a config change or something expiring. Restoring service comes before understanding it, so I will roll back and diagnose afterwards — but I capture logs and state first, because a restart destroys the only evidence of why it broke. Then a blameless postmortem with actions that have owners and dates.',
            'Scope, communicate, what changed, mitigate, preserve evidence, review.',
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
            [
              (
                'Cadence',
                'Fixed intervals, and always say when the next update is',
              ),
              (
                'Content',
                'Impact, what is being done, next update time. Not a technical narration',
              ),
              (
                'Audience',
                'Plain language — the reader may be a business stakeholder',
              ),
              (
                'Honesty',
                'Say what you do not know yet rather than speculating',
              ),
              (
                'Why',
                'Good updates stop people interrupting the person fixing it',
              ),
            ],
            'Fixed cadence updates in plain language, covering three things: what the impact is, what is being done right now, and when the next update will come. I avoid technical narration because the audience often includes people who just need to know whether to tell a client. And I would rather say we do not know the cause yet than speculate, because a wrong cause stated confidently costs you credibility for the rest of the incident. Good updates also stop five people messaging the person who is actually fixing it.',
            'Impact, action, next update time. Say what you do not know.',
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
            [
              (
                'Audience',
                'Someone at 3am with no context and no adrenaline to spare',
              ),
              (
                'Structure',
                'Symptom, checks, remediation steps, when to escalate',
              ),
              (
                'Concrete',
                'Actual commands and queries, not "investigate the issue"',
              ),
              ('Location', 'Linked from the alert that fires it'),
              ('Maintenance', 'Updated as part of the change, not afterwards'),
            ],
            'I write it for someone at three in the morning with no context. Symptom at the top so they know they are in the right document, then the checks in order, then the actual remediation commands rather than "investigate the issue", then a clear line for when to stop and escalate. It should be linked directly from the alert that fires it, and it gets updated as part of whatever change made it stale — a runbook nobody trusts is worse than none, because people waste time reading it first.',
            'Written for 3am. Symptom, checks, commands, escalation. Linked from the alert.',
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
            [
              ('Own it', 'Plainly, in the first sentence, no deflection'),
              (
                'Spend time on',
                'Detection, response, and the control you added afterwards',
              ),
              (
                'Blameless',
                'The question is what let a human error become an outage',
              ),
              ('Never', 'Blame a colleague, a vendor, or "the process"'),
              (
                'End on',
                'The guardrail that means it cannot happen the same way again',
              ),
            ],
            'I would name it in the first sentence without softening it, then spend most of the answer on what happened next — how it was detected, how fast it was mitigated, and specifically what changed afterwards so the same mistake could not have the same consequence. That last part is the whole point. A blameless postmortem is not about being nice to the person, it is about accepting that people will make mistakes and asking why the system let a mistake become an outage.',
            'Own it in sentence one. Spend the answer on the guardrail you added.',
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
            [
              (
                'Change record',
                'Every production change has a ticket, an approval and a window',
              ),
              (
                'Evidence',
                'Pipeline run links the change to a commit and an approver',
              ),
              (
                'Freeze',
                'Know when the freeze periods are and plan around them',
              ),
              (
                'Patching',
                'Regular cycles, with risk and audit findings tracked to due dates',
              ),
              (
                'Attitude',
                'Controls are part of engineering, not an obstacle to route around',
              ),
            ],
            'Every production change has a record, an approver and a window, and I want the pipeline producing that evidence automatically rather than someone assembling it later for an audit. Patching runs on a cycle, and risk and audit findings get tracked with owners and due dates like any other backlog. The attitude I would bring is that these controls are part of the engineering job — an unapproved production change is a bigger problem in a bank than the outage it was trying to prevent, and I would rather design the pipeline so the compliant path is also the easy path.',
            'Ticket, approver, window. Pipeline produces the evidence. Compliant path = easy path.',
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
            [
              (
                'Layers',
                'Each instruction adds a read-only layer; the image is the stack',
              ),
              ('Cache', 'A changed layer invalidates every layer after it'),
              (
                'Order',
                'Dependencies before source, so a code change does not reinstall packages',
              ),
              (
                'Multi-stage',
                'Build fat, ship slim — compilers never reach production',
              ),
              (
                'Secrets',
                'A secret in an early layer stays in the image even if a later layer deletes it',
              ),
            ],
            'An image is a stack of read-only layers, one per instruction, and the build cache is invalidated from the first changed layer onward. So I order the Dockerfile with the things that change least at the top — copy the dependency manifest and install before copying the source, otherwise every code change reinstalls every package. I use multi-stage builds so the compiler and build tooling stay in the build stage and only the artefact ships. And I never put a secret in any layer, because deleting it in a later layer does not remove it from the image.',
            'Least-changing first. Multi-stage to ship slim. Deleted secrets are still in the layer.',
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
            [
              (
                'Registry',
                'ACR, private, with managed identity auth rather than a pull secret',
              ),
              ('Tags', 'Commit SHA or digest — never latest'),
              ('Base images', 'Minimal and pinned; rebuild on base image CVEs'),
              (
                'Runtime',
                'Non-root user, read-only root filesystem, drop capabilities',
              ),
              (
                'Scanning',
                'In the pipeline, failing the build on high severity',
              ),
            ],
            'Private ACR with managed identity authentication so there is no pull secret to manage, and images tagged with the commit SHA rather than latest so whatever is running traces back to a commit. Base images are minimal and pinned, and scanning runs in the pipeline and fails the build on high severity rather than warning. At runtime the container runs as a non-root user with a read-only root filesystem — most of container security is just not giving the process privileges it never needed.',
            'ACR plus managed identity. Tag by SHA. Non-root, minimal, scanned.',
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
            [
              (
                'Control plane',
                'API server, etcd, scheduler, controller manager',
              ),
              ('Nodes', 'kubelet, kube-proxy, container runtime (containerd)'),
              (
                'Model',
                'You declare desired state; controllers reconcile toward it continuously',
              ),
              (
                'Scheduler',
                'Decides placement only — the kubelet actually starts containers',
              ),
              (
                'On AKS',
                'Microsoft manages the control plane; you own node pools and workloads',
              ),
            ],
            'The control plane holds desired state — the API server is the front door, etcd stores it, the scheduler decides placement, and the controller manager runs the reconciliation loops. On each node the kubelet starts and supervises containers through containerd, and kube-proxy programs the routing rules for Services. The mental model underneath is that you never tell Kubernetes to do something, you declare what should be true and controllers close the gap continuously — which is why deleting a pod owned by a Deployment just gets you a new pod. On AKS Microsoft runs the control plane and I own the node pools and everything above the API.',
            'Declare desired state, controllers reconcile. Scheduler decides, kubelet starts.',
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
            [
              (
                'Pod',
                'Smallest unit — containers sharing an IP and volumes; disposable',
              ),
              (
                'Deployment',
                'Stateless replicas with rolling updates and rollback — the default',
              ),
              (
                'StatefulSet',
                'Stable identity and per-replica storage — databases',
              ),
              ('DaemonSet', 'One pod per node — log and metrics agents'),
              ('Service', 'Stable virtual IP over label-selected pods'),
              (
                'ConfigMap / Secret',
                'Config injected without rebuilding the image',
              ),
            ],
            'Pod is the smallest unit and it is disposable — it never gets repaired, only replaced, which is why Services exist. Deployment is the default for stateless work because it gives rolling updates and rollback. StatefulSet when replicas are not interchangeable and each needs its own identity and storage, like a database. DaemonSet when the workload is per-node rather than per-application, like a log agent. And a Service is the stable virtual IP in front of whichever pods currently match its label selector.',
            'Deployment default, StatefulSet for identity, DaemonSet per node, Service for stability.',
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
            [
              (
                'Pending',
                'Unschedulable — resources, taints, or an unbound PVC',
              ),
              ('ImagePullBackOff', 'Bad tag or registry authentication'),
              ('CrashLoopBackOff', 'Starts and exits — check logs --previous'),
              ('OOMKilled', 'Exceeded its memory limit, exit code 137'),
              (
                'The rule',
                'describe tells you why it will not start; logs tell you why it misbehaves',
              ),
            ],
            'I start with get pods to see the state, because the state tells me which tool to use. If it is Pending there are no logs to read — it never ran — so I describe it and read the events for insufficient resources, a taint, or an unbound volume. If it is CrashLoopBackOff it did run, so logs with the previous flag gets me the dead container output. ImagePullBackOff is almost always a tag typo or registry auth. The rule I keep is that describe tells you why something will not start and logs tell you why something running is wrong.',
            'describe for will-not-start, logs for behaving-wrong. Pending has no logs.',
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
            [
              (
                'Microsoft',
                'Control plane — API server, etcd, scheduler, controller manager, and its patching',
              ),
              (
                'You',
                'Node pools, node image and version upgrades, workloads, networking, identity',
              ),
              (
                'Node pools',
                'System pool for cluster services, user pools for workloads, taints to separate',
              ),
              (
                'Identity',
                'Workload identity federation for pods; ACR attach for image pulls',
              ),
              (
                'Upgrades',
                'Cordon, drain, replace — respects PodDisruptionBudgets',
              ),
            ],
            'Microsoft runs and patches the control plane, and there is an SLA on it in the Standard tier. I own the node pools — including deciding when Kubernetes version and node image upgrades happen — plus the workloads, the networking configuration and the identity integration. The part that catches people is that node upgrades are still my decision and my maintenance window even though the control plane is not. And an over-strict PodDisruptionBudget is the usual reason an AKS upgrade hangs, because the drain cannot proceed without violating it.',
            'Control plane theirs, nodes mine. PDBs are why upgrades hang.',
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
            [
              (
                'Azure SDK',
                'azure-identity with DefaultAzureCredential, then the mgmt libraries',
              ),
              (
                'Databricks',
                'The Databricks SDK or REST API for jobs, clusters and permissions',
              ),
              (
                'Data',
                'PySpark on a cluster; pandas only for genuinely small local work',
              ),
              (
                'Hygiene',
                'Typed function signatures, real exception handling, argparse, logging',
              ),
              (
                'Not',
                'It is not a LeetCode round — they want maintainable operational scripts',
              ),
            ],
            'Mostly operational automation rather than application development — reporting on resources, reconciling configuration, and driving APIs. I use DefaultAzureCredential so the same script works locally with my own identity and in a pipeline with a federated one, without a code change. For Databricks I use the SDK or the REST API for jobs and permissions. I have written export and deployment scripts in Python, and the thing I care about is that they are readable, log what they did, and fail with a non-zero exit rather than half-succeeding quietly.',
            'DefaultAzureCredential everywhere. Log what it did. Fail loudly.',
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
            [
              (
                'First line',
                'set -euo pipefail — exit on error, undefined vars, and pipe failures',
              ),
              (
                'Exit codes',
                'Non-zero on failure so the pipeline actually fails',
              ),
              ('Idempotent', 'Safe to re-run without doubling anything'),
              (
                'Dry run',
                'A flag that prints what it would do before it does it',
              ),
              ('Tools', 'jq for JSON from az CLI, plus grep, sed, awk'),
            ],
            'set -euo pipefail on the first line, so it exits on an error, on an undefined variable, and on a failure anywhere in a pipe rather than silently continuing with bad state. Beyond that: idempotent so re-running is safe, a dry-run flag for anything destructive, and non-zero exit codes so a pipeline actually fails instead of going green. I have written deploy and teardown scripts this way — the teardown one especially, because a destructive script that half-runs is worse than one that does not run at all.',
            'set -euo pipefail. Idempotent, dry-run, honest exit codes.',
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
            [
              (
                'Honest',
                'Least-used of the three — say so, the posting says "Python, Bash, PowerShell"',
              ),
              (
                'Key difference',
                'Object-based pipeline, not text — output is structured',
              ),
              ('Az module', 'Connect-AzAccount, Get-Az* verb-noun cmdlets'),
              (
                'Adjacent',
                'Azure CLI with --query JMESPath covers most of the same ground',
              ),
              (
                'Framing',
                'The concept is the same; the syntax is a short ramp',
              ),
            ],
            'PowerShell is the least-used of the three for me — I have done more in Python and Bash. What I would say is that the mental shift is the pipeline being object-based rather than text-based, so you are filtering properties instead of parsing strings, and the Az module follows a consistent verb-noun pattern that makes it fairly discoverable. Most of what I would reach for it for I have done with the Azure CLI and JMESPath queries. It is a short ramp rather than a new concept, and I would rather tell you that than overstate it.',
            'Least-used of the three. Object pipeline, not text. Short ramp, say so honestly.',
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
            [
              (
                'Pre-change',
                'Plan reviewed, scans clean, tested in a lower environment',
              ),
              (
                'Post-change',
                'Smoke test that the thing actually works, not just that apply succeeded',
              ),
              (
                'Rollback',
                'Defined and tested before the change, not improvised after',
              ),
              (
                'Evidence',
                'The pipeline run is the record that validation happened',
              ),
              ('Definition of done', 'Deployed and verified, not deployed'),
            ],
            'To me it is the set of checks a change has to pass before we call it delivered. Before: the plan is reviewed, the scans are clean, and it has been applied in a lower environment first. After: a smoke test that proves the thing actually works, because a successful apply only tells you the API accepted the change. And a rollback path defined before we start rather than improvised at the point we need it. Done means deployed and verified, not deployed.',
            'Reviewed, scanned, lower environment, smoke test, rollback ready. Done = verified.',
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
            [
              (
                'Correctness',
                'Does it do what it says, and what happens when it fails',
              ),
              (
                'Blast radius',
                'For IaC especially — what does this plan destroy',
              ),
              (
                'Reuse',
                'Is this the fourth copy of something that should be a module',
              ),
              (
                'Readability',
                'Will someone understand it at 3am in an incident',
              ),
              (
                'As author',
                'Keep the diff small — that is the main thing that makes review work',
              ),
            ],
            'Correctness first, then blast radius — with infrastructure I read the plan output as carefully as the code, because the interesting question is what it destroys, not what it creates. Then whether it is the fourth copy of something that should be a module. And readability, specifically whether someone will understand it during an incident. When I am the author the main thing I can do is keep the diff small, because a thousand-line pull request gets approved rather than reviewed.',
            'Correctness, blast radius, reuse, 3am readability. Small diffs as author.',
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
            [
              (
                'Audience',
                'Written for someone new and stuck, not for someone who already knows',
              ),
              (
                'Location',
                'Next to the code, so it is updated in the same pull request',
              ),
              (
                'Types',
                'Runbook for incidents, SOP for repeated procedures, onboarding for new joiners',
              ),
              (
                'Test it',
                'Watch a new person follow it — the gaps show up immediately',
              ),
              (
                'Honest',
                'Documentation that is wrong is worse than documentation that is missing',
              ),
            ],
            'I write it for the person who is new and stuck rather than for someone who already understands the system, and I keep it next to the code so it gets updated in the same pull request as the change. The test I like is watching a new joiner actually follow it, because every assumption you did not know you were making shows up in the first ten minutes. And I would rather delete a stale page than leave it, because documentation people cannot trust costs more time than none at all.',
            'Write for the newcomer. Keep it next to the code. Delete stale pages.',
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
            [
              (
                'Spot it',
                'The third copy of the same thing is the signal to abstract',
              ),
              (
                'Bake in',
                'Private endpoint, diagnostics, tagging — the standard becomes the default',
              ),
              (
                'Version it',
                'So teams adopt upgrades deliberately, not by surprise',
              ),
              ('Adoption', 'Make the module the easiest path, not a mandate'),
              (
                'Do not',
                'Over-abstract on the first instance — two examples before a module',
              ),
            ],
            'I wait for the third copy before abstracting, because a module built from one example usually encodes the wrong assumptions. Once it is clearly a pattern, I put the standard inside it — the private endpoint, the diagnostic settings, the tagging — so doing the compliant thing is also the least work. Then version it, so a team upgrades when they choose rather than being surprised by a change. The adoption strategy is making it the easiest path rather than mandating it, because a mandate produces copies with the mandate worked around.',
            'Third copy, then abstract. Standard becomes the default. Easiest path beats mandate.',
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
            [
              (
                'Frame it',
                'Controls are part of engineering, not friction to route around',
              ),
              (
                'Design for it',
                'Make the compliant path the easy path and people stop working around it',
              ),
              (
                'Your evidence',
                '200+ AWS accounts — governance was the job, not an overhead',
              ),
              (
                'Do not say',
                '"It slows things down" or anything that sounds like impatience',
              ),
            ],
            'It suits how I already work. Running governance across two hundred plus AWS accounts, the controls were the job rather than an overhead on it — guardrails, access boundaries, and standards that let a lot of teams move without stepping on each other. My view is that if people are routing around a control, the control is badly designed rather than the people being careless, so I try to make the compliant path also the easiest one. That is why I care about things like pipelines producing audit evidence automatically.',
            'Governance was the job at 200+ accounts. Compliant path = easy path.',
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
            [
              (
                'Traceability',
                'Every production change ties to a commit, an approval and a pipeline run',
              ),
              (
                'Access',
                'Role assignments reviewed and recertified; PIM activations logged',
              ),
              (
                'Retention',
                'Audit logs shipped to Log Analytics with a compliance retention tier',
              ),
              (
                'Automatic',
                'The pipeline produces the evidence — nobody assembles it afterwards',
              ),
              (
                'Findings',
                'Tracked with owners and due dates like any other backlog',
              ),
            ],
            'The goal is that evidence is a by-product of how we work rather than a project every quarter. Every production change traces to a commit, a reviewer and a pipeline run, so "who changed this and who approved it" is a query rather than an investigation. Access is recertified through reviews, and privileged activations are logged. Audit logs go to Log Analytics with a retention tier that matches the requirement. And findings get owners and due dates like anything else on the backlog.',
            'Evidence as a by-product. Commit, approver, pipeline run. Findings get owners and dates.',
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
            [
              (
                'Classification',
                'What is sensitive, and what controls follow from that',
              ),
              (
                'Residency',
                'Where data may physically live — multi-geography makes this real',
              ),
              (
                'Access',
                'Unity Catalog grants and lineage answer who can see what, and who did',
              ),
              (
                'Non-production',
                'Masked or synthetic data in lower environments',
              ),
              (
                'Retention',
                'Both a minimum for compliance and a maximum for privacy',
              ),
            ],
            'Classification first, because everything else follows from it — what is sensitive determines who can see it, where it can live and how long you keep it. Residency matters specifically because the posting mentions multiple geographies, so data may not be allowed to leave a region. Unity Catalog does a lot of the heavy lifting here: grants control access and lineage answers where a column came from and who consumed it, which is exactly what a regulator asks. And lower environments should not have real production data in them.',
            'Classify, then access, residency, masking, retention. UC gives you grants plus lineage.',
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
            [
              (
                'Engage early',
                'Bring them in at design, not at the point you are blocked',
              ),
              (
                'Bring context',
                'Come with the requirement and options, not just a request',
              ),
              (
                'Their constraints',
                'Understand why the control exists before asking for an exception',
              ),
              (
                'Your evidence',
                '200+ accounts meant these were daily counterparties',
              ),
              (
                'Follow through',
                'Track the dependency yourself rather than assuming someone else is',
              ),
            ],
            'Early and with context. In the AWS role those teams were daily counterparties, and the thing that made it work was going to them at design time with the requirement and a couple of options rather than at the point I was already blocked. I try to understand why a control exists before asking for an exception, because usually there is a way to meet the intent that I had not thought of. And I track the dependency myself rather than assuming it is moving — a request sitting in someone else queue is still my delivery date.',
            'Early, with options, understand the control first, track it yourself.',
          ),
        ],
      ),
    ],
  ),
];
