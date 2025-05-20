import { ConfigPlugin, ExportedConfigWithProps } from '@expo/config-plugins';
import type { ExpoConfig } from '@expo/config/build/Config.types';
import type { AppDelegateProjectFile } from '@expo/config-plugins/build/ios/Paths';
import type { InfoPlist } from '@expo/config-plugins/build/ios/IosConfig.types';
import { PluginConfigType } from '../pluginConfig';
export declare const withIosCaptchaOpenUrlFix: ConfigPlugin<PluginConfigType>;
export declare function shouldApplyIosOpenUrlFix({ config, props, }: {
    config: ExpoConfig;
    props?: PluginConfigType;
}): boolean;
export declare function withOpenUrlFixForAppDelegate({ config, props, }: {
    config: ExportedConfigWithProps<AppDelegateProjectFile>;
    props?: PluginConfigType;
}): ExportedConfigWithProps<AppDelegateProjectFile>;
export declare function modifyAppDelegate(contents: string, language: string): string | null;
export declare const appDelegateOpenUrlInsertionPointAfter: RegExp;
export declare const multiline_appDelegateOpenUrlInsertionPointAfter: RegExp;
export declare function modifyObjcAppDelegate(contents: string): string | null;
export declare const appDelegateSwiftOpenUrlInsertionPointAfter: RegExp;
export declare function modifySwiftAppDelegate(contents: string): string | null;
export type ExpoConfigPluginEntry = string | [] | [string] | [string, any];
export declare function isFirebaseSwizzlingDisabled(config: ExportedConfigWithProps<InfoPlist>): boolean;
export declare function ensureFirebaseSwizzlingIsEnabled(config: ExportedConfigWithProps<InfoPlist>): boolean;
