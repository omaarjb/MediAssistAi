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
    final style = context.outlinedButtonTheme.style?.copyWith(
      fixedSize: MaterialStateProperty.all(
        Size(context.width / 3.8, context.height * 0.07),
      ),
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
              style: style,
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
              style: style,
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
              style: style,
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
