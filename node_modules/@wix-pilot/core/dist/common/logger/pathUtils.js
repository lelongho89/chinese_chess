"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.findProjectRoot = findProjectRoot;
exports.getRelativePath = getRelativePath;
const path = __importStar(require("path"));
const fs = __importStar(require("fs"));
/**
 * Finds the project root directory by searching upwards from the startPath
 * for a directory containing a 'package.json' file.
 *
 * @param startPath - The starting file or directory path.
 * @returns The absolute path to the project root directory, or null if not found.
 */
function findProjectRoot(startPath) {
    let currentDir = path.dirname(startPath); // Start from the directory containing the file
    const root = path.parse(currentDir).root;
    while (currentDir !== root) {
        const packageJsonPath = path.join(currentDir, "package.json");
        if (fs.existsSync(packageJsonPath)) {
            return currentDir;
        }
        const parentDir = path.dirname(currentDir);
        if (parentDir === currentDir) {
            break;
        }
        currentDir = parentDir;
    }
    const packageJsonPath = path.join(currentDir, "package.json");
    if (fs.existsSync(packageJsonPath)) {
        return currentDir;
    }
    return null;
}
/**
 * Calculates the relative path from a root path to a file path.
 *
 * @param filePath - The absolute path to the file.
 * @param rootPath - The absolute path to the root directory.
 * @returns The relative path.
 */
function getRelativePath(filePath, rootPath) {
    return path.relative(rootPath, filePath);
}
