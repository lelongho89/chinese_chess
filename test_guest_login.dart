import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:chinese_chess/global.dart';
import 'package:chinese_chess/supabase_client.dart';
import 'package:chinese_chess/services/device_id_service.dart';
import 'package:chinese_chess/models/supabase_auth_service.dart';
import 'package:chinese_chess/models/user_repository.dart';

/// Simple test script to debug guest login functionality
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🔍 Testing Guest Login Functionality...\n');
  
  try {
    // 1. Load environment variables
    print('1. Loading environment variables...');
    await dotenv.load(fileName: '.env');
    print('   ✅ Environment loaded');
    
    // 2. Initialize Supabase
    print('2. Initializing Supabase...');
    await SupabaseClientWrapper.initialize();
    print('   ✅ Supabase initialized');
    
    // 3. Initialize Device ID Service
    print('3. Initializing Device ID Service...');
    await DeviceIdService.instance.initialize();
    print('   ✅ Device ID Service initialized');
    
    // 4. Test Device ID Generation
    print('4. Testing Device ID generation...');
    final deviceId = await DeviceIdService.instance.getDeviceId();
    print('   ✅ Device ID: ${deviceId.substring(0, 8)}...');
    
    // 5. Test Auth Service Initialization
    print('5. Initializing Auth Service...');
    final authService = await SupabaseAuthService.getInstance();
    print('   ✅ Auth Service initialized');
    
    // 6. Test Anonymous Sign In
    print('6. Testing anonymous sign in...');
    final user = await authService.signInAnonymously();
    
    if (user != null) {
      print('   ✅ Anonymous sign in successful!');
      print('   User ID: ${user.id}');
      print('   Is Anonymous: ${user.isAnonymous}');
      print('   Email: ${user.email ?? 'N/A'}');
      
      // 7. Test User Repository
      print('7. Testing user repository...');
      final userModel = await UserRepository.instance.get(user.id);
      if (userModel != null) {
        print('   ✅ User found in database');
        print('   Display Name: ${userModel.displayName}');
        print('   Device ID: ${userModel.deviceId ?? 'N/A'}');
        print('   Is Anonymous: ${userModel.isAnonymous}');
      } else {
        print('   ⚠️ User not found in database (this might be expected)');
      }
      
      // 8. Test Sign Out
      print('8. Testing sign out...');
      await authService.signOut();
      print('   ✅ Sign out successful');
      
    } else {
      print('   ❌ Anonymous sign in failed - user is null');
    }
    
    print('\n🎉 Guest login test completed successfully!');
    
  } catch (e, stackTrace) {
    print('\n❌ Error during guest login test:');
    print('Error: $e');
    print('Stack trace: $stackTrace');
    
    // Try to identify the specific issue
    if (e.toString().contains('SUPABASE_URL')) {
      print('\n💡 Suggestion: Check your .env file for SUPABASE_URL');
    } else if (e.toString().contains('device_id')) {
      print('\n💡 Suggestion: Check device ID service implementation');
    } else if (e.toString().contains('database')) {
      print('\n💡 Suggestion: Check database schema and permissions');
    } else if (e.toString().contains('auth')) {
      print('\n💡 Suggestion: Check Supabase auth configuration');
    }
  }
}
