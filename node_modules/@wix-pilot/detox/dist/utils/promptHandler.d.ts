export declare class PromptHandler {
    uploadImage(imagePath: string): Promise<string>;
    runPrompt(prompt: string, imagePath?: string): Promise<string>;
    isSnapshotImageSupported(): boolean;
}
