package com.gsj4w.feathers.orientation
{
	/**
	 * The StageOrientation class defines constants enumerating the possible orientations of the stage and the device.
	 * @langversion	3.0
	 * @playerversion	AIR 2
	 */
	public final class StageOrientation extends Object
	{
		/**
		 * Specifies that the stage is currently in the default orientation of the device (right-side up).
		 * @langversion	3.0
		 * @playerversion	AIR 2
		 */
		public static const DEFAULT : String = "default";

		/**
		 * Specifies that the stage is currently rotated left relative to the default orientation.
		 * 
		 *   Note: When the orientation of the device is rotated left, the orientation of the
		 * stage must be rotated right in order to remain upright.
		 * @langversion	3.0
		 * @playerversion	AIR 2
		 */
		public static const ROTATED_LEFT : String = "rotatedLeft";

		/**
		 * Specifies that the stage is currently rotated right relative to the default orientation.
		 * 
		 *   Note: When the orientation of the device is rotated right, the orientation of the
		 * stage must be rotated left in order to remain upright.
		 * @langversion	3.0
		 * @playerversion	AIR 2
		 */
		public static const ROTATED_RIGHT : String = "rotatedRight";

		/**
		 * Specifies that the device has not determined an orientation. This state can occur when
		 * the device is lying flat on a table and also while the application is initializing.
		 * @langversion	3.0
		 * @playerversion	AIR 2
		 */
		public static const UNKNOWN : String = "unknown";

		/**
		 * Specifies that the stage is currently upside down relative to the default orientation.
		 * @langversion	3.0
		 * @playerversion	AIR 2
		 */
		public static const UPSIDE_DOWN : String = "upsideDown";

		public function StageOrientation ();
	}
}
