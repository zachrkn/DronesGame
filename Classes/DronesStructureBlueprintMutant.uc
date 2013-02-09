//==========================CLASS DECLARATION==================================
class DronesStructureBlueprintMutant extends DronesStructureBlueprint;

//==========================FUNCTIONS==========================================
function SetBrickRelativeLocationsArray(array<vector> ParentOneRelLocArray, array<vector> ParentTwoRelLocArray)
{
	local int NewArrayLength;
	local int ArrayLengthDiff;
	local int i;
	local vector Halfway;	
	local float FullDistance, HalfwayDistance;
	local int RandNum;
	local array<vector> LongerParent, ShorterParent;
	local int RandWhatToDoWithExtraSlots;
	
	if( ParentOneRelLocArray.Length <= ParentTwoRelLocArray.Length )
	{
		LongerParent = ParentTwoRelLocArray;
		ShorterParent = ParentOneRelLocArray;
	}
	else
	{
		ShorterParent = ParentTwoRelLocArray;
		LongerParent = ParentOneRelLocArray;		
	}
	
	ArrayLengthDiff = LongerParent.Length - ShorterParent.Length;
	NewArrayLength = ShorterParent.Length + ArrayLengthDiff;
	if( RandRange(0,2) == 0 )
	{
		NewArrayLength += NewArrayLength+(RandRange(0,ArrayLengthDiff)-ArrayLengthDiff/2);
	}
	
	RandWhatToDoWithExtraSlots = RandRange(0,2);
	
	for( i=0; i<NewArrayLength; i++)
	{
		if( i>=ShorterParent.Length && RandWhatToDoWithExtraSlots==0)
		{
			BrickRelativeLocationsArray[i] = LongerParent[i];
		}
		else
		{
			RandNum = RandRange(0,3);
			if( RandNum == 0 )
			{
				FullDistance = VSize(ShorterParent[i] - LongerParent[i]);
				HalfwayDistance = FullDistance / 2;
				Halfway = (ShorterParent[i] + Normal(LongerParent[i] - ShorterParent[i])*HalfwayDistance);
				BrickRelativeLocationsArray[i] = Halfway;
			}
			else if( RandNum == 1 )
			{
				BrickRelativeLocationsArray[i] = ShorterParent[i];
			}
			else
			{
				BrickRelativeLocationsArray[i] = LongerParent[i];
			}
		}
	}
}

function SetBrickRelativeRotationsArray(array<rotator> ParentOneRelRotArray, array<rotator> ParentTwoRelRotArray)
{
	local int NewArrayLength;
	local int ArrayLengthDiff;
	local int i;
	local int RandNum;
	
//	`Log("In function SetBrickRelativeRotationsArray");
	ArrayLengthDiff = Abs(ParentOneRelRotArray.Length - ParentTwoRelRotArray.Length);
//	`Log("Difference between length of two arrays "$ArrayLengthDiff);
	if( ParentOneRelRotArray.Length <= ParentTwoRelRotArray.Length )
	{
		//`Log("Parent one's array was shorter, or they were the same legth");
		NewArrayLength = ParentOneRelRotArray.Length + ArrayLengthDiff;
		for( i=0; i<NewArrayLength; i++)
		{
			if( i>=ParentOneRelRotArray.Length )
			{
				BrickRelativeRotationsArray[i] = ParentTwoRelRotArray[i];
				//`Log("i is greater than or equal to parent one (the shorter array)'s length, so i'm going to set location to parent two's location "$BrickRelativeLocationsArray[i]);
			}
			else
			{
				RandNum = RandRange(0,3);
				if( RandNum == 0 )
				{
					if( RandRange(0,2) == 0 )
					{
						BrickRelativeRotationsArray[i] = RLerp(ParentOneRelRotArray[i], ParentTwoRelRotArray[i], 0.5F);
						//`Log("ParentOneRotation "$ParentOneRelRotArray[i]$" and ParentTwoRotation "$ParentTwoRelRotArray[i]$" and child rotation "$BrickRelativeRotationsArray[i]);
					}
					else
					{
						BrickRelativeRotationsArray[i] =  rot( 32768, 32768, 32768 ) + RLerp(ParentOneRelRotArray[i], ParentTwoRelRotArray[i], 0.5F);
					}				
				}
				else if( RandNum == 1 )
				{
					BrickRelativeRotationsArray[i] = ParentOneRelRotArray[i];
				}
				else
				{
					BrickRelativeRotationsArray[i] = ParentTwoRelRotArray[i];
				}
			}
		}
	}
	else
	{
		//`Log("Parent two's array was shorter");
		NewArrayLength = ParentTwoRelRotArray.Length + ArrayLengthDiff;
		for( i=0; i<NewArrayLength; i++)
		{
			if( i>=ParentTwoRelRotArray.Length )
			{
				BrickRelativeRotationsArray[i] = ParentOneRelRotArray[i];
				//`Log("i is greater than or equal to parent two (the shorter array)'s length, so i'm going to set location to parent two's location "$BrickRelativeLocationsArray[i]);
			}
			else
			{
				RandNum = RandRange(0,3);
				if( RandNum == 0 )
				{
					if( RandRange(0,2) == 0 )
					{
						BrickRelativeRotationsArray[i] = RLerp(ParentOneRelRotArray[i], ParentTwoRelRotArray[i], 0.5F);
						//`Log("ParentOneRotation "$ParentOneRelRotArray[i]$" and ParentTwoRotation "$ParentTwoRelRotArray[i]$" and child rotation "$BrickRelativeRotationsArray[i]);
					}
					else
					{
						BrickRelativeRotationsArray[i] = rot( 32768, 32768, 32768 ) + RLerp(ParentOneRelRotArray[i], ParentTwoRelRotArray[i], 0.5F);
					}
				}
				else if( RandNum == 1 )
				{
					BrickRelativeRotationsArray[i] = ParentOneRelRotArray[i];
				}
				else
				{
					BrickRelativeRotationsArray[i] = ParentTwoRelRotArray[i];
				}
				
			}
		}
	}
	
	if( RandRange(0,100) < 75)
	{
		for( i=0; i<BrickRelativeRotationsArray.Length; i++)
		{
			if( RandRange(0,100) < 15)
			{
				BrickRelativeRotationsArray[i].Pitch + RandRange(-6000,6000);
				BrickRelativeRotationsArray[i].Yaw + RandRange(-6000,6000);
				BrickRelativeRotationsArray[i].Roll + RandRange(-6000,6000);
			}
		}
	}
}