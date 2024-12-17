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
  late Map<String, Color> _topOvalColors;
  late ChartSeriesController _controller;

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
    _topOvalColors = {
      'Iceland': const Color.fromARGB(255, 210, 83, 74),
      'Norway': const Color.fromARGB(255, 145, 56, 160),
      'Sweden': const Color.fromARGB(255, 47, 150, 140),
      'Brazil': const Color.fromARGB(255, 59, 128, 185),
      'New Zealand': const Color.fromARGB(255, 117, 80, 67),
      'Denmark': const Color.fromARGB(255, 179, 163, 15)
    };
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SfCartesianChart(
        title: const ChartTitle(
            alignment: ChartAlignment.center,
            text:
                'Percentage of Total Energy Consumption from Renewable Sources in a Country'),
        tooltipBehavior: TooltipBehavior(enable: true),
        onTooltipRender: (TooltipArgs tooltipArgs) {
          List<String> tooltipText = tooltipArgs.text!.split(' : ');
          tooltipArgs.header = tooltipText[0];
          tooltipArgs.text = '${tooltipText[1]}%';
        },
        onDataLabelRender: (DataLabelRenderArgs dataLabelArgs) {
          dataLabelArgs.text = '${dataLabelArgs.text}%';
        },
        plotAreaBorderWidth: 0,
        primaryXAxis: CategoryAxis(
          majorGridLines: const MajorGridLines(width: 0),
          majorTickLines: const MajorTickLines(width: 0),
          axisLine: const AxisLine(width: 0),
          axisLabelFormatter: (axisLabelRenderArgs) {
            final String countryName = axisLabelRenderArgs.text;
            TextStyle textStyle = Theme.of(context)
                .textTheme
                .titleSmall!
                .copyWith(color: _cylinderColors[countryName]);
            return ChartAxisLabel(countryName, textStyle);
          },
          labelPosition: ChartDataLabelPosition.inside,
        ),
        primaryYAxis: const NumericAxis(
          isVisible: false,
          plotOffsetStart: 50,
          plotOffsetEnd: 50,
        ),
        series: <CartesianSeries<EnergyData, String>>[
          ColumnSeries(
            dataSource: _energyConsumedData,
            xValueMapper: (EnergyData data, index) => data.country,
            yValueMapper: (EnergyData data, index) =>
                data.energyConsumedPercent,
            onCreateRenderer: (ChartSeries series) {
              return _CustomColumn3DSeriesRenderer(_topOvalColors);
            },
            onRendererCreated: (ChartSeriesController controller) {
              _controller = controller;
            },
            isTrackVisible: true,
            trackColor: const Color.fromARGB(255, 191, 188, 188),
            pointColorMapper: (EnergyData data, index) =>
                _cylinderColors[data.country],
            dataLabelSettings: const DataLabelSettings(
                isVisible: true,
                labelAlignment: ChartDataLabelAlignment.middle),
            animationDuration: 2000,
          ),
        ],
      ),
    );
  }
}

class _CustomColumn3DSeriesRenderer
    extends ColumnSeriesRenderer<EnergyData, String> {
  _CustomColumn3DSeriesRenderer(this.topOvalColors);

  final Map<String, Color> topOvalColors;

  @override
  ColumnSegment<EnergyData, String> createSegment() {
    return _CustomColumn3DSegment(topOvalColors);
  }
}

class _CustomColumn3DSegment extends ColumnSegment<EnergyData, String> {
  _CustomColumn3DSegment(this.topOvalColors);

  final Map<String, Color> topOvalColors;

  @override
  void onPaint(Canvas canvas) {
    final String countryName = series.xRawValues[currentSegmentIndex]!;
    final double trackerTop = series.pointToPixelY(0, 100);
    final Rect trackerTopOval = ovalRect(trackerTop);
    final Rect bottomOval = ovalRect(segmentRect!.bottom);
    final Rect animatedTopOval = ovalRect(segmentRect!.bottom -
        ((segmentRect!.bottom - segmentRect!.top) * animationFactor));

    super.onPaint(canvas);
    canvas.drawOval(trackerTopOval,
        Paint()..color = const Color.fromARGB(255, 204, 201, 201));
    canvas.drawOval(bottomOval, Paint()..color = fillPaint.color);
    canvas.drawOval(
        animatedTopOval, Paint()..color = topOvalColors[countryName]!);
  }

  Rect ovalRect(double ovalCenterY) {
    const double ovalRadius = 15;
    return Rect.fromLTRB(segmentRect!.left, ovalCenterY - ovalRadius,
        segmentRect!.right, ovalCenterY + ovalRadius);
  }
}

class EnergyData {
  EnergyData(this.country, this.energyConsumedPercent);
  final String country;
  final double energyConsumedPercent;
}
