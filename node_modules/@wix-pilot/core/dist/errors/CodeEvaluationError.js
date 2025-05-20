"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.CodeEvaluationError = void 0;
const PilotError_1 = require("../errors/PilotError");
class CodeEvaluationError extends PilotError_1.PilotError {
    originalError;
    constructor(message, originalError) {
        super(message, originalError);
        this.originalError = originalError;
        this.name = "CodeEvaluationError";
    }
}
exports.CodeEvaluationError = CodeEvaluationError;
