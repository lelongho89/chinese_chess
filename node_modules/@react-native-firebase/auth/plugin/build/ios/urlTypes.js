"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.withIosCaptchaUrlTypes = void 0;
exports.setUrlTypesForCaptcha = setUrlTypesForCaptcha;
const config_plugins_1 = require("@expo/config-plugins");
const fs_1 = __importDefault(require("fs"));
const path_1 = __importDefault(require("path"));
const plist_1 = __importDefault(require("plist"));
// does this for you: https://firebase.google.com/docs/auth/ios/phone-auth#enable-phone-number-sign-in-for-your-firebase-project
const withIosCaptchaUrlTypes = config => {
    return (0, config_plugins_1.withInfoPlist)(config, config => {
        return setUrlTypesForCaptcha({ config });
    });
};
exports.withIosCaptchaUrlTypes = withIosCaptchaUrlTypes;
function getReversedClientId(googleServiceFilePath) {
    try {
        const googleServicePlist = fs_1.default.readFileSync(googleServiceFilePath, 'utf8');
        const googleServiceJson = plist_1.default.parse(googleServicePlist);
        const REVERSED_CLIENT_ID = googleServiceJson.REVERSED_CLIENT_ID;
        return REVERSED_CLIENT_ID;
    }
    catch {
        throw new Error('[@react-native-firebase/auth] Failed to parse your GoogleService-Info.plist. Are you sure it is a valid Info.Plist file with a REVERSED_CLIENT_ID field?');
    }
}
// Utility function to make REVERSED_CLIENT_ID optional by only proceeding if it exists in Google-Services.plist
function reversedClientIDExists(googleServiceFilePath) {
    try {
        const googleServicePlist = fs_1.default.readFileSync(googleServiceFilePath, 'utf8');
        const googleServiceJson = plist_1.default.parse(googleServicePlist);
        return !!googleServiceJson.REVERSED_CLIENT_ID;
    }
    catch {
        return false;
    }
}
// add phone auth support by configuring recaptcha
// https://github.com/invertase/react-native-firebase/pull/6167
function addUriScheme(config, reversedClientId) {
    if (!config.modResults) {
        config.modResults = {};
    }
    if (!config.modResults.CFBundleURLTypes) {
        config.modResults.CFBundleURLTypes = [];
    }
    const hasReverseClientId = config.modResults.CFBundleURLTypes?.some(urlType => urlType.CFBundleURLSchemes.includes(reversedClientId));
    if (!hasReverseClientId) {
        config.modResults.CFBundleURLTypes.push({
            CFBundleURLSchemes: [reversedClientId],
        });
    }
    return config;
}
function setUrlTypesForCaptcha({ config, }) {
    const googleServicesFileRelativePath = config.ios?.googleServicesFile;
    if (!googleServicesFileRelativePath) {
        throw new Error(`[@react-native-firebase/auth] Your app.json file is missing ios.googleServicesFile. Please add this field.`);
    }
    const googleServiceFilePath = path_1.default.resolve(config.modRequest.projectRoot, googleServicesFileRelativePath);
    if (!fs_1.default.existsSync(googleServiceFilePath)) {
        throw new Error(`[@react-native-firebase/auth] GoogleService-Info.plist doesn't exist in ${googleServiceFilePath}. Place it there or configure the path in app.json`);
    }
    if (reversedClientIDExists(googleServiceFilePath)) {
        const reversedClientId = getReversedClientId(googleServiceFilePath);
        addUriScheme(config, reversedClientId);
    }
    else {
        // eslint-disable-next-line no-console
        console.warn('[@react-native-firebase/auth] REVERSED_CLIENT_ID field not found in GoogleServices-Info.plist. Google Sign-In requires this is - if you need Google Sign-In, enable it and re-download your plist file');
    }
    return config;
}
