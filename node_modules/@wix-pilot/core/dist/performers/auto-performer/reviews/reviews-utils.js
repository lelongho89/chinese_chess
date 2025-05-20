"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.reviewConfigsToOutputsMapping = reviewConfigsToOutputsMapping;
exports.breakReviewArrayToItsTypes = breakReviewArrayToItsTypes;
function reviewConfigsToOutputsMapping(reviews) {
    return reviews.reduce((pilotStep, review) => {
        const { title } = review;
        return {
            ...pilotStep,
            [title]: { tag: title.toUpperCase(), isRequired: true },
        };
    }, {});
}
function breakReviewArrayToItsTypes(reviews) {
    return reviews.map((review) => review.title);
}
