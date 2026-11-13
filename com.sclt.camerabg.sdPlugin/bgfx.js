// Reads/sets macOS Video Effects > Background for an app, via the private AVFoundation API Control Center uses.
// usage: osascript -l JavaScript bgfx.js status|toggle|on|off <bundle-id>   -> prints on|off
ObjC.import("AVFoundation");
const EFFECT = "AVControlCenterVideoEffectBackgroundReplacement"; // the exported constant's value is its own name
ObjC.bindFunction("AVControlCenterVideoEffectsModuleIsEffectEnabledForBundleID", ["bool", ["id", "id"]]);

function run([cmd, app]) {
  if (!["status", "toggle", "on", "off"].includes(cmd) || !app) throw new Error("usage: bgfx.js status|toggle|on|off <bundle-id>");
  const isOn = () => $.AVControlCenterVideoEffectsModuleIsEffectEnabledForBundleID($(EFFECT), $(app));
  if (cmd === "status") return isOn() ? "on" : "off";
  const want = cmd === "on" || (cmd === "toggle" && !isOn());
  $.NSClassFromString("AVControlCenterModuleState").moduleStateForBundleID(app).setEnabledForVideoEffect(want, EFFECT);
  $.NSRunLoop.mainRunLoop.runUntilDate($.NSDate.dateWithTimeIntervalSinceNow(0.3)); // let the change propagate
  if (isOn() !== want) throw new Error("change did not stick");
  return want ? "on" : "off";
}
