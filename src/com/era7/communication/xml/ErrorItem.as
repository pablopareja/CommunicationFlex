package com.era7.communication.xml
{
	import com.era7.xmlapi.model.XMLError;
	import com.era7.xmlapi.model.XMLObject;
	
	
	public class ErrorItem extends XMLObject
	{
		
		public static const TAG_NAME:String = "error";	
		
		/**
		 * 	Constructor
		 */
		public function ErrorItem(... args)
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
		public function getCode():String{
			return this.content.@code; 
		}
		public function getTitle():String{
			return XMLObject.removeCDATATag(this.content.title.toString());
		}
		public function getDescription():String{
			return XMLObject.removeCDATATag(this.content.description.toString());
		}
		public function getSource():XML{
			return this.content.source;
		}
		//-----------------------------------------------------------------------------	
		
		
		//-----------------------------------------------------------------------------	
		//---------------------------------SETTERS----------------------------------------
		public function setCode(value:String):void{
			this.content.@code = value; 
		}
		public function setTitle(value:String):void{
			this.content.title = XMLObject.CDATA("title",value);
		}
		public function setDescription(value:String):void{
			this.content.description = XMLObject.CDATA("description",value);
		}
		public function setSource(value:XML):void{
			this.content.source = value; 
		}
		//-----------------------------------------------------------------------------	
	}
}