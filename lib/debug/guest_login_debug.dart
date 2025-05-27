import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/supabase_auth_service.dart';
import '../services/device_id_service.dart';
import '../global.dart';

/// Debug widget to test guest login functionality step by step
class GuestLoginDebugScreen extends StatefulWidget {
  const GuestLoginDebugScreen({super.key});

  @override
  State<GuestLoginDebugScreen> createState() => _GuestLoginDebugScreenState();
}

class _GuestLoginDebugScreenState extends State<GuestLoginDebugScreen> {
  final List<String> _logs = [];
  bool _isLoading = false;

  void _addLog(String message) {
    setState(() {
      _logs.add('${DateTime.now().toIso8601String()}: $message');
    });
    logger.info(message);
  }

  Future<void> _testDeviceId() async {
    setState(() {
      _isLoading = true;
      _logs.clear();
    });

    try {
      _addLog('🔍 Testing Device ID Service...');
      
      // Test device ID initialization
      await DeviceIdService.instance.initialize();
      _addLog('✅ Device ID Service initialized');
      
      // Test device ID generation
      final deviceId = await DeviceIdService.instance.getDeviceId();
      _addLog('✅ Device ID generated: ${deviceId.substring(0, 8)}...');
      
      // Test device info
      final deviceInfo = await DeviceIdService.instance.getDeviceInfo();
      _addLog('✅ Device info: ${deviceInfo?.toString() ?? 'null'}');
      
    } catch (e, stackTrace) {
      _addLog('❌ Device ID test failed: $e');
      _addLog('Stack trace: $stackTrace');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testSupabaseConnection() async {
    setState(() {
      _isLoading = true;
      _logs.clear();
    });

    try {
      _addLog('🔍 Testing Supabase Connection...');
      
      final authService = Provider.of<SupabaseAuthService>(context, listen: false);
      _addLog('✅ Auth service obtained');
      
      _addLog('🔄 Attempting anonymous sign in...');
      final user = await authService.signInAnonymously();
      
      if (user != null) {
        _addLog('✅ Anonymous sign in successful!');
        _addLog('User ID: ${user.id}');
        _addLog('Is Anonymous: ${user.isAnonymous}');
        _addLog('Email: ${user.email ?? 'N/A'}');
      } else {
        _addLog('❌ Anonymous sign in returned null user');
      }
      
    } catch (e, stackTrace) {
      _addLog('❌ Supabase test failed: $e');
      _addLog('Stack trace: $stackTrace');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testFullGuestLogin() async {
    setState(() {
      _isLoading = true;
      _logs.clear();
    });

    try {
      _addLog('🔍 Testing Full Guest Login Flow...');
      
      // Step 1: Device ID
      _addLog('Step 1: Device ID Service');
      await DeviceIdService.instance.initialize();
      final deviceId = await DeviceIdService.instance.getDeviceId();
      _addLog('✅ Device ID: ${deviceId.substring(0, 8)}...');
      
      // Step 2: Auth Service
      _addLog('Step 2: Auth Service');
      final authService = Provider.of<SupabaseAuthService>(context, listen: false);
      _addLog('✅ Auth service ready');
      
      // Step 3: Anonymous Sign In
      _addLog('Step 3: Anonymous Sign In');
      final user = await authService.signInAnonymously();
      
      if (user != null) {
        _addLog('✅ Guest login successful!');
        _addLog('🎉 Ready to navigate to main screen');
      } else {
        _addLog('❌ Guest login failed - user is null');
      }
      
    } catch (e, stackTrace) {
      _addLog('❌ Full guest login test failed: $e');
      _addLog('Stack trace: $stackTrace');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guest Login Debug'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          // Control buttons
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _testDeviceId,
                        child: const Text('Test Device ID'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _testSupabaseConnection,
                        child: const Text('Test Supabase'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _testFullGuestLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text('Test Full Guest Login'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _logs.clear();
                      });
                    },
                    child: const Text('Clear Logs'),
                  ),
                ),
              ],
            ),
          ),
          
          // Loading indicator
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          
          // Logs display
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8.0),
                color: Colors.grey[50],
              ),
              child: ListView.builder(
                itemCount: _logs.length,
                itemBuilder: (context, index) {
                  final log = _logs[index];
                  Color textColor = Colors.black;
                  
                  if (log.contains('❌')) {
                    textColor = Colors.red;
                  } else if (log.contains('✅')) {
                    textColor = Colors.green;
                  } else if (log.contains('🔍') || log.contains('🔄')) {
                    textColor = Colors.blue;
                  } else if (log.contains('🎉')) {
                    textColor = Colors.purple;
                  }
                  
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Text(
                      log,
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                        color: textColor,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
