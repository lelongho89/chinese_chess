"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.SnapshotManager = void 0;
const DEFAULT_POLL_INTERVAL = 500; // ms
const DEFAULT_TIMEOUT = 5000; // ms
class SnapshotManager {
    driver;
    snapshotComparator;
    downscaleImage;
    constructor(driver, snapshotComparator, downscaleImage = (imagePath) => Promise.resolve(imagePath)) {
        this.driver = driver;
        this.snapshotComparator = snapshotComparator;
        this.downscaleImage = downscaleImage;
    }
    async captureSnapshotsUntilStable(captureFunc, compareFunc, pollInterval = DEFAULT_POLL_INTERVAL, timeout = DEFAULT_TIMEOUT) {
        const startTime = Date.now();
        let lastSnapshot;
        while (Date.now() - startTime < timeout) {
            const currentSnapshot = await captureFunc();
            if (!currentSnapshot) {
                return undefined;
            }
            if (lastSnapshot) {
                const isStable = await compareFunc(currentSnapshot, lastSnapshot);
                if (isStable) {
                    return currentSnapshot;
                }
            }
            lastSnapshot = currentSnapshot;
            await new Promise((resolve) => setTimeout(resolve, pollInterval));
        }
        // Return the last snapshot if timeout is reached
        return lastSnapshot;
    }
    async compareSnapshots(current, last) {
        const currentHash = await this.snapshotComparator.generateHashes({
            snapshot: current,
        });
        const lastHash = await this.snapshotComparator.generateHashes({
            snapshot: last,
        });
        return this.snapshotComparator.compareSnapshot(currentHash, lastHash);
    }
    async captureDownscaledImage(useHighlights) {
        const imagePath = await this.driver.captureSnapshotImage(useHighlights);
        if (imagePath) {
            return await this.downscaleImage(imagePath);
        }
        return undefined;
    }
    async captureSnapshotImage(useHighlights, pollInterval, timeout) {
        return this.driver.driverConfig.useSnapshotStabilitySync
            ? await this.captureSnapshotsUntilStable(async () => this.captureDownscaledImage(useHighlights), async (current, last) => this.compareSnapshots(current, last), pollInterval, timeout)
            : await this.captureDownscaledImage(useHighlights);
    }
    async captureViewHierarchyString() {
        return await this.driver.captureViewHierarchyString();
    }
}
exports.SnapshotManager = SnapshotManager;
