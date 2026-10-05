import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_example/core/theme/app_button_styles.dart';
import 'package:flutter_example/core/theme/app_text_styles.dart';
import 'package:flutter_example/features/hotel_details/hotel_details/bloc/hotel_details_bloc.dart';
import 'package:flutter_example/utilities/extensions/context_extension.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class HotelDetailsLocation extends StatelessWidget {
  const HotelDetailsLocation({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HotelDetailsBloc, HotelDetailsState>(
      builder: (context, state) {
        final lat = state.hotel.location?.lat;
        final lon = state.hotel.location?.lon;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  context.localization.hotel_details_location_title,
                  style: AppTextStyles.titleMedium(
                    context,
                    color: context.colors.titleColor,
                  ),
                ),
                const Spacer(),
                AppButtonStyles.textPlatform(
                  context: context,
                  title: context.localization.hotel_details_open_map,
                  textStyle: AppTextStyles.labelSmall(
                    context,
                    color: context.colors.primary800,
                  ),
                  onPressed: () {
                    context
                        .read<HotelDetailsBloc>()
                        .add(const HotelDetailsEvent.didPressOnOpenMap());
                  },
                ),
              ],
            ),
            SizedBox(height: context.scaleValue(8)),
            if (lat != null && lon != null)
              InkWell(
                onTap: () {
                  context
                      .read<HotelDetailsBloc>()
                      .add(const HotelDetailsEvent.didPressOnOpenMap());
                },
                child: Container(
                  height: context.scaleValue(200),
                  width: double.infinity,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: context.colors.gray100,
                    borderRadius: BorderRadius.circular(context.scaleValue(12)),
                  ),
                  child: AbsorbPointer(
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: LatLng(lat, lon),
                        initialZoom: 18,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: context.colors.brightness ==
                                  Brightness.dark
                              ? 'https://{s}.basemaps.cartocdn.com/rastertiles/dark_all/{z}/{x}/{y}{r}.png'
                              : 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
                          subdomains: const ['a', 'b', 'c', 'd'],
                          userAgentPackageName: 'com.linkdev.iOSFullFlutterApp',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: LatLng(lat, lon),
                              width: 80,
                              height: 80,
                              child: Icon(
                                Icons.location_on,
                                color: context.colors.alertError100,
                                size: 40,
                              ),
                            ),
                          ],
                        ),
                        RichAttributionWidget(
                          attributions: [
                            TextSourceAttribution(
                              '© OpenStreetMap contributors, © CARTO',
                              onTap: () => launchUrl(
                                  Uri.parse('https://carto.com/attributions')),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            SizedBox(height: context.scaleValue(12)),
            if (state.pinAddress != null)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    color: context.colors.gray500,
                    size: context.scaleValue(20),
                  ),
                  SizedBox(width: context.scaleValue(8)),
                  Expanded(
                    child: Text(
                      state.pinAddress!,
                      style: AppTextStyles.bodySmall(
                        context,
                        color: context.colors.gray600,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        );
      },
    );
  }
}
