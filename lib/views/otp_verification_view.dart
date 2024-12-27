import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_flutter_app/viewModels/user_auth_view_model.dart';
import 'package:recipe_flutter_app/views/navigation_view.dart';
import 'package:recipe_flutter_app/utils.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String email;

  const OTPVerificationScreen({required this.email, super.key});

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final otpController = TextEditingController();
  late UserAuthViewModel userAuthViewModel;
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
      await userAuthViewModel.verifyOTP(
          widget.email, otpController.text.trim());

      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const NavigationScreen()));
    } catch (e) {
      showSnackbar("Error while verifying OTP", context);
    }
  }

  resendOTP() async {
    try {
      await userAuthViewModel.resendOtp(widget.email);
      startTimer();
    } catch (e) {
      showSnackbar("Error while refetching OTP", context);
    }
  }

  @override
  Widget build(BuildContext context) {
    userAuthViewModel = Provider.of<UserAuthViewModel>(context);
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: otpController,
              decoration: InputDecoration(
                  labelText: "Enter OTP to verify your account",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10))),
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          Container(
            width: 200,
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade200),
                onPressed: () {
                  verifyOtp();
                },
                child: Text(
                  "Submit",
                  style: TextStyle(color: Colors.black),
                )),
          ),
          const SizedBox(
            height: 20,
          ),
          const Text("Didn't get the OTP ?"),
          const SizedBox(
            height: 10,
          ),
          Container(
            width: 200,
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isResendButtonDisabled ? Colors.grey : Colors.red),
                onPressed: isResendButtonDisabled
                    ? null
                    : () {
                        resendOTP();
                      },
                child: const Text(
                  "Resend OTP",
                  style: TextStyle(color: Colors.white),
                )),
          ),
          if (isResendButtonDisabled) ...[
            Text("Please wait $start seconds before resending OTP")
          ]
        ],
      ),
    );
  }
}
