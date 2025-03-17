import 'package:dr_ai/utils/constant/image.dart';
import 'package:dr_ai/utils/constant/routes.dart';
import 'package:dr_ai/utils/helper/extention.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../logic/auth/social_auth/social_auth_cubit.dart';

class SocialLoginCard extends StatelessWidget {
  const SocialLoginCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Define a circular button style
    final circularButtonStyle = OutlinedButton.styleFrom(
      shape: const CircleBorder(), // Make the button circular
      padding: EdgeInsets.all(5.w), // Adjust padding as needed
      side: const BorderSide(
        color: Color.fromARGB(255, 2, 89, 219), // Border color
        width: 2.0, // Border width
      ),
      // Equal width and height
    );

    return BlocConsumer<SocialAuthCubit, SocialAuthState>(
      listener: (context, state) {
        if (state == SocialAuthState.error) {
          final errorMessage = context.read<SocialAuthCubit>().errorMessage;
          if (errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(errorMessage)),
            );
          }
        }
        if (state == SocialAuthState.authenticated) {
          // Navigate to the home screen or perform other actions
          Navigator.pushNamedAndRemoveUntil(
              context, RouteManager.nav, (route) => false);
        }
      },
      builder: (context, state) {
        print("SocialAuthCubit state: $state"); // Debugging
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            OutlinedButton(
              style: circularButtonStyle,
              onPressed: state == SocialAuthState.loading ||
                      state == SocialAuthState.authenticated
                  ? null // Disable button when loading or authenticated
                  : () {
                      print("Google sign-in button pressed"); // Debugging
                      context.read<SocialAuthCubit>().signInWithGoogle();
                    },
              child: state == SocialAuthState.loading
                  ? const CircularProgressIndicator() // Show loading indicator
                  : _buildSVGIcon(ImageManager.googleIcon),
            ),
            OutlinedButton(
              style: circularButtonStyle,
              onPressed: state == SocialAuthState.loading ||
                      state == SocialAuthState.authenticated
                  ? null // Disable button when loading or authenticated
                  : () {
                      print("Facebook sign-in button pressed"); // Debugging
                      context.read<SocialAuthCubit>().signInWithFacebook();
                    },
              child: state == SocialAuthState.loading
                  ? const CircularProgressIndicator() // Show loading indicator
                  : _buildSVGIcon(ImageManager.facebookIcon),
            ),
            OutlinedButton(
              style: circularButtonStyle,
              onPressed: state == SocialAuthState.loading ||
                      state == SocialAuthState.authenticated
                  ? null // Disable button when loading or authenticated
                  : () {
                      print("Apple sign-in button pressed"); // Debugging
                      context.read<SocialAuthCubit>().signInWithApple();
                    },
              child: state == SocialAuthState.loading
                  ? const CircularProgressIndicator() // Show loading indicator
                  : _buildSVGIcon(ImageManager.appleIcon),
            ),
          ],
        );
      },
    );
  }

  SvgPicture _buildSVGIcon(String icon) {
    return SvgPicture.asset(
      icon,
      width: 24.w,
      height: 24.w,
    );
  }
}
