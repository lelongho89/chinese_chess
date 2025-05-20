import { PreviousStep, TestingFrameworkAPICatalog, TestingFrameworkAPICatalogCategory } from "../../types";
export declare class StepPerformerPromptCreator {
    readonly apiCatalog: TestingFrameworkAPICatalog;
    private apiFormatter;
    constructor(apiCatalog: TestingFrameworkAPICatalog);
    extendAPICategories(newCategories: TestingFrameworkAPICatalogCategory[]): void;
    private mergeCategories;
    createPrompt(intent: string, viewHierarchy: string, isSnapshotImageAttached: boolean, previousSteps: PreviousStep[]): string;
    private createBasePrompt;
    private createContext;
    private createAPIInfo;
    private createInstructions;
    private createStepByStepInstructions;
    private previousStepResultOrError;
}
