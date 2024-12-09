import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_flutter_app/providers/auth_provider.dart';
import 'package:recipe_flutter_app/screens/home_screen.dart';
import 'package:recipe_flutter_app/screens/navigation_screen.dart';
import 'package:recipe_flutter_app/services/api_services.dart';
import 'package:recipe_flutter_app/utils.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String email;

  const OTPVerificationScreen({required this.email, super.key});

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final otpController = TextEditingController();
  late AuthProvider authProvider;
  Timer? timer;
  int start = 30;
  bool isResendButtonDisabled = true;

  @override
  void initState() {
    startTimer();
    super.initState();
  }

  @override
  void dispose() {
    otpController.dispose();
    timer!.cancel();
    super.dispose();
  }

  startTimer() {
    setState(() {
      start = 30;
      isResendButtonDisabled = true;
    });

    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (start == 0) {
          timer.cancel();
          isResendButtonDisabled = false;
        } else {
          start--;
        }
      });
    });
  }

  verifyOtp() async {
    try {
      await authProvider.signup(widget.email, otpController.text.trim());

      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => NavigationScreen()));
    } catch (e) {
      showSnackbar("Error while verifying OTP", context);
    }
  }

  resendOTP() async {
    try {
      await ApiService().resendOTP(widget.email);
      startTimer();
    } catch (e) {
      showSnackbar("Error while refetching OTP", context);
    }
  }

  @override
  Widget build(BuildContext context) {
    authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TextField(
            controller: otpController,
            decoration: InputDecoration(
                labelText: "Enter OTP to verify your account",
                hintText: "Enter OTP Code"),
          ),
          ElevatedButton(
              onPressed: () {
                verifyOtp();
              },
              child: Text("Submit")),
          Text("Didn't get the OTP ?"),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isResendButtonDisabled ? Colors.grey : Colors.red),
              onPressed: isResendButtonDisabled
                  ? null
                  : () {
                      resendOTP();
                    },
              child: Text(
                "Resend OTP",
                style: TextStyle(color: Colors.white),
              )),
          if (isResendButtonDisabled) ...[
            Text("Please wait $start seconds before resending OTP")
          ]
        ],
      ),
    );
  }
}
