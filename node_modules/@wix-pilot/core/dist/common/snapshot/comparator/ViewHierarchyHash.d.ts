import { ScreenCapturerResult, SnapshotHashing } from "../../../types";
/**
 * ViewHierarchyHash implements a hashing algorithm for view hierarchies.
 * It uses MD5 to generate a hash of the view hierarchy string.
 */
export declare class ViewHierarchyHash implements SnapshotHashing {
    hashSnapshot(screenCapture: ScreenCapturerResult): Promise<string | undefined>;
    areSnapshotsSimilar(hash1: string, hash2: string): boolean;
}
