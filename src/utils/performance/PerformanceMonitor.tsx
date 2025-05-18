import React, { useEffect, useState } from 'react';
import { View, Text, StyleSheet, TouchableOpacity, ScrollView } from 'react-native';
import { InteractionManager } from 'react-native';

interface PerformanceMetrics {
  renderTime: number;
  jsThreadTime: number;
  layoutTime: number;
  memoryUsage: number;
  fps: number;
}

interface PerformanceMonitorProps {
  enabled?: boolean;
  sampleInterval?: number;
  historySize?: number;
}

/**
 * A component that monitors and displays performance metrics for the app.
 * This should only be used in development builds.
 */
export const PerformanceMonitor: React.FC<PerformanceMonitorProps> = ({
  enabled = __DEV__,
  sampleInterval = 1000,
  historySize = 60,
}) => {
  const [visible, setVisible] = useState(false);
  const [metrics, setMetrics] = useState<PerformanceMetrics[]>([]);
  const [isRunning, setIsRunning] = useState(true);

  useEffect(() => {
    if (!enabled) return;

    let frameCount = 0;
    let lastFrameTime = performance.now();
    let intervalId: NodeJS.Timeout;

    const calculateFPS = () => {
      const now = performance.now();
      const elapsed = now - lastFrameTime;
      const fps = Math.round((frameCount * 1000) / elapsed);
      frameCount = 0;
      lastFrameTime = now;
      return fps;
    };

    const measurePerformance = () => {
      if (!isRunning) return;

      const startTime = performance.now();

      // Measure JS thread time
      InteractionManager.runAfterInteractions(() => {
        const jsThreadTime = performance.now() - startTime;

        // Get memory usage if available
        const memoryUsage = (global as any).performance?.memory?.usedJSHeapSize || 0;

        // Calculate FPS
        const fps = calculateFPS();

        // Add new metrics
        setMetrics((prevMetrics) => {
          const newMetrics = [
            ...prevMetrics,
            {
              renderTime: performance.now() - startTime,
              jsThreadTime,
              layoutTime: 0, // This is harder to measure accurately
              memoryUsage,
              fps,
            },
          ];

          // Keep only the last N entries
          if (newMetrics.length > historySize) {
            return newMetrics.slice(newMetrics.length - historySize);
          }
          return newMetrics;
        });
      });
    };

    // Set up animation frame callback for FPS counting
    const animationFrameCallback = () => {
      frameCount++;
      if (isRunning) {
        requestAnimationFrame(animationFrameCallback);
      }
    };

    // Start measuring
    if (isRunning) {
      intervalId = setInterval(measurePerformance, sampleInterval);
      requestAnimationFrame(animationFrameCallback);
    }

    return () => {
      clearInterval(intervalId);
      setIsRunning(false);
    };
  }, [enabled, sampleInterval, historySize, isRunning]);

  if (!enabled || !visible) {
    return (
      <TouchableOpacity
        style={styles.toggleButton}
        onPress={() => setVisible(true)}
      >
        <Text style={styles.toggleButtonText}>📊</Text>
      </TouchableOpacity>
    );
  }

  // Calculate averages
  const averages = metrics.length > 0
    ? {
        renderTime: metrics.reduce((sum, m) => sum + m.renderTime, 0) / metrics.length,
        jsThreadTime: metrics.reduce((sum, m) => sum + m.jsThreadTime, 0) / metrics.length,
        fps: metrics.reduce((sum, m) => sum + m.fps, 0) / metrics.length,
        memoryUsage: metrics[metrics.length - 1].memoryUsage,
      }
    : { renderTime: 0, jsThreadTime: 0, fps: 0, memoryUsage: 0 };

  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.title}>Performance Monitor</Text>
        <TouchableOpacity onPress={() => setVisible(false)}>
          <Text style={styles.closeButton}>✕</Text>
        </TouchableOpacity>
      </View>

      <View style={styles.metricsContainer}>
        <View style={styles.metricRow}>
          <Text style={styles.metricLabel}>FPS:</Text>
          <Text style={[
            styles.metricValue,
            averages.fps < 30 ? styles.warning : (averages.fps < 50 ? styles.caution : styles.good)
          ]}>
            {averages.fps.toFixed(1)}
          </Text>
        </View>

        <View style={styles.metricRow}>
          <Text style={styles.metricLabel}>JS Thread:</Text>
          <Text style={[
            styles.metricValue,
            averages.jsThreadTime > 16 ? styles.warning : styles.good
          ]}>
            {averages.jsThreadTime.toFixed(2)} ms
          </Text>
        </View>

        <View style={styles.metricRow}>
          <Text style={styles.metricLabel}>Render Time:</Text>
          <Text style={[
            styles.metricValue,
            averages.renderTime > 16 ? styles.warning : styles.good
          ]}>
            {averages.renderTime.toFixed(2)} ms
          </Text>
        </View>

        <View style={styles.metricRow}>
          <Text style={styles.metricLabel}>Memory:</Text>
          <Text style={styles.metricValue}>
            {(averages.memoryUsage / (1024 * 1024)).toFixed(2)} MB
          </Text>
        </View>
      </View>

      <View style={styles.controls}>
        <TouchableOpacity
          style={[styles.button, isRunning ? styles.activeButton : {}]}
          onPress={() => setIsRunning(!isRunning)}
        >
          <Text style={styles.buttonText}>{isRunning ? 'Pause' : 'Resume'}</Text>
        </TouchableOpacity>
        
        <TouchableOpacity
          style={styles.button}
          onPress={() => setMetrics([])}
        >
          <Text style={styles.buttonText}>Reset</Text>
        </TouchableOpacity>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    position: 'absolute',
    bottom: 50,
    right: 10,
    backgroundColor: 'rgba(0, 0, 0, 0.8)',
    borderRadius: 10,
    padding: 10,
    width: 200,
    zIndex: 9999,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 10,
  },
  title: {
    color: 'white',
    fontWeight: 'bold',
    fontSize: 14,
  },
  closeButton: {
    color: 'white',
    fontSize: 16,
  },
  metricsContainer: {
    marginBottom: 10,
  },
  metricRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: 5,
  },
  metricLabel: {
    color: 'white',
    fontSize: 12,
  },
  metricValue: {
    color: 'white',
    fontSize: 12,
    fontWeight: 'bold',
  },
  good: {
    color: '#4CAF50',
  },
  caution: {
    color: '#FFC107',
  },
  warning: {
    color: '#F44336',
  },
  controls: {
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  button: {
    backgroundColor: '#2196F3',
    padding: 5,
    borderRadius: 5,
    flex: 1,
    marginHorizontal: 2,
    alignItems: 'center',
  },
  activeButton: {
    backgroundColor: '#F44336',
  },
  buttonText: {
    color: 'white',
    fontSize: 12,
  },
  toggleButton: {
    position: 'absolute',
    bottom: 10,
    right: 10,
    backgroundColor: 'rgba(0, 0, 0, 0.5)',
    width: 40,
    height: 40,
    borderRadius: 20,
    justifyContent: 'center',
    alignItems: 'center',
    zIndex: 9999,
  },
  toggleButtonText: {
    color: 'white',
    fontSize: 20,
  },
});

export default PerformanceMonitor;
