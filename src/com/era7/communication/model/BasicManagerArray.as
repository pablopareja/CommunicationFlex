package com.era7.communication.model
{
	import com.era7.communication.events.BasicManagerEvent;
	import com.era7.communication.managers.BasicManager;
	import com.era7.communication.managers.MainManager;
	
	import flash.events.EventDispatcher;
	
	public class BasicManagerArray extends EventDispatcher
	{
		
		protected var array:Array = null;
		protected var mainManager:MainManager = null;
		
		/**
		 * 	Constructor
		 */
		public function BasicManagerArray(value:MainManager)
		{					
			this.array = new Array();		
			this.mainManager = value;			
		}
		
		protected function onRequestError(event:BasicManagerEvent):void{
			this.dispatchEvent(event.clone());
		}
		protected function onRequestComplete(event:BasicManagerEvent):void{
			this.dispatchEvent(event.clone());
		}
		
		/**
		 * 	GET SIZE
		 */
		public function getSize():int{
			return array.length;
		}
		
		/**
		 * 	INIT BASIC MANAGER
		 */
		public function initBasicManager(url:String,
						communicationMode:String = "HTTP_MODE",
						urlRequestMethod:String = "POST"):void{
			var found:Boolean = false;
			
			for(var i:int = 0;i<array.length && !found;i++){
				var temp:BasicManager = BasicManager(array[i]);
				if(temp.getUrl() == url){
					found = true;
				}
			}
			if(!found){
				var manager:BasicManager = new BasicManager(url,mainManager,communicationMode,urlRequestMethod);
				manager.addEventListener(BasicManagerEvent.REQUEST_ERROR,onRequestError);	
				manager.addEventListener(BasicManagerEvent.REQUEST_COMPLETE,onRequestComplete);	
				array.push(manager);
			}
		}
		
		/**
		 * 	GET BASIC MANAGER BY URL
		 */		
		public function getBasicManagerByUrl(url:String):BasicManager{
					
			for(var i:int = 0;i<array.length;i++){
				var temp:BasicManager = BasicManager(array[i]);
				if(temp.getUrl() == url){
					return temp;
				}
			}
			
			return null;
		}

	}
}