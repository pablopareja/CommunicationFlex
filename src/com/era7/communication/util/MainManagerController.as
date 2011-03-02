package com.era7.communication.util
{
	import mx.core.Application;
	import mx.core.FlexGlobals;
	import mx.core.UIComponent;
	import mx.managers.PopUpManager;
	
	public class MainManagerController
	{
		
		private static var WINDOW:MainManagerWindow = null;
		
		/**
		 * 	Shows a window which auto-updates with the current state of the main manager 
		 *  object used in the application; including number of requests, successful responses, etc
		 */
		public static function showMainManagerWindow():void{
			if(WINDOW == null){
				WINDOW = MainManagerWindow(PopUpManager.createPopUp(UIComponent(FlexGlobals.topLevelApplication),MainManagerWindow,false));
				PopUpManager.centerPopUp(WINDOW);				
			}
			
			WINDOW.visible = true;
			PopUpManager.bringToFront(WINDOW);
		}

	}
}