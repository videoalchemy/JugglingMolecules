/* jason stephens  - 3 Jan 2012
 Making Things See - practice and examples
 This Branch = TrackingNearestObject
 
 
 TODO:
 DONE____track the point closest to the kinect
 DONE____get depth array from the kinect
 DONE____ask about a pixels related info (location in image, location in depth array, hires depth value, depthImage greyscale
 DONE____ask each pixel for related info and compare all pixel info to all other pixel info
 DONE____answer questions about the entire depth image as a whole (eg Where, out of everywhere, is the closest? furthest? 
 DONE____translate from code that runs on a series of individual points to information that holds up for all points in the image.
 DONE____make transition from static single pixel analysis to conclusions about the entire single frame
 DONE____make transition from conclusions about the entire single frame to information about frames in motion over time.  
 DONE____How can I use variables to aggregate data from individual pixels into a more widely useful form?  SCOPE
 
 ____uh oh, usb extension cord issues with the Kinect....  email greg bornestein:  awaiting response
 
 NOTES:
 ->Kinect; // depth resolution = 11bits per pixel (0-2047).  range: 20inches - 25feet (0-8000 millimeters). brightness() values of 0-255.  
 relationship between distance and brightness is not a simple linear ratio.
 !Kinect's depth readings have millimeter precision. If millimeter units, then how many millimeters in 25 feet?  nearly 8000 millimeters. 
 8000 millimeters is far more than can fit in the bit depth of the depth image pixels (0-255).  How do we map these 2?  use the map() function?
 Using map() function would be like pulling stretchy cloth to cover a large area: more cloth isn't created, just space added between threads.
 Mapping brightness() to 8000millimeters would stretch 255 without enough information to cover intermediate values.  
 In order to cover all 8000 distance values without holes, we need to access the depth data from the Kinect in some higher resolution form.
 Asking brightness() of a depth pixel reduces the 11bit resolution (0-2047) to 8bits (0-255).
 
 
 ->PImage(); // class provides all kinds of useful functionso for working with images such as the ability to access and alter individual pixels
 Having the Kinect data in the form of a PImage is an advantage because it means we can use the kinect data with other libraries
 that themselves don't know anything about the kinect, but do know how to process PImages.  PImages force the use of 8bit pixel depth. 
 Using PImage to store and draw depthImage requires a compression of depthImage's 11bit pixel depth to 8bit.  0-2047 vs 0-255.
 Advantage of using PImage reduction of depthImage is conservation of CPU.  no need for that many shades of gray.  
 
 ->frameRate(); //Kinect delivers 30fps.  Processing tries for 60Hertz.  If we loop more or less than 30cycles/sec, then we get either 
 too few or too many images per loop.  Keeping Processing looping at same rate of Kinect framerate is ideal.  
 Cannot simply set frameRate in the sketch to (30), since we do not know the load placed on the app while running, especially if interactive.
 
 ->depthImage(); // 640x480.  the color of each pixel in the depth image represents the distance in that part of the scene (0-255) GREYSCALE;
 r()g()b() extracted values from color variable passed by return from get() at mouseX mouseY reveals 3 equal values.  sine color is difference
 between rgb values, greyscale will always have 3 equal values.  BRIGHTNESS is the DISTANCE between white and black.
 But what of the pixels ACTUAL DEPTH?  How far away is a greyscale brightness() extracted value of 142 or 19?
 To access depthImage:  compress and store 11bit into 8bit PImage, draw PImage, get() brightness() of drawn pixel. But this is impratical when
 we want to access the depthImage at its full 11bit resolution, or when we want to access more than a single pixel's worth of depth value
 How do I access the depth data without having to first display the pixels?  Ans: access the array of pixels directly (while they are offstage)
 In Processing and most Graphics Programming Environments, image data is stored as arrays of pixels behind the scenes.  Accessing these arrays
 directly will let our programs run fast enough to do some really interesting things (eg. working with the higher resolution data 
 and processing more than one pixel at a time)
 
 ->rgbImage(); //  each pixel of the color image has 3 components (0-255) for R, G, and B.
 
 ->get(); // a function provided by Processing to let me access the value of any pixel ALREADY drawn on the screen. In this program
 pixels are drawn from Kinect depth and rgb image.  the function takes two arguments X and Y coordinates.
 
 ->color(); // color is a variable type used to store color.  since get() returns a color value, we store get() info into color variable c.
 
 ->red(), green(), blue() // Processing functions used to extract each of these component values from the color variable type.
 color comes from a difference between indicudual color compenents (128,10,10)=red, (128,128,128)=grey (250,128,128)=red
 overall brightness is determined by the sum total between the levels of all 3 components
 
 ->brightness(); // Processing function used to extract the value of a pixels distance between white and black. (like red(),green()blue().
 clicking around in the black areas of the depth image reveals different brightness values even though the image is definitely BLACK.
 Why is there detailed depth information even in parts of the image where the eye can't see different shades of grey?
 Looking for gaps in pixels brightness = edge detection.  Looking for brightest pixel = closest point to kinect. 
 How do we translate from brightness() value to real world distance? 
 
 1-D Arrays of 2-D images; //  TRANSLATIONS!!  how do we figure out which pixel is clicked on (TRANSLATE from image to array)?  how do we draw something on the screen
 where we found a particular depth value (TRANSLATE from array to image)?  How do I convert between array in which pixel is stored and pixel's position
 Notice that the first pixel of every line is always a multiple of the screen.width (or in this case, 640)
 ->depthMap(); // a SimpleOpenNI function that provides access to higher resolution depth data unmodifed - neither converted nor processed values
 What is the form of depth values returned by depthMap()?  Ans:  can't be stored as the pixels of image as with depthImage(); because 
 higher res depth values can't be stored in the 8bits provided by a pixel.  
 Ans:  depthMap() values are stored as an array of integers.  there is one high res depth value for each pixel in the depth image.
 since depthImage() = 640x480, there are640x480 pixel locations, each represented in the depthMap() 1D array. 307,200 indexes in single linear stack
 in depthImage() we use get(x,y) to return the pixel values at x,y then stored it as color c = get(mouseX,mouseY);
 with depthMap() we assoicate  the pixel x,y location with the corresponding location in the 1D array.  When mousePressed,
 calculate that pixels location in the array as mouseX +(mouseY*screen.width); // thus turning x,y cordinates into an index #
 
 [From static analysis to conclusions about process] 
 1.Get info on a pixel.  2.Over time scan every pixel from a set of pixels that are presented all at once in parallel as an emergent image.
 3.Using information gathered by a serial process from a parallel emergent image, make a parallel conclusion about all static pixels 
 within the emergent image. 1b Get info on an image. 2b.Over time, scan every parallel conclusions about all static pixels within a series
of emergent images presented as an emergent video.  3b.Using information gathered by a serial process from a parallel emergent video,
make a parallel conclusion about all static images within an emergent video.  1c. Gather info on videos.  .....
it's like going serial scan over each static pixel to parallel simultaneous conclusion about the entirety of those static pixels
then going from serial conclusions about several parallel conclusions from static-pixel-entireties 
to a parellel conclusion of single frames over time  ENOUGH!

Going from code running serial analysis of individual points to information regarding the emergent image, we need variables that store 
information about the RELATIONSHIPS between individual points.  If they aren't moving, then we must move our point of analysis.
What's the difference between moving through static environment and stasis in a moving environment.  Did I just happen upon the Liebniz 
vs Newton debate on substantival space?  Spinning bucket ring any bells? For reals, philosophical seque = done.

Variables to hold information about the RELATIONSHIPS between pixels.  At the end of one sweep through all depth values presented at
time t, variables are gathered, tested and acted on.  Cycle repeats with new set of static data points.  In closestValue, closestX, closestY,
we store the information that we "build up" from processing each individual depth point. 

SCOPE:  describes HOW LONG a variable sticks around.  The quality of "stick-aroundness" is what allows variables to aggregate data
eg. does a variable stick around only inside a for loop (int i = 0.....???
does the variable exist only in a single function? (a local variable)?
is the variable initialized before setup, allowing it persist in the entire sketch as a global variable?
In this sketch we have them all 3.  

'THE DATA TUNNELS ITS WAY OUT FROM THE INNERMOST SCOPE WHERE IT RELATES ONLY TO SINGLE PIXELS TO THE OUTER SCOPE WHERE IT CONTAINS
INFORMATION ABOUT THE ENTIRE DEPTH IMAGE, THE LOCATION AND DISTANCE OF ITS CLOSEST POINT.'  -g.borstein

Consider the variables as existing on different plans of reality within the sketch where each plane of reality covers a different SCOPE.
Once a variable is assigned, it stays set for all the realities inside the one in which it wsa originally assigned.
One plane of reality is global, and is therefore available everywhere.  Variables defined outside of any function are omnipresent. 
Variables defined within a lower plane only exist inside that lower plane of reality, and they DISAPPEAR whenever we leave that layer.
Like jumping from one individual consciousness to another.  Collective consciousness exists in setup() and draw(), but individual consciousnesses
must be REINHABITED everytime we re enter the plane on which that individual was created.  If we leave that plane, our awareness of what is means
to be that individual consciousness is lost.  If we want to create a variable to store info about an individual consciousness, then we have to 
declare that variable on the appropriate plane of reality.  We wouldn't want to try to aggregate relationships between individual consciousness
with variables that build up values over multiple consciousness.  We have different variables for that.  We declare and initialize clean, new
variables for use with each individual.  Other variables, created with larger scope, store info about the collective consciousness by aggregate 
 info about the relationships of individuals.  
 Look at the draw() in this sketch.  in the inner most sanctum, inside the double for-loop where the individual pixel lives, 2 variables
 are declared.  One is specific to the pixels location, the other to the depthValue associated with that pixels location.  Once we leave the loop,
 those variables are essentially erased.  However, they live on, because information gleaned from them are passed to variables that are
 used inside the inner sanctum, but which were themselves declared and initilized on a higher plane of reality.  It's like a net that dips 
 down into the water, the hand of God reaching down to provide a path to a higher level of consciousness.  Information passed into
 higher planes of reality emerge from lower level processes as collective effervescence (or information about connections between
individuals collectively experiencing a process), but the individuals and the lower level processes they experience remain on the level 
within which they were orignially initialized.  the 'i' of the inner most scope, along with the currentDepthValue assoiciated with this inner 'i,'
are declared inside the inner most scope precisely because they must reflect the individuality of each pixel.  It's not the 'i' which transcends,
it's not even the 'i' with the winning depth value that transcends.  What transcends is the high water mark produced by a group of individuals 
collectively experiencing a single process.  
Some info we want to change at every draw, but we want to stay the same inside all for loops and functions inside draw().  These we create 
as relatively global variables at the top of draw().  These are like the collective consciousnesses of a city.  Everyone in NYC has NYC
inside of them, but NYC is not inside America.  This is why I moved here, to allow the collective intelligence of NYC to inhabit me by
residing inside my particular layer of reality.  Only by existing inside the draw() loop do []depthValues exist.  At the end of the cycle,
the depthValues must be born again with no memory of what they were in the previous iteration.  There's no information carried over into
their next life.  Since we want to pull in a new frame from the kinect at every draw cycle, we want the variable holding the incoming information
to be reset.  Hmmmm, interesting argument for death.  Imagine the issues of rejuvinations and memory crystals and potential immortality.  
We'd have to create parts of ourselves that were erasable, but still connected to our higher SELF.  We'd have to partially renew ourselves,
or better, renew our partial selves.  Without a clean break from information about the past, we could never experience an experience of having
no previous experience.  Hence, some variables should get reset everytime the draw function restarts.  However, we do want some variables
to persist for the duration of the draw cycle so that they may experience the full extent of all internal processes. The depthValues array, 
for example, must exist for an entire cycle so that all the individuals there unto pretaining can be analyzed.  We wouldn't want to call
an update from the kinect before the current array of pixels are scanned and relevant information saved.  
As for variables in the highest plane of reality, the so called "global" variables to which the application has UNIVERSAL access at all times.
What is the term to describe an entity that exists anywhere at all times?  Omnipresent?  No matter how many times the variables of the
inner cycles die and are reborn, information gathered from their internal processes can live on.  This is how stable information of a dynamic
system can persist in the face of constant novelty.  this is also how a single piece of information from a single individual can effect
the overall outcome of the whole entity.  The individual pixel does not need to contain information about other pixels in order to contribute
to conclusions about the emergent image.  Even though the inner loop only asks for the depth Value of the current pixel, it can constantly
compare this depth with the closestValue, changing it if necessary.  A single pixel imbued with the qualities collected by higher order processes,
can connect to the highest order behaviors achievable by the system.
Color emerges from variations in brightness levels.  If r,g,and b are of equal brightness, the color is greyscale.  Complexity in software arises
from variation in the SCOPES of its variables.

One way to make a sketch more sophisticated is to take advantage of the global scope of variables.  closestX closestY get reset through every
loop, as does closetValue.  They could have been created inside the top level of draw.  Having them top level global however, does reveal the 
intentions of the application.  It also gives us the ability to access the their global scope.  Transition from resetting the global variables
to updating the global variables.  Updating implies retaining information from the past.  Updating and retaining past info of closestX closestY
would allow us to do things like smoothing by averaging location over time to iron out the abrupt transitions inherent in resetting the variables.

Using the global scope of closestValue could give lead to information about the distance between where the closestValue was, and where 
it is currently.  Kinect.depthImage(1) closestValue = closestValue1.  Variables then arrise to handle metadata about connections between connections
Change persistance over time.  With this information, certain thresholds can be used as triggers.  Example, draw a line between the location of
Previous closetValue and the location of currrent closestValue iff the distance between the two is greater than the square root of the distance 
between the current close point and the kinect.  Or something like THAT.  Track my hand only if it moves MORE than a certain amount.
If I move quickly, then distance is greater, then draw THIS, otherwise draw THAT.

 */

import SimpleOpenNI.*;  //importing the SimpleOpenNI library, which is a wrapper for the OpenNI toolkit provided by PrimeSense
SimpleOpenNI kinect;  // declares the SimpleOpenNI object and names it "kinect."  this object is used to access of the Kinect's data

int closestValue; //holds high res depth value from depthMap associated with a pixels location in the depthImage
int closestX;//holds x cordinate of pixel with closest depth value
int closestY;//holds y cordinate of pixel with closest depth value

void setup() {
  size (640, 480); // declare the size of our application.  width set to doube the width of both Depth and RGB
  kinect = new SimpleOpenNI(this); //instantiate the previously declared instance of the SimpleOpenNI object

  //TURN ON ACCESS DEPTH IMAGES FROM KINECT
  kinect.enableDepth(); // enableDepth() method using dot syntax to attach this function to the specific instance of the SimpleOpenNI object
}
void draw () {
  closestValue = 8000; // this is the limit of the depth value and represents the furthest object (and closest at starting point)

  //UPDATE the DEPTH IMAGES FROM KINECT
  kinect.update();  //call the update function on the 'kinect' object.  why is this a function and not a method?

  //get the depth array from the kinect
  int []depthValues = kinect.depthMap();

  //SCAN ALL PIXELS FROM 0 - 300,702.  If it's not closer than what we got, keep going, otherwise, replace current with new closest
  //for each row in the depth image
  for (int y=0; y<480; y++) { //for every one of these rows starting at the top and going down, look at every pixel along the way

    //look at each pixel in the row
    for (int x=0; x<640; x++) {  // all the way across to the end

      //and pull out the corresponding value from the depth array
      int i = x + (y*640);  //at each x,y coordinate, convert your location to the corresponding index in the depthMap array
      int currentDepthValue = depthValues[i];  //reach into that array at that index and store that distance into the currentDepthValue var

      //if the current pixel is the closest one we've seen so far
      if (currentDepthValue > 0 && currentDepthValue < closestValue) {  //Test for a nonZero currentDepthValue 
        //that's closer than the closest value  depth value.  0 depth values happen at occlusions, in depth shadows where there's no data
        // or if the point is closer than the minimum range of 20inches (450mill).  By testing for currentDepthValue greater than 0, 
        //we use only points that have nonZero readings

        //then save its value as the closestValue
        closestValue = currentDepthValue;
        //and and then save its x,y position
        closestX = x;
        closestY = y;
        //what emerges after one analysis cycle of 300,000 individual pixels is 3 pieces of information about the group. 
      }
    }
  }

  //draw the depth image on the screen
  image (kinect.depthImage(), 0, 0);

  //draw a red circle over it at the x,y location of the pixel with the closest depth value
  fill (255, 0, 0);
  color c = get(closestX, closestY);
  ellipse(closestX, closestY, 15, 15);


  //PImage depthImage = kinect.depthImage();  // this makes the return type of the image-accessing function explicit vs image(kinect.depthImage(),0,0)
  //image(depthImage, 0, 0);  // the kinect.depth is already called; its return type is stored in a PImage which is passed to this image function
}

// Get INFO for each pixel:  when mouse click on a pixel, print out information on that pixel
void mousePressed () {  // this function gets called everytime whenever mousePressed inside the running app
  int[] depthValues = kinect.depthMap(); //creat an array called depthValues from this instance of the kinect object's depthMap
  int clickPosition = mouseX + (mouseY*640); //the clicked pixel's position in the 1-D array is its mouseX value + the total value of mouseY*screen.width
  int millimeters = depthValues[clickPosition]; // reach into index # "clickPosition" on the 1-D array, get that value, and store it in clickedDepth variable.

  float inches = millimeters/25.4; // if clickedDepth is 0-8000? how would / by 25.4 work?  1inch * 12 is a foot.  1 foot * 25 = range of kinect
  // 12inches * 25 feet = 400inches/25feet.  8000millimeters/25feet.  8000

  println("millimeters: " + millimeters + " inches: " + inches);
}

