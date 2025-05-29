import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:wanzo/core/services/api_client.dart';
import 'package:wanzo/features/auth/models/user.dart';
import 'package:wanzo/features/settings/models/settings.dart';
import 'package:wanzo/features/auth/models/business_sector.dart';

class ProfileApiService {
  final ApiClient _apiClient;

  ProfileApiService(this._apiClient);

  Future<User> getCurrentUserProfile() async {
    final response = await _apiClient.get('/profile');
    return User.fromJson(response);
  }

  Future<User> updateUserProfile({
    required String userId,
    String? name,
    String? email,
    String? phone,
    String? jobTitle,
    String? physicalAddress,
    File? pictureFile,
    String? idCardNumber, // Assuming idCard is a number/string, not a file initially
    // Add other updatable fields from User model as needed
  }) async {
    var request = http.MultipartRequest(
      'PUT',
      Uri.parse('${_apiClient.baseUrl}/profile/$userId'),
    );
    request.headers.addAll(await _apiClient.getHeaders());

    if (name != null) request.fields['name'] = name;
    if (email != null) request.fields['email'] = email;
    if (phone != null) request.fields['phone_number'] = phone; // as per snake_case in User model
    if (jobTitle != null) request.fields['job_title'] = jobTitle;
    if (physicalAddress != null) request.fields['physical_address'] = physicalAddress;
    if (idCardNumber != null) request.fields['id_card'] = idCardNumber;


    if (pictureFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'picture', // API field name for profile picture
          pictureFile.path,
        ),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    final dynamic decodedResponse = _apiClient.handleResponse(response);
    return User.fromJson(decodedResponse as Map<String, dynamic>);
  }
  
  Future<User> updateUserBusinessProfile({
    required String userId,
    String? companyName,
    String? rccmNumber,
    String? companyLocation,
    String? businessSectorId,
    String? businessAddress,
    File? businessLogoFile,
  }) async {
    var request = http.MultipartRequest(
      'PUT',
      Uri.parse('${_apiClient.baseUrl}/profile/$userId/business'), // Assuming a dedicated endpoint
    );
    request.headers.addAll(await _apiClient.getHeaders());

    if (companyName != null) request.fields['company_name'] = companyName;
    if (rccmNumber != null) request.fields['rccm_number'] = rccmNumber;
    if (companyLocation != null) request.fields['company_location'] = companyLocation;
    if (businessSectorId != null) request.fields['business_sector_id'] = businessSectorId;
    if (businessAddress != null) request.fields['business_address'] = businessAddress;

    if (businessLogoFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'business_logo', // API field name for business logo
          businessLogoFile.path,
        ),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    final dynamic decodedResponse = _apiClient.handleResponse(response);
    return User.fromJson(decodedResponse as Map<String, dynamic>);
  }


  Future<Settings> getSettings() async {
    final response = await _apiClient.get('/settings');
    return Settings.fromJson(response);
  }

  Future<Settings> updateSettings(Settings settings, {File? companyLogoFile}) async {
    var request = http.MultipartRequest(
      'PUT',
      Uri.parse('${_apiClient.baseUrl}/settings'),
    );
    request.headers.addAll(await _apiClient.getHeaders());
    
    // Add all non-file fields from settings.toJson()
    settings.toJson().forEach((key, value) {
      if (value != null && key != 'company_logo') { // company_logo handled as file
        request.fields[key] = value.toString();
      }
    });

    if (companyLogoFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'company_logo', // API field name for company logo
          companyLogoFile.path,
        ),
      );
    } else if (settings.companyLogo.isNotEmpty && !settings.companyLogo.startsWith('http')) {
      // If companyLogo is a path and no new file is uploaded, it might mean no change or a URL.
      // If it's a local path and needs to be sent as a string (not typical for updates), handle accordingly.
      // For now, we assume if it's not a new file, the existing URL (if any) is preserved or handled by backend.
      // If the existing companyLogo is a URL, we don't need to re-send it unless it's being cleared.
      // If it's a placeholder for a new upload but no file is provided, the backend should handle it.
    }


    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    final dynamic decodedResponse = _apiClient.handleResponse(response);
    return Settings.fromJson(decodedResponse as Map<String, dynamic>);
  }

  Future<List<BusinessSector>> getBusinessSectors() async {
    final response = await _apiClient.get('/business-sectors');
    final List<dynamic> decodedResponse = response as List<dynamic>;
    return decodedResponse.map((json) => BusinessSector.fromJson(json as Map<String, dynamic>)).toList();
  }
}
