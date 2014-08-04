class MiningBullet extends Actor
	placeable;

var MiningActor_Comandable targetActor;
var() float travelSpeed;
var() float damageAmount;

function init(MiningActor_Comandable target, int damage) {
	targetActor = target;
	damageAmount = damage;
}

function Tick(float DeltaTime) {
	local Vector Direction;
	Direction = targetActor.Location - Location;
	if (vSize(Direction) < targetActor.getRadius() || targetActor.currentHealth <= 0) {
		hitTarget();
		return;
	}
	SetRotation(Rotator(Direction));
	SetLocation(Location + normal(Direction)*travelSpeed*DeltaTime);
}

function hitTarget() {
	targetActor.damage(damageAmount);
	Destroy();
}

DefaultProperties
{
	
	
	begin object name=bulletParticle class=ParticleSystemComponent
        Template=ParticleSystem'WP_LinkGun.Effects.P_FX_LinkGun_3P_Beam_MF_Blue'
    end object
	Components.add(bulletParticle)

	travelSpeed=500
	damageAmount=10
	bCollideWorld=false
}
