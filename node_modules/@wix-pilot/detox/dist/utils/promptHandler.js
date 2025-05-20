"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.PromptHandler = void 0;
const axios_1 = __importDefault(require("axios"));
const fs_1 = require("fs");
class PromptHandler {
    async uploadImage(imagePath) {
        const image = await fs_1.promises.readFile(imagePath);
        try {
            const response = await axios_1.default.post("https://bo.wix.com/mobile-infra-ai-services/v1/image-upload", {
                image,
            });
            const imageUrl = response.data.url;
            if (!imageUrl) {
                throw new Error(`Cannot find uploaded URL, got response: ${JSON.stringify(response.data)}`);
            }
            return imageUrl;
        }
        catch (error) {
            console.error("Error while uploading image:", error);
            throw error;
        }
    }
    async runPrompt(prompt, imagePath) {
        if (!imagePath) {
            try {
                const response = await axios_1.default.post("https://bo.wix.com/mobile-infra-ai-services/v1/prompt", {
                    prompt,
                    model: "SONNET_3_5",
                    ownershipTag: "Detox OSS",
                    project: "Detox OSS",
                    images: [],
                });
                const generatedText = response.data.generatedTexts[0];
                if (!generatedText) {
                    throw new Error(`Failed to generate text, got response: ${JSON.stringify(response.data)}`);
                }
                return generatedText;
            }
            catch (error) {
                console.error("Error running prompt:", error);
                throw error;
            }
        }
        const imageUrl = await this.uploadImage(imagePath);
        try {
            const response = await axios_1.default.post("https://bo.wix.com/mobile-infra-ai-services/v1/prompt", {
                prompt,
                model: "SONNET_3_5",
                ownershipTag: "Detox OSS",
                project: "Detox OSS",
                images: [imageUrl],
            });
            const generatedText = response.data.generatedTexts[0];
            if (!generatedText) {
                throw new Error(`Failed to generate text, got response: ${JSON.stringify(response.data)}`);
            }
            return generatedText;
        }
        catch (error) {
            console.error("Error running prompt:", error);
            throw error;
        }
    }
    isSnapshotImageSupported() {
        return true;
    }
}
exports.PromptHandler = PromptHandler;
