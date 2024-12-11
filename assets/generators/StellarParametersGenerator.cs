using System;
using System.Collections.Generic;
using System.Linq;
using Generator;
using StellarLibraries;

public class StellarParameters
{
	public Dictionary<string, object> GetStellarParameters(float mass, string type)
	{
		try
		{
			switch (type)
			{
				case "MAIN_SEQUENCE":
					return Roll.Search(StarsData.STELLAR_EVOLUTION, mass.ToString()) as Dictionary<string, object> 
						   ?? new Dictionary<string, object>();

				case "MASSIVE_STAR":
					return Roll.Search(StarsData.MASSIVE_STARS, Math.Round(mass).ToString()) as Dictionary<string, object> 
						   ?? new Dictionary<string, object>();

				case "BROWN_DWARF":
					var parameters = StarsData.BROWN_DWARF["PARAMETERS"] as Dictionary<string, Dictionary<string, double>>;
					var bdResult = Roll.Search(parameters, Math.Round(mass, 2).ToString());
					return bdResult?.ToDictionary(kvp => kvp.Key, kvp => (object)kvp.Value) 
						   ?? new Dictionary<string, object>();

				default:
					return new Dictionary<string, object>();
			}
		}
		catch (Exception e)
		{
			Console.WriteLine($"Error in GetStellarParameters: {e.Message}");
			return new Dictionary<string, object>();
		}
	}

	public Dictionary<string, object> GetEvolutionaryParameters(float mass, float age)
	{
		try
		{
			string massStr = Roll.Search(StarsData.STELLAR_VAR, (int)Math.Round(mass)).ToString();
			return Roll.Search(StarsData.STELLAR_EVOLUTION, massStr) as Dictionary<string, object> 
				   ?? new Dictionary<string, object>();
		}
		catch (Exception e)
		{
			Console.WriteLine($"Error in GetEvolutionaryParameters: {e.Message}");
			return new Dictionary<string, object>();
		}
	}
}
