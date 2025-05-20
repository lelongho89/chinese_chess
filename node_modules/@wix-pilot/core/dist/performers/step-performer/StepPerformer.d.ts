import { StepPerformerPromptCreator } from "./StepPerformerPromptCreator";
import { CodeEvaluator } from "../../common/CodeEvaluator";
import { CacheHandler } from "../../common/cacheHandler/CacheHandler";
import { SnapshotComparator } from "../../common/snapshot/comparator/SnapshotComparator";
import { CodeEvaluationResult, PreviousStep, PromptHandler, ScreenCapturerResult } from "../../types";
import { ScreenCapturer } from "../../common/snapshot/ScreenCapturer";
export declare class StepPerformer {
    private context;
    private promptCreator;
    private codeEvaluator;
    private promptHandler;
    private cacheHandler;
    private snapshotComparator;
    private screenCapturer;
    private sharedContext;
    constructor(context: any, promptCreator: StepPerformerPromptCreator, codeEvaluator: CodeEvaluator, promptHandler: PromptHandler, cacheHandler: CacheHandler, snapshotComparator: SnapshotComparator, screenCapturer: ScreenCapturer);
    extendJSContext(newContext: any): void;
    private generateCode;
    perform(step: string, previous: PreviousStep[] | undefined, screenCapture: ScreenCapturerResult, maxAttempts?: number): Promise<CodeEvaluationResult>;
}
