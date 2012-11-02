//==========================CLASS DECLARATION==================================
class DronesDroneAIController extends AIController
	DependsOn(DronesGame);

//==========================VARIABLES==========================================
var DronesBrickKActor PickUpBrick;

var DronesBrickKActor AdjacentBrick;
var int AdjacentBrickSocketNumber;
var vector DropLocation;
var rotator DropRotation;

var vector DestinationRangeCenter;
var vector DestinationRangeSize;

var DronesDrone ChildDrone;
var DronesDroneAIController ChildDroneAIController;

var int ProbabilityForDropLocationToBeAdjacentToABrick;
var int ProbabilityForAttachingPickUpBrickToAdjacentBrick;
var int ProbabilityForAttachingPickUpBrickToAllDropLocationAdjacentBricks;


//==========================EVENTS==========================================
event Possess( Pawn inPawn, bool bVehicleTransition)
{
	super.Possess(inPawn, bVehicleTransition);
	DronesDrone(Pawn).UpdateDroneColor();
}

//==========================STATES==========================================
auto state Idle
{
	event Tick (float DeltaTime)
    {
		if(DoesAnAvailableBrickExist())
		{
			PickUpBrick = GetARandomAvailableBrick();
			GotoState('GetBrick');
		}
    }
Begin:
}

state GetBrick
{
	local StaticMeshComponent ThisStaticMeshComponent;
	local int i;
	local DronesBrickConstraint Constraint;
	local DronesBrickKActor OtherConstrainedBrick;

	event Tick (float DeltaTime)
	{		
		// check to make sure the brick is still available; if it's not, go back to idle
		if ( !IsBrickAvailable(PickUpBrick) )
		{
			GotoState('Idle');
		}
		
		// if the Drone reaches the brick, disappear the brick, make it unavailable, and pick an unoccupied brick location to spawn the held brick
		if ( IsPawnAtTargetBrick())
		{
			PickUpBrick.SetBaseToDrone(DronesDrone(Pawn));
			PickUpBrick.LoseCollision();
			
			// remove constraints from PickUpBrick, remove the reference to those constraints from the other bricks they affected, and delete the constraints
			for (i=0; i<PickUpBrick.ConstraintsApplied.Length; i++)
			{
				Constraint = PickUpBrick.ConstraintsApplied[i];
				DronesBrickKActor(Constraint.ConstraintActor1).ConstraintsApplied.RemoveItem(Constraint);
				DronesBrickKActor(Constraint.ConstraintActor2).ConstraintsApplied.RemoveItem(Constraint);
				Constraint.Destroy();
			}

			PickUpBrick.MakeUnavailable();
					
			SetDropLocationAndGoToDropState();		
		}
		// if drone is not at the PickUpBrick yet, keep moving toward it
		else
		{
			MoveDroneTowardLocation(PickUpBrick.Location, DeltaTime);
		}
	}

Begin:
}

state PlaceBrickAtDropLocation
{
	local StaticMeshComponent ThisStaticMeshComponent;
	local bool bSpawnChildDrone;

	event Tick (float DeltaTime)
	{
		if ( IsPawnAtLocation(DropLocation) )
		{			
			// check to make sure the DropLocation is still unoccupied; if it is, get a new drop location
			if ( IsBrickSizedLocationOccupied(DropLocation,DropRotation) )
			{
				//`Log("In state PlaceThatBrickAtRandomDropLocation, in Tick Event, the DropLocation is now occupied, so getting a new one");
				SetRandomDropLocationAndRotationWithinDestinationRange(DropLocation, DropRotation);
			}
			else
			{
				PickUpBrick.SetBaseToSelf();
				PickUpBrick.LoseMomentum();
				PickUpBrick.GainCollision();
				PickUpBrick.SetPositionAndRotation(DropLocation, DropRotation);
				PickUpBrick.MakeAvailable();
									
				if( ShouldSpawnNewDrone() )
				{
					SpawnChildDrone();
				}
			
				Pawn.SetDrawScale(Pawn.DrawScale-0.15);
				If(Pawn.DrawScale <= 0.1)
				{
					DronesDrone(Pawn).Kill();
				}
		
				GotoState('Idle');
			}
		}
		else
		{
			MoveDroneTowardLocation(DropLocation, DeltaTime);
		}
	}
	
Begin:
}

state PlaceBrickAdjacentToBrick
{
	local bool bSpawnChildDrone;
	local vector SocketLocation;
	local SkeletalMeshComponent ThisSkeletalMeshComponent;

	event Tick (float DeltaTime)
	{
		foreach AdjacentBrick.ComponentList(class'SkeletalMeshComponent', ThisSkeletalMeshComponent)
		{
			SocketLocation = GetSocketWorldLocationFromNumberAndComponent(AdjacentBrickSocketNumber, ThisSkeletalMeshComponent);
		}

		if ( IsPawnAtLocation(SocketLocation) )
		{
			// check to make sure the SocketLocation is still unoccupied
			if ( IsBrickSizedLocationOccupied(SocketLocation,AdjacentBrick.Rotation) )
			{
				if( DoesAnAvailableBrickWithinDestinationRangeThatHasAnUnoccupiedSocketLocationExist() )
				{
					AdjacentBrick = GetRandomAvailableBrickWithinDestinationRangeThatHasAnUnoccupiedSocketLocation(0);
					AdjacentBrickSocketNumber = GetRandomUnoccupiedSocketNumberFromBrick(AdjacentBrick);
				}
				else
				{
					SetRandomDropLocationAndRotationWithinDestinationRange(DropLocation, DropRotation);
					GotoState('PlaceBrickAtDropLocation');
				}
			}
			else
			{	
				PickUpBrick.SetBaseToSelf();
				PickUpBrick.LoseMomentum();
				PickUpBrick.GainCollision();
				PickUpBrick.SetPositionAndRotation(SocketLocation, AdjacentBrick.Rotation);
				
				//PickUpBrick.CreateConstraintWithBrick(AdjacentBrick); // shouldn't need this because next line should include adjacent brick
				PickUpBrick.CreateConstraintWithAllTouchingBricks();
												
				// make the brick available
				PickUpBrick.MakeAvailable();
								
				if( ShouldSpawnNewDrone() )
				{
					SpawnChildDrone();
				}
			
				Pawn.SetDrawScale(Pawn.DrawScale-0.15);
				If(Pawn.DrawScale <= 0.1)
				{
					DronesDrone(Pawn).Kill();
				}
		
				//LastTargetBrick = PickUpBrick;
				GotoState('Idle');
			}
		}
		else
		{
			MoveDroneTowardLocation(SocketLocation, DeltaTime);
		}
	}
Begin:
}

state PauseDrone
{

Begin:
}


//==========================FUNCTIONS==========================================
function MoveDroneTowardLocation(vector InLoc, float DeltaTime)
{
	local vector NewLocation;
	local rotator NewRotation;
	local rotator RotationToFace;
	
	NewLocation = Pawn.Location + Normal(InLoc - Pawn.Location)*DronesGame(WorldInfo.Game).OverallDroneSpeed;

	If(NewLocation.Z < 80)
	{	
		// this keeps the drone from colliding with the ground and looking like a dumbfuck
		NewLocation.Z = 80;
	}

	//`Log("In GetThatBrick, i am "$Pawn$" and i'm going to my new location which is "$NewLocation);
	Pawn.SetLocation(NewLocation);
	
	RotationToFace = Rotator(InLoc-Pawn.Location);
	NewRotation = RInterpTo(Pawn.Rotation, RotationToFace,DeltaTime, 4);
	SetFocalPoint(InLoc);
	Pawn.SetRotation(NewRotation);
}


function SetDropLocationAndGoToDropState()
{
	if( ShouldDropLocationBeAdjacentToABrick() && DoesAnAvailableBrickWithinDestinationRangeThatHasAnUnoccupiedSocketLocationExist())
	{
		//`Log("Selecting a destination location that is adjacent to a brick");
		AdjacentBrick = GetRandomAvailableBrickWithinDestinationRangeThatHasAnUnoccupiedSocketLocation(0);
		AdjacentBrickSocketNumber = GetRandomUnoccupiedSocketNumberFromBrick(AdjacentBrick);
		GotoState('PlaceBrickAdjacentToBrick');
	}
	else
	{
		//`Log("Getting a random target destination");
		SetRandomDropLocationAndRotationWithinDestinationRange(DropLocation, DropRotation);
		GotoState('PlaceBrickAtDropLocation');
	}
}

function SpawnChildDrone()
{
	ChildDrone = Spawn(class'DronesDrone',,,Pawn.Location,,,TRUE);
	ChildDrone.Controller = Spawn(class'DronesDroneAIController');
	ChildDrone.Controller.Possess(ChildDrone, FALSE);
	ChildDroneAIController = DronesDroneAIController(ChildDrone.Controller);
	//`Log("Drone: "$Pawn$" spawned a new drone!!");
					
	// The center of the destination range for the child should be based on both the original range of the parent as well as the most recent destination it picked
	ChildDroneAIController.DestinationRangeCenter.X = DestinationRangeCenter.X + (RandRange(0, 600)-300);
	ChildDroneAIController.DestinationRangeCenter.Y = DestinationRangeCenter.Y + (RandRange(0, 600)-300);
	ChildDroneAIController.DestinationRangeCenter.Z = DestinationRangeCenter.Z + (RandRange(0, 200)-100);
	ChildDroneAIController.DestinationRangeSize.X = DestinationRangeSize.X + (RandRange(0, 200)-100);
	ChildDroneAIController.DestinationRangeSize.Y = DestinationRangeSize.Y + (RandRange(0, 200)-100);
	ChildDroneAIController.DestinationRangeSize.Z = DestinationRangeSize.Z + (RandRange(0, 100)-50);				

	If(ChildDroneAIController.DestinationRangeCenter.Z < 0)
	{
		ChildDroneAIController.DestinationRangeCenter.Z = 0;
	}
	If(ChildDroneAIController.DestinationRangeCenter.Z > 500)
	{
		ChildDroneAIController.DestinationRangeCenter.Z = 500;
	}
	If(ChildDroneAIController.DestinationRangeSize.X < 30)
	{
		ChildDroneAIController.DestinationRangeSize.X = 30;
	}
	If(ChildDroneAIController.DestinationRangeSize.Y < 30)
	{
		ChildDroneAIController.DestinationRangeSize.Y = 30;
	}
	If(ChildDroneAIController.DestinationRangeSize.Z < 30)
	{
		ChildDroneAIController.DestinationRangeSize.Z = 30;
	}

	ChildDrone.UpdateDroneColor();
}

function bool ShouldSpawnNewDrone()
{
	if( RandRange(0,100)/30.00 < Pawn.DrawScale)
	{
		//`Log("Returning TRUE");
		return TRUE;
	}
	else
	{
		`Log("Returning FALSE");
		return FALSE;
	}
}

function bool ShouldDropLocationBeAdjacentToABrick()
{
	if( RandRange(0,100) < ProbabilityForDropLocationToBeAdjacentToABrick ) 
	{
		return TRUE;
	}
	else
	{
		return FALSE;
	}
}

function bool ShouldTargetBrickAttachToAdjacentBrick()
{
	if( RandRange(0,100) < ProbabilityForAttachingPickUpBrickToAdjacentBrick ) 
	{
		return TRUE;
	}
	else
	{
		return FALSE;
	}
}

function SetRandomDropLocationAndRotationWithinDestinationRange(out vector TargetVector, out rotator TargetRotation)
{	
	local bool bOccupied;
	
	TargetVector.X = DestinationRangeCenter.X + (RandRange(0,DestinationRangeSize.X)-(DestinationRangeSize.X/2));
	TargetVector.Y = DestinationRangeCenter.Y + (RandRange(0,DestinationRangeSize.Y)-(DestinationRangeSize.Y/2));
	TargetVector.Z = DestinationRangeCenter.Z + (RandRange(0,DestinationRangeSize.Z)-(DestinationRangeSize.Z/2));
	TargetRotation.Pitch = RandRange(0, 65556);
	TargetRotation.Yaw = RandRange(0, 65556);	
	TargetRotation.Roll = RandRange(0, 65556);
	
	//`Log("in function GetUnoccupiedRandomTargetDestinationWithinDestinationRange calling function IsBrickSizedLocationOccupied");
	bOccupied = IsBrickSizedLocationOccupied(TargetVector,TargetRotation);
	if( (bOccupied || (TargetVector.Z < -1.5)))
	{
		SetRandomDropLocationAndRotationWithinDestinationRange(TargetVector, TargetRotation);
	}
}

function bool DoesAnAvailableBrickWithinDestinationRangeThatHasAnUnoccupiedSocketLocationExist()
{
	local DronesBrickKActor AvailableBrick;
	local array<DronesBrickKActor> AvailableBricks;
	
	AvailableBricks = DronesGame(WorldInfo.Game).AvailableBricks;
	
	//`Log("In function DoesAnAvailableBrickWithinDestinationRangeThatHasAnUnoccupiedSocketLocationExist");
	if ( DoesAnAvailableBrickWithinDestinationRangeExist() )
	{
		foreach AvailableBricks(AvailableBrick)
		{
			if( IsVectorWithinDestinationRange(AvailableBrick.Location) )
			{
				//`Log("Drone "$Pawn$" In function DoesAnAvailableBrickWithinDestinationRangeThatHasAnUnoccupiedSocketLocationExist, running through foreach brick, and checking to see if there is one with an unoccupied socket location");
				// if this brick has a socket with an occupied location that is above ground
				if( IsThereAnUnoccupiedSocketOnBrick(AvailableBrick) )
				{
					return TRUE;
				}
			}
		}
	}

	return FALSE;
}

function DronesBrickKActor GetRandomAvailableBrickWithinDestinationRangeThatHasAnUnoccupiedSocketLocation(int RecursionDepth)
{
	local DronesBrickKActor AvailableBrick;
	local array<DronesBrickKActor> AvailableBricks;
	
	AvailableBricks = DronesGame(WorldInfo.Game).AvailableBricks;
	if( RecursionDepth > 50)
	{
		foreach AvailableBricks(AvailableBrick)
		{
			//`Log("Drone "$Pawn$" in function GetRandomAvailableBrickWithinDestinationRangeThatHasAnUnoccupiedSocketLocation, going through foreach brick "$AvailableBrick$" checking to see if there is one with an unoccupied socket location");
			if( IsThereAnUnoccupiedSocketOnBrick(AvailableBrick) )
			{
				return AvailableBrick;
			}
		}
	}
	else
	{
		AvailableBrick = GetRandomAvailableBrickWithinDestinationRange(0);
		if( !IsThereAnUnoccupiedSocketOnBrick(AvailableBrick) )
		{
			AvailableBrick = GetRandomAvailableBrickWithinDestinationRangeThatHasAnUnoccupiedSocketLocation(RecursionDepth);
		}
		return AvailableBrick;
	}
}

function bool DoesAnAvailableBrickWithinDestinationRangeExist()
{
	local DronesBrickKActor TempBrick;
	local array<DronesBrickKActor> AvailableBricks;
	
	//`Log("In function DoesAnAvailableBrickWithinDestinationRangeExist");
	AvailableBricks = DronesGame(WorldInfo.Game).AvailableBricks;
	
	foreach AvailableBricks(TempBrick)
	{
		if(IsVectorWithinDestinationRange(TempBrick.Location))
		{
			//`Log("Going to return true, that a brick within destination range exists");
			return TRUE;
		}
	}
	//`Log("Going to return false, that a brick within destination range does NOT exist");
	return FALSE;
}

function DronesBrickKActor GetRandomAvailableBrickWithinDestinationRange(int RecursionDepth)
{
	local int BrickIndex;
	local DronesBrickKActor TempBrick;
	local array<DronesBrickKActor> AvailableBricks;
	local int i;
	local bool bFound;

	bFound = FALSE;
	RecursionDepth += 1;
	AvailableBricks = DronesGame(WorldInfo.Game).AvailableBricks;
	
	//`Log("Drone: "$Pawn$" Before doing anything, RecursionDepth: "$RecursionDepth);
	if (RecursionDepth < 50)
	{
		//`Log("RecursionDepth less than 50");
		BrickIndex = RandRange(0,AvailableBricks.Length-1);
		TempBrick = AvailableBricks[BrickIndex];
		//`Log("Got a new brick from the AvailableBricks array. TempBrick: "$TempBrick);
		if(!IsVectorWithinDestinationRange(TempBrick.Location))
		{
			//`Log("But that brick is out of destination range, so I'm going to do a recursive call to this function");
			TempBrick = GetRandomAvailableBrickWithinDestinationRange(RecursionDepth);
			//`Log("Returned out of recursive call");
		}
	}
	else
	{
		//`Log("RecursionDepth greater than 50");
		for (i=0; (i<AvailableBricks.Length) && !bFound; i++)
		{
			TempBrick = AvailableBricks[i];
			//`Log("Got a new brick from AvailableBricks aray: "$TempBrick);
			if(IsVectorWithinDestinationRange(TempBrick.Location))
			{
				bFound=TRUE;
			}
		}
	}

	//`Log("Returning TempBrick "$TempBrick);
	return TempBrick;
	
}

function bool IsVectorWithinDestinationRange(vector InVector)
{
	local bool bXWithinRange, bYWithinRange, bZWithinRange;
	bXWithinRange = FALSE; bYWithinRange = FALSE; bZWithinRange = FALSE;
	
	if(	(InVector.X > (DestinationRangeCenter.X-(DestinationRangeSize.X/2))) && (InVector.X < (DestinationRangeCenter.X+(DestinationRangeSize.X/2))) )
	{
		bXWithinRange = TRUE;
	}
	if(	(InVector.Y > (DestinationRangeCenter.Y-(DestinationRangeSize.Y/2))) && (InVector.Y < (DestinationRangeCenter.Y+(DestinationRangeSize.Y/2))) )
	{
		bYWithinRange = TRUE;
	}
	if(	(InVector.Z > (DestinationRangeCenter.Z-(DestinationRangeSize.Z/2))) && (InVector.Z < (DestinationRangeCenter.Z+(DestinationRangeSize.Z/2))) )
	{
	
		bZWithinRange = TRUE;
	}
	
	if (bXWithinRange && bYWithinRange && bZWithinRange)
	{
		return TRUE;
	}
	else
	{
		return FALSE;
	}
}

function bool IsBrickSizedLocationOccupied(vector InLocation, rotator InRotation)
{
	local DronesBrickLocationTester BrickTester;
	local bool bOverlap;
	
	BrickTester = Spawn(class'DronesBrickLocationTester',,,InLocation,InRotation,,);
	bOverlap = BrickTester.DoesBrickOverlap();
	BrickTester.Destroy();
	//`Log("In function IsBrickSizedLocationOccupied, the answer is "$bOverlap);
	return bOverlap;
}

function bool IsThereAnUnoccupiedSocketOnBrick(DronesBrickKActor InBrick)
{
	local SkeletalMeshComponent ThisSkeletalMeshComponent;
	local vector SocketLocation;
	local int i;
	local bool bIsThereAnUnoccupiedSocketLocation;
	
	bIsThereAnUnoccupiedSocketLocation = FALSE;
	
	foreach InBrick.ComponentList(class'SkeletalMeshComponent', ThisSkeletalMeshComponent)
	{
		for (i=1; i<7 && !bIsThereAnUnoccupiedSocketLocation; i++)
		{
			SocketLocation = GetSocketWorldLocationFromNumberAndComponent(i, ThisSkeletalMeshComponent);
			
			//`Log("Drone "$Pawn$" in function IsThereAnUnoccupiedSocketOnBrick with InBrick "$InBrick$" i "$i$" SocketLocation.Z "$SocketLocation.Z);
			if( SocketLocation.Z > 1.5 )
			{
				//`Log("Drone "$Pawn$" in function IsThereAnUnoccupiedSocketOnBrick calling function IsBrickSizedLocationOccupied with InBrick "$InBrick);
				if( !IsBrickSizedLocationOccupied(SocketLocation, InBrick.Rotation) )
				{
					//`Log("Drone "$Pawn$" in function IsThereAnUnoccupiedSocketOnBrick, and returning that the following socket location is unoccupied: "$i$" with InBrick "$InBrick);
					bIsThereAnUnoccupiedSocketLocation = TRUE;
				}
			}
		}
	}
	//`Log("in function IsThereAnUnoccupiedSocketOnBrick, with InBrick "$InBrick$" returning "$bIsThereAnUnoccupiedSocketLocation);
	return bIsThereAnUnoccupiedSocketLocation;
}

function int GetRandomUnoccupiedSocketNumberFromBrick(DronesBrickKActor InBrick)
{	
	local SkeletalMeshComponent ThisSkeletalMeshComponent;
	local Vector SocketLocation;
	local int SocketNum;
	
	foreach InBrick.ComponentList(class'SkeletalMeshComponent', ThisSkeletalMeshComponent)
	{
		SocketNum = RandRange(1,7);
		SocketLocation = GetSocketWorldLocationFromNumberAndComponent(SocketNum, ThisSkeletalMeshComponent);
	}
	
	//`Log("Drone "$Pawn$" in function GetRandomUnoccupiedSocketNumberFromBrick calling function IsBrickSizedLocationOccupied with the Brick "$InBrick$" location of socket "$SocketNum$" which is at location "$SocketLocation);
	// if the return vector would be below ground, or the return vector is occupied, get a new socket
	if ( (SocketLocation.Z < -1.5) || IsBrickSizedLocationOccupied(SocketLocation, InBrick.Rotation) )
	{
		//`Log("Drone "$Pawn$" in function GetRandomUnoccupiedSocketNumberFromBrick doing a recursive call.  SocketLocation.Z "$SocketLocation.Z$" and i used socket "$SocketNum);
		SocketNum = GetRandomUnoccupiedSocketNumberFromBrick(InBrick);
	}
	
	return SocketNum;
}

function vector GetSocketWorldLocationFromNumberAndComponent(int SocketNum, SkeletalMeshComponent InSMComp)
{
	local vector SocketLocation;
	switch( SocketNum )
	{
		case 1:
			InSMComp.GetSocketWorldLocationAndRotation('Socket01', SocketLocation);
			break;
		case 2:
			InSMComp.GetSocketWorldLocationAndRotation('Socket02', SocketLocation);
			break;
		case 3:
			InSMComp.GetSocketWorldLocationAndRotation('Socket03', SocketLocation);
			break;
		case 4:
			InSMComp.GetSocketWorldLocationAndRotation('Socket04', SocketLocation);
			break;
		case 5:
			InSMComp.GetSocketWorldLocationAndRotation('Socket05', SocketLocation);
			break;
		case 6:
			InSMComp.GetSocketWorldLocationAndRotation('Socket06', SocketLocation);
			break;
	}
	return SocketLocation;
}

function bool IsPawnAtLocation(vector InLocation)
{
	if ( vsize(Pawn.Location-InLocation) < 100)
	{
		return TRUE;
	}
	else
	{
		return FALSE;
	}
}

function bool IsPawnAtTargetBrick()
{
	if( vSize(Pawn.Location-PickUpBrick.Location) < 100)
	{
		return TRUE;
	}
	else
	{
		return FALSE;
	}
}

function bool DoesAnAvailableBrickExist()
{
	// if there are still available bricks, return TRUE, otherwise return FALSE
	if (DronesGame(WorldInfo.Game).AvailableBricks.Length > 0)
	{
		return TRUE;
	}
	else
	{
		return FALSE;
	}
}

function DronesBrickKActor GetARandomAvailableBrick()
{
	local int Index;
	local DronesBrickKActor Brick;
	
	// get a random brick
	Index = RandRange(0, DronesGame(WorldInfo.Game).AvailableBricks.Length);
	Brick = DronesGame(WorldInfo.Game).AvailableBricks[Index];

	return Brick;
}

function bool IsBrickAvailable(DronesBrickKActor ThisBrick)
{
	if ( DronesGame(WorldInfo.Game).AvailableBricks.Find(ThisBrick) > 0)
	{
		return TRUE;
	}
	else
	{
		return FALSE;
	}
}

//==========================DELEGATES==========================================
delegate int SortBricksRandomly(DronesBrickKActor BrickA, DronesBrickKActor BrickB)
{
	if(RandRange(0,1) < 0.5)
	{
		return -1;
	}
	else
	{
		return 1;
	}
}

//==========================DEFAULT PROPERTIES==========================================
DefaultProperties
{
	DestinationRangeCenter=(X=0,Y=0,Z=100)
	DestinationRangeSize=(X=500,Y=500,Z=200)
	DropRotation=(Pitch=0,Yaw=0,Roll=0)
	
	ProbabilityForDropLocationToBeAdjacentToABrick=100;
	ProbabilityForAttachingPickUpBrickToAdjacentBrick = 100;
	ProbabilityForAttachingPickUpBrickToAllDropLocationAdjacentBricks = 100;
}