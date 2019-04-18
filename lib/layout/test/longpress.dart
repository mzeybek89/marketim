import 'package:flutter/material.dart';
import 'dart:math';


const int _kNumberOfItems = 50;
const int _kNumberOfItemsPerRow = 2;

class Page extends StatelessWidget {
    @override
    Widget build(BuildContext context){
        return SafeArea(
            child: Scaffold(
                appBar: AppBar(
                    title: Text('Application title'),
                ),
                body: Container(
                    child: ClipRect(        // Forces the OverlayEntry not to overflow this container
                        child: Overlay(     // The Overlay that allows us to control the positioning
                            initialEntries: <OverlayEntry>[
                                OverlayEntry(
                                    builder: (BuildContext context) {
                                        return GridView.builder(
                                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: _kNumberOfItemsPerRow,
                                                childAspectRatio: 1.0,
                                            ),
                                            itemCount: _kNumberOfItems,
                                            itemBuilder: (BuildContext context, int index) {
                                                return ItemWidget(
                                                    id: index,
                                                    color: Color((Random().nextDouble() * 0xFFFFFF).toInt() << 0)
                                                                .withOpacity(1.0),
                                                );
                                            },
                                        );
                                    },
                                ),
                            ],
                        ),
                    ),
                ),
            ),
        );
    }
}

///
/// Simple Widget to demonstrate the use
/// of the OverlayableContainerOnLongPress
///
class ItemWidget extends StatelessWidget {
    ItemWidget({
        Key key,
        this.id,
        this.color,
    }): super(key: key);

    final int id;
    final Color color;

    @override
    Widget build(BuildContext context){
        return OverlayableContainerOnLongPress(
            child: GridTile(
                child: Card(
                    child: Container(
                        color: color,
                        child: Center(
                            child: Text('item_$id', style: TextStyle(color: Colors.black,)),
                        ),
                    ),
                ),
            ),
            overlayContentBuilder: (BuildContext context, VoidCallback onHideOverlay) {
                return Container(
                    height: double.infinity,
                    color: Colors.black38,
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                            IconButton(
                                icon: const Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                ),
                                onPressed: () {
                                    onHideOverlay();
                                    _onEditItem();
                                },
                            ),
                            IconButton(
                                icon: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                ),
                                onPressed: () {
                                    onHideOverlay();
                                    _onDeleteItem();
                                },
                            ),
                        ],
                    ),
                );
            },
            onTap: () {
                _onViewItem();
            },
        );
    }

    void _onViewItem(){
        print('view item: $id');
    }

    void _onEditItem(){
        print('edit item: $id');
    }

    void _onDeleteItem(){
        print('delete item: $id');
    }
}


/// -----------------------------------------------------------------
/// Widget that accepts an overlay to be displayed on top of itself
/// when a LongPress gesture is detected.
/// 
/// Required a specific Overlay higher in the hierarchy to be used
/// as a parent
/// -----------------------------------------------------------------
typedef OverlayableContainerOnLongPressBuilder(BuildContext context, VoidCallback hideOverlay);

class OverlayableContainerOnLongPress extends StatefulWidget {
  OverlayableContainerOnLongPress({
    Key key,
    @required this.child,
    @required this.overlayContentBuilder,
    this.onTap,
  }): super(key: key);

  final Widget child;
  final OverlayableContainerOnLongPressBuilder overlayContentBuilder;
  final VoidCallback onTap;

  @override
  _OverlayableContainerOnLongPressState createState() => _OverlayableContainerOnLongPressState();
}

class _OverlayableContainerOnLongPressState extends State<OverlayableContainerOnLongPress> {
  OverlayEntry _overlayEntry;

  @override
  void dispose() {
    _removeOverlayEntry();
    super.dispose();
  }

  void _removeOverlayEntry() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  ///
  /// Returns the position (as a Rect) of an item
  /// identified by its BuildContext
  ///
  Rect _getPosition(BuildContext context) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset topLeft = box.size.topLeft(box.localToGlobal(Offset.zero));
    final Offset bottomRight =
        box.size.bottomRight(box.localToGlobal(Offset.zero));
    return Rect.fromLTRB(
        topLeft.dx, topLeft.dy, bottomRight.dx, bottomRight.dy);
  }

  ///
  /// Displays an OverlayEntry on top of the selected item
  /// This overlay disappears if we click outside or, on demand
  ///
  void _showOverlayOnTopOfItem(BuildContext context) {
    OverlayState overlayState = Overlay.of(context);
    final Rect overlayPosition = _getPosition(overlayState.context);

    // Get the coordinates of the item
    final Rect widgetPosition = _getPosition(context).translate(
        -overlayPosition.left, 
        -overlayPosition.top,
    );

    // Generate the overlay entry
    _overlayEntry = OverlayEntry(builder: (BuildContext context) {
      return GestureDetector(
        behavior: HitTestBehavior.deferToChild,
        onTap: () {
          ///
          /// Remove the overlay when we tap outside
          ///
          _removeOverlayEntry();
        },
        child: Material(
          color: Colors.black12,
          child: CustomSingleChildLayout(
            delegate: _OverlayableContainerLayout(widgetPosition),
            child: widget.overlayContentBuilder(context, _removeOverlayEntry),
          ),
        ),
      );
    });

    // Insert the overlayEntry on the screen
    overlayState.insert(
      _overlayEntry,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.onTap != null){
          widget.onTap();
        }
      },
      onLongPress: () {
        _showOverlayOnTopOfItem(context);
      },     

      onLongPressUp: (){print("kapat"); },
      child: widget.child,
    );
  }
}

class _OverlayableContainerLayout extends SingleChildLayoutDelegate {
  _OverlayableContainerLayout(this.position);

  final Rect position;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints.loose(Size(position.width, position.height));
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    return Offset(position.left, position.top);
  }

  @override
  bool shouldRelayout(_OverlayableContainerLayout oldDelegate) {
    return position != oldDelegate.position;
  }
}