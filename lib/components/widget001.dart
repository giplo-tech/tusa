import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:podpole/color.dart';
import 'package:podpole/pages/party_details_page.dart';

import 'class_party.dart';

class Widget001 extends StatelessWidget {
  final Party party;

  const Widget001({
    Key? key,
    required this.party,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PartyDetailsPage(party: party)),
        );
      },
      child: Card(
        color: AppColors.black_l,
        margin: EdgeInsets.all(0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.asset(
                  'assets/images/party.png',
                  fit: BoxFit.cover,
                  height: 170,
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                party.title,
                style: const TextStyle(
                  fontFamily: 'Unbounded',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: 0),

              // Place
              Text(
                party.place,
                style: const TextStyle(
                  fontFamily: 'Styrene',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.grey,
                ),
              ),
              const SizedBox(height: 6),

              // Address
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/icons/location_p.svg',
                    width: 16,
                    height: 16,
                    color: AppColors.primary_b,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    party.address,
                    style: const TextStyle(
                      fontFamily: 'Styrene',
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Date and time
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Date
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/icons/calendar.svg',
                        width: 16,
                        height: 16,
                        color: AppColors.primary_b,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        party.date,
                        style: const TextStyle(
                          fontFamily: 'Styrene',
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                          color: AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),

                  // Time
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/icons/clock.svg',
                        width: 16,
                        height: 16,
                        color: AppColors.primary_b,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        party.time,
                        style: const TextStyle(
                          fontFamily: 'Styrene',
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                          color: AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
