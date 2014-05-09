package {
	import flash.display.Sprite;
	import flash.events.Event;
	import Matrix;
	import LUDecomposition;
	
	
	/**
	 * ...
	 * @author Kyle Howell
	 */
	public class Testing extends Sprite {
		
		public function Testing():void {
			if (stage)
				init();
			else
				addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			trace("Hello World!");
			var lu:LUDecomposition = new LUDecomposition(new Matrix(2, 3));
		}
	}
}