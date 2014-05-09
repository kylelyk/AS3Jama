package util {
	import flash.errors.IllegalOperationError;
	
	/**
	 * Utility functions for AS3Jama.
	 * @author Kyle Howell
	 */
	public class Maths {
		
		/** sqrt(a^2 + b^2) without under/overflow. **/
		public static function hypot(a:Number, b:Number):Number {
			var r:Number;
			if (Math.abs(a) > Math.abs(b)) {
				r = b / a;
				r = Math.abs(a) * Math.sqrt(1 + r * r);
			} else if (b != 0) {
				r = a / b;
				r = Math.abs(b) * Math.sqrt(1 + r * r);
			} else {
				r = 0.0;
			}
			return r;
		}
	}
}