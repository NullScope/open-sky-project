package {
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.BitmapData;
	import flash.display.Bitmap;
	import flash.display.BitmapDataChannel;
	import flash.display.BlendMode;
	import flash.events.Event;
	import flash.geom.Point;
	
	import caurina.transitions.Tweener;
	
	public class RGBShift extends Sprite {
		
		private var _centerX:Number;
		private var _centerY:Number;
		
		// CONSTRUCTOR
		public function RGBShift(dObj:DisplayObject) {
			var rgbBMD:Array = createRGB(dObj);

	        for (var i:int=0; i<rgbBMD.length; i++) {
	            var bmp:Bitmap = new Bitmap(rgbBMD[i]);
				bmp.smoothing = true;
				
				if(i>0) {
					// set SCREEN blend mode for the 2nd and 3rd images
	            	bmp.blendMode = BlendMode.SCREEN;
				}	
				var container:Sprite = new Sprite(); // container sprite 
				container.addChild(bmp); // add the Bitmap to the Sprite's display list
				
				// find the center
				_centerX = bmp.width/2;
				_centerY = bmp.height/2;
				
				// center the image
				bmp.x = 0-_centerX;
				bmp.y =	0-_centerY;

				container.x = _centerX;
				container.y = _centerY;
				
				addChild(container); // add the Sprite to the display list
				distort(container);  // start the bitmap distortion
	        }
		}

		//-----------------------------------------------------------------------------
		private function distort(img:Sprite):void {
			Tweener.addTween(img, {
					y: randRange(_centerY-3, _centerY+3), 			// ranomize y shift
					time:randRange(1,2) /10, 		// randomize time
					alpha: randRange(8,10) /10,		// randomize alpha
					transition:"easeInOutSine",
					
					onComplete:distort, 			// when finished start the distortion again 
					onCompleteParams:[img]
					}
			);
		}
		
		//-----------------------------------------------------------------------------
		private function createBMD(dObj:DisplayObject):BitmapData {
			// create a new BitmapData object the size of our DisplayObject
			var bmd:BitmapData = new BitmapData(dObj.width, dObj.height, true, 0xFF000000);
			
			// draw the display object to the bitmap data
			bmd.draw(dObj);

			return bmd;
		}
		
		//-----------------------------------------------------------------------------
		private function createRGB(dObj:DisplayObject):Array {
			var bmd:BitmapData = createBMD(dObj); // create bitmapData from the display object
			
			// create a new bitmap data object for each color channel
	        var r:BitmapData = new BitmapData(bmd.width, bmd.height, true, 0xFF000000);
	        var g:BitmapData = new BitmapData(bmd.width, bmd.height, true, 0xFF000000);
	        var b:BitmapData = new BitmapData(bmd.width, bmd.height, true, 0xFF000000);
	
			// copy the data from each channel into the corresponding bitmap data
	        r.copyChannel(bmd, bmd.rect, new Point(), BitmapDataChannel.RED, BitmapDataChannel.RED);
	        g.copyChannel(bmd, bmd.rect, new Point(), BitmapDataChannel.GREEN, BitmapDataChannel.GREEN);
	        b.copyChannel(bmd, bmd.rect, new Point(), BitmapDataChannel.BLUE, BitmapDataChannel.BLUE);
			
			// return an array with the bitmap data for the 3 color channels
	        return [r, g, b];
	    }
	
	}

}