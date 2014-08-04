class MiningBarracks extends MiningBuilding;

function PostBeginPlay(){
	super.PostBeginPlay();
	
	skills[3] = makeMarine;
	
	tempSkill.key = 10;
	tempSkill.cost = 150;
	tempSkill.costIndex = 0;
	tempSkill.cooldown = 0;
	tempSkill.castTime = 7.5f;
	tempSkill.range = 0;
	tempSkill.skillName = "Marine";
	tempSkill.skillDescription = "Train a Marine to defend or attack the enemy";
	tempSkill.skillIcon = 5;
	tempSkill.skillButtonIndex = 6;
	tempSkill.requiresTarget = FALSE;
	
	skillsInfo.AddItem(tempSkill);
}

function Tick(float DeltaTime){
	super.Tick(DeltaTime);
}

function makeMarine(){
	buildUnit(class'MiningMarine',3);
}

defaultproperties
{
	unitName = "Barracks"
	maxHealth = 1000
	
	isStorage = false
	canSetRallyPoint = true
	
	teamMaterials[0] = Material'UDKRTSGameContent.Materials.Structures.BarracksMaterial_0'
	teamMaterials[1] = Material'UDKRTSGameContent.Materials.Structures.BarracksMaterial_1'
	teamMaterials[2] = Material'UDKRTSGameContent.Materials.Structures.BarracksMaterial_2'
	teamMaterials[3] = Material'UDKRTSGameContent.Materials.Structures.BarracksMaterial_3'
	teamMaterials[4] = Material'UDKRTSGameContent.Materials.Structures.BarracksMaterial_4'
	teamMaterials[5] = Material'UDKRTSGameContent.Materials.Structures.BarracksMaterial_5'
	
	Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
		ModShadowFadeoutTime=0.25
		MinTimeBetweenFullUpdates=0.2
		AmbientGlow=(R=.01,G=.01,B=.01,A=1)
		AmbientShadowColor=(R=0.15,G=0.15,B=0.15)
		bSynthesizeSHLight=TRUE
	End Object
	Components.Add(MyLightEnvironment)

    Begin Object Class=SkeletalMeshComponent Name=InitialSkeletalMesh
		CastShadow=TRUE
		bCastDynamicShadow=TRUE
		bOwnerNoSee=FALSE
		LightEnvironment=MyLightEnvironment;
		CollideActors=TRUE
		BlockActors=TRUE
		BlockRigidBody=TRUE
        BlockZeroExtent=TRUE
		BlockNonZeroExtent=TRUE
		bIgnoreControllersWhenNotRendered=TRUE
		bUpdateSkelWhenNotRendered=FALSE
		SkeletalMesh=SkeletalMesh'UDKRTSGameContent.SkeletalMeshes.PlaceHolderStructure'
		Materials(0)=Material'UDKRTSGameContent.Materials.Structures.BarracksMaterial_0'
	End Object
	
	Components.add(InitialSkeletalMesh)
	unitMesh = InitialSkeletalMesh
	CollisionComponent=InitialSkeletalMesh
}