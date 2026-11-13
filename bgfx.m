// bgfx: toggle macOS Video Effects > Background for an app, via private AVFoundation API (no UI clicking).
// usage: bgfx [toggle|on|off|status] [bundle-id]   (bundle-id defaults to Microsoft Teams)
// shortcut: private API found on macOS 27.2; may change in any macOS update. Re-check with `bgfx status` after updates.
#import <Foundation/Foundation.h>
#include <dlfcn.h>

int main(int argc, char **argv) {
	@autoreleasepool {
		NSString *cmd = argc > 1 ? @(argv[1]) : @"toggle";
		NSString *bid = argc > 2 ? @(argv[2]) : @"com.microsoft.teams2";
		void *h = dlopen("/System/Library/Frameworks/AVFoundation.framework/AVFoundation", RTLD_NOW);
		NSString * __unsafe_unretained *effp = h ? (NSString * __unsafe_unretained *)dlsym(h, "AVControlCenterVideoEffectBackgroundReplacement") : NULL;
		BOOL (*isOn)(NSString *, NSString *) = h ? dlsym(h, "AVControlCenterVideoEffectsModuleIsEffectEnabledForBundleID") : NULL;
		Class cls = NSClassFromString(@"AVControlCenterModuleState");
		if (!effp || !isOn || ![cls respondsToSelector:@selector(moduleStateForBundleID:)]) {
			fprintf(stderr, "private Video Effects API not found on this macOS version\n");
			return 2;
		}
		NSString *eff = *effp;
		BOOL cur = isOn(eff, bid);
		if ([cmd isEqualToString:@"status"]) { printf("%s\n", cur ? "on" : "off"); return 0; }

		BOOL want;
		if ([cmd isEqualToString:@"toggle"]) want = !cur;
		else if ([cmd isEqualToString:@"on"]) want = YES;
		else if ([cmd isEqualToString:@"off"]) want = NO;
		else { fprintf(stderr, "usage: bgfx [toggle|on|off|status] [bundle-id]\n"); return 64; }

		id st = [cls performSelector:@selector(moduleStateForBundleID:) withObject:bid];
		BOOL (*setE)(id, SEL, BOOL, id) = (void *)[st methodForSelector:@selector(setEnabled:forVideoEffect:)];
		setE(st, @selector(setEnabled:forVideoEffect:), want, eff);
		[[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.3]]; // let the change propagate

		BOOL now = isOn(eff, bid);
		printf("%s\n", now ? "on" : "off");
		return now == want ? 0 : 1;
	}
}
