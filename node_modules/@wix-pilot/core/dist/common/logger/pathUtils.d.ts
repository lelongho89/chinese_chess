/**
 * Finds the project root directory by searching upwards from the startPath
 * for a directory containing a 'package.json' file.
 *
 * @param startPath - The starting file or directory path.
 * @returns The absolute path to the project root directory, or null if not found.
 */
export declare function findProjectRoot(startPath: string): string | null;
/**
 * Calculates the relative path from a root path to a file path.
 *
 * @param filePath - The absolute path to the file.
 * @param rootPath - The absolute path to the root directory.
 * @returns The relative path.
 */
export declare function getRelativePath(filePath: string, rootPath: string): string;
