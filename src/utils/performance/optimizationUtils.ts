import { useCallback, useEffect, useRef } from 'react';

/**
 * A utility to log component renders in development mode.
 * @param componentName The name of the component to track
 * @param props The props to log (optional)
 */
export const useRenderLogger = (componentName: string, props?: any) => {
  if (__DEV__) {
    console.log(`[Render] ${componentName}`, props ? props : '');
  }
};

/**
 * A utility to measure and log the render time of a component.
 * @param componentName The name of the component to measure
 * @param threshold The threshold in ms to log a warning (default: 16ms - one frame at 60fps)
 */
export const useRenderTime = (componentName: string, threshold = 16) => {
  const startTimeRef = useRef<number>(performance.now());
  
  useEffect(() => {
    if (__DEV__) {
      const endTime = performance.now();
      const renderTime = endTime - startTimeRef.current;
      
      if (renderTime > threshold) {
        console.warn(`[Slow Render] ${componentName} took ${renderTime.toFixed(2)}ms to render`);
      } else {
        console.log(`[Render Time] ${componentName} took ${renderTime.toFixed(2)}ms to render`);
      }
    }
    
    return () => {
      startTimeRef.current = performance.now();
    };
  });
};

/**
 * A utility to track prop changes between renders.
 * @param componentName The name of the component to track
 * @param props The current props object
 */
export const usePropChangeLogger = (componentName: string, props: Record<string, any>) => {
  const prevPropsRef = useRef<Record<string, any>>({});
  
  useEffect(() => {
    if (__DEV__) {
      const prevProps = prevPropsRef.current;
      const changedProps: Record<string, { from: any, to: any }> = {};
      
      // Check which props have changed
      Object.keys(props).forEach(key => {
        if (prevProps[key] !== props[key]) {
          changedProps[key] = {
            from: prevProps[key],
            to: props[key]
          };
        }
      });
      
      // Check for removed props
      Object.keys(prevProps).forEach(key => {
        if (!(key in props)) {
          changedProps[key] = {
            from: prevProps[key],
            to: undefined
          };
        }
      });
      
      if (Object.keys(changedProps).length > 0) {
        console.log(`[Props Changed] ${componentName}:`, changedProps);
      }
      
      // Update the ref
      prevPropsRef.current = { ...props };
    }
  });
};

/**
 * A utility to create a stable callback that doesn't change on every render.
 * Similar to useCallback but with automatic dependency tracking.
 * @param callback The callback function to stabilize
 * @returns A stable callback function
 */
export function useStableCallback<T extends (...args: any[]) => any>(callback: T): T {
  const callbackRef = useRef<T>(callback);
  
  useEffect(() => {
    callbackRef.current = callback;
  });
  
  return useCallback(
    ((...args) => callbackRef.current(...args)) as T,
    []
  );
}

/**
 * A utility to create a debounced version of a function.
 * @param fn The function to debounce
 * @param delay The delay in ms
 * @returns A debounced function
 */
export function useDebounce<T extends (...args: any[]) => any>(
  fn: T,
  delay: number
): (...args: Parameters<T>) => void {
  const timeoutRef = useRef<NodeJS.Timeout | null>(null);
  
  const debouncedFn = useCallback(
    (...args: Parameters<T>) => {
      if (timeoutRef.current) {
        clearTimeout(timeoutRef.current);
      }
      
      timeoutRef.current = setTimeout(() => {
        fn(...args);
      }, delay);
    },
    [fn, delay]
  );
  
  useEffect(() => {
    return () => {
      if (timeoutRef.current) {
        clearTimeout(timeoutRef.current);
      }
    };
  }, []);
  
  return debouncedFn;
}

/**
 * A utility to create a throttled version of a function.
 * @param fn The function to throttle
 * @param limit The time limit in ms
 * @returns A throttled function
 */
export function useThrottle<T extends (...args: any[]) => any>(
  fn: T,
  limit: number
): (...args: Parameters<T>) => void {
  const lastRunRef = useRef<number>(0);
  const timeoutRef = useRef<NodeJS.Timeout | null>(null);
  
  const throttledFn = useCallback(
    (...args: Parameters<T>) => {
      const now = Date.now();
      
      if (now - lastRunRef.current >= limit) {
        lastRunRef.current = now;
        fn(...args);
      } else if (timeoutRef.current === null) {
        timeoutRef.current = setTimeout(() => {
          lastRunRef.current = Date.now();
          timeoutRef.current = null;
          fn(...args);
        }, limit - (now - lastRunRef.current));
      }
    },
    [fn, limit]
  );
  
  useEffect(() => {
    return () => {
      if (timeoutRef.current) {
        clearTimeout(timeoutRef.current);
      }
    };
  }, []);
  
  return throttledFn;
}

/**
 * A utility to measure the execution time of a function.
 * @param fn The function to measure
 * @param fnName The name of the function (for logging)
 * @returns A wrapped function that logs execution time
 */
export function measureExecutionTime<T extends (...args: any[]) => any>(
  fn: T,
  fnName: string
): (...args: Parameters<T>) => ReturnType<T> {
  return (...args: Parameters<T>): ReturnType<T> => {
    if (!__DEV__) {
      return fn(...args);
    }
    
    const start = performance.now();
    const result = fn(...args);
    const end = performance.now();
    
    console.log(`[Execution Time] ${fnName} took ${(end - start).toFixed(2)}ms`);
    
    return result;
  };
}

export default {
  useRenderLogger,
  useRenderTime,
  usePropChangeLogger,
  useStableCallback,
  useDebounce,
  useThrottle,
  measureExecutionTime,
};
