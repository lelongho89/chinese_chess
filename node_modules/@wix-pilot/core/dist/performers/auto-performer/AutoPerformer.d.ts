import { AutoPerformerPromptCreator } from "./AutoPerformerPromptCreator";
import { AutoPreviousStep, AutoReport, AutoReviewSectionConfig, AutoStepReport } from "../../types/auto";
import { PromptHandler, ScreenCapturerResult } from "../../types";
import { StepPerformer } from "../../performers/step-performer/StepPerformer";
import { ScreenCapturer } from "../../common/snapshot/ScreenCapturer";
import { CacheHandler } from "../../common/cacheHandler/CacheHandler";
import { SnapshotComparator } from "../../common/snapshot/comparator/SnapshotComparator";
export declare class AutoPerformer {
    private promptCreator;
    private stepPerformer;
    private promptHandler;
    private screenCapturer;
    private cacheHandler;
    private snapshotComparator;
    constructor(promptCreator: AutoPerformerPromptCreator, stepPerformer: StepPerformer, promptHandler: PromptHandler, screenCapturer: ScreenCapturer, cacheHandler: CacheHandler, snapshotComparator: SnapshotComparator);
    private extractReviewOutput;
    private formatReviewSection;
    analyseScreenAndCreatePilotStep(goal: string, previousSteps: AutoPreviousStep[], screenCapture: ScreenCapturerResult, reviewSectionTypes?: AutoReviewSectionConfig[], maxAttempts?: number): Promise<AutoStepReport>;
    perform(goal: string, reviewSectionTypes?: AutoReviewSectionConfig[]): Promise<AutoReport>;
    private logReviews;
    private getValueFromCache;
}
