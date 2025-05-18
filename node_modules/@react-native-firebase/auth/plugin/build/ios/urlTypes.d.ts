import { ConfigPlugin, IOSConfig, ExportedConfigWithProps } from '@expo/config-plugins';
import { PluginConfigType } from '../pluginConfig';
export declare const withIosCaptchaUrlTypes: ConfigPlugin<PluginConfigType>;
export declare function setUrlTypesForCaptcha({ config, }: {
    config: ExportedConfigWithProps<IOSConfig.InfoPlist>;
}): ExportedConfigWithProps<IOSConfig.InfoPlist>;
