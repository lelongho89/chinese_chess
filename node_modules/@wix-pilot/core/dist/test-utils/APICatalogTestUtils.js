"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.promptCreatorConstructorMockAPI = exports.dummyBarContext2 = exports.dummyBarContext1 = exports.dummyContext = exports.barCategory2 = exports.barCategory1 = exports.bazCategory = void 0;
exports.bazCategory = {
    title: "Custom Actions",
    items: [
        {
            signature: "swipe(direction: string)",
            description: "Swipes in the specified direction.",
            example: 'await swipe("up");',
            guidelines: ["Use this method to scroll the screen."],
        },
    ],
};
exports.barCategory1 = {
    title: "Actions",
    items: [
        {
            signature: "tapButton(id: string)",
            description: "Taps the button with the specified ID.",
            example: 'await tapButton("submit");',
            guidelines: ["Use this method to tap buttons."],
        },
    ],
};
exports.barCategory2 = {
    title: "Actions",
    items: [
        {
            signature: "swipe(direction: string)",
            description: "Swipes in the specified direction.",
            example: 'await swipe("up");',
            guidelines: ["Use this method to scroll the screen."],
        },
    ],
};
exports.dummyContext = { foo: jest.fn() };
exports.dummyBarContext1 = { bar: jest.fn() };
exports.dummyBarContext2 = { bar: jest.fn() };
exports.promptCreatorConstructorMockAPI = {
    context: {},
    name: "Test Framework",
    description: "A testing framework for unit testing purposes",
    categories: [
        {
            title: "Actions",
            items: [
                {
                    signature: "tap(element: Element)",
                    description: "Taps on the specified element.",
                    example: 'await element(by.id("button")).tap();',
                    guidelines: [
                        "Ensure the element is tappable before using this method.",
                    ],
                },
                {
                    signature: "typeText(element: Element, text: string)",
                    description: "Types the specified text into the element.",
                    example: 'await element(by.id("input")).typeText("Hello, World!");',
                    guidelines: ["Use this method only on text input elements."],
                },
            ],
        },
        {
            title: "Assertions",
            items: [
                {
                    signature: "toBeVisible()",
                    description: "Asserts that the element is visible on the screen.",
                    example: 'await expect(element(by.id("title"))).toBeVisible();',
                    guidelines: ["Consider scroll position when using this assertion."],
                },
            ],
        },
        {
            title: "Assertions",
            items: [
                {
                    signature: "toBeEnabled()",
                    description: "Asserts that the element is enabled and can be interacted with.",
                    example: 'await expect(element(by.id("submitButton"))).toBeEnabled();',
                    guidelines: [
                        "Ensure that the element is not disabled before performing actions.",
                    ],
                },
            ],
        },
        {
            title: "Matchers",
            items: [
                {
                    signature: "by.id(id: string)",
                    description: "Matches elements by their ID attribute.",
                    example: 'element(by.id("uniqueId"))',
                    guidelines: [
                        "Use unique IDs for elements to avoid conflicts, combine with atIndex() if necessary.",
                    ],
                },
            ],
        },
        {
            title: "Actions",
            items: [
                {
                    signature: "swipe(direction: string)",
                    description: "Swipes in the specified direction.",
                    example: 'await swipe("up");',
                    guidelines: ["Use this method to scroll the screen."],
                },
            ],
        },
    ],
};
