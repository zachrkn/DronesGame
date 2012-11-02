//==========================CLASS DECLARATION==================================
class DronesHUDWrapper extends UDKHUD;

//==========================VARIABLES==========================================
/** Reference the actual SWF container (UDNGFxHUD created in the PostBeginPlay function) */
var DronesGFxHUD HUDMovie;

/** Whether or not the GUI is currently showing
 *  Set in the exec function ShowGUIToggle
 * 	Used in the class UDNPawn in the function calcCamera
 *	Used in the class UDNPlayerController in the function UpdateRotation 
 *	Used in the class UDNPlayerController in the exec function StartFire (handles left click) */
var bool bIsGUIShowing;

/** Holds the resolution of the HUD
 *	Set in the function PostBeginPlay
 *	Used in the class UDNPlayerController in the function GetHUDSize */
var GFxObject HUDMovieSize;

/** Holds the current coordinates of the GUI mouse
 *  Set and used in the function SetMouseCoordinates */
var Vector2d CurrentMouseCoordinates;

// The texture which represents the cursor on the screen
var const Texture2D CrosshairTexture; 
// The color of the cursor
var const Color CrosshairColor;

var bool bDrawMessageNothingHit;
var int DrawMessageNothingHitDisplayCountDown;
var bool bDrawMessageFedDrone;
var int DrawMessageFedDroneDisplayCountDown;
var bool bDrawDroneInfo;

//==========================EVENTS==========================================
/** Inherited from parent class */
simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	
	//Create a UDNGFxHUD for HUDMovie
	HUDMovie = new class'DronesGFxHUD';

	//Call the Init2 function of UDNGFxHud (HUDMovie) and pass it PlayerOwner which is of type UDNPlayerController
	HUDMovie.Init2(HUDMovie.PlayerOwner);
	
	// Set HUDMovieSize to hold the GFxObject which holds the resolution of the HUD
	HUDMovieSize = HUDMovie.GetVariableObject("Stage.originalRect");
	
	// Hides the GUI so it is not showing initially
	HUDMovie.hideGUI();
}

event Tick( float Deltatime )
{
	DrawMessageNothingHitDisplayCountDown -= 1;
	DrawMessageFedDroneDisplayCountDown -= 1;
}


//==========================EXECS==========================================
/** Used to show and hide the GUI.  Calls the showGUI and hideGUI function of the class UDNGFxHUD to get er done.
 *	Triggered by the cmd input event when the middle mouse button is released */
exec function ShowGUIToggle()
{
/*
	// if GUI is hidden, show it
	if(!bIsGUIShowing)
	{
		// Call the showGUI function of the HUDMovie instance of the UDNGFxHUD class
		HUDMovie.showGUI();
		bIsGUIShowing = true;
	}
	// if GUI is showing, hide it
	else
	{
		// Call the hideGUI function of the HUDMovie instance of the UDNGFxHUD class
		HUDMovie.hideGUI();
		bIsGUIShowing = false;
	}
*/
}

//==========================FUNCTIONS==========================================
function DrawMessageNothingHit()
{
	bDrawMessageNothingHit = TRUE;
	DrawMessageNothingHitDisplayCountDown = 255;
}

function DrawMessageFedDrone()
{
	bDrawMessageFedDrone = TRUE;
	DrawMessageFedDroneDisplayCountDown = 255;
}



function SetMouseCoordinates()
{
	local Vector2d newMouseChange;
	local PlayerController PC;
	local DronesPlayerController ThisDronesPlayerController;
	local float HUDWidth, HUDHeight;
	
	HUDWidth = HudMovieSize.GetFloat("width");
	HUDHeight = HudMovieSize.GetFloat("height");
	
	PC = WorldInfo.Game.GetALocalPlayerController();
	ThisDronesPlayerController = DronesPlayerController(PC);
	newMouseChange.X = ThisDronesPlayerController.PlayerInput.aMouseX;
	newMouseChange.Y = ThisDronesPlayerController.PlayerInput.aMouseY;
	
	if(bIsGUIShowing)
	{
		CurrentMouseCoordinates.X = Clamp( ( (newMouseChange.X/12) + CurrentMouseCoordinates.X), 0, HUDWidth);
		CurrentMouseCoordinates.Y = Clamp( ( -(newMouseChange.Y/12) + CurrentMouseCoordinates.Y), 0, HUDHeight);
	}
	
	HUDMovie.SetMouseCoordinates(CurrentMouseCoordinates);
}


/**
 * This function is called to draw the hud while the game is still in progress.  You should only draw items here
 * that are always displayed.  If you want to draw something that is displayed only when the player is alive
 * use DrawLivingHud().
 */
function DrawGameHud()
{
//	super.DrawGameHUD();

	DisplayLocalMessages();
	DisplayConsoleMessages();
}

//==========================DEBUG==========================================
/** Draws current mouse coordinates to the screen */
event PostRender()
{
	local float HUDWidth, HUDHeight;
	local DronesPlayerController ThisDronesPlayerController;
	local DronesDrone DroneToDrawInfo;
	local DronesDroneAIController DroneAIController;
	local vector DestinationRangeSize;
	local vector DestinationRangeCenter;
	
	HUDWidth = HudMovieSize.GetFloat("width");
	HUDHeight = HudMovieSize.GetFloat("height");

	if(bDrawMessageNothingHit && DrawMessageNothingHitDisplayCountDown > 0)
	{
		Canvas.SetDrawColor( 255, 0, 0, DrawMessageNothingHitDisplayCountDown );
		Canvas.SetPos( 25, 950 );
		Canvas.DrawText( "Clicked on nothing... Try clicking on a drone to feed it",,1.5,1.5 );
	}
	
	if(bDrawMessageFedDrone && DrawMessageFedDroneDisplayCountDown > 0)
	{
		Canvas.SetDrawColor( 255, 0, 0, DrawMessageFedDroneDisplayCountDown );
		Canvas.SetPos( 25, 990 );
		Canvas.DrawText( "Fed drone!",,1.5,1.5 );
	}
	
	if(bDrawDroneInfo)
	{
		HUDWidth = HudMovieSize.GetFloat("width");
		HUDHeight = HudMovieSize.GetFloat("height");
	
		ThisDronesPlayerController = DronesPlayerController(WorldInfo.Game.GetALocalPlayerController());
		DroneToDrawInfo = ThisDronesPlayerController.LastTraceHitDrone;
		DroneAIController = DronesDroneAIController(DroneToDrawInfo.Controller);
		DestinationRangeSize = DroneAIController.DestinationRangeSize;
		DestinationRangeCenter = DroneAIController.DestinationRangeCenter;
		
		Canvas.SetDrawColor( 255, 0, 0, 255 );
		Canvas.SetPos( 600, 950 );
		Canvas.DrawText( "Drone Area of Influence Center: X="$DestinationRangeCenter.X$"  Y="$DestinationRangeCenter.Y$"  Z="$DestinationRangeCenter.Z,,1.5,1.5 );
		Canvas.SetPos( 600, 990 );
		Canvas.DrawText( "Drone Area of Influence Size: X="$DestinationRangeSize.X$"  Y="$DestinationRangeSize.Y$"  Z="$DestinationRangeSize.Z,,1.5,1.5 );
	}
	
		Canvas.SetDrawColor( 255, 0, 0, 255 );
		Canvas.SetPos( 1360, 950 );
		Canvas.DrawText( "Drone Speed: "$DronesGame(WorldInfo.Game).OverallDroneSpeed,,1.5,1.5 );
		
		Canvas.SetDrawColor( 255, 0, 0, 255 );
		Canvas.SetPos( 1360, 990 );
		Canvas.DrawText( "Number of Drones: "$DronesGame(WorldInfo.Game).NumDrones,,1.5,1.5 );		
	
      // Set the crosshair position to the center of the screen
      Canvas.SetPos( (HUDWidth/2 - CrosshairTexture.SizeX/32), (HUDHeight/2 - CrosshairTexture.SizeY/32)); 
      // Set the crosshair color color
      Canvas.DrawColor = CrosshairColor;
      // Draw the texture on the screen
      Canvas.DrawTile(CrosshairTexture, CrosshairTexture.SizeX/16, CrosshairTexture.SizeX/16, 0.f, 0.f, CrosshairTexture.SizeX, CrosshairTexture.SizeY,, true);

}

//==========================DEFAULT PROPERTIES==========================================
DefaultProperties
{
	bDrawMessageNothingHit = FALSE
	bDrawMessageFedDrone = FALSE

	bIsGUIShowing = FALSE
	CrosshairColor=(R=255,G=255,B=255,A=255)
	//CrosshairTexture=Texture2D'EngineResources.Cursors.Arrow'
	CrosshairTexture=Texture2D'DronesHUD.DronesCrosshair'
}


