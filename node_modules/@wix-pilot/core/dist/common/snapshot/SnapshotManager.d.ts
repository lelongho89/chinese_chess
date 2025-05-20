import { TestingFrameworkDriver } from "../../types";
import { SnapshotComparator } from "./comparator/SnapshotComparator";
export declare class SnapshotManager {
    private driver;
    private snapshotComparator;
    private downscaleImage;
    constructor(driver: TestingFrameworkDriver, snapshotComparator: SnapshotComparator, downscaleImage?: (imagePath: string) => Promise<string>);
    private captureSnapshotsUntilStable;
    private compareSnapshots;
    private captureDownscaledImage;
    captureSnapshotImage(useHighlights: boolean, pollInterval?: number, timeout?: number): Promise<string | undefined>;
    captureViewHierarchyString(): Promise<string>;
}
