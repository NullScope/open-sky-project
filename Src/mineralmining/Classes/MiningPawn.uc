class MiningPawn extends Pawn;

var(Team) editinline int										team;

var	int															attackRate;
var int															attackRange;
var int															attackDamage;

var float														turnRate;

var bool														isSelected;

//var MiningAIController										pawnController;
var MiningBullet												bullet;

var Box															screenBoundingBox;

var MiningGameInfo												MiningGame;

var SkeletalMeshComponent										unitMesh;
var SkeletalMeshComponent										weaponMesh;
var ParticleSystem												muzzleFlashTemplate;
var ParticleSystemComponent										muzzleFlash;

function PostBeginPlay(){
	super.PostBeginPlay();
	
	SpawnDefaultController();
	SetMovementPhysics();
	
	/*pawnController = Spawn(class'MiningAIController');
	pawnController.Possess(self, false);*/
	
	MiningGame = MiningGameInfo(WorldInfo.Game);
	
	//MiningGame.units.AddItem(self);
	
	unitMesh.AttachComponentToSocket(weaponMesh, 'WeaponPoint');
    muzzleFlash = new class'ParticleSystemComponent';
    muzzleFlash.bAutoActivate=false;
    muzzleFlash.SetTemplate(muzzleFlashTemplate);
    weaponMesh.AttachComponentToSocket(muzzleFlash,'MussleFlashSocket');
	Health = HealthMax;
	
}

function Tick(float DeltaTime){
	
	if(Health <= 0){
		killUnit();
	}
	
}

function fireTo(MiningPawn target){
	SetDesiredRotation(Rotator(target.Location - Location), true, true, turnRate, false);
	bullet = Spawn(class'MiningBullet',self,,Location, Rotator(Location));
	//bullet.init(target, attackDamage);
}

function float getRadius() { return 50; }

function damage(int damageAmount){
	Health = Health - damageAmount;
}

function setTeam(int newTeam){
	team = newTeam;
}

function killUnit(){
	//MiningGame.units.RemoveItem(self);
	//pawnController.Destroy();
	Destroy();	
}

defaultproperties
{
	team = 1
	HealthMax = 100
	
	attackRate = 1
	attackRange = 800
	attackDamage = 20
	
	turnRate = 0.2f
	
	bCollideActors=true
	bBlockActors=true
	BlockRigidBody=false
	bNoEncroachCheck=false
	
	Components.Remove(Sprite)
	
	Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
		ModShadowFadeoutTime=0.25
		MinTimeBetweenFullUpdates=0.2
		AmbientGlow=(R=.01,G=.01,B=.01,A=1)
		AmbientShadowColor=(R=0.15,G=0.15,B=0.15)
		bSynthesizeSHLight=TRUE
	End Object
	Components.Add(MyLightEnvironment)

    Begin Object Class=SkeletalMeshComponent Name=InitialSkeletalMesh
		CastShadow=false
		bCastDynamicShadow=false
		bOwnerNoSee=false
		LightEnvironment=MyLightEnvironment;
        BlockRigidBody=true
        CollideActors=true
        BlockZeroExtent=true
		BlockNonZeroExtent=TRUE
		bIgnoreControllersWhenNotRendered=TRUE
		bUpdateSkelWhenNotRendered=FALSE
		PhysicsAsset=PhysicsAsset'CH_AnimCorrupt.Mesh.SK_CH_Corrupt_Male_Physics'
		AnimSets(0)=AnimSet'CH_AnimHuman.Anims.K_AnimHuman_AimOffset'
		AnimSets(1)=AnimSet'CH_AnimHuman.Anims.K_AnimHuman_BaseMale'
		AnimTreeTemplate=AnimTree'CH_AnimHuman_Tree.AT_CH_Human'
		SkeletalMesh=SkeletalMesh'CH_IronGuard_Male.Mesh.SK_CH_IronGuard_MaleA'
	End Object
	
	Begin Object Class=SkeletalMeshComponent Name=weapon
		SkeletalMesh=SkeletalMesh'WP_LinkGun.Mesh.SK_WP_LinkGun_3P'
		bUpdateSkelWhenNotRendered=False
		ReplacementPrimitive=None
		LightEnvironment=MyLightEnvironment
		Scale3D=(X=1,Y=0.75,Z=1)
		LightingChannels=(bInitialized=True,Dynamic=True)
		CastShadow=false
		bCastDynamicShadow=false
		bOwnerNoSee=false
    End Object
    
	Components.Add(InitialSkeletalMesh)
	unitMesh=InitialSkeletalMesh
	weaponMesh=weapon;
}