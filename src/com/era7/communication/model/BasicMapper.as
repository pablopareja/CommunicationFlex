package com.era7.communication.model
{
	import com.era7.communication.managers.MainManager;
	import com.era7.communication.managers.MainManagerFactory;
	
	/**
	 * 	Esta clase debe ser extendida una vez por cada Servicio del servidor utilizado,
	 *  agrupando todas las peticiones que se realizaran al mismo desde este mapeador
	 */
	public class BasicMapper
	{
		protected var mainManager:MainManager = null;
		
		/**
		 * 
		 */				
		public function BasicMapper()
		{			
			mainManager = MainManagerFactory.getMainManager();
		}

	}
}