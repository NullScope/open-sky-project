class MiningNavController extends GameAIController;

var array<vector>			moves;
var Vector					direction;
var Vector					Dest;
var Actor					Target;
var bool					CurrentTargetIsReachable;

function setNewLocation(vector newLocation){
	moves.AddItem(newLocation);
}

function clearMoves(){
	moves.remove(0,moves.Length);
}

function bool GeneratePathTo(Vector Goal, optional float WithinDistance, optional bool bAllowPartialPath)
{
  if (navigationHandle == None)
  {
    InitNavigationHandle();
  }
 
  //AddBasePathConstraints(false);
  
  class'NavMeshPath_Toward'.static.TowardPoint(navigationHandle, Goal);
  //class'NavMeshGoal_At'.static.AtActor(navigationHandle, Goal, WithinDistance, bAllowPartialPath);
  class'NavMeshGoal_At'.static.AtLocation(navigationHandle, Goal, WithinDistance, bAllowPartialPath);
   
  return navigationHandle.FindPath();
}

/*auto state Seeking
{
Begin:
	if(Target != none)
	{
		CurrentTargetIsReachable = NavActorReachable(Target);
		

		Dest=PathToActor(Target);
		Focus = none;
		MoveTo(Dest,none,30,false);
			
		// else
		// {
		// 	Focus = Target;
		// 	MoveToward(Target,Target,30,false,false);
		// }
	}

	//goto 'Begin';
}*/

simulated function InitNavigationHandle()
{
	if( NavigationHandleClass != None && NavigationHandle == none )
		NavigationHandle = new(self) NavigationHandleClass;
}

function bool NavActorReachable(Actor a)
{
	local bool retValue;

	if ( NavigationHandle == None )
		InitNavigationHandle();

	retValue = NavigationHandle.ActorReachable(a);
	
	if(retValue)
		ClearTimer('NoPathDeathTimer');

	return retValue;
}


function vector PathToActor( Actor Goal, optional float WithinDistance, optional bool bAllowPartialPath)
{
	local vector NextDest;
	NextDest = Pawn.Location;


	if ( NavigationHandle == None )
		InitNavigationHandle();

		class'NavMeshPath_Toward'.static.TowardGoal( NavigationHandle, Goal );
		class'NavMeshGoal_At'.static.AtActor( NavigationHandle, Goal, WithinDistance, true );
		if ( NavigationHandle.FindPath() )
		{
			ClearTimer('NoPathDeathTimer');
			NavigationHandle.GetNextMoveLocation(NextDest, 60);
		}
		else
			SetTimer(5.0,false,'NoPathDeathTimer');

		NavigationHandle.ClearConstraints();


	return NextDest;
}


state Run{

Begin:
	WaitForLanding();
	
	direction = moves[0] - Location;
	
	pawn.SetDesiredRotation(Rotator(direction),true,true,0.2f,true);
	MoveTo(moves[0],,50,true);
	
	moves.remove(0,1);
	
	if(moves.Length==0){
		GotoState('Idle');
	}else{
		GotoState('Run');	
	}
}

defaultproperties
{
	NavigationHandleClass=class'NavigationHandle'
}