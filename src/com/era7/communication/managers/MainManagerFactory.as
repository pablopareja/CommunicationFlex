package com.era7.communication.managers
{
	import mx.controls.Alert;
	
	public class MainManagerFactory
	{
		private static var mainManager:MainManager = null; 
		
		/**
		 * 	Metodo para obtener el MainManager necesario para la comunicacion con el servidor.
		 *  Nunca instanciar la clase MainManager directamente, (esto no esta limitado ya que 
		 *  en AS3 no existen constructores internos) 
		 */
		public static function getMainManager():MainManager{
			if(mainManager == null){
				mainManager = new MainManager();
			}
			return mainManager;
		}

	}
}