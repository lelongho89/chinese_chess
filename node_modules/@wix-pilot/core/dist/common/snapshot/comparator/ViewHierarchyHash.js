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
exports.ViewHierarchyHash = void 0;
const crypto = __importStar(require("crypto"));
/**
 * ViewHierarchyHash implements a hashing algorithm for view hierarchies.
 * It uses MD5 to generate a hash of the view hierarchy string.
 */
class ViewHierarchyHash {
    async hashSnapshot(screenCapture) {
        if (!screenCapture.viewHierarchy) {
            return undefined;
        }
        return crypto
            .createHash("md5")
            .update(screenCapture.viewHierarchy)
            .digest("hex");
    }
    areSnapshotsSimilar(hash1, hash2) {
        if (!hash1 || !hash2) {
            return false;
        }
        return hash1 === hash2;
    }
}
exports.ViewHierarchyHash = ViewHierarchyHash;
