# Ahassu — Azure Pipelines setup

CI/CD for Ahassu on **Azure Pipelines**, deploying to **Firebase Hosting**.
Everything below is free and needs no credit card.

```
push to master
   │
   ▼
Azure Pipelines (self-hosted agent on your Mac)
   │  flutter analyze → flutter test → flutter build web
   ▼
Firebase Hosting (Spark, free)
```

## Cost: $0

| Component | Plan | Limit |
|---|---|---|
| Azure DevOps users | Free | 5 Basic (2 in use) |
| Azure Repos | Free | Unlimited private repos |
| Pipelines — **self-hosted** | Free | 1 parallel job, **unlimited minutes** |
| Pipelines — Microsoft-hosted | Free | 1 job, 1,800 min/month, **grant required** |
| Firebase Hosting | Spark | 10 GB stored, 360 MB/day transfer |

Firebase Spark has no paid overage — it stops serving rather than billing.
Nothing here can generate a charge.

---

## Why self-hosted by default

New Azure DevOps organizations are granted **zero Microsoft-hosted parallel
jobs**. A pipeline using `vmImage:` fails immediately with:

> No hosted parallelism has been purchased or granted.

Two ways out, both free:

1. **Self-hosted agent on your Mac** — works today, unlimited minutes. This is
   what `azure-pipelines.yml` is configured for.
2. **Request the free grant** at `https://aka.ms/azpipelines-parallelism-request`
   — takes about 2–3 business days. Once approved, edit the `pool:` block in
   `azure-pipelines.yml` to use `vmImage: 'ubuntu-latest'`.

---

## Step 1 — Push the code to Azure Repos

The repo already exists but is empty:
`https://dev.azure.com/ymiriyala19/IRV/_git/ahassu`

Create a PAT first at `https://dev.azure.com/ymiriyala19/_usersSettings/tokens`
with **Code (Read & write)** scope, then:

```bash
cd ~/Desktop/ahassu
git remote add azure https://ymiriyala19@dev.azure.com/ymiriyala19/IRV/_git/ahassu
git push -u azure master
```

Paste the PAT when prompted for a password. GitHub stays as `origin`; this adds
Azure DevOps as a second remote named `azure`.

> Azure Pipelines can also build **directly from GitHub** without this step, via
> a GitHub service connection. Pushing to Azure Repos keeps everything in one
> place and avoids the connection setup.

## Step 2 — Register the self-hosted agent

1. In Azure DevOps: **Project settings → Agent pools → Default → New agent → macOS**.
2. Download the agent tarball, then:

```bash
mkdir -p ~/azagent && cd ~/azagent
tar zxvf ~/Downloads/vsts-agent-osx-*.tar.gz
./config.sh
```

Answer the prompts:
- Server URL: `https://dev.azure.com/ymiriyala19`
- Authentication type: `PAT`, then paste a PAT with **Agent Pools (Read & manage)**
- Agent pool: `Default`
- Agent name: accept the default

Then run it:

```bash
./run.sh                 # foreground, stops when you close the terminal
./svc.sh install && ./svc.sh start   # or run it as a background service
```

The agent must be running for builds to execute. It only consumes your Mac's
CPU — no cloud cost.

## Step 3 — Create the pipeline

**Pipelines → New pipeline → Azure Repos Git → ahassu → Existing Azure Pipelines
YAML file → `/azure-pipelines.yml`** → Save.

## Step 4 — Add the Firebase deploy credential

Google deprecated `firebase login:ci` tokens, so use a service account.

1. Firebase Console → **Project settings → Service accounts → Generate new
   private key**. This downloads a JSON file.
2. In Azure DevOps: **Pipelines → ahassu → Edit → Variables → New variable**
   - Name: `FIREBASE_SERVICE_ACCOUNT`
   - Value: the entire contents of the JSON file
   - **Tick "Keep this value secret"**

The pipeline writes it to a temp file, exports `GOOGLE_APPLICATION_CREDENTIALS`,
and deletes the file in an `always()` step so the key never outlives the run.

> Treat that JSON as a password — it grants deploy rights to the Firebase
> project. Never commit it.

## Step 5 — Approval gate (optional)

The Deploy stage targets an environment named `ahassu-production`. Create it
under **Pipelines → Environments** and add yourself as an approver to require a
click before anything reaches production.

---

## What the pipeline does

**Verify stage** — runs on every push *and* every PR to `master`:

| Step | Purpose |
|---|---|
| Cache Flutter SDK | Keyed on version; avoids re-downloading each run |
| `flutter analyze` | Fails the build on analyzer errors |
| `flutter test` | Results converted to JUnit and shown in the **Tests** tab |
| `flutter build web --release` | Proves the app actually compiles |
| Publish artifact | Hands `build/web` to the Deploy stage |

**Deploy stage** — only on `master`, only if Verify passed, never from a PR.

The stage `condition` enforces all three, so a green PR build cannot deploy.

---

## Known issue: the widget test currently fails

`test/widget_test.dart` fails on `master` today, before any CI existed:

```
Bad state: No ProviderScope found
  _AhassuAppState.initState (package:ahassu/main.dart:27:25)
```

The test pumps `AhassuApp` bare, but `initState` calls
`ref.read(firestoreServiceProvider)`, which needs a `ProviderScope` ancestor —
`main()` supplies one, the test does not. Adding the scope alone is not enough:
the provider builds `FirestoreService(FirebaseFirestore.instance)`, and
`FirebaseFirestore.instance` throws in a test process with no initialized
Firebase app.

The fix is to override `firestoreServiceProvider` with a fake in the test.
**Until then the pipeline will be red** — deliberately. The test step does not
set `continueOnError`, because a pipeline that hides a failing test is worse
than no pipeline.
