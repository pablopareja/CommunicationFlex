package com.era7.communication.xml
{
	import com.era7.xmlapi.model.XMLError;
	import com.era7.xmlapi.model.XMLObject;
	
	public class Parameters extends XMLObject
	{
		
		public static const TAG_NAME:String = "parameters";
		
		/**
		 * 	Constructor
		 */
		public function Parameters(... args)
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
		public function getParametersContent():XMLList{
			return this.content.elements();
		}
		public function getParamByName(name:String):XML{
			for each(var element:XML in this.content.elements()){
				if(element.name() == name){
					return element;
				}
			}
			return new XML();
		}		
		//-----------------------------------------------------------------------------	
		
		
		//-----------------------------------------------------------------------------	
		//---------------------------------SETTERS----------------------------------------
		
		//-----------------------------------------------------------------------------	
		
		public function addParametersContent(value:XML):void{
			this.content.appendChild(value);
		}

	}
}