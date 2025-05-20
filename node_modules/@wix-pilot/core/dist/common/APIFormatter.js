"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.APIFormatter = void 0;
class APIFormatter {
    apiCatalog;
    constructor(apiCatalog) {
        this.apiCatalog = apiCatalog;
    }
    /**
     * Formats API method
     */
    formatAPIMethod(method) {
        const methodInfo = [
            `#### ${method.signature}`,
            "",
            method.description,
            "",
            "##### Example",
            "",
            "```",
            method.example,
            "```",
            "",
        ];
        if (method.guidelines && method.guidelines.length > 0) {
            methodInfo.push("##### Guidelines", "", ...method.guidelines.map((g) => `- ${g}`), "");
        }
        return methodInfo.join("\n");
    }
    /**
     * Formats API category with its methods
     */
    formatAPICategory(category) {
        return [
            `### ${category.title}`,
            "",
            ...category.items.map((item) => this.formatAPIMethod(item)),
        ].join("\n");
    }
    /**
     * Formats all API methods grouped by categories
     */
    formatAPIInfo() {
        return this.apiCatalog.categories
            .map((category) => this.formatAPICategory(category))
            .join("\n");
    }
}
exports.APIFormatter = APIFormatter;
