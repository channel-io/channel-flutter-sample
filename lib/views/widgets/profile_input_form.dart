import 'package:flutter/material.dart';
import '../../constants/texts.dart';
import '../common/common_input_field.dart';

class ProfileInputForm extends StatelessWidget {
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final TextEditingController mobileNumberController;
  final bool isEnabled;
  final bool showRequiredFields;
  final bool showOptionalFields;

  const ProfileInputForm({
    super.key,
    required this.firstNameController,
    required this.lastNameController,
    required this.emailController,
    required this.mobileNumberController,
    this.isEnabled = true,
    this.showRequiredFields = true,
    this.showOptionalFields = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Required Fields Section
        if (showRequiredFields) ...[
          Text(
            AppTexts.requiredFields,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // Last Name (Family name)
              Expanded(
                child: CommonInputField(
                  controller: lastNameController,
                  enabled: isEnabled,
                  labelText: AppTexts.lastName,
                  hintText: AppTexts.enterLastName,
                  isRequired: true,
                  errorText: lastNameController.text.isEmpty && !isEnabled
                      ? 'Required'
                      : null,
                ),
              ),
              const SizedBox(width: 8),
              // First Name (Given name)
              Expanded(
                child: CommonInputField(
                  controller: firstNameController,
                  enabled: isEnabled,
                  labelText: AppTexts.firstName,
                  hintText: AppTexts.enterFirstName,
                  isRequired: true,
                  errorText: firstNameController.text.isEmpty && !isEnabled
                      ? 'Required'
                      : null,
                ),
              ),
            ],
          ),
        ],

        // Optional Fields Section
        if (showOptionalFields) ...[
          const SizedBox(height: 16),
          Text(
            AppTexts.optionalFields,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),

          // Email
          CommonInputField(
            controller: emailController,
            enabled: isEnabled,
            keyboardType: TextInputType.emailAddress,
            labelText: AppTexts.email,
            hintText: AppTexts.enterEmail,
            prefixIcon: Icons.email_outlined,
          ),

          const SizedBox(height: 8),

          // Mobile Number
          CommonInputField(
            controller: mobileNumberController,
            enabled: isEnabled,
            keyboardType: TextInputType.phone,
            labelText: AppTexts.mobileNumber,
            hintText: AppTexts.enterMobileNumber,
            prefixIcon: Icons.phone_outlined,
          ),
        ],
      ],
    );
  }

  /// Combine first and last name to create full name (for UI display)
  String getFullName() {
    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();
    return '$firstName $lastName'.trim();
  }

  /// Return profile data as Map
  Map<String, dynamic> getProfileData() {
    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();
    final email = emailController.text.trim();
    final mobileNumber = mobileNumberController.text.trim();

    final profile = <String, dynamic>{};

    // Set name as firstName + " " + lastName
    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      profile['name'] = '$firstName $lastName';
    }

    // Add individual fields
    if (firstName.isNotEmpty) {
      profile['firstName'] = firstName;
    }
    if (lastName.isNotEmpty) {
      profile['lastName'] = lastName;
    }
    if (email.isNotEmpty) {
      profile['email'] = email;
    }
    if (mobileNumber.isNotEmpty) {
      profile['mobileNumber'] = mobileNumber;
    }

    return profile;
  }

  /// Check if all required fields are filled
  bool isRequiredFieldsValid() {
    return firstNameController.text.trim().isNotEmpty &&
        lastNameController.text.trim().isNotEmpty;
  }

  /// Initialize form data
  void clearForm() {
    setFormData(); // Clear all fields with null values
  }

  /// Set form data
  void setFormData({
    String? firstName,
    String? lastName,
    String? email,
    String? mobileNumber,
  }) {
    firstNameController.text = firstName ?? '';
    lastNameController.text = lastName ?? '';
    emailController.text = email ?? '';
    mobileNumberController.text = mobileNumber ?? '';
  }
}
