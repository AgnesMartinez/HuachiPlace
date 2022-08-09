import 'package:flutter/material.dart';
import 'placecolors.dart';
import 'apitools.dart';

//The mighty GridManager
class GridManager extends StatefulWidget {
  const GridManager({Key? key}) : super(key: key);

  @override
  State<GridManager> createState() => _GridManagerState();
}

class _GridManagerState extends State<GridManager> {

  //widget key from inside the widget tree
  final GlobalKey gridKey = GlobalKey();

  //Grid size
  Size gridSize = const Size(1000,1000);

  //Transformation controller for the InteractiveViewer
  TransformationController transformationCon = TransformationController();

  //A brush is needed to paint on the canvas
  BrochaController brocha = BrochaController();

  //Current scale place holder
  late double correctScaleValue;

  //Get canvas background as bytes
  Future<List> loadData() async {

    //Use the session to make api calls
    Session api = Session();
    
    List<dynamic> response = await api.getGrid();

    return response[1]; 
  }

  @override
  Widget build(BuildContext context) {

    //Get the current scale before the widget is rendered
    correctScaleValue = transformationCon.value.getMaxScaleOnAxis();

    /*A FutureBuilder is needed in order to make api calls 
    before the widget gets inserted into the tree*/
    return FutureBuilder(
      future: loadData(),
      builder: (context,snapshot) {
        
        //snapshot holds metadata from the future
        if (snapshot.hasData) {

          brocha.bytes = snapshot.data;

          /*A widget that handles Zoom and Span
          designed for images but works with widgets too*/
          return InteractiveViewer(
            //Constrains widget inside a box if true
            constrained: false,
            maxScale: 90,
            minScale: 1,
            //Controller that holds metadata from widget interaction
            transformationController: transformationCon,
            onInteractionEnd: (details) {
              //Save scale value each rebuild
              correctScaleValue = transformationCon.value.getMaxScaleOnAxis();
               },

            //Widget that limits rebuilds for a given child
            //to increase app performance  
            child: RepaintBoundary(

              //Ignore rebuild calls from this widget key (grid)
              //Only the brush controller will rebuild the canvas
              key: gridKey,
              child: GestureDetector(
                
                //Track location of pixel tapped down by user
                onTapDown: (details) {

                  //Prevent pixel color changes on lower scales
                  if (correctScaleValue >= 5) {

                    Offset position = details.localPosition; 

                    //Get the size of rendered element
                    dynamic box = gridKey.currentContext!.findRenderObject();

                    //Adjust coordinate values to current scale
                    double widgetScaleWidth = box.size.width / gridSize.width;

                    double widgetScaleHeight = box.size.height / gridSize.height;

                    double x = position.dx / widgetScaleWidth ;

                    double y = position.dy / widgetScaleHeight;

                    //Let the values hit the floor
                    //Call color change menu with tapped location
                    brocha.changeColorMenu(context, x.floor(), y.floor());

                  }
                },

                //3 layer canvas
                child: CustomPaint(
                  size: gridSize,
                  //Top layer
                  foregroundPainter: GridJob(brocha: brocha),
                  //Middle layer
                  child: Image.memory(brocha.bytes,filterQuality: FilterQuality.none)
                ),
              ),
            )            
          );

        } else {

          // By default, show a loading spinner.
          return Container(
            alignment: Alignment.center,
            child: const SizedBox(
              width: 300,
              height: 300,
              child: CircularProgressIndicator()
            )
          );
        }
      }
    );
  }

  @override 
  void initState() {

    super.initState();
  }

  @override
  void dispose(){
    //Dispose the brush after use
    brocha.dispose();
    super.dispose();
  }

}

//Canvas class to paint the grid
class GridJob extends CustomPainter {

  //Only the brush calls repaint
  GridJob({Key? key, required this.brocha}): super(repaint: brocha);

  BrochaController brocha;

  Size gridSize = const Size(1000,1000);

  @override 
  void paint(Canvas canvas, Size size) {

    double tileWidth = size.width / gridSize.width;

    double tileHeight = size.height / gridSize.height;
    
    brocha.currentChanges.forEach((item) {

      canvas.drawRect(Rect.fromLTWH(item[0], item[1], tileWidth, tileHeight), Paint()..color = item[2]);

    });  
  }

  @override
  bool shouldRepaint(GridJob oldDelegate) => true;

}

/*Custom brush controller
  Holds image background bytes and pixel color changes
  Methods to inform changes to the backend

  Only the controller can trigger repaint to the canvas
*/
class BrochaController extends ChangeNotifier {
  
  List<dynamic> currentChanges = [];

  var bytes;

  void changeTile(int x, int y, Color newColor) {

    currentChanges.add([x,y,newColor]);

    notifyListeners();
  }

  void submit(int x,int y,int colore) async {

    Session api = Session();

    Map data = {"position":"${x},${y}","color": colore};

    List<dynamic> response = await api.postColor(data);
  
  }

  //Banner sheet for colors menu
  void changeColorMenu(BuildContext context,int x, int y) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            height: 400,
            color: PlaceColors.primaryBackground,
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text('( X : ${x}  ,  Y : ${y} )',
                    style: const TextStyle(color: Colors.white),
                    textScaleFactor: 2),
                  const SizedBox(height: 30),
                  FittedBox(
                    fit: BoxFit.fill,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () { 

                            submit(x,y,PlaceColors.black.value);

                            changeTile(x,y,PlaceColors.black);
                            
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            width: 200,
                            height: 200,
                            color: PlaceColors.black
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () { 

                            submit(x,y,PlaceColors.white.value);

                            changeTile(x,y,PlaceColors.white);
                            
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            width: 200,
                            height: 200,
                            color: PlaceColors.white
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () { 
                            
                            submit(x,y,PlaceColors.gray.value);

                            changeTile(x,y,PlaceColors.gray);

                            Navigator.of(context).pop();
                          },
                          child: Container(
                            width: 200,
                            height: 200,
                            color: PlaceColors.gray
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () { 

                            submit(x,y,PlaceColors.darkGray.value);

                            changeTile(x,y,PlaceColors.darkGray);
                            
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            width: 200,
                            height: 200,
                            color: PlaceColors.darkGray
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () { 
                            submit(x,y,PlaceColors.purple.value);
                            changeTile(x,y,PlaceColors.purple);
                      
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            width: 200,
                            height: 200,
                            color: PlaceColors.purple
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () { 
                            submit(x,y,PlaceColors.pink1.value);
                            changeTile(x,y,PlaceColors.pink1);
                      
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            width: 200,
                            height: 200,
                            color: PlaceColors.pink1
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () { 
                            submit(x,y,PlaceColors.pink2.value);
                            changeTile(x,y,PlaceColors.pink2);
                      
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            width: 200,
                            height: 200,
                            color: PlaceColors.pink2
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () { 
                            submit(x,y,PlaceColors.yellow1.value);
                            changeTile(x,y,PlaceColors.yellow1);
                      
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            width: 200,
                            height: 200,
                            color: PlaceColors.yellow1
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () { 
                            submit(x,y,PlaceColors.orange.value);
                            changeTile(x,y,PlaceColors.orange);
                      
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            width: 200,
                            height: 200,
                            color: PlaceColors.orange
                          ),
                        ),
                      ],
                  )
            ),
            const SizedBox(height: 20),
            FittedBox(
              fit: BoxFit.fill,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () { 
                      submit(x,y,PlaceColors.red2.value);
                      changeTile(x,y,PlaceColors.red2);
                      
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      width: 200,
                      height: 200,
                      color: PlaceColors.red2
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () { 
                      submit(x,y,PlaceColors.blue1.value);
                      changeTile(x,y,PlaceColors.blue1);
                      
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      width: 200,
                      height: 200,
                      color: PlaceColors.blue1
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () { 
                      submit(x,y,PlaceColors.blue2.value);
                      changeTile(x,y,PlaceColors.blue2);
                      
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      width: 200,
                      height: 200,
                      color: PlaceColors.blue2
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () { 
                      submit(x,y,PlaceColors.blue3.value);
                      changeTile(x,y,PlaceColors.blue3);
                      
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      width: 200,
                      height: 200,
                      color: PlaceColors.blue3
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                   onTap: () { 
                      submit(x,y,PlaceColors.green1.value);
                      changeTile(x,y,PlaceColors.green1);
                      
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      width: 200,
                      height: 200,
                      color: PlaceColors.green1
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () { 
                      submit(x,y,PlaceColors.green2.value);
                      changeTile(x,y,PlaceColors.green2);
                      
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      width: 200,
                      height: 200,
                      color: PlaceColors.green2
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () { 
                      submit(x,y,PlaceColors.brown.value);
                      changeTile(x,y,PlaceColors.brown);
                      
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      width: 200,
                      height: 200,
                      color: PlaceColors.brown
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () { 
                      submit(x,y,PlaceColors.red1.value);
                      changeTile(x,y,PlaceColors.red1);
                      
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      width: 200,
                      height: 200,
                      color: PlaceColors.red1
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () { 
                      submit(x,y,PlaceColors.yellow2.value);
                      changeTile(x,y,PlaceColors.yellow2);
                      
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      width: 200,
                      height: 200,
                      color: PlaceColors.yellow2
                    ),
                  )
                ],
                  )
            ),
                ],
              )
          )
        );
      }
    );
  }

}


