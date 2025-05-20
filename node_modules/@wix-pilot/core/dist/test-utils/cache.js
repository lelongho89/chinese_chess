"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.mockCache = exports.mockedCacheFile = void 0;
const fs_1 = __importDefault(require("fs"));
const mockCache = (data = undefined) => {
    exports.mockedCacheFile = data;
    fs_1.default.writeFileSync.mockImplementation((filePath, data) => {
        exports.mockedCacheFile = JSON.parse(data);
    });
    fs_1.default.readFileSync.mockReturnValue(JSON.stringify(exports.mockedCacheFile));
    fs_1.default.existsSync.mockReturnValue(exports.mockedCacheFile !== undefined);
};
exports.mockCache = mockCache;
