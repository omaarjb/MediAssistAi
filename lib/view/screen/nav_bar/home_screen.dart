import 'package:dr_ai/utils/constant/image.dart';
import 'package:dr_ai/utils/constant/routes.dart';
import 'package:dr_ai/utils/helper/extention.dart';
import 'package:dr_ai/view/widget/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import '../../../utils/constant/color.dart';
import '../../../logic/chat/chat_cubit.dart';
import '../../widget/contact_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 60),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.center, // Align content to the start
            children: [
              // Welcome Title
              Text(
                "Welcome to",
                style: context.textTheme.displayLarge?.copyWith(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              Gap(5.h),
              Text(
                "MediAssistAi",
                style: context.textTheme.displayLarge?.copyWith(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(
                      255, 2, 89, 219), // "MediAssistAi" in blue
                ),
              ),
              Gap(32.h),

              // Chat Card
              _buildChatCard(context),
              Gap(32.h),

              // Contacts Section Title
              Text(
                "Emergency Contacts",
                style: context.textTheme.displayLarge?.copyWith(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Gap(12.h),

              // Contacts Cards
              _buidContactsCard(),
              Gap(32.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatCard(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
        side: BorderSide(
            color: const Color.fromARGB(255, 229, 229, 230).withOpacity(0.3),
            width: 0.5),
      ),
      color: const Color.fromARGB(255, 229, 229, 230).withOpacity(0.9),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Chat with MediAssistAi",
                    style: context.textTheme.displayLarge?.copyWith(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Gap(12.h),
                  const Text(
                    "Ask your MediAssistAi for help with symptoms, medicine recommendations, health tips, or medical questions. Your health companion is here to guide you.",
                    style: TextStyle(color: Color.fromARGB(255, 88, 89, 90)),
                  ),
                  Gap(18.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomButton(
                        size: Size(context.width * 0.375, 47),
                        title: "Chat Now",
                        onPressed: () {
                          context.bloc<ChatCubit>().initHive();
                          Navigator.pushNamed(context, RouteManager.chat);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Image.asset(ImageManager.robotIcon),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buidContactsCard() {
    return const Row(
      children: [
        Expanded(
          child: ContactCard(
            image: ImageManager.ambulanceIcon,
            title: "Ambulance",
            number: "150",
            color: ColorManager.orange,
          ),
        ),
        Gap(12),
        Expanded(
          child: ContactCard(
            image: ImageManager.policeIcon,
            title: "Police",
            number: "19",
            color: ColorManager.lightBlue,
          ),
        ),
        Gap(12),
        Expanded(
          child: ContactCard(
            image: ImageManager.firefightingIcon,
            title: "Firefighting",
            number: "15",
            color: ColorManager.green,
          ),
        ),
      ],
    );
  }
}
