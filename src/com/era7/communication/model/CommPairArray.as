package com.era7.communication.model
{
	import com.era7.util.debug.Debugger;
	
	public class CommPairArray
	{
		
		protected var array:Array = null;
		
		public function CommPairArray()
		{		
			this.array = new Array();		
		}
		
		public function getSize():int{
			return array.length;
		}
		
		public function push(value:CommPair):void{
			array.push(value);
		}
		public function pop():CommPair{
			var temp:CommPair = CommPair(array.shift());
			return temp;
		}
		
		public function getCommPair(i:int):CommPair{
			if(i>=0 && i<array.length){
				var temp:CommPair = CommPair(array[i]);
				return temp;
			}else{
				return null;
			}
		}
		
		public function getCommPairByID(value:String):CommPair{
					
			for(var i:int = 0;i<array.length;i++){
				var temp:CommPair = CommPair(array[i]);
				if(temp.getRequest().getID() == value){
					return temp;
				}
			}
			
			return null;
		}
		
		public function deleteCommPairByID(value:String):Boolean{		
					
			for(var i:int = 0;i<array.length;i++){
				var temp:CommPair = CommPair(array[i]);
				if(temp.getRequest().getID() == value){
					array.splice(i,1);
					return true;
				}
			}
			
			return false;
		}
		
		

	}
}