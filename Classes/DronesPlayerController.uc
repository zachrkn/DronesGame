//==========================CLASS DECLARATION==================================
class DronesPlayerController extends PlayerController;

//==========================VARIABLES==========================================
var Actor LastTraceHit;
var DronesDrone LastTraceHitDrone;
var DronesFogVolumeConstantDensityInfo DestinationFogVolume;
var array<DronesBrickKActor> LastPhantomStructureBrickArray;

var DronesHUDWrapper HUDWrapper;

var float LastOverallDroneSpeed;

//==========================EVENTS==========================================
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
	
	super.PlayerTick( DeltaTime );
		
	HUDWrapper = DronesHUDWrapper(myHUD);
	
	if (Pawn.Location.Z < -1000)
	{
		ThisVectorLocation.X = 0;
		ThisVectorLocation.Y = 0;
		ThisVectorLocation.Z = 50;
		Pawn.SetLocation(ThisVectorLocation);
	}
		
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

}

function BuildPhantomStructure( DronesStructureBlueprint Blueprint )
{	
	local vector v;
	local DronesBrickKActor NewPhantomBrick;
	local StaticMeshComponent ThisStaticMeshComponent;
	local MaterialInstanceConstant ThisMaterialInstanceConstant;
	local float CurrentOpacity;
	
	foreach Blueprint.BrickWorldLocationsArray(v)
	{
		NewPhantomBrick = Spawn(class'DronesBrickKActor',,,v,Blueprint.StructureRotation,,FALSE);
		NewPhantomBrick.LoseCollision();
		NewPhantomBrick.SetPhysics(PHYS_None);
		
		// make them translucent
		foreach NewPhantomBrick.ComponentList(class'StaticMeshComponent', ThisStaticMeshComponent)
		{
			ThisMaterialInstanceConstant = ThisStaticMeshComponent.CreateAndSetMaterialInstanceConstant(0);
		}
		ThisMaterialInstanceConstant.GetScalarParameterValue('Opacity', CurrentOpacity);
		ThisMaterialInstanceConstant.SetScalarParameterValue('Opacity',0.8F);
		ThisMaterialInstanceConstant.GetScalarParameterValue('Opacity', CurrentOpacity);
		
		LastPhantomStructureBrickArray.AddItem(NewPhantomBrick);
	}
}

function DestroyPhantomStructure( )
{
	local DronesBrickKActor Brick;
	foreach LastPhantomStructureBrickArray( Brick )
	{
		Brick.Destroy();
	}
}
/*	OUTDATED CODE FOR DRAWING FOG VOLUMES FOR DRONE DESTINATION RANGES
			r.Pitch = 0; r.Yaw = 0; r.Roll = 0;

			NewScale3D.X = DronesDroneAIController(TraceHitDrone.Controller).DestinationRangeSize.X / 256;
			NewScale3D.Y = DronesDroneAIController(TraceHitDrone.Controller).DestinationRangeSize.Y / 256;
			NewScale3D.Z = DronesDroneAIController(TraceHitDrone.Controller).DestinationRangeSize.Z / 256;
			
			DestinationFogVolume = Spawn(class'DronesFogVolumeConstantDensityInfo',,,DronesDroneAIController(TraceHitDrone.Controller).DestinationRangeCenter,r,,);
			DestinationFogVolume.SetDrawScale3D (NewScale3D);
	
			foreach DestinationFogVolume.ComponentList(class'StaticMeshComponent', ThisStaticMeshComponent)
			{
				ThisMaterialInstanceConstant = ThisStaticMeshComponent.CreateAndSetMaterialInstanceConstant(0);
			}
			ThisMaterialInstanceConstant.SetVectorParameterValue('EmissiveColor',TraceHitDrone.DroneColor);
*/

 
//==========================EXECS==========================================
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

exec function ShowMenu()
{
   ConsoleCommand("Quit"); // call the quit command to quit.
}

exec function Use()
{
	//ConsoleCommand("open DronesLandscape01");
}

exec function PauseDrones()
{
	local DronesDrone ThisDrone;
	local DronesDroneAIController DroneController;
	
	`Log("In exec PauseDrones");
	
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

	`Log("In exec UnpauseDrones");
	
	foreach AllActors(class'DronesDrone', ThisDrone)
	{
		//DronesGame(WorldInfo.Game).CurrentDroneSpeed = DronesGame(WorldInfo.Game).OverallDroneSpeed;
		DroneController = DronesDroneAIController(ThisDrone.Controller);
		DroneController.PopState();
	}
}

exec function PrevWeapon()
{
	if( DronesGame(WorldInfo.Game).OverallDroneSpeed < 100)
	{
		DronesGame(WorldInfo.Game).OverallDroneSpeed += 0.5;
	}
}

exec function NextWeapon()
{
	if( DronesGame(WorldInfo.Game).OverallDroneSpeed > 0.0)
	{
		DronesGame(WorldInfo.Game).OverallDroneSpeed -= 0.5;
	}
}

//==========================STATES==========================================


//==========================FUNCTIONS==========================================


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
	LastTraceHit=None
	LastTraceHitDrone=None
}