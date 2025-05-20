"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.ScreenCapturer = void 0;
const logger_1 = __importDefault(require("../../common/logger"));
class ScreenCapturer {
    snapshotManager;
    promptHandler;
    constructor(snapshotManager, promptHandler) {
        this.snapshotManager = snapshotManager;
        this.promptHandler = promptHandler;
    }
    async capture(useHighlights) {
        const progress = logger_1.default.startProgress({
            actionLabel: "CAPTURE",
            successLabel: "CAPTURED",
            failureLabel: "FAILED",
        }, "Taking screenshot of current screen");
        try {
            const shouldCaptureSnapshot = this.promptHandler.isSnapshotImageSupported();
            const [snapshot, viewHierarchy] = await Promise.all([
                shouldCaptureSnapshot
                    ? this.snapshotManager.captureSnapshotImage(useHighlights)
                    : Promise.resolve(undefined),
                this.snapshotManager.captureViewHierarchyString(),
            ]);
            progress.stop("success", "Screenshot captured successfully");
            return {
                snapshot,
                viewHierarchy: viewHierarchy,
            };
        }
        catch (error) {
            const errorMessage = error instanceof Error ? error.message : String(error);
            progress.stop("failure", `Screen capture failed: ${errorMessage}`);
            throw error;
        }
    }
}
exports.ScreenCapturer = ScreenCapturer;
