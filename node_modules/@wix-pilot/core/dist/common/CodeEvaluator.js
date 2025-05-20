"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.CodeEvaluator = void 0;
const CodeEvaluationError_1 = require("../errors/CodeEvaluationError");
const logger_1 = __importDefault(require("../common/logger"));
class CodeEvaluator {
    async evaluate(code, context, sharedContext = {}) {
        const asyncFunction = this.createAsyncFunction(code, context, sharedContext);
        try {
            const result = await asyncFunction();
            logger_1.default.labeled("EVAL").info("Code executed successfully\n", {
                message: `${code}`,
                isBold: false,
                color: "gray",
            });
            return { code, result, sharedContext };
        }
        catch (error) {
            const errorMessage = error instanceof Error ? error.message : String(error);
            logger_1.default.labeled("ERROR").error(`Execution failed: ${errorMessage}`);
            throw error;
        }
    }
    createAsyncFunction(code, context, sharedContext) {
        try {
            const contextValues = Object.values(context);
            // Wrap the code in an immediately-invoked async function expression (IIFE), and inject context variables into the function
            return new Function(...Object.keys(context), "sharedContext", `return (async () => { 
              ${code}
            })();`).bind(null, ...contextValues, sharedContext);
        }
        catch (error) {
            const underlyingErrorMessage = error?.message;
            throw new CodeEvaluationError_1.CodeEvaluationError(`Failed to execute test step code, error: ${underlyingErrorMessage}:\n\`\`\`\n${code}\n\`\`\``);
        }
    }
}
exports.CodeEvaluator = CodeEvaluator;
