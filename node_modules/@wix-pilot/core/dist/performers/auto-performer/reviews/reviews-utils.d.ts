import { AutoReviewSectionConfig } from "../../../types";
import { OutputsMapping } from "../../../common/extract/extractTaggedOutputs";
export declare function reviewConfigsToOutputsMapping(reviews: AutoReviewSectionConfig[]): OutputsMapping;
export declare function breakReviewArrayToItsTypes(reviews: AutoReviewSectionConfig[]): string[];
