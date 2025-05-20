import type { LocaleDirection } from '@react-navigation/native';
import * as React from 'react';
import { Animated, type StyleProp, type ViewProps, type ViewStyle } from 'react-native';
import type { EdgeInsets } from 'react-native-safe-area-context';
import type { GestureDirection, Layout, StackCardStyleInterpolator, TransitionSpec } from '../../types';
type Props = ViewProps & {
    interpolationIndex: number;
    opening: boolean;
    closing: boolean;
    next?: Animated.AnimatedInterpolation<number>;
    current: Animated.AnimatedInterpolation<number>;
    gesture: Animated.Value;
    layout: Layout;
    insets: EdgeInsets;
    direction: LocaleDirection;
    pageOverflowEnabled: boolean;
    gestureDirection: GestureDirection;
    onOpen: () => void;
    onClose: () => void;
    onTransition: (props: {
        closing: boolean;
        gesture: boolean;
    }) => void;
    onGestureBegin: () => void;
    onGestureCanceled: () => void;
    onGestureEnd: () => void;
    children: React.ReactNode;
    overlay: (props: {
        style: Animated.WithAnimatedValue<StyleProp<ViewStyle>>;
    }) => React.ReactNode;
    overlayEnabled: boolean;
    shadowEnabled: boolean;
    gestureEnabled: boolean;
    gestureResponseDistance?: number;
    gestureVelocityImpact: number;
    transitionSpec: {
        open: TransitionSpec;
        close: TransitionSpec;
    };
    preloaded: boolean;
    styleInterpolator: StackCardStyleInterpolator;
    containerStyle?: StyleProp<ViewStyle>;
    contentStyle?: StyleProp<ViewStyle>;
};
export declare class Card extends React.Component<Props> {
    static defaultProps: {
        shadowEnabled: boolean;
        gestureEnabled: boolean;
        gestureVelocityImpact: number;
        overlay: ({ style, }: {
            style: Animated.WithAnimatedValue<StyleProp<ViewStyle>>;
        }) => import("react/jsx-runtime").JSX.Element | null;
    };
    componentDidMount(): void;
    componentDidUpdate(prevProps: Props): void;
    componentWillUnmount(): void;
    private isCurrentlyMounted;
    private isClosing;
    private inverted;
    private layout;
    private isSwiping;
    private interactionHandle;
    private pendingGestureCallback;
    private lastToValue;
    private animate;
    private getAnimateToValue;
    private setPointerEventsEnabled;
    private handleStartInteraction;
    private handleEndInteraction;
    private handleGestureStateChange;
    private getInterpolatedStyle;
    private getCardAnimation;
    private gestureActivationCriteria;
    private ref;
    render(): import("react/jsx-runtime").JSX.Element;
}
export {};
//# sourceMappingURL=Card.d.ts.map