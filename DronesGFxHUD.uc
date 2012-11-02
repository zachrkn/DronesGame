//==========================CLASS DECLARATION==================================
class DronesGFxHUD extends GFxMoviePlayer;

//==========================VARIABLES==========================================
/** Declare a variable of the type of PlayerController
 *	Set in the parent of this class???
 *	Used in the class UDNHudWrapper in the function PostBeginPlay */
var DronesPlayerController PlayerOwner;

/** Hold the mouse X and Y positions.
 *  Set in the function ReceiveMouseCoords
 *  Used in the class UDNHudWrapper */
var Vector2d MouseCoordinates;

//==========================FUNCTIONS==========================================
/** Initializes the HUD by starting the movie and advancing it
 *	Called in the class UDNHUDWrapper in the function PostBeginPlay */
function Init2(DronesPlayerController PC)
{
	//Start and load the SWF Movie
	Start();
	Advance(0.f);
}

/*
// This is called from Flash to tell UDK what the new mouse coordinates are
function ReceiveMouseCoords( float x, float y )
{
	`Log("in class UDNGFxHUD in function ReceiveMouseCoords");
	`Log("x "$x);
	`Log("y "$y);
	MouseCoordinates.X = x;
	MouseCoordinates.Y = y;
}
*/

function SetMouseCoordinates( Vector2d mousePos )
{
	CallASFunction(mousePos.X, mousePos.Y);
}

function CallASFunction(float xCoord, float yCoord)
{
	ActionScriptVoid("setMouseToCoordinates");
}

function showGUI()
{
	ActionScriptVoid("showGUI");
}

function hideGUI()
{
	ActionScriptVoid("hideGUI");
}

//==========================DEFAULT PROPERTIES==========================================
DefaultProperties
{
	//The path to the swf asset we will create later
	//MovieInfo=SwfMovie'DronesHUD.GUI1920x1200'
	MovieInfo=SwfMovie'DronesHUD.GUI1920x1080'
	//MovieInfo=SwfMovie'DronesHUD.GUI1600x1200'
	//MovieInfo=SwfMovie'DronesHUD.GUI1600x1024'
	//MovieInfo=SwfMovie'DronesHUD.GUI'
}