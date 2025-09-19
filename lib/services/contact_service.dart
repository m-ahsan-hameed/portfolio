import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

Future<http.Response> sendEmails({
  required BuildContext context,
  required String name,
  required String email,
  required String message,
}) async {
  const serviceId = 'service_hymepyj';
  const templateId = 'template_1ulo96f';
  const publicKey = "5uMgN-J3AcV8jasSF";

  final uri = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
  final response = await http.post(
    uri,
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      'service_id': serviceId,
      'template_id': templateId,
      'user_id': publicKey,
      'template_params': {
        // Add your template parameters here
        'from_name': name,
        'from_email': email,
        'message': message,
      },
    }),
  );

  return response;
  ;
}
