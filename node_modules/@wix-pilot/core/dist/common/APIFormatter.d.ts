import { TestingFrameworkAPICatalog, TestingFrameworkAPICatalogCategory, TestingFrameworkAPICatalogItem } from "../types";
export declare class APIFormatter {
    private apiCatalog;
    constructor(apiCatalog: TestingFrameworkAPICatalog);
    /**
     * Formats API method
     */
    formatAPIMethod(method: TestingFrameworkAPICatalogItem): string;
    /**
     * Formats API category with its methods
     */
    formatAPICategory(category: TestingFrameworkAPICatalogCategory): string;
    /**
     * Formats all API methods grouped by categories
     */
    formatAPIInfo(): string;
}
