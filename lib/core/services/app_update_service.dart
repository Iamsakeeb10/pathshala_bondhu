import 'dart:convert';
import 'dart:io' show Platform;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../network/api_endpoints.dart';
import '../../shared/utils/app_colors.dart';

class AppUpdateService {
  static const String _prefVersionKey = 'last_run_version_code';
  static const MethodChannel _channel = MethodChannel(
    'com.pathshala.bondhu/app_update',
  );

  /// Get device ABI from native Android
  Future<String?> _getDeviceAbi() async {
    if (!Platform.isAndroid) return null;
    try {
      final String? abi = await _channel.invokeMethod('getDeviceAbi');
      print('📱 Device ABI detected: $abi');
      return abi;
    } on PlatformException catch (e) {
      print('❌ Failed to get device ABI: ${e.message}');
      return null;
    } catch (e) {
      print('❌ Error getting device ABI: $e');
      return null;
    }
  }

  /// Check if the app was just updated (version code changed since last run)
  /// This is used to trigger soft resets for local data (like chat cache)
  Future<bool> checkIfAppRecentlyUpdated() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      int currentVersionCode = int.parse(packageInfo.buildNumber);

      final prefs = await SharedPreferences.getInstance();
      final lastRunVersion = prefs.getInt(_prefVersionKey) ?? 0;

      if (currentVersionCode > lastRunVersion) {
        print(
          '🚀 App update detected! (v$lastRunVersion -> v$currentVersionCode)',
        );

        // Update stored version
        await prefs.setInt(_prefVersionKey, currentVersionCode);
        return true;
      }

      return false;
    } catch (e) {
      print('❌ Error checking app version change: $e');
      return false;
    }
  }

  /// Check for app updates from the backend
  Future<Map<String, dynamic>?> checkForUpdate() async {
    try {
      // Get current app version information
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      int currentVersionCode = int.parse(packageInfo.buildNumber);
      String currentVersion = packageInfo.version;

      // Get Android OS version (for Android version targeting)
      int? androidVersion;
      String? deviceAbi;
      if (Platform.isAndroid) {
        DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        // Extract Android version (e.g., "11" from "11.0")
        androidVersion = int.tryParse(
          androidInfo.version.release.split('.').first,
        );

        // Get Device ABI
        deviceAbi = await _getDeviceAbi();
      }

      // Prepare request body
      Map<String, dynamic> requestBody = {
        'current_version_code': currentVersionCode,
        'platform': Platform.isAndroid ? 'android' : 'ios',
        'current_version': currentVersion,
      };

      // Add Android version if available
      if (androidVersion != null) {
        // requestBody['android_version'] = androidVersion;
      }

      // Add Device ABI if available
      if (deviceAbi != null) {
        requestBody['device_abi'] = deviceAbi;
      }

      print('📱 Checking for updates...');
      print('Current Version: $currentVersion (Code: $currentVersionCode)');
      if (androidVersion != null) {
        print('Android Version: $androidVersion');
      }
      if (deviceAbi != null) {
        print('Device ABI: $deviceAbi');
      }

      // Make API request to check for updates using ApiEndpoints
      final response = await http.post(
        Uri.parse(ApiEndpoints.checkAppUpdate),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      print('Response Status: ${response.statusCode}');

      // Check if request was successful
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // Check if response indicates success
        if (responseData['success'] == true) {
          print('✅ Update check successful');

          // Log response data
          final data = responseData['data'];
          print('Update Available: ${data['update_available']}');

          if (data['update_available'] == true) {
            print(
              'Latest Version: ${data['latest_version']['version']} (Code: ${data['latest_version']['version_code']})',
            );
            print('Force Update: ${data['force_update']}');
          }

          return responseData['data'];
        } else {
          print('❌ Update check failed: ${responseData['message']}');
          return null;
        }
      } else if (response.statusCode == 401) {
        print('❌ Unauthorized - Access token may be invalid or expired');
        return null;
      } else {
        print('❌ HTTP Error: ${response.statusCode}');
        print('Response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Error checking for updates: $e');
      return null;
    }
  }

  /// Show update dialog to user
  void showUpdateDialog({
    required BuildContext context,
    required Map<String, dynamic> updateInfo,
    required bool isForceUpdate,
  }) {
    // Calculate file size in MB from bytes if available
    double? fileSizeMB;
    if (updateInfo['latest_version']['file_size'] != null) {
      final bytes = updateInfo['latest_version']['file_size'];
      fileSizeMB = bytes / (1024 * 1024);
    }

    showDialog(
      context: context,
      barrierDismissible: !isForceUpdate,
      builder: (BuildContext context) {
        return PopScope(
          canPop: !isForceUpdate,
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24.r),
            ),
            elevation: 8,
            backgroundColor: AppColors.surfaceLight,
            child: Container(
              constraints: BoxConstraints(maxWidth: 400.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header section with gradient
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 28.h,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isForceUpdate
                            ? [
                                AppColors.error,
                                AppColors.error.withOpacity(0.8),
                              ]
                            : [AppColors.primary, AppColors.primaryDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24.r),
                        topRight: Radius.circular(24.r),
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(16.r),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isForceUpdate
                                ? Icons.warning_rounded
                                : Icons.system_update_rounded,
                            color: AppColors.surfaceLight,
                            size: 48.sp,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          isForceUpdate
                              ? 'Update Required'
                              : 'Update Available',
                          style: TextStyle(
                            color: AppColors.surfaceLight,
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Content section
                  Flexible(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(24.r),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Version info card
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(16.r),
                            decoration: BoxDecoration(
                              color: AppColors.backgroundLight,
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(
                                color: AppColors.primaryLight,
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12.w,
                                        vertical: 6.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        borderRadius: BorderRadius.circular(
                                          8.r,
                                        ),
                                      ),
                                      child: Text(
                                        'v${updateInfo['latest_version']['version']}',
                                        style: TextStyle(
                                          color: AppColors.surfaceLight,
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      'New Version',
                                      style: TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  'Current: ${updateInfo['current_version']}',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 20.h),

                          // Changelog section
                          if (updateInfo['latest_version']['changelog'] !=
                              null) ...[
                            Row(
                              children: [
                                Icon(
                                  Icons.new_releases_rounded,
                                  color: AppColors.primary,
                                  size: 20.sp,
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  'What\'s New',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12.h),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(16.r),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: AppColors.primaryLight,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                updateInfo['latest_version']['changelog'],
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 14.sp,
                                  height: 1.5,
                                ),
                              ),
                            ),
                            SizedBox(height: 16.h),
                          ],

                          // File size
                          if (fileSizeMB != null) ...[
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 8.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.backgroundLight,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.file_download_rounded,
                                    size: 18.sp,
                                    color: AppColors.textSecondary,
                                  ),
                                  SizedBox(width: 6.w),
                                  Text(
                                    'Download size: ${fileSizeMB.toStringAsFixed(1)} MB',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 16.h),
                          ],

                          // Force update warning
                          if (isForceUpdate) ...[
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(16.r),
                              decoration: BoxDecoration(
                                color: AppColors.error.withOpacity(0.08),
                                border: Border.all(
                                  color: AppColors.error.withOpacity(0.3),
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(6.r),
                                    decoration: const BoxDecoration(
                                      color: AppColors.error,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.priority_high_rounded,
                                      color: AppColors.surfaceLight,
                                      size: 16.sp,
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Critical Update',
                                          style: TextStyle(
                                            color: AppColors.error,
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 4.h),
                                        Text(
                                          'This update is mandatory. You must update to continue using the app.',
                                          style: TextStyle(
                                            color: AppColors.textPrimary,
                                            fontSize: 13.sp,
                                            height: 1.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // Action buttons
                  Container(
                    padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 24.h),
                    child: Row(
                      children: [
                        // "Later" button (only if not force update)
                        if (!isForceUpdate) ...[
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.textSecondary,
                                side: BorderSide(
                                  color: AppColors.textSecondary.withOpacity(
                                    0.3,
                                  ),
                                  width: 1.5,
                                ),
                                padding: EdgeInsets.symmetric(vertical: 14.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                              child: Text(
                                'Later',
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                        ],

                        // "Update Now" button
                        Expanded(
                          flex: isForceUpdate ? 1 : 1,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              _downloadAndInstall(
                                updateInfo['latest_version']['download_url'],
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isForceUpdate
                                  ? AppColors.error
                                  : AppColors.primary,
                              foregroundColor: AppColors.surfaceLight,
                              elevation: 0,
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Update Now',
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Icon(Icons.arrow_forward_rounded, size: 18.sp),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Download and install the APK/IPA
  Future<void> _downloadAndInstall(String downloadUrl) async {
    try {
      print('🔽 Opening download URL: $downloadUrl');

      final uri = Uri.parse(downloadUrl);

      // Force external browser
      await launchUrl(uri, mode: LaunchMode.externalApplication);

      print('✅ Download started in browser');
    } catch (e) {
      print('❌ Error launching download URL: $e');
    }
  }
}
