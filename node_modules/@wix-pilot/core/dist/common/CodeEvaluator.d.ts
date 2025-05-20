import { CodeEvaluationResult } from "../types";
export declare class CodeEvaluator {
    evaluate(code: string, context: any, sharedContext?: Record<string, any>): Promise<CodeEvaluationResult>;
    private createAsyncFunction;
}
