package com.era7.communication.xml
{
	import com.era7.xmlapi.model.XMLError;
	import com.era7.xmlapi.model.XMLObject;
	
	
	public class Response extends XMLObject
	{
		
		public static const TAG_NAME:String = "response";
	
		public static const STATUS_ERROR:String = "error";
		public static const STATUS_SUCCESSFUL:String = "ok";
		public static const STATUS_NO_SESSION:String = "no_session";
		
		/**
		 *	Constructor
		 */
		public function Response(... args)
		{
			var temp:Object;
			var proceed:Boolean = false;			
			
			if(args.length == 0){
				temp = new XML(<{TAG_NAME}/>);
				proceed = true;
			}else if(args.length == 1){
				temp = args[0];
				proceed = true;
			}else{
				proceed = false;
			}
			
			if(proceed){
				super(temp);
				
				if(this.content.name() != TAG_NAME){
					throw new XMLError(XMLError.WRONG_TAG_NAME_ERROR);
				}				
					
			}else{
				throw new XMLError(XMLError.TOO_MANY_PARAMETERS_FOR_THE_CONSTRUCTOR);
			}
		}
		
		//-----------------------------------------------------------------------------	
		//---------------------------------GETTERS----------------------------------------		
		public function getComponent():String{
			return this.content.@component; 
		}
		public function getMethod():String{
			return this.content.@method; 
		}
		public function getStatus():String{
			return this.content.@status; 
		}
		public function getID():String{
			return this.content.@id;
		}
		public function getErrorItem():ErrorItem{
			return new ErrorItem(this.content.error[0]);
		}
		public function getResult():Result{			
			return new Result(this.content.result[0]);
		}
		public function getSessionID():String{	return this.content.@session_id;}		
		//-----------------------------------------------------------------------------	
		
		
		//-----------------------------------------------------------------------------	
		//---------------------------------SETTERS----------------------------------------
		public function setSessionID(value:String):void{	this.content.@session_id = value;}
		public function setComponent(value:String):void{
			this.content.@component = value; 
		}
		public function setMethod(value:String):void{
			this.content.@method = value; 
		}
		public function setStatus(value:String):void{
			this.content.@status = value; 
		}
		public function setID(value:String):void{
			this.content.@id = value; 
		}
		public function setError(value:ErrorItem):void{
			this.content.error = value.getContent();
		}
		public function setResult(value:Result):void{
			this.content.result = value.getContent();
		}		
		//-----------------------------------------------------------------------------	
		
	}
}