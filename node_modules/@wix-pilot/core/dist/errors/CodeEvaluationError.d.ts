import { PilotError } from "../errors/PilotError";
export declare class CodeEvaluationError extends PilotError {
    originalError?: Error | undefined;
    constructor(message: string, originalError?: Error | undefined);
}
