package com.era7.communication.model
{
	public class CommPairUploadArray
	{
		protected var array:Array = null;
		
		/*
		*	CONSTRUCTOR
		*/	
		public function CommPairUploadArray()
		{		
			this.array = new Array();		
		}
		
		public function getSize():int{
			return array.length;
		}
		
		public function push(value:CommPairUpload):void{
			array.push(value);
		}
		public function pop():CommPairUpload{
			var temp:CommPairUpload = CommPairUpload(array.shift());
			return temp;
		}
		
		public function getCommPairUpload(i:int):CommPairUpload{
			if(i>=0 && i<array.length){
				var temp:CommPairUpload = CommPairUpload(array[i]);
				return temp;
			}else{
				return null;
			}
		}
		
		public function getCommPairUploadByID(value:String):CommPairUpload{
					
			for(var i:int = 0;i<array.length;i++){
				var temp:CommPairUpload = CommPairUpload(array[i]);
				if(temp.getRequest().getID() == value){
					return temp;
				}
			}
			
			return null;
		}
		
		public function deleteCommPairUploadByID(value:String):Boolean{		
					
			for(var i:int = 0;i<array.length;i++){
				var temp:CommPairUpload = CommPairUpload(array[i]);
				if(temp.getRequest().getID() == value){
					array.splice(i,1);
					return true;
				}
			}
			
			return false;
		}

	}
}