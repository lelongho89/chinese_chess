import { LoggerMessageComponent } from "../../../types/logger";
/**
 * Parses text with markdown-like formatting and converts it to logger message components:
 * - Regular text will be displayed in gray (default color)
 * - *Text between single asterisks* will be displayed in white
 * - **Text between double asterisks** will be displayed bold in gray
 * - ***Text between triple asterisks*** will be displayed bold in white
 *
 * @param text The text with formatting to parse
 * @returns An array of LoggerMessageComponents with correct formatting
 */
export declare function parseFormattedText(text: string): LoggerMessageComponent[];
