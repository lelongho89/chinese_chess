import { SnapshotManager } from "./SnapshotManager";
import { PromptHandler, ScreenCapturerResult } from "../../types";
export declare class ScreenCapturer {
    private snapshotManager;
    private promptHandler;
    constructor(snapshotManager: SnapshotManager, promptHandler: PromptHandler);
    capture(useHighlights: boolean): Promise<ScreenCapturerResult>;
}
