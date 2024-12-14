import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

void main() {
  runApp(const MaterialApp(
    home: MyHomePage(),
    debugShowCheckedModeBanner: false,
  ));
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late List<EnergyData> _energyConsumedData;
  late Map<String, Color> _cylinderColors;
  late Map<String, Color> _shadowColors;
  late double _trackerBaseHeight;

  @override
  void initState() {
    _energyConsumedData = <EnergyData>[
      EnergyData('Iceland', 86.87),
      EnergyData('Norway', 71.56),
      EnergyData('Sweden', 50.92),
      EnergyData('Brazil', 46.22),
      EnergyData('New Zealand', 40.22),
      EnergyData('Denmark', 39.25),
    ];
    _cylinderColors = {
      'Iceland': const Color.fromARGB(255, 178, 52, 43),
      'Norway': const Color.fromARGB(255, 125, 31, 142),
      'Sweden': const Color.fromARGB(255, 8, 133, 120),
      'Brazil': const Color.fromARGB(255, 25, 108, 176),
      'New Zealand': const Color.fromARGB(255, 92, 63, 53),
      'Denmark': const Color.fromARGB(255, 139, 126, 4)
    };
    _shadowColors = {
      'Iceland': const Color.fromARGB(255, 210, 83, 74),
      'Norway': const Color.fromARGB(255, 145, 56, 160),
      'Sweden': const Color.fromARGB(255, 47, 150, 140),
      'Brazil': const Color.fromARGB(255, 59, 128, 185),
      'New Zealand': const Color.fromARGB(255, 117, 80, 67),
      'Denmark': const Color.fromARGB(255, 179, 163, 15)
    };
    _trackerBaseHeight = 18;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SfCartesianChart(
        backgroundColor: const Color.fromARGB(255, 202, 196, 196),
        title: const ChartTitle(
            alignment: ChartAlignment.center,
            text:
                'Percentage of Total Energy Consumption from Renewable Sources in a Country',
            textStyle: TextStyle(
                color: Color.fromARGB(255, 51, 51, 51),
                fontSize: 16,
                fontWeight: FontWeight.bold)),
        tooltipBehavior: TooltipBehavior(enable: true),
        onTooltipRender: (tooltipArgs) {
          List<String> tooltipText = tooltipArgs.text!.split(' : ');
          tooltipArgs.header = tooltipText[0];
          tooltipArgs.text = '${tooltipText[1]}%';
        },
        onDataLabelRender: (dataLabelArgs) {
          dataLabelArgs.textStyle = dataLabelArgs.textStyle.copyWith(
              fontSize: 14,
              color: const Color.fromARGB(200, 222, 219, 219),
              fontWeight: FontWeight.bold);
          dataLabelArgs.text = '${dataLabelArgs.text}%';
        },
        plotAreaBorderWidth: 0,
        primaryXAxis: CategoryAxis(
          majorGridLines: const MajorGridLines(color: Colors.transparent),
          axisLabelFormatter: (axisLabelRenderArgs) {
            TextStyle textStyle = axisLabelRenderArgs.textStyle.copyWith(
                color: _cylinderColors[axisLabelRenderArgs.text],
                fontWeight: FontWeight.w700,
                fontSize: 15);
            return ChartAxisLabel(axisLabelRenderArgs.text, textStyle);
          },
          labelPosition: ChartDataLabelPosition.inside,
        ),
        primaryYAxis: const NumericAxis(
          isVisible: false,
          plotOffsetStart: 70,
          plotOffsetEnd: 70,
        ),
        enableSideBySideSeriesPlacement: false,
        series: <CartesianSeries<EnergyData, String>>[
          StackedColumnSeries<EnergyData, String>(
            dataSource: _energyConsumedData,
            xValueMapper: (EnergyData data, index) => data.country,
            yValueMapper: (EnergyData data, index) => _trackerBaseHeight,
            color: const Color.fromARGB(255, 132, 130, 130),
            isTrackVisible: true,
            trackColor: const Color.fromARGB(255, 178, 175, 175),
            onCreateRenderer: (series) {
              return _CustomStackedColumn3DTrackerSeriesRenderer(
                  const Color.fromARGB(255, 101, 100, 100));
            },
            enableTooltip: false,
            width: 0.65,
            animationDuration: 0,
          ),
          StackedColumnSeries<EnergyData, String>(
            dataSource: _energyConsumedData,
            xValueMapper: (EnergyData data, index) => data.country,
            yValueMapper: (EnergyData data, index) =>
                data.percentageOfEnergyConsumed,
            onCreateRenderer: (series) {
              return _CustomStackedColumn3DSeriesRenderer(_shadowColors);
            },
            pointColorMapper: (EnergyData data, index) =>
                _cylinderColors[data.country],
            dataLabelSettings: const DataLabelSettings(
                isVisible: true,
                labelAlignment: ChartDataLabelAlignment.middle),
            width: 0.6,
            animationDuration: 0,
          ),
        ],
      ),
    );
  }
}

class _CustomStackedColumn3DSeriesRenderer
    extends StackedColumnSeriesRenderer<EnergyData, String> {
  _CustomStackedColumn3DSeriesRenderer(this.shadowColors);

  final Map<String, Color> shadowColors;

  @override
  StackedColumnSegment<EnergyData, String> createSegment() {
    return _CustomStackedColumn3DPainter(shadowColors);
  }
}

class _CustomStackedColumn3DPainter
    extends StackedColumnSegment<EnergyData, String> {
  _CustomStackedColumn3DPainter(this.shadowColors);

  final Map<String, Color> shadowColors;

  @override
  void onPaint(Canvas canvas) {
    const double segmentOvalHeight = 34;
    const double ovalPadding = segmentOvalHeight / 2;
    final String countryName = series.xRawValues[currentSegmentIndex]!;
    final Rect bottomOval = Rect.fromLTWH(
        segmentRect!.left,
        segmentRect!.bottom - ovalPadding,
        segmentRect!.width,
        segmentOvalHeight);
    final Rect topOval = Rect.fromLTWH(segmentRect!.left,
        segmentRect!.top - ovalPadding, segmentRect!.width, segmentOvalHeight);

    canvas.drawOval(bottomOval, Paint()..color = fillPaint.color);
    super.onPaint(canvas);
    canvas.drawOval(topOval, Paint()..color = shadowColors[countryName]!);
  }
}

class _CustomStackedColumn3DTrackerSeriesRenderer
    extends StackedColumnSeriesRenderer<EnergyData, String> {
  _CustomStackedColumn3DTrackerSeriesRenderer(this.trackerTopColor);

  final Color trackerTopColor;

  @override
  StackedColumnSegment<EnergyData, String> createSegment() {
    return _CustomStackedColumn3DTrackPainter(trackerTopColor);
  }
}

class _CustomStackedColumn3DTrackPainter
    extends StackedColumnSegment<EnergyData, String> {
  _CustomStackedColumn3DTrackPainter(this.trackerTopColor);

  final Color trackerTopColor;

  @override
  void onPaint(Canvas canvas) {
    const double trackerOvalHeight = 40;
    const double ovalPadding = trackerOvalHeight / 2;

    // The pointToPixelY method used for find the pixel value of track rect
    // top value
    final double trackerTop = series.pointToPixelY(0, 120);
    final Rect trackerTopRect = Rect.fromLTWH(segmentRect!.left,
        trackerTop - ovalPadding, segmentRect!.width, trackerOvalHeight);
    final Rect trackerBottomRect = Rect.fromLTWH(segmentRect!.left,
        segmentRect!.top - ovalPadding, segmentRect!.width, trackerOvalHeight);
    final Rect trackerBaseBottomRect = Rect.fromLTWH(
        segmentRect!.left,
        segmentRect!.bottom - ovalPadding,
        segmentRect!.width,
        trackerOvalHeight);

    super.onPaint(canvas);
    canvas.drawOval(trackerBaseBottomRect, Paint()..color = fillPaint.color);
    canvas.drawOval(trackerBottomRect, Paint()..color = trackerTopColor);
    canvas.drawOval(trackerTopRect,
        Paint()..color = const Color.fromARGB(255, 184, 181, 181));
  }
}

class EnergyData {
  EnergyData(this.country, this.percentageOfEnergyConsumed);
  final String country;
  final double percentageOfEnergyConsumed;
}
