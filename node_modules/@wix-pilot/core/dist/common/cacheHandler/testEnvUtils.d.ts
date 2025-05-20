/**
 * Utility functions for working with Jest
 */
/**
 * Gets the current test file path from the Jest expect API or the stack trace
 * @returns The current Jest test file path, or undefined if not in Jest or the path is not available
 */
export declare function getCurrentTestFilePath(): string | undefined;
