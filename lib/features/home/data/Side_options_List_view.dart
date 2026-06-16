import 'package:flutter/material.dart';
import 'package:hungry/core/theme/custom_text.dart';
import 'package:hungry/core/theme/app_colors.dart';
import 'package:hungry/core/theme/app_text_style.dart';
import 'package:hungry/features/product/widget/Side_Options_Image_view.dart';

class SideOptionsListView extends StatefulWidget {
  const SideOptionsListView({super.key});

  @override
  State<SideOptionsListView> createState() => _SideOptionsListViewState();
}

List<Map<dynamic, dynamic>> SideOptions = [
  {'SideOption': 'Fries', 'image': 'assets/detail/Fries.png'},
  {'SideOption': 'Coleslaw', 'image': 'assets/detail/Coleslaw.png'},
  {'SideOption': 'Salad', 'image': 'assets/detail/Salad.png'},
  {'SideOption': 'Onion', 'image': 'assets/detail/Onion.png'},
];
Set<int> selectedSideOptions = {};

class _SideOptionsListViewState extends State<SideOptionsListView> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      shrinkWrap: true,
      physics: BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      itemCount: SideOptions.length,
      itemBuilder: (context, index) {
        return Stack(
          children: [
            Container(
              margin: EdgeInsets.only(right: 12.5, left: 12.5),
              decoration: BoxDecoration(
                color: Appcolors.Black12,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Appcolors.grey.withValues(alpha: 1.2),
                    spreadRadius: 0.5,
                    blurRadius: 10,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              height: 120,
              width: 85,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 9, right: 9, bottom: 13.0),
                    child: Row(
                      children: [
                        CustomText(
                          SideOptions[index]['SideOption']!,
                          style: Textstyle.text10bold.copyWith(
                            color: Appcolors.white,
                          ),
                        ),
                        Spacer(),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              if (selectedSideOptions.contains(index)) {
                                selectedSideOptions.remove(index);
                              } else {
                                selectedSideOptions.add(index);
                              }
                            });
                          },
                          child: Container(
                            height: 20,
                            width: 20,
                            decoration: BoxDecoration(
                              color: Appcolors.background,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Icon(
                              selectedSideOptions.contains(index)
                                  ? Icons.remove
                                  : Icons.add,
                              color: Appcolors.white,
                              size: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 12.5,
              top: 0,
              child: SideOptionsImageView(image: SideOptions[index]['image']!),
            ),
          ],
        );
      },
    );
  }
}



