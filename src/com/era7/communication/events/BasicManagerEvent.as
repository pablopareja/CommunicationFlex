package com.era7.communication.events
{
	import com.era7.communication.xml.Response;
	
	import flash.events.Event;

	public class BasicManagerEvent extends Event
	{
		private static const SUFIX:String = "bMEvT";
		
		/**La peticion ha sido resuelta con exito*/
		public static const REQUEST_COMPLETE:String = "requestComplete" + SUFIX;
		/**Se ha alcanzado el timeout de la peticion sin recibir respuesta del servidor*/
		public static const REQUEST_TIMEOUT:String = "requestTimeout" + SUFIX;
		/**Se produjo un error al procesar la peticion*/
		public static const REQUEST_ERROR:String = "requestError" + SUFIX;
		
		
		protected var response:Response = null;
		
		/**
		 * CONSTRUCTOR
		 */
		public function BasicManagerEvent(resp:Response,type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.response = resp;
		}
		
		
		/**
		*  Clone function
		*/
		public override function clone():Event{						
			return new BasicManagerEvent(this.response,this.type,this.bubbles,this.cancelable);
		}
		
		/**
		 * 	GET RESPONSE
		 */
		public function getResponse():Response{
			return this.response;
		}
		
	}
}