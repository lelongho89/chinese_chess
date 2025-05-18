"use strict";

import Color from 'color';
import * as React from 'react';
import { Animated, InteractionManager, Platform, StyleSheet, View } from 'react-native';
import { CardAnimationContext } from "../../utils/CardAnimationContext.js";
import { getDistanceForDirection } from "../../utils/getDistanceForDirection.js";
import { getInvertedMultiplier } from "../../utils/getInvertedMultiplier.js";
import { getShadowStyle } from "../../utils/getShadowStyle.js";
import { memoize } from "../../utils/memoize.js";
import { GestureState, PanGestureHandler } from '../GestureHandler';
import { CardSheet } from "./CardSheet.js";
import { jsx as _jsx, jsxs as _jsxs } from "react/jsx-runtime";
const GESTURE_VELOCITY_IMPACT = 0.3;
const TRUE = 1;
const FALSE = 0;

/**
 * The distance of touch start from the edge of the screen where the gesture will be recognized
 */
const GESTURE_RESPONSE_DISTANCE_HORIZONTAL = 50;
const GESTURE_RESPONSE_DISTANCE_VERTICAL = 135;
const useNativeDriver = Platform.OS !== 'web';
const hasOpacityStyle = style => {
  if (style) {
    const flattenedStyle = StyleSheet.flatten(style);
    return flattenedStyle.opacity != null;
  }
  return false;
};
export class Card extends React.Component {
  static defaultProps = {
    shadowEnabled: false,
    gestureEnabled: true,
    gestureVelocityImpact: GESTURE_VELOCITY_IMPACT,
    overlay: ({
      style
    }) => style ? /*#__PURE__*/_jsx(Animated.View, {
      pointerEvents: "none",
      style: [styles.overlay, style]
    }) : null
  };
  componentDidMount() {
    if (!this.props.preloaded) {
      this.animate({
        closing: this.props.closing
      });
    }
    this.isCurrentlyMounted = true;
  }
  componentDidUpdate(prevProps) {
    const {
      gesture,
      direction,
      layout,
      gestureDirection,
      opening,
      closing
    } = this.props;
    const {
      width,
      height
    } = layout;
    if (width !== prevProps.layout.width) {
      this.layout.width.setValue(width);
    }
    if (height !== prevProps.layout.height) {
      this.layout.height.setValue(height);
    }
    if (gestureDirection !== prevProps.gestureDirection) {
      this.inverted.setValue(getInvertedMultiplier(gestureDirection, direction === 'rtl'));
    }
    const toValue = this.getAnimateToValue(this.props);
    if (this.getAnimateToValue(prevProps) !== toValue || this.lastToValue !== toValue) {
      // We need to trigger the animation when route was closed
      // The route might have been closed by a `POP` action or by a gesture
      // When route was closed due to a gesture, the animation would've happened already
      // It's still important to trigger the animation so that `onClose` is called
      // If `onClose` is not called, cleanup step won't be performed for gestures
      this.animate({
        closing
      });
    } else if (opening && !prevProps.opening) {
      // This can happen when screen somewhere below in the stack comes into focus via rearranging
      // Also reset the animated value to make sure that the animation starts from the beginning
      gesture.setValue(getDistanceForDirection(layout, gestureDirection, direction === 'rtl'));
      this.animate({
        closing
      });
    }
  }
  componentWillUnmount() {
    this.props.gesture?.stopAnimation();
    this.isCurrentlyMounted = false;
    this.handleEndInteraction();
  }
  isCurrentlyMounted = false;
  isClosing = new Animated.Value(FALSE);
  inverted = new Animated.Value(getInvertedMultiplier(this.props.gestureDirection, this.props.direction === 'rtl'));
  layout = {
    width: new Animated.Value(this.props.layout.width),
    height: new Animated.Value(this.props.layout.height)
  };
  isSwiping = new Animated.Value(FALSE);
  animate = ({
    closing,
    velocity
  }) => {
    const {
      transitionSpec,
      onOpen,
      onClose,
      onTransition,
      gesture
    } = this.props;
    const toValue = this.getAnimateToValue({
      ...this.props,
      closing
    });
    this.lastToValue = toValue;
    this.isClosing.setValue(closing ? TRUE : FALSE);
    const spec = closing ? transitionSpec.close : transitionSpec.open;
    const animation = spec.animation === 'spring' ? Animated.spring : Animated.timing;
    this.setPointerEventsEnabled(!closing);
    this.handleStartInteraction();
    clearTimeout(this.pendingGestureCallback);
    onTransition?.({
      closing,
      gesture: velocity !== undefined
    });
    animation(gesture, {
      ...spec.config,
      velocity,
      toValue,
      useNativeDriver,
      isInteraction: false
    }).start(({
      finished
    }) => {
      this.handleEndInteraction();
      clearTimeout(this.pendingGestureCallback);
      if (finished) {
        if (closing) {
          onClose();
        } else {
          onOpen();
        }
        if (this.isCurrentlyMounted) {
          // Make sure to re-open screen if it wasn't removed
          this.forceUpdate();
        }
      }
    });
  };
  getAnimateToValue = ({
    closing,
    layout,
    gestureDirection,
    direction,
    preloaded
  }) => {
    if (!closing && !preloaded) {
      return 0;
    }
    return getDistanceForDirection(layout, gestureDirection, direction === 'rtl');
  };
  setPointerEventsEnabled = enabled => {
    const pointerEvents = enabled ? 'box-none' : 'none';
    this.ref.current?.setPointerEvents(pointerEvents);
  };
  handleStartInteraction = () => {
    if (this.interactionHandle === undefined) {
      this.interactionHandle = InteractionManager.createInteractionHandle();
    }
  };
  handleEndInteraction = () => {
    if (this.interactionHandle !== undefined) {
      InteractionManager.clearInteractionHandle(this.interactionHandle);
      this.interactionHandle = undefined;
    }
  };
  handleGestureStateChange = ({
    nativeEvent
  }) => {
    const {
      direction,
      layout,
      onClose,
      onGestureBegin,
      onGestureCanceled,
      onGestureEnd,
      gestureDirection,
      gestureVelocityImpact
    } = this.props;
    switch (nativeEvent.state) {
      case GestureState.ACTIVE:
        this.isSwiping.setValue(TRUE);
        this.handleStartInteraction();
        onGestureBegin?.();
        break;
      case GestureState.CANCELLED:
      case GestureState.FAILED:
        {
          this.isSwiping.setValue(FALSE);
          this.handleEndInteraction();
          const velocity = gestureDirection === 'vertical' || gestureDirection === 'vertical-inverted' ? nativeEvent.velocityY : nativeEvent.velocityX;
          this.animate({
            closing: this.props.closing,
            velocity
          });
          onGestureCanceled?.();
          break;
        }
      case GestureState.END:
        {
          this.isSwiping.setValue(FALSE);
          let distance;
          let translation;
          let velocity;
          if (gestureDirection === 'vertical' || gestureDirection === 'vertical-inverted') {
            distance = layout.height;
            translation = nativeEvent.translationY;
            velocity = nativeEvent.velocityY;
          } else {
            distance = layout.width;
            translation = nativeEvent.translationX;
            velocity = nativeEvent.velocityX;
          }
          const closing = (translation + velocity * gestureVelocityImpact) * getInvertedMultiplier(gestureDirection, direction === 'rtl') > distance / 2 ? velocity !== 0 || translation !== 0 : this.props.closing;
          this.animate({
            closing,
            velocity
          });
          if (closing) {
            // We call onClose with a delay to make sure that the animation has already started
            // This will make sure that the state update caused by this doesn't affect start of animation
            this.pendingGestureCallback = setTimeout(() => {
              onClose();

              // Trigger an update after we dispatch the action to remove the screen
              // This will make sure that we check if the screen didn't get removed so we can cancel the animation
              this.forceUpdate();
            }, 32);
          }
          onGestureEnd?.();
          break;
        }
    }
  };

  // Memoize this to avoid extra work on re-render
  getInterpolatedStyle = memoize((styleInterpolator, animation) => styleInterpolator(animation));

  // Keep track of the animation context when deps changes.
  getCardAnimation = memoize((interpolationIndex, current, next, layout, insetTop, insetRight, insetBottom, insetLeft) => ({
    index: interpolationIndex,
    current: {
      progress: current
    },
    next: next && {
      progress: next
    },
    closing: this.isClosing,
    swiping: this.isSwiping,
    inverted: this.inverted,
    layouts: {
      screen: layout
    },
    insets: {
      top: insetTop,
      right: insetRight,
      bottom: insetBottom,
      left: insetLeft
    }
  }));
  gestureActivationCriteria() {
    const {
      direction,
      layout,
      gestureDirection,
      gestureResponseDistance
    } = this.props;
    const enableTrackpadTwoFingerGesture = true;
    const distance = gestureResponseDistance !== undefined ? gestureResponseDistance : gestureDirection === 'vertical' || gestureDirection === 'vertical-inverted' ? GESTURE_RESPONSE_DISTANCE_VERTICAL : GESTURE_RESPONSE_DISTANCE_HORIZONTAL;
    if (gestureDirection === 'vertical') {
      return {
        maxDeltaX: 15,
        minOffsetY: 5,
        hitSlop: {
          bottom: -layout.height + distance
        },
        enableTrackpadTwoFingerGesture
      };
    } else if (gestureDirection === 'vertical-inverted') {
      return {
        maxDeltaX: 15,
        minOffsetY: -5,
        hitSlop: {
          top: -layout.height + distance
        },
        enableTrackpadTwoFingerGesture
      };
    } else {
      const hitSlop = -layout.width + distance;
      const invertedMultiplier = getInvertedMultiplier(gestureDirection, direction === 'rtl');
      if (invertedMultiplier === 1) {
        return {
          minOffsetX: 5,
          maxDeltaY: 20,
          hitSlop: {
            right: hitSlop
          },
          enableTrackpadTwoFingerGesture
        };
      } else {
        return {
          minOffsetX: -5,
          maxDeltaY: 20,
          hitSlop: {
            left: hitSlop
          },
          enableTrackpadTwoFingerGesture
        };
      }
    }
  }
  ref = /*#__PURE__*/React.createRef();
  render() {
    const {
      styleInterpolator,
      interpolationIndex,
      current,
      gesture,
      next,
      layout,
      insets,
      overlay,
      overlayEnabled,
      shadowEnabled,
      gestureEnabled,
      gestureDirection,
      pageOverflowEnabled,
      children,
      containerStyle: customContainerStyle,
      contentStyle,
      /* eslint-disable @typescript-eslint/no-unused-vars */
      closing,
      direction,
      gestureResponseDistance,
      gestureVelocityImpact,
      onClose,
      onGestureBegin,
      onGestureCanceled,
      onGestureEnd,
      onOpen,
      onTransition,
      transitionSpec,
      /* eslint-enable @typescript-eslint/no-unused-vars */
      ...rest
    } = this.props;
    const interpolationProps = this.getCardAnimation(interpolationIndex, current, next, layout, insets.top, insets.right, insets.bottom, insets.left);
    const interpolatedStyle = this.getInterpolatedStyle(styleInterpolator, interpolationProps);
    const {
      containerStyle,
      cardStyle,
      overlayStyle,
      shadowStyle
    } = interpolatedStyle;
    const handleGestureEvent = gestureEnabled ? Animated.event([{
      nativeEvent: gestureDirection === 'vertical' || gestureDirection === 'vertical-inverted' ? {
        translationY: gesture
      } : {
        translationX: gesture
      }
    }], {
      useNativeDriver
    }) : undefined;
    const {
      backgroundColor
    } = StyleSheet.flatten(contentStyle || {});
    const isTransparent = typeof backgroundColor === 'string' ? Color(backgroundColor).alpha() === 0 : false;
    return /*#__PURE__*/_jsxs(CardAnimationContext.Provider, {
      value: interpolationProps,
      children: [/*#__PURE__*/_jsx(Animated.View, {
        style: {
          // This is a dummy style that doesn't actually change anything visually.
          // Animated needs the animated value to be used somewhere, otherwise things don't update properly.
          // If we disable animations and hide header, it could end up making the value unused.
          // So we have this dummy style that will always be used regardless of what else changed.
          opacity: current
        }
        // Make sure that this view isn't removed. If this view is removed, our style with animated value won't apply
        ,
        collapsable: false
      }), /*#__PURE__*/_jsxs(View, {
        pointerEvents: "box-none"
        // Make sure this view is not removed on the new architecture, as it causes focus loss during navigation on Android.
        // This can happen when the view flattening results in different trees - due to `overflow` style changing in a parent.
        ,
        collapsable: false,
        ...rest,
        children: [overlayEnabled ? /*#__PURE__*/_jsx(View, {
          pointerEvents: "box-none",
          style: StyleSheet.absoluteFill,
          children: overlay({
            style: overlayStyle
          })
        }) : null, /*#__PURE__*/_jsx(Animated.View, {
          style: [styles.container, containerStyle, customContainerStyle],
          pointerEvents: "box-none",
          children: /*#__PURE__*/_jsx(PanGestureHandler, {
            enabled: layout.width !== 0 && gestureEnabled,
            onGestureEvent: handleGestureEvent,
            onHandlerStateChange: this.handleGestureStateChange,
            ...this.gestureActivationCriteria(),
            children: /*#__PURE__*/_jsxs(Animated.View, {
              needsOffscreenAlphaCompositing: hasOpacityStyle(cardStyle),
              style: [styles.container, cardStyle],
              children: [shadowEnabled && shadowStyle && !isTransparent ? /*#__PURE__*/_jsx(Animated.View, {
                style: [styles.shadow, gestureDirection === 'horizontal' ? [styles.shadowHorizontal, styles.shadowStart] : gestureDirection === 'horizontal-inverted' ? [styles.shadowHorizontal, styles.shadowEnd] : gestureDirection === 'vertical' ? [styles.shadowVertical, styles.shadowTop] : [styles.shadowVertical, styles.shadowBottom], {
                  backgroundColor
                }, shadowStyle],
                pointerEvents: "none"
              }) : null, /*#__PURE__*/_jsx(CardSheet, {
                ref: this.ref,
                enabled: pageOverflowEnabled,
                layout: layout,
                style: contentStyle,
                children: children
              })]
            })
          })
        })]
      })]
    });
  }
}
const styles = StyleSheet.create({
  container: {
    flex: 1
  },
  overlay: {
    flex: 1,
    backgroundColor: '#000'
  },
  shadow: {
    position: 'absolute'
  },
  shadowHorizontal: {
    top: 0,
    bottom: 0,
    width: 3,
    ...getShadowStyle({
      offset: {
        width: -1,
        height: 1
      },
      radius: 5,
      opacity: 0.3
    })
  },
  shadowStart: {
    start: 0
  },
  shadowEnd: {
    end: 0
  },
  shadowVertical: {
    start: 0,
    end: 0,
    height: 3,
    ...getShadowStyle({
      offset: {
        width: 1,
        height: -1
      },
      radius: 5,
      opacity: 0.3
    })
  },
  shadowTop: {
    top: 0
  },
  shadowBottom: {
    bottom: 0
  }
});
//# sourceMappingURL=Card.js.map