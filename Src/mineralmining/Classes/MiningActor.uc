class MiningActor extends Actor placeable;

enum EShape
{
  EShape_Square,
  EShape_Rectangle,
  EShape_Circle
};

var DecalComponent                      selectionEffect;
var(Unit) editinline String             unitName;
var SceneCapture2DComponent             portrait;
var TextureRenderTarget2D               portraitTexture;

var MiningGameInfo                      MiningGame;
var MiningPlayer                        MiningPlayerOwner;
var MiningAIController                  MiningAIOwner;

var NavigationHandle				          	navHandle;
var MiningNavController                 navController;
var DynamicNavMeshObstacle              navMeshObstacle;

var EShape							               	ObstacleType;

var array<MaterialInterface>            teamMaterials;
var array<MaterialInterface>		      	buildMaterials;

var SkeletalMeshComponent               unitMesh;

var Vector								              lastUpdatedLocation;

var(Team) editinline int                team;
var(Collision) editinline float         radius;
var bool                                isSelected;
var bool                                bIsStationary;

function PostBeginPlay(){
    super.PostBeginPlay();

    //selectionEffect.SetHidden(TRUE);
    /*selectionEffect.Width = radius;
    selectionEffect.Height = radius;*/
    if(bIsStationary){
        navMeshObstacle = Spawn(class'DynamicNavMeshObstacle',,,Location);
        
        if(ObstacleType == EShape_Square){
        	navMeshObstacle.setAsSquare(radius);
        }else{
    			if(ObstacleType == EShape_Rectangle){
            navMeshObstacle.setAsRectangle(radius, radius);
    			}else{
    				if(ObstacleType == EShape_Circle){
            	navMeshObstacle.setAsCircle(radius, 8);
    				}
          }	
        }
        
        navMeshObstacle.RegisterObstacle();
    }
    // portraitTexture = class'TextureRenderTarget2D'.static.Create( 512, 512 );
    // portrait.SetCaptureParameters(portraitTexture,,, 100);
    // portrait.SetView(Location, Rotation);
    // portrait.ViewMode = SceneCapView_Unlit;
    
    //unitMesh.AttachComponentToSocket(portrait, 'Rocket_1');

    MiningGame = MiningGameInfo(WorldInfo.Game);
    MiningPlayerOwner = MiningPlayer(GetALocalPlayerController());

    unitMesh.SetMaterial(0, teamMaterials[team]);
    
    if(!bIsStationary){
      SetPhysics(PHYS_Falling);
    }
}

function notifyMovementArea(vector notifyLocation, optional int notifyRadius = 0)
{
  local MiningActor_Comandable tempActor;

  foreach MiningGame.units(tempActor)
  {
    if(VSize(notifyLocation - tempActor.Location) <= notifyRadius && tempActor.team == team){

    }
  }
}

function int getDistanceBetweenActors(MiningActor actor1, MiningActor actor2){
  local Vector direction;

  direction = (actor2.Location - actor1.Location);
  direction.Z = 0;

  return (VSize(direction) - (actor1.radius+actor2.radius));
}

function Tick(float DeltaTime){
    super.Tick(DeltaTime);

    if(MiningGame == none){
      MiningGame = MiningGameInfo(WorldInfo.Game);
    }
    
    if(MiningPlayerOwner == none){
      MiningPlayerOwner = MiningPlayer(GetALocalPlayerController());
    }
}

function clearQueue(){
}

function setAIController(MiningAIController newAIController)
{
  MiningAIOwner = newAIController;
}

function setRadius(int newRadius){
  radius = newRadius;
}

function bool GeneratePathTo(Vector Goal, optional float WithinDistance, optional bool bAllowPartialPath)
{
  if (navHandle == None)
  {
    return false;
  }
 
  //AddBasePathConstraints(false);
  
  class'NavMeshPath_Toward'.static.TowardPoint(navHandle, Goal);
  //class'NavMeshGoal_At'.static.AtActor(navHandle, Goal, WithinDistance, bAllowPartialPath);
  class'NavMeshGoal_At'.static.AtLocation(navHandle, Goal, WithinDistance, bAllowPartialPath);
   
  return navHandle.FindPath();
}

function selectUnit(){

	if(!isSelected){
		isSelected = true;
		selectionEffect.SetHidden(false);
	}
}

function deselectUnit(){
	if(isSelected){
		isSelected = false;
		selectionEffect.SetHidden(true);
	}
}

function setTeam(int newTeam){
  team = newTeam;
  unitMesh.SetMaterial(0, teamMaterials[team]);
}

function selectedUnit(bool selectState){
  isSelected = selectState;    
}

function float getRadius() { 
  return radius; 
}

function kill(){
  destroy();
}

defaultproperties
{
  unitName = "Missing name"
  bCollideActors=true
  bBlockActors=true
  blockRigidBody=true
  bNoEncroachCheck=false
  bCollideWorld=true
  bIsStationary=false
  bPathColliding=true
  team=0
  radius=0
  CollisionType=COLLIDE_BlockAll
  ObstacleType=EShape_Square

  /*Begin Object Class=SceneCapture2DComponent Name=SceneCapture2DComponent0
    
  End Object
  Components.Add(SceneCapture2DComponent0)
  portrait = SceneCapture2DComponent0

  /*Begin Object Class=DecalComponent Name=Decal0
        DecalMaterial                   = DecalMaterial'MineralMiningGameContent.Textures.temporary_ring'
        Orientation                     = (Pitch=0,Yaw=0,Roll=0)

        bStaticDecal                    = false //(implied)

        FilterMode                      = FM_None //(implied) this and Filter array control receivers
        DecalRotation                   = 0.0;

    //Defined in DecalCompontent
        bMovableDecal                   = true
        TileX                           = 1
        TileY                           = 1
        NearPlane                       = 0
        FarPlane                        = 100
        FieldOfView                     = 80
        HitNodeIndex                    = -1
        HitLevelIndex                   = -1
        DepthBias                       = -0.00006
        SlopeScaleDepthBias             = 0.0
        BackfaceAngle                   = 0.001         


        bProjectOnBSP                   = true
        bProjectOnSkeletalMeshes        = false
        bProjectOnStaticMeshes          = true
        bProjectOnTerrain               = true


        BlendRange                      = (X=270,Y=270)


        StreamingDistanceMultiplier     = 1.0


        DecalTransform                  = DecalTransform_OwnerRelative
        ParentRelativeOrientation       = (Pitch=-16384,Yaw=0,Roll=0)


    End Object
    Components.Add( Decal0 )
    selectionEffect = Decal0*/