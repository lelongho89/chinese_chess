import * as React from 'react';
import { type ViewProps } from 'react-native';
export type CardSheetRef = {
    setPointerEvents: React.Dispatch<ViewProps['pointerEvents']>;
};
export declare const CardSheet: React.ForwardRefExoticComponent<ViewProps & {
    enabled: boolean;
    layout: {
        width: number;
        height: number;
    };
    children: React.ReactNode;
} & React.RefAttributes<CardSheetRef>>;
//# sourceMappingURL=CardSheet.d.ts.map