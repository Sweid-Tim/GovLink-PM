#!/usr/bin/env bash
set -euo pipefail

DEFAULT_VAULT="/Users/tianye/Library/Mobile Documents/iCloud~md~obsidian/Documents/GovLink-PM"
MODE="${1:-install}"
if [[ "$MODE" == "install" || "$MODE" == "verify" || "$MODE" == "sanitize" ]]; then
  shift || true
else
  MODE="install"
fi

VAULT="${1:-$DEFAULT_VAULT}"
FORCE="${FORCE:-0}"
STAMP="$(date +%Y%m%d-%H%M%S)"

echo "Claudian team doctor"
echo "Mode: $MODE"
echo "Vault: $VAULT"
echo

if [[ ! -d "$VAULT" ]]; then
  echo "Vault not found: $VAULT" >&2
  exit 1
fi

if [[ "$MODE" != "verify" && "$FORCE" != "1" ]]; then
  if pgrep -x "Obsidian" >/dev/null 2>&1; then
    echo "Obsidian is currently running." >&2
    echo "Fully quit Obsidian first, then run this command again." >&2
    echo "If you are certain it is safe, run with FORCE=1." >&2
    exit 3
  fi
fi

MODE="$MODE" VAULT="$VAULT" STAMP="$STAMP" node <<'NODE'
const fs = require("fs");
const path = require("path");
const os = require("os");
const childProcess = require("child_process");

const mode = process.env.MODE;
const vault = process.env.VAULT;
const stamp = process.env.STAMP;
function getStableHostKey() {
  try {
    const computerName = childProcess.execFileSync("scutil", ["--get", "ComputerName"], { encoding: "utf8" }).trim();
    if (computerName) return computerName.replace(/[^A-Za-z0-9._-]/g, "_");
  } catch {}
  return os.hostname().replace(/[^A-Za-z0-9._-]/g, "_");
}

const hostKey = getStableHostKey();
const pluginDir = path.join(vault, ".obsidian/plugins/claudian");
const mainPath = path.join(pluginDir, "main.js");
const dataPath = path.join(pluginDir, "data.json");
const claudianDir = path.join(vault, ".claudian");
const hostClaudianDir = path.join(claudianDir, hostKey);
const hostSessionsDir = path.join(hostClaudianDir, "sessions");
const legacySharedSessionsDir = path.join(claudianDir, "sessions");
const legacyClaudeSessionsDir = path.join(vault, ".claude/sessions");

function fail(message) {
  throw new Error(message);
}

function exists(file) {
  return fs.existsSync(file);
}

function read(file) {
  return fs.readFileSync(file, "utf8");
}

function write(file, content) {
  fs.mkdirSync(path.dirname(file), { recursive: true });
  fs.writeFileSync(file, content);
}

function readJson(file, fallback = {}) {
  if (!exists(file)) return fallback;
  return JSON.parse(read(file));
}

function writeJson(file, data) {
  write(file, `${JSON.stringify(data, null, 2)}\n`);
}

function backup(file) {
  if (!exists(file)) return;
  fs.copyFileSync(file, `${file}.bak-team-doctor-${stamp}`);
}

function moveAside(dir, label) {
  if (!exists(dir)) return false;
  const entries = fs.readdirSync(dir).filter((name) => !name.startsWith("."));
  if (entries.length === 0) return false;
  const target = `${dir}.disabled-${label}-${stamp}`;
  fs.renameSync(dir, target);
  console.log(`Disabled shared state: ${target}`);
  return true;
}

function patchStoragePath(source) {
  const original = 'var CLAUDIAN_STORAGE_PATH = ".claudian";';
  const patched = 'var CLAUDIAN_STORAGE_PATH = `.claudian/${getMachineStorageKey()}`;';
  if (source.includes(original)) {
    return source.replace(original, patched);
  }
  if (source.includes(patched)) {
    return source;
  }
  fail("Could not patch CLAUDIAN_STORAGE_PATH. Claudian plugin version may have changed.");
}

function patchBlock(source, original, patched, alreadyNeedle, label) {
  if (source.includes(original)) {
    return source.replaceAll(original, patched);
  }
  if (source.includes(alreadyNeedle)) {
    return source;
  }
  fail(`Could not patch ${label}. Claudian plugin version may have changed.`);
}

function patchMainJs() {
  if (!exists(mainPath)) fail(`Missing Claudian plugin file: ${mainPath}`);
  backup(mainPath);
  let source = read(mainPath);
  const hostFunctionNeedle = `function getMachineStorageKey()`;
  if (!source.includes(hostFunctionNeedle)) {
    source = source.replace(
      `function getHostnameKey() {
  return os4.hostname();
}`,
      `function getHostnameKey() {
  return os4.hostname();
}
function getMachineStorageKey() {
  try {
    const name = require("child_process").execFileSync("scutil", ["--get", "ComputerName"], { encoding: "utf8" }).trim();
    if (name) return name.replace(/[^A-Za-z0-9._-]/g, "_");
  } catch (e2) {
  }
  return getHostnameKey().replace(/[^A-Za-z0-9._-]/g, "_");
}`
    );
  }
  source = patchStoragePath(source);

  const providerGetOriginal = `  async getTabManagerState() {
    try {
      const data = await this.plugin.loadData();
      if (data == null ? void 0 : data.tabManagerState) {
        return this.validateTabManagerState(data.tabManagerState);
      }
      return null;
    } catch (e2) {
      return null;
    }
  }`;
  const providerGetPatched = `  async getTabManagerState() {
    try {
      const data = await this.plugin.loadData();
      const hostKey = getMachineStorageKey();
      const scopedState = data == null ? void 0 : data.tabManagerStateByHost == null ? void 0 : data.tabManagerStateByHost[hostKey];
      if (scopedState) {
        return this.validateTabManagerState(scopedState);
      }
      return null;
    } catch (e2) {
      return null;
    }
  }`;
  source = patchBlock(source, providerGetOriginal, providerGetPatched, "tabManagerStateByHost", "provider getTabManagerState");

  const providerSetOriginal = `  async setTabManagerState(state) {
    try {
      const data = await this.plugin.loadData() || {};
      data.tabManagerState = state;
      await this.plugin.saveData(data);
    } catch (e2) {
      new import_obsidian3.Notice("Failed to save tab layout");
    }
  }`;
  const providerSetPatched = `  async setTabManagerState(state) {
    try {
      const data = await this.plugin.loadData() || {};
      const hostKey = getMachineStorageKey();
      data.tabManagerStateByHost = data.tabManagerStateByHost && typeof data.tabManagerStateByHost === "object" && !Array.isArray(data.tabManagerStateByHost) ? data.tabManagerStateByHost : {};
      data.tabManagerStateByHost[hostKey] = state;
      delete data.tabManagerState;
      await this.plugin.saveData(data);
    } catch (e2) {
      new import_obsidian3.Notice("Failed to save tab layout");
    }
  }`;
  source = patchBlock(source, providerSetOriginal, providerSetPatched, "data.tabManagerStateByHost[hostKey] = state", "provider setTabManagerState");

  const appGetOriginal = `  async getTabManagerState() {
    try {
      const data = await this.plugin.loadData();
      if (!(data == null ? void 0 : data.tabManagerState)) {
        return null;
      }
      return this.validateTabManagerState(data.tabManagerState);
    } catch (e2) {
      return null;
    }
  }`;
  const appGetPatched = `  async getTabManagerState() {
    try {
      const data = await this.plugin.loadData();
      const hostKey = getMachineStorageKey();
      const scopedState = data == null ? void 0 : data.tabManagerStateByHost == null ? void 0 : data.tabManagerStateByHost[hostKey];
      if (!scopedState) {
        return null;
      }
      return this.validateTabManagerState(scopedState);
    } catch (e2) {
      return null;
    }
  }`;
  source = patchBlock(source, appGetOriginal, appGetPatched, "return this.validateTabManagerState(scopedState);", "app getTabManagerState");

  const appSetOriginal = `  async setTabManagerState(state) {
    try {
      const data = await this.plugin.loadData() || {};
      data.tabManagerState = state;
      await this.plugin.saveData(data);
    } catch (e2) {
      new import_obsidian20.Notice("Failed to save tab layout");
    }
  }`;
  const appSetPatched = `  async setTabManagerState(state) {
    try {
      const data = await this.plugin.loadData() || {};
      const hostKey = getMachineStorageKey();
      data.tabManagerStateByHost = data.tabManagerStateByHost && typeof data.tabManagerStateByHost === "object" && !Array.isArray(data.tabManagerStateByHost) ? data.tabManagerStateByHost : {};
      data.tabManagerStateByHost[hostKey] = state;
      delete data.tabManagerState;
      await this.plugin.saveData(data);
    } catch (e2) {
      new import_obsidian20.Notice("Failed to save tab layout");
    }
  }`;
  source = patchBlock(source, appSetOriginal, appSetPatched, "new import_obsidian20.Notice(\"Failed to save tab layout\")", "app setTabManagerState");

  source = source.replace(
    "      const resumeSessionId = meta3.sessionId !== void 0 ? meta3.sessionId : meta3.id;",
    "      const resumeSessionId = null;"
  );
  source = source.replace(
    "        providerState: meta3.providerState,",
    "        providerState: void 0,"
  );
  source = source.replace(
    `    this.messageChannel = new MessageChannel();
    if (resumeSessionId) {`,
    `    this.messageChannel = new MessageChannel();
    resumeSessionId = null;
    if (resumeSessionId) {`
  );
  source = source.replace(
    "    const resumeAtMessageId = this.pendingResumeAt;",
    "    const resumeAtMessageId = void 0;"
  );
  source = source.replace(
    "      resume: resumeSessionId ? { sessionId: resumeSessionId, sessionAt: resumeAtMessageId, fork: this.pendingForkSession || void 0 } : void 0,",
    "      resume: void 0,"
  );
  source = source.replace(
    `  if (config2.resumeSessionId) {
    options.resume = config2.resumeSessionId;
  }`,
    `  config2.resumeSessionId = void 0;`
  );
  source = source.replace(
    `    if (ctx.resume) {
      options.resume = ctx.resume.sessionId;
      if (ctx.resume.sessionAt) {
        options.resumeSessionAt = ctx.resume.sessionAt;
      }
      if (ctx.resume.fork) {
        options.forkSession = true;
      }
    }`,
    `    ctx.resume = void 0;`
  );
  source = source.replace(
    `    if (ctx.sessionId) {
      options.resume = ctx.sessionId;
    }`,
    `    ctx.sessionId = void 0;`
  );
  source = source.replace(
    `      if (I) p.push("--continue");
      if (x) p.push("--resume", x);`,
    `      I = false;
      x = void 0;
      this.options.resumeSessionAt = void 0;
      this.options.sessionId = void 0;
      if (I) p.push("--continue");
      if (x) p.push("--resume", x);`
  );

  write(mainPath, source);
  console.log("Patched Claudian plugin storage.");
}

function migrateLocalState() {
  fs.mkdirSync(hostSessionsDir, { recursive: true });
  const sharedSettings = path.join(claudianDir, "claudian-settings.json");
  const hostSettings = path.join(hostClaudianDir, "claudian-settings.json");
  if (exists(sharedSettings) && !exists(hostSettings)) {
    fs.copyFileSync(sharedSettings, hostSettings);
    console.log(`Copied settings to local host scope: .claudian/${hostKey}/claudian-settings.json`);
  }

  if (exists(dataPath)) backup(dataPath);
  const data = readJson(dataPath, {});
  data.tabManagerStateByHost = data.tabManagerStateByHost && typeof data.tabManagerStateByHost === "object" && !Array.isArray(data.tabManagerStateByHost) ? data.tabManagerStateByHost : {};
  if (!data.tabManagerStateByHost[hostKey]) {
    data.tabManagerStateByHost[hostKey] = { openTabs: [], activeTabId: null };
  }
  delete data.tabManagerState;
  writeJson(dataPath, data);
  console.log(`Prepared host tab state: ${hostKey}`);
}

function sanitizeSharedState() {
  fs.mkdirSync(claudianDir, { recursive: true });
  moveAside(legacySharedSessionsDir, "shared-claudian-sessions");
  moveAside(legacyClaudeSessionsDir, "shared-claude-sessions");
  if (exists(dataPath)) {
    const data = readJson(dataPath, {});
    if ("tabManagerState" in data) {
      backup(dataPath);
      delete data.tabManagerState;
      writeJson(dataPath, data);
      console.log("Removed global tabManagerState from Claudian data.json.");
    }
  }
}

function installClaudeWrapper() {
  const localClaude = path.join(os.homedir(), ".local/bin/claude");
  if (!exists(localClaude)) {
    console.log("Claude wrapper skipped: ~/.local/bin/claude not found.");
    return;
  }
  let realClaude = localClaude;
  try {
    const stat = fs.lstatSync(localClaude);
    if (stat.isSymbolicLink()) {
      realClaude = fs.readlinkSync(localClaude);
      if (!path.isAbsolute(realClaude)) {
        realClaude = path.resolve(path.dirname(localClaude), realClaude);
      }
    } else {
      const current = read(localClaude);
      const match = current.match(/REAL_CLAUDE="([^"]+)"/);
      if (match) {
        realClaude = match[1];
      } else {
        const backup = `${localClaude}.real-${stamp}`;
        fs.renameSync(localClaude, backup);
        realClaude = backup;
      }
    }
  } catch (error) {
    console.log(`Claude wrapper skipped: ${error.message}`);
    return;
  }
  const wrapper = `#!/usr/bin/env bash
set -euo pipefail
REAL_CLAUDE="${realClaude}"
filtered=()
skip_next=0
for arg in "$@"; do
  if [[ "$skip_next" == "1" ]]; then
    skip_next=0
    continue
  fi
  case "$arg" in
    --resume|--session-id|--resume-session-at)
      skip_next=1
      ;;
    --resume=*|--session-id=*|--resume-session-at=*|--continue)
      ;;
    *)
      filtered+=("$arg")
      ;;
  esac
done
exec "$REAL_CLAUDE" "\${filtered[@]}"
`;
  write(localClaude, wrapper);
  fs.chmodSync(localClaude, 0o755);
  console.log("Installed Claude Code resume-filter wrapper at ~/.local/bin/claude.");
}

function verify() {
  const problems = [];
  if (!exists(mainPath)) {
    problems.push(`Missing ${mainPath}`);
  } else {
    const source = read(mainPath);
    if (!source.includes('CLAUDIAN_STORAGE_PATH = `.claudian/${getMachineStorageKey()}`')) {
      problems.push("Claudian storage is not host-scoped.");
    }
    if (!source.includes("const resumeSessionId = null;") || !source.includes("resume: void 0,")) {
      problems.push("Claude Code session resume is not disabled.");
    }
    if (!source.includes("config2.resumeSessionId = void 0;") || !source.includes("ctx.resume = void 0;") || !source.includes("ctx.sessionId = void 0;")) {
      problems.push("All Claude Code resume option builders are not disabled.");
    }
    if (!source.includes("I = false;") || !source.includes("x = void 0;") || !source.includes("this.options.sessionId = void 0;")) {
      problems.push("Claude Code CLI resume flags are not disabled.");
    }
    const hostScopedTabMentions = (source.match(/tabManagerStateByHost/g) || []).length;
    if (hostScopedTabMentions < 8) {
      problems.push("Claudian tab state is not fully host-scoped.");
    }
  }
  if (exists(dataPath)) {
    const data = readJson(dataPath, {});
    if ("tabManagerState" in data) {
      problems.push("data.json still contains global tabManagerState.");
    }
  }
  if (exists(legacySharedSessionsDir) && fs.readdirSync(legacySharedSessionsDir).some((name) => name.endsWith(".meta.json"))) {
    problems.push(".claudian/sessions still contains shared session metadata.");
  }
  if (exists(legacyClaudeSessionsDir) && fs.readdirSync(legacyClaudeSessionsDir).some((name) => name.endsWith(".meta.json"))) {
    problems.push(".claude/sessions still contains shared session metadata.");
  }
  if (!exists(hostClaudianDir)) {
    problems.push(`Host-scoped Claudian directory missing: .claudian/${hostKey}`);
  }
  if (problems.length) {
    console.log("Verification failed:");
    for (const problem of problems) console.log(`- ${problem}`);
    process.exitCode = 2;
    return;
  }
  console.log("Verification passed.");
  console.log(`This computer uses isolated Claudian storage: .claudian/${hostKey}`);
}

if (mode === "install") {
  patchMainJs();
  migrateLocalState();
  sanitizeSharedState();
  installClaudeWrapper();
  verify();
} else if (mode === "sanitize") {
  migrateLocalState();
  sanitizeSharedState();
  verify();
} else if (mode === "verify") {
  verify();
} else {
  fail(`Unknown mode: ${mode}`);
}
NODE
