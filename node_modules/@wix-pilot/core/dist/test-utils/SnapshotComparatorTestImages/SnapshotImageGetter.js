"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.getSnapshotImage = void 0;
const path_1 = __importDefault(require("path"));
const imageFileNames = {
    baseline: "baseline.png",
    different: "different.png",
    grayed: "grayed.png",
    very_different_colors: "very_different_colors.png",
    with_text: "with_text.png",
};
const getSnapshotImage = (image) => {
    return path_1.default.resolve(__dirname, ".", imageFileNames[image]);
};
exports.getSnapshotImage = getSnapshotImage;
