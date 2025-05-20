import { TestingFrameworkAPICatalog, TestingFrameworkDriver, TestingFrameworkDriverConfig } from "@wix-pilot/core";
/**
 * Pilot driver for the Detox testing framework.
 */
export declare class DetoxFrameworkDriver implements TestingFrameworkDriver {
    private _detox;
    /**
     * Creates a new Detox driver instance.
     * @param detox optional Detox instance to use, if not provided, it will be imported from the
     *  `detox` package (peer dependency). The reason for this parameter is to allow usage from the Detox package itself.
     */
    constructor(detox?: any);
    private get detox();
    get driverConfig(): TestingFrameworkDriverConfig;
    captureViewHierarchyString(): Promise<string>;
    captureSnapshotImage(_: boolean): Promise<string | undefined>;
    get apiCatalog(): TestingFrameworkAPICatalog;
}
