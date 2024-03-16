import 'package:flutter/material.dart';

class BrowserTab extends StatefulWidget {
  BrowserTab({
    required this.tabTitles,
    required this.tabContents,
    this.tabRightWidget,
    Key? key,
  }) : super(key: key);

  final List<String> tabTitles;
  final List<Widget> tabContents;
  final Widget? tabRightWidget;

  @override
  _BrowserTabState createState() => _BrowserTabState();
}

class _BrowserTabState extends State<BrowserTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(vsync: this, length: widget.tabTitles.length);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Stack(
          children: [
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 0.5,
                color: Colors.black.withOpacity(0.1),
              ),
            ),
            Container(
              constraints: BoxConstraints.expand(height: 35),
              child: TabBar(
                  isScrollable: true,
                  controller: _tabController,
                  labelColor: Colors.black,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelColor: Colors.black.withOpacity(0.5),
                  tabs: widget.tabTitles
                      .map((title) => Tab(text: title))
                      .toList(),
                  indicatorColor: Colors.black,
                  indicatorWeight: 2,
                  indicatorSize: TabBarIndicatorSize.label,
                  labelPadding:
                      EdgeInsets.only(left: 0, right: 20, top: 0, bottom: 0)),
            ),
            widget.tabRightWidget != null
                ? Positioned(bottom: 8, right: 0, child: widget.tabRightWidget!)
                : Container(),
          ],
        ),
        SizedBox(height: 10),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: widget.tabContents,
          ),
        ),
      ],
    );
  }
}

class TabBorderContent extends StatelessWidget {
  TabBorderContent({required this.tabContent});

  final Widget tabContent;
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border:
                Border.all(color: Colors.black.withOpacity(0.05), width: 0.5)),
        padding: const EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: tabContent,
        ));
  }
}
