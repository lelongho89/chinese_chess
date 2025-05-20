"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const path_1 = __importDefault(require("path"));
const os_1 = __importDefault(require("os"));
const logger_1 = __importDefault(require("../../common/logger"));
const fs_1 = require("fs");
const pngjs_1 = require("pngjs");
const MAX_PIXELS = 2000000;
async function downscaleImage(imagePath) {
    try {
        if (!(0, fs_1.existsSync)(imagePath)) {
            return imagePath;
        }
        const readPNG = () => {
            return new Promise((resolve, reject) => {
                const png = new pngjs_1.PNG();
                try {
                    (0, fs_1.createReadStream)(imagePath)
                        .pipe(png)
                        .on("parsed", () => {
                        resolve(png);
                    })
                        .on("error", reject);
                }
                catch (error) {
                    reject(error);
                }
            });
        };
        const sourceImage = await readPNG();
        const originalWidth = sourceImage.width;
        const originalHeight = sourceImage.height;
        const originalTotalPixels = originalWidth * originalHeight;
        if (originalTotalPixels <= MAX_PIXELS) {
            return imagePath;
        }
        const aspectRatio = originalWidth / originalHeight;
        const newHeight = Math.sqrt(MAX_PIXELS / aspectRatio);
        const newWidth = newHeight * aspectRatio;
        const targetWidth = Math.round(newWidth);
        const targetHeight = Math.round(newHeight);
        const targetImage = new pngjs_1.PNG({
            width: targetWidth,
            height: targetHeight,
            filterType: -1,
        });
        for (let y = 0; y < targetHeight; y++) {
            for (let x = 0; x < targetWidth; x++) {
                const srcX = Math.floor((x * originalWidth) / targetWidth);
                const srcY = Math.floor((y * originalHeight) / targetHeight);
                const srcIdx = (srcY * originalWidth + srcX) * 4;
                const targetIdx = (y * targetWidth + x) * 4;
                targetImage.data[targetIdx] = sourceImage.data[srcIdx];
                targetImage.data[targetIdx + 1] = sourceImage.data[srcIdx + 1];
                targetImage.data[targetIdx + 2] = sourceImage.data[srcIdx + 2];
                targetImage.data[targetIdx + 3] = sourceImage.data[srcIdx + 3];
            }
        }
        const parsedPath = path_1.default.parse(imagePath);
        parsedPath.dir = os_1.default.tmpdir();
        parsedPath.name += "_downscaled";
        parsedPath.ext = ".png";
        const downscaledPath = path_1.default.format(parsedPath);
        await new Promise((resolve, reject) => {
            const writeStream = (0, fs_1.createWriteStream)(downscaledPath);
            targetImage
                .pack()
                .pipe(writeStream)
                .on("finish", () => resolve())
                .on("error", reject);
        });
        return downscaledPath;
    }
    catch (err) {
        logger_1.default.error({
            message: `Error processing image: ${err}`,
            isBold: false,
            color: "gray",
        });
        return imagePath;
    }
}
exports.default = downscaleImage;
