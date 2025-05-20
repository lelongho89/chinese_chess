export declare class PilotError extends Error {
    originalError?: Error | undefined;
    constructor(message: string, originalError?: Error | undefined);
}
