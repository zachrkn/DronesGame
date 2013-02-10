//==========================CLASS DECLARATION==================================
class DronesPlayerController extends PlayerController;

//==========================VARIABLES==========================================
var Actor LastTraceHit;
var DronesDrone LastTraceHitDrone;
var array<DronesBrickPhantom> LastPhantomStructureBrickArray;

var DronesHUDWrapper HUDWrapper;

var float LastOverallDroneSpeed;

var bool bPause;

var Actor Sphere;
//==========================EVENTS==========================================
event simulated PostBeginPlay()
{	
/*
	super.PostBeginPlay();
	Sphere = Spawn(class'DronesSphereOfInfluence',,,Pawn.Location,Pawn.Rotation);
	Sphere.SetBase(Pawn);
	//Sphere.SetHardAttach(TRUE);
	Sphere.SetPhysics(PHYS_Interpolating);
*/
}

/** Inherited from parent class
 *  Calls the HUDWrapper's SetMouseCoordinates function every tick, which in turns moves the mouse in the GUI.
 *  If I find an event that happens every tick in the HUD class, this wouldn't have to be here */
event PlayerTick( float DeltaTime )
{	
	local vector ThisVectorLocation;
	local vector cameraLocation;
	local rotator cameraRotation;
	local Actor traceHit;
	local TraceHitInfo hitInfo;
	local vector hitLoc, hitNorm, startTraceLoc, endTraceLoc;
	local DronesDrone TraceHitDrone;
	local DronesBrickSMActor ThisSMBrick;
	local DronesBrickKActor ThisKBrick;
	local array<DronesBrickKActor> OverlappedKBricks;
	local int i;
	
	super.PlayerTick( DeltaTime );
		
	HUDWrapper = DronesHUDWrapper(myHUD);
	
	if (Pawn.Location.Z < -1000)
	{
		ThisVectorLocation.X = 0;
		ThisVectorLocation.Y = 0;
		ThisVectorLocation.Z = 50;
		Pawn.SetLocation(ThisVectorLocation);
	}
	
	if(bPause)
	{
	cameraLocation = DronesPawn(Pawn).FinalCameraLocation;
	cameraRotation = DronesPawn(Pawn).FinalCameraRotation;
	endTraceLoc = cameraLocation + normal(vector(cameraRotation))*32768;
	startTraceLoc = cameraLocation;
	traceHit = trace(hitLoc, hitNorm, endTraceLoc, startTraceLoc, true, , hitInfo);

	if( LastTraceHitDrone != NONE)
	{
		LastTraceHitDrone.ToggleHighlightOff();
	}
	if( traceHit==none || traceHit.class.name != 'DronesDrone' )
	{
		HUDWrapper.bDrawDroneInfo = FALSE;
		if( LastTraceHit != NONE)
		{
			if( LastTraceHit.class.name == 'DronesDrone' )
			{
				// destroy the phantom structure
				DestroyPhantomStructure();
			}
		}
	}
	else
	{
		HUDWrapper.bDrawDroneInfo = TRUE;
		TraceHitDrone = DronesDrone(traceHit);
		TraceHitDrone.ToggleHighlightOn();
		
		if( traceHit != LastTraceHit )
		{
			//`Log("traceHit is not equal to LastTraceHit.  traceHit: "$traceHit$" and LastTraceHit: "$LastTraceHit);
			// destroy the phantom structure
			DestroyPhantomStructure();
			// build new phantom structure
			BuildPhantomStructure( DronesDroneAIController(DronesDrone(traceHit).Controller).StructureBlueprint );
		}
		LastTraceHitDrone = TraceHitDrone;
	}
	LastTraceHit = traceHit;
	} // end bpause

	foreach OverlappingActors(class'DronesBrickSMActor', ThisSMBrick, 500, Pawn.Location, TRUE)
	{
//		ThisBrick.BrickParentShell.GainCollision();
//		ThisBrick.SetPhysics(PHYS_RigidBody);
		`Log("Overlapping SM Brick: " $ThisSMBrick$ " so going to destroy it and spawn a kbrick");
		ThisSMBrick.BrickParentShell.DestroySMBrickAndSpawnKBrick();	
	}

	foreach OverlappingActors(class'DronesBrickKActor', ThisKBrick, 500, Pawn.Location, TRUE)
	{
		OverlappedKBricks.AddItem(ThisKBrick);
	}
	
	foreach AllActors(class'DronesBrickKActor', ThisKBrick)
	{
		if( OverlappedKBricks.Find( ThisKBrick ) < 0 )
		{
			ThisKBrick.BrickParentShell.DestroyKBrickAndSpawnSMBrick();
		}
	}

}


 
//==========================EXECS==========================================
exec function ResetBricks()
{
	DronesGame(WorldInfo.Game).ResetBricksIndex = 0;
	DronesGame(WorldInfo.Game).bResetBricks = TRUE;
}
exec function StopResettingBricks()
{
	DronesGame(WorldInfo.Game).bResetBricks = FALSE;
}

exec function ResetDrones()
{
	DronesGame(WorldInfo.Game).ResetDrones();
}
/*
exec function StartFire( optional Byte FireModeNum )
{
	local vector cameraLocation;
	local rotator cameraRotation;
	local Actor traceHit;
	local TraceHitInfo hitInfo;
	local vector hitLoc, hitNorm, startTraceLoc, endTraceLoc;
		
	cameraLocation = DronesPawn(Pawn).FinalCameraLocation;
	cameraRotation = DronesPawn(Pawn).FinalCameraRotation;
	
	endTraceLoc = cameraLocation + normal(vector(cameraRotation))*32768;
	startTraceLoc = cameraLocation;
	
	traceHit = trace(hitLoc, hitNorm, endTraceLoc, startTraceLoc, true, , hitInfo);
	
	if(traceHit != none)
	{
		HUDWrapper.DrawTraceHitActorMsg(traceHit);
		if(traceHit.class.name == 'DronesDrone')
		{
			DronesDrone(traceHit).Feed();
			HUDWrapper.DrawMessageFedDrone();
		}
		else
		{
			HUDWrapper.DrawMessageNothingHit();
		}
	}
	else
	{
		HUDWrapper.DrawMessageNothingHit();
	}
}
*/
/*
exec function StartAltFire( optional Byte FireModeNum )
{
	local vector cameraLocation;
	local rotator cameraRotation;
	local Actor traceHit;
	local TraceHitInfo hitInfo;
	local vector hitLoc, hitNorm, startTraceLoc, endTraceLoc;
	local DronesDroneAIController ThisController;
		
	cameraLocation = DronesPawn(Pawn).FinalCameraLocation;
	cameraRotation = DronesPawn(Pawn).FinalCameraRotation;
	
	endTraceLoc = cameraLocation + normal(vector(cameraRotation))*32768;
	startTraceLoc = cameraLocation;
	
	traceHit = trace(hitLoc, hitNorm, endTraceLoc, startTraceLoc, true, , hitInfo);
	
	if(traceHit != none)
	{
		if(traceHit.class.name == 'DronesDrone')
		{
			ThisController = DronesDroneAIController(DronesDrone(traceHit).Controller);
			if( ThisController.bHoldingBrick )
			{
				ThisController.PickUpBrick.SetBaseToSelf();
				ThisController.PickUpBrick.GainCollision();
				ThisController.PickUpBrick.Availability = AVAIL_Available;
			}
			
			DronesDrone(traceHit).Kill();
			
		}
		else
		{
		}
	}
	else
	{
	}
}
*/
exec function ShowMenu()
{
   //ConsoleCommand("Quit"); // call the quit command to quit.
   	DronesGame(WorldInfo.Game).Reset();
	WorldInfo.Reset();
}

exec function Use()
{
	//ConsoleCommand("open DronesLandscape01");
//	`Log("In USE exec function");
	DronesGame(WorldInfo.Game).Reset();
	WorldInfo.Reset();
	ConsoleCommand("RestartLevel");
}

exec function PauseDrones()
{
	local DronesDrone ThisDrone;
	local DronesDroneAIController DroneController;
	
//	`Log("In exec PauseDrones");
	bPause = TRUE;
	
	foreach AllActors(class'DronesDrone', ThisDrone)
	{
		//DronesGame(WorldInfo.Game).CurrentDroneSpeed = 0;
		DroneController = DronesDroneAIController(ThisDrone.Controller);
		DroneController.PushState('PauseDrone');
	}
}

exec function UnpauseDrones()
{
	local DronesDrone ThisDrone;
	local DronesDroneAIController DroneController;

	bPause = FALSE;
//	`Log("In exec UnpauseDrones");
	
	foreach AllActors(class'DronesDrone', ThisDrone)
	{
		//DronesGame(WorldInfo.Game).CurrentDroneSpeed = DronesGame(WorldInfo.Game).OverallDroneSpeed;
		DroneController = DronesDroneAIController(ThisDrone.Controller);
		DroneController.PopState();
	}
}
/*
exec function PrevWeapon()
{
	if( DronesGame(WorldInfo.Game).OverallDroneSpeed < 200)
	{
		DronesGame(WorldInfo.Game).OverallDroneSpeed += 2;
	}
}

exec function NextWeapon()
{
	if( DronesGame(WorldInfo.Game).OverallDroneSpeed > 0.0)
	{
		DronesGame(WorldInfo.Game).OverallDroneSpeed -= 2;
	}
}
*/
//==========================STATES==========================================


//==========================FUNCTIONS==========================================
function BuildPhantomStructure( DronesStructureBlueprint Blueprint )
{	
	local int i;
	local vector v;
	local rotator r;
	local DronesBrickPhantom NewPhantomBrick;
//	local StaticMeshComponent ThisStaticMeshComponent;
//	local MaterialInstanceConstant ThisMaterialInstanceConstant;
//	local float CurrentOpacity;
	
	for( i=0; i<Blueprint.BrickWorldLocationsArray.Length; i++)
	{
		v = Blueprint.BrickWorldLocationsArray[i];
		r = Blueprint.BrickWorldRotationsArray[i];
		NewPhantomBrick = Spawn(class'DronesBrickPhantom',,,v,r,,FALSE);		
		LastPhantomStructureBrickArray.AddItem(NewPhantomBrick);
	}
}

function DestroyPhantomStructure( )
{
	local DronesBrickPhantom Brick;
	foreach LastPhantomStructureBrickArray( Brick )
	{
		Brick.Destroy();
	}
}


/** Inherited from parent class
 *  Controller rotates with turning input 
 *  I didn't write most of this code, so I don't understand everything it does
 *  I only added in the if clause to only update the pawn's facerotation if the right mouse button isn't down and the GUI isn't showing */
function UpdateRotation( float DeltaTime )
{
	local rotator DeltaRot, NewRotation, ViewRotation;

   ViewRotation = Rotation;
   if (Pawn!=none)
   {
      Pawn.SetDesiredRotation(ViewRotation);
   }

   // Calculate Delta to be applied on ViewRotation
   DeltaRot.Yaw   = PlayerInput.aTurn;
   DeltaRot.Pitch   = PlayerInput.aLookUp;

   ProcessViewRotation( DeltaTime, ViewRotation, DeltaRot );
   SetRotation(ViewRotation);

   NewRotation = ViewRotation;
   NewRotation.Roll = Rotation.Roll;
	
	Pawn.FaceRotation(NewRotation, deltatime); //notify pawn of rotation


}


//==========================DEFAULT PROPERTIES==========================================
DefaultProperties
{
	bPause=FALSE
	LastTraceHit=None
	LastTraceHitDrone=None
}