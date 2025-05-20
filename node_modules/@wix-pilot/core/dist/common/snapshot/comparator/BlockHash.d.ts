import { ScreenCapturerResult, SnapshotHashing } from "../../../types";
export declare class BlockHash implements SnapshotHashing {
    private bits;
    constructor(bits?: number);
    hashSnapshot(screenCapture: ScreenCapturerResult): Promise<string | undefined>;
    private calculateBlockHash;
    /**
     * Implementation of the bmvbhash (Block Mean Value Based Hash) algorithm.
     * This is a perceptual hashing algorithm for images that handles non-uniform blocking.
     */
    private bmvbhash;
    /**
     * Simplified version of bmvbhash for images with dimensions evenly divisible by the bit size
     */
    private bmvbhashEven;
    /**
     * Converts block brightness values to bits by comparing to median values
     */
    private translateBlocksToBits;
    /**
     * Converts an array of bits to a hexadecimal string
     */
    private bitsToHexhash;
    private readPNG;
    private median;
    calculateSnapshotDistance(snapshot1: string, snapshot2: string): number;
    areSnapshotsSimilar(snapshot1: string, snapshot2: string): boolean;
}
