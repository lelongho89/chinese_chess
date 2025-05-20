"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.SnapshotComparator = void 0;
const BlockHash_1 = require("./BlockHash");
const ViewHierarchyHash_1 = require("./ViewHierarchyHash");
/**
 * SnapshotComparator manages different hashing algorithms for comparing snapshots.
 * It can register and use multiple algorithms like BlockHash and ViewHierarchyHash.
 */
class SnapshotComparator {
    hashingAlgorithms;
    constructor() {
        this.hashingAlgorithms = new Map([
            ["BlockHash", new BlockHash_1.BlockHash(16)],
            ["ViewHierarchyHash", new ViewHierarchyHash_1.ViewHierarchyHash()],
        ]);
    }
    /**
     * Generate hashes for a snapshot using all registered algorithms
     * @param screenCapture The screen capture result
     * @returns Object with hash values from each registered algorithm
     */
    async generateHashes(screenCapture) {
        const hashPromises = Array.from(this.hashingAlgorithms.entries()).map(async ([algorithm, implementation]) => {
            const hash = await implementation.hashSnapshot(screenCapture);
            return [algorithm, hash];
        });
        const hashEntries = await Promise.all(hashPromises);
        // Filter out any undefined hashes
        const filteredEntries = hashEntries.filter(([_, hash]) => !!hash);
        return Object.fromEntries(filteredEntries);
    }
    /**
     * Compare two sets of snapshot hashes to determine if they're similar
     * A match is found if any common algorithm between current and cached hashes shows a match
     * @param newSnapshot New snapshot hashes
     * @param cachedSnapshot Cached snapshot hashes (might be partial with fewer algorithms)
     * @returns True if snapshots are considered similar according to any matching algorithm
     */
    compareSnapshot(newSnapshot, cachedSnapshot) {
        const hasNewSnapshot = !!(newSnapshot && Object.keys(newSnapshot).length > 0);
        const hasCachedSnapshot = !!(cachedSnapshot && Object.keys(cachedSnapshot).length > 0);
        // Both empty -> match, one empty -> no match
        if (!hasNewSnapshot || !hasCachedSnapshot) {
            return !hasNewSnapshot && !hasCachedSnapshot;
        }
        // Find common algorithms between the two snapshot hash sets, and check if any of them match
        const commonAlgorithms = Object.keys(newSnapshot).filter((algorithm) => algorithm in cachedSnapshot);
        if (commonAlgorithms.length === 0) {
            return false;
        }
        for (const algorithmName of commonAlgorithms) {
            const algorithm = this.hashingAlgorithms.get(algorithmName);
            if (!algorithm) {
                continue;
            }
            const newHash = newSnapshot[algorithmName];
            const cachedHash = cachedSnapshot[algorithmName];
            if (!newHash || !cachedHash) {
                continue;
            }
            const isMatch = algorithm.areSnapshotsSimilar(newHash, cachedHash);
            if (isMatch) {
                return true;
            }
        }
        return false;
    }
}
exports.SnapshotComparator = SnapshotComparator;
