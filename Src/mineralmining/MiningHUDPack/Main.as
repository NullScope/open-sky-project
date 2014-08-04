package {
	
	import flash.display.MovieClip;
	
	public class Main extends MovieClip {
	
		public function Main() {
			
			var rgb = new RGBShift(titleScreen); // create a new RGBShift from the titleScreen
			removeChild(titleScreen); // remove the original title screen from the stage
			
			// add it to the stage at the bottom of the display list
			addChildAt(rgb, 0); 
		
		}
	}

}