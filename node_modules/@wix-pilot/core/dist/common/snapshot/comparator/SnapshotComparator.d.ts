import { ScreenCapturerResult, SnapshotHashes } from "../../../types";
/**
 * SnapshotComparator manages different hashing algorithms for comparing snapshots.
 * It can register and use multiple algorithms like BlockHash and ViewHierarchyHash.
 */
export declare class SnapshotComparator {
    private readonly hashingAlgorithms;
    constructor();
    /**
     * Generate hashes for a snapshot using all registered algorithms
     * @param screenCapture The screen capture result
     * @returns Object with hash values from each registered algorithm
     */
    generateHashes(screenCapture: ScreenCapturerResult): Promise<SnapshotHashes>;
    /**
     * Compare two sets of snapshot hashes to determine if they're similar
     * A match is found if any common algorithm between current and cached hashes shows a match
     * @param newSnapshot New snapshot hashes
     * @param cachedSnapshot Cached snapshot hashes (might be partial with fewer algorithms)
     * @returns True if snapshots are considered similar according to any matching algorithm
     */
    compareSnapshot(newSnapshot?: SnapshotHashes, cachedSnapshot?: Partial<SnapshotHashes>): boolean;
}
