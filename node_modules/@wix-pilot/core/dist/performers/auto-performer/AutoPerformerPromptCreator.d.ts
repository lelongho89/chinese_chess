import { AutoPreviousStep, AutoReviewSectionConfig } from "../../types";
export declare class AutoPerformerPromptCreator {
    constructor();
    createPrompt(goal: string, viewHierarchy: string, isSnapshotImageAttached: boolean, previousSteps: AutoPreviousStep[], reviewTypes?: AutoReviewSectionConfig[]): string;
    private createBasePrompt;
    private createContext;
    private createInstructions;
    private createStepByStepInstructions;
    private isPreviousStepError;
    private generateReviewSections;
}
