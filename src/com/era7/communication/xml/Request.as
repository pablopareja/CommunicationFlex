package com.era7.communication.xml
{
	import com.era7.xmlapi.model.XMLError;
	import com.era7.xmlapi.model.XMLObject;
	
	public class Request extends XMLObject
	{
		
		public static const TAG_NAME:String = "request";
		
		/**
		 * 	Constructor
		 */
		public function Request(... args)
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
			
		
		//-------------------------------SETTERS---------------------------------
		//-----------------------------------------------------------------------		
		public function setParameters(param:Parameters):void{	this.content.parameters = param.getContent();	}
		public function setMethod(value:String):void{	this.content.@method = value; }
		public function setID(value:String):void{	this.content.@id = value; }
		public function setSessionID(value:String):void{	this.content.@session_id = value;}
		public function setServlet(value:String):void{	this.content.@servlet = value;}
		//-----------------------------------------------------------------------
				
		//-------------------------------GETTERS----------------------------------
		//------------------------------------------------------------------------
		public function getParameters():Parameters{return new Parameters(this.content.child(Parameters.TAG_NAME)[0]);	}	
		public function getMethod():String{	return this.content.@method; }
		public function getID():String{	return this.content.@id; }
		public function getSessionID():String{	return this.content.@session_id;}
		public function getServlet():String{ return this.content.@servlet;}
		//------------------------------------------------------------------------		

	}
}