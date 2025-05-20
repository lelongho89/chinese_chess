"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.truncateString = truncateString;
function truncateString(str, limit = 2000) {
    if (str.length <= limit) {
        return str;
    }
    else {
        return str.slice(0, limit) + "...";
    }
}
