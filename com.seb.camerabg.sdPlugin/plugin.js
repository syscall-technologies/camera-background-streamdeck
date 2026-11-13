// Minimal Stream Deck plugin, no deps (Node 24 has a global WebSocket).
// Polls `bgfx status` to set the key state (0 = off, 1 = on); a press runs `bgfx toggle`.
const { execFile } = require("node:child_process");
const path = require("node:path");

const BGFX = path.join(__dirname, "bin", "bgfx");
const DEFAULT_APP = "com.microsoft.teams2";
const parseState = (out) => ({ on: 1, off: 0 })[String(out).trim()]; // undefined = unknown

if (process.argv.includes("--selftest")) {
  const assert = require("node:assert");
  assert.equal(parseState("on\n"), 1);
  assert.equal(parseState("off\n"), 0);
  assert.equal(parseState("private Video Effects API not found"), undefined);
  console.log("selftest ok");
  process.exit(0);
}

const arg = (name) => process.argv[process.argv.indexOf(name) + 1];
const keys = new Map(); // context -> bundle ID
const ws = new WebSocket(`ws://127.0.0.1:${arg("-port")}`);
const send = (msg) => ws.readyState === WebSocket.OPEN && ws.send(JSON.stringify(msg));

function run(cmd, context) {
  execFile(BGFX, [cmd, keys.get(context)], { timeout: 5000 }, (err, stdout) => {
    const state = parseState(stdout);
    if (state === undefined) return send({ event: "showAlert", context }); // API gone (macOS update) or bad ID
    send({ event: "setState", context, payload: { state } });
    if (err && cmd === "toggle") send({ event: "showAlert", context }); // change did not stick
  });
}

const refresh = () => keys.forEach((_app, context) => run("status", context));

ws.onopen = () => send({ event: arg("-registerEvent"), uuid: arg("-pluginUUID") });
ws.onmessage = ({ data }) => {
  const { event, context, payload } = JSON.parse(data);
  if (event === "willAppear" || event === "didReceiveSettings") {
    keys.set(context, payload.settings.appId?.trim() || DEFAULT_APP);
    run("status", context);
  }
  if (event === "willDisappear") keys.delete(context);
  if (event === "keyDown") run("toggle", context);
};
ws.onclose = () => process.exit(0);
setInterval(refresh, 2000); // also catches changes made from Control Center
