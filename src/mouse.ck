//-----------------------------------------------------------------------------
// name: Mouse.ck
// desc: mouse input for ChuGL and general usage
//       - tracks which mouse buttons are down/up
//       - tracks delta of mouse motion and scroll wheel
//
// author: Andrew Zhu Aday (https://ccrma.stanford.edu/~azaday/)
// date: May 2023
//
// note: see GG.mouseX() and GG.mouseY() to get cursor pos
// note: these are not designed to be shared by multiple shreds;
//             as needed, each shred should create their own
//-----------------------------------------------------------------------------

public class Mouse
{
    // state to track cumulative mouse motion
    // x: mouse delta x
    // y: mouse delta y
    // z: scrollwheel delta
    @(0.0, 0.0, 0.0) => vec3 motionDeltas;

    int mouseState[10];  // TODO: what's the max number of mouse states?
    Event mouseDownEvents[10];

    0 => static int LEFT_CLICK;
    1 => static int RIGHT_CLICK;
    2 => static int MIDDLE_CLICK;

    1.0 => float SPP;  // framebuffer to screen pixel ratio 

    // workaround for mac retina displays
    if (GG.frameWidth() != GG.windowWidth()) {
        2.0 => SPP;
        <<< "retina display detected, SPP = " + SPP >>>;
    }

    // returns motion delts since last time this function was called
    fun vec3 deltas()
    {
        motionDeltas => vec3 tmp;
        @(0.0, 0.0, 0.0) => motionDeltas;  // rezero sum
        return tmp;
    }

    // return the last z
    fun float scrollDelta()
    {
        return motionDeltas.z;
    }

    1.0 => float mouseZ;  // mouse depth in world space
    vec3 worldPos;

    // start this device (should be sporked)
    fun void start(int device)
    {
        // HID input and a HID message
        Hid hi;
        HidMsg msg;

        // open mouse 0, exit on fail
        if( !hi.openMouse( device ) )
        {
            cherr <= "failed to open device " + device <= IO.newline();
            me.exit();
        }
        <<< "mouse '" + hi.name() + "' ready", "" >>>;

        // infinite event loop
        while( true )
        {
            hi => now;
            while( hi.recv( msg ) )
            {
                // mouse motion
                if( msg.isMouseMotion() )
                {
                    if( msg.deltaX )
                        motionDeltas.x + msg.deltaX => motionDeltas.x;
                    if( msg.deltaY )
                        motionDeltas.y + msg.deltaY => motionDeltas.y;
                }
                // mouse button down
                else if( msg.isButtonDown() )
                {
                    1 => mouseState[msg.which];
                    mouseDownEvents[msg.which].broadcast();
                }
                // mouse button up
                else if( msg.isButtonUp() ) {
                    0 => mouseState[msg.which];
                }
                // mouse wheel motion
                else if( msg.isWheelMotion() ) {
                    if( msg.deltaY )
                        motionDeltas.z + msg.deltaY => motionDeltas.z;
                }
            }
        }
    }

    // update mouse world position
    fun void selfUpdate() {
        while (true) {
            GG.mouseX() => float x;
            GG.mouseY() => float y;
            GG.frameWidth() / SPP => float screenWidth;
            GG.frameHeight() / SPP => float screenHeight;

            // calculate mouse world X and Y coords
            if (GG.camera().mode() == GCamera.ORTHO) {
                // calculate screen aspect
               screenWidth / screenHeight => float aspect;

                // calculate camera frustrum size in world space
                GG.camera().viewSize() => float frustrumHeight;  // height of frustrum in world space
                frustrumHeight * aspect => float frustrumWidth;  // width of frustrum in world space

                // convert from normalized mouse coords to view space coords
                // (we negate viewY so that 0,0 is bottom left instead of top left)
                frustrumWidth * (x / screenWidth - 0.5) => float viewX;
                -frustrumHeight * (y / screenHeight - 0.5) => float viewY;

                // convert from view space coords to world space coords
                GG.camera().posLocalToWorld(@(viewX, viewY, -mouseZ)) => worldPos;
            } else { // perspective
                // generate ray going from camera through click location
                GG.camera().screenCoordToWorldRay(x, y) => vec3 ray;

                // calculate spawn position by moving along ray
                mouseZ * ray + GG.camera().posWorld() => worldPos;
            }
            GG.nextFrame() => now;
        }
    }
}

// Mouse mouse
// spork ~ mouse.start(0);

// while (true) {
//     <<< mouse.deltas() >>>;
//     20::ms => now;
// }
