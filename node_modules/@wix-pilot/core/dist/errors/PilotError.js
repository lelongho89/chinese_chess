"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.PilotError = void 0;
class PilotError extends Error {
    originalError;
    constructor(message, originalError) {
        super(message);
        this.originalError = originalError;
        this.name = "PilotError";
    }
}
exports.PilotError = PilotError;
