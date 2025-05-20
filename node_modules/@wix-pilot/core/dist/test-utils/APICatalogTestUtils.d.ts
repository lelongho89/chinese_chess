import { TestingFrameworkAPICatalog } from "../types";
export declare const bazCategory: {
    title: string;
    items: {
        signature: string;
        description: string;
        example: string;
        guidelines: string[];
    }[];
};
export declare const barCategory1: {
    title: string;
    items: {
        signature: string;
        description: string;
        example: string;
        guidelines: string[];
    }[];
};
export declare const barCategory2: {
    title: string;
    items: {
        signature: string;
        description: string;
        example: string;
        guidelines: string[];
    }[];
};
export declare const dummyContext: {
    foo: jest.Mock<any, any, any>;
};
export declare const dummyBarContext1: {
    bar: jest.Mock<any, any, any>;
};
export declare const dummyBarContext2: {
    bar: jest.Mock<any, any, any>;
};
export declare const promptCreatorConstructorMockAPI: TestingFrameworkAPICatalog;
