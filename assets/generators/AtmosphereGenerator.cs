using System;
using System.Collections.Generic;
using System.Linq;
using Generator;
using StellarLibraries;

public class AtmosphereGenerator
{
	private static readonly int[] TAINTED_ATMOSPHERES = new int[] { 2, 4, 6, 8, 10, 11, 12, 13, 15 };
	private static readonly Dictionary<string, int> ATMO_CLASS = new Dictionary<string, int> 
	{
		["Trace"] = 1,
		["Very Thin"] = 3,
		["Thin"] = 5,
		["Standard"] = 7,
		["Dense"] = 9,
		["Very Dense"] = 11,
		["Superdense"] = 16,
	};
	private static readonly string[] ADJ_ATMO = new string[] 
		{ "Arid", "Hebean", "Oceanic", "Promethean", "Tectonic", "Vesperian" };
	private const float DENSE_ATMO = 0.07f;

	public AtmosphereData GenerateAtmosphere(Dictionary<string, object> typeData, int size, 
		int luminosity, string spectralType)
	{
		int atmoMod = 0;
		
		if ((string)typeData["Planet_class"] == "Arean")
		{
			atmoMod -= luminosity == 3 ? 2 : 0;
		}
		if ((string)typeData["Planet_class"] == "Oceanic")
		{
			atmoMod -= luminosity == 4 ? 1 : 0;
			atmoMod -= (spectralType == "K" && luminosity == 5) ? 1 : 0;
			atmoMod -= (spectralType == "M" && luminosity == 5) ? 2 : 0;
			atmoMod -= luminosity == 7 ? 3 : 0;
		}
		
		int[] atmosData = (int[])typeData["Atmosphere"];
		int atmo = Roll.Dice(atmosData[0], atmosData[1], atmosData[2]);
		if (Array.Exists(ADJ_ATMO, element => element == (string)typeData["Planet_class"]))
		{
			atmo += size;
		}
		atmo += atmoMod;
		
		float atMass = GetAtmoMass(atmo);
		string atmoComp = GetAtmoComposition(atmo);
		
		return new AtmosphereData 
		{ 
			Atmosphere = atmo, 
			AtmoMass = atMass, 
			AtmoComposition = atmoComp 
		};
	}

	public float GetAtmoMass(int atmo)
	{
		if (atmo <= 1) return 0;
		return Roll.Vary(Roll.Dice() / 10f);
	}

	private string GetAtmoComposition(int atmo)
	{
		string taint = "";
		string toxicity = "";
		if (Array.Exists(TAINTED_ATMOSPHERES, element => element == atmo))
		{
			var taintedAtmo = PlanetsData.TAINTED_ATMO;
			taint = Roll.Seek(taintedAtmo);
			
			int toxRoll = atmo;
			if (taint == ": Low Oxygen" || taint == " High Oxygen")
			{
				if (Roll.Dice(2) > 7 && atmo > 7 && taint == " High Oxygen")
				{
					toxRoll += 9;
				}
			}
			else
			{
				toxRoll = Roll.Dice();
			}
			
			toxicity = Roll.Seek(PlanetsData.TOXICITY_LEVEL[taint], toxRoll);
		}
		
		string baseComposition = Roll.Seek(PlanetsData.ATMO_COMPOSITION, atmo);
		return $"{baseComposition}{taint}{toxicity}";
	}

	public AtmosphereData AdjustAtmoForBio(Dictionary<string, object> typeData, int biosphere, 
		string chemistry, int atmosphere)
	{
		int newAtmo = atmosphere;
		if ((string)typeData["Planet_class"] == "Oceanic")
		{
			if (chemistry != "Water")
			{
				var atmo2Results = (Dictionary<string, int[]>)typeData["Atmo2_results"];
				var newRoll = Roll.Search(atmo2Results, Roll.Dice(1));
				newAtmo = Roll.Dice(newRoll[0], newRoll[1], newRoll[2]);
			}
		}
		else if (biosphere < 3 || chemistry != "Water")
		{
			if (Array.Exists(new string[] {"Tectonic", "Vesperian"}, 
				element => element == (string)typeData["Planet_class"]) && 
				biosphere >= 3 && 
				(chemistry == "Sulfur" || chemistry == "Chlorine"))
			{
				newAtmo = 11;
			}
			else
			{
				newAtmo = 10;
			}
		}
		
		string atmoComp = GetAtmoComposition(newAtmo);
		float atMass = GetAtmoMass(newAtmo);
		
		return new AtmosphereData 
		{ 
			Atmosphere = newAtmo, 
			AtmoMass = atMass, 
			AtmoComposition = atmoComp 
		};
	}

	public TidalLockData AdjustForTidalLock(int atmosphere, float hydrology, float temperature)
	{
		string classType = Roll.Seek(ATMO_CLASS, atmosphere);
		
		var tidalAdjustDict = PlanetsData.TIDAL_ADJUST[classType];
		
		float day = Convert.ToSingle(tidalAdjustDict["Day"]);
		float night = Convert.ToSingle(tidalAdjustDict["Night"]);
		
		int newAtmo = atmosphere;
		if (newAtmo >= 3 && tidalAdjustDict.ContainsKey("Final_Atmo"))
		{
			newAtmo = Convert.ToInt32(tidalAdjustDict["Final_Atmo"]);
		}
		else if (newAtmo >= 5)
		{
			newAtmo -= 2;
		}
		
		float newHydrology = Math.Max(hydrology + Convert.ToSingle(tidalAdjustDict["Hydro_Penalty"]), 0.0f);
		var newTemperature = new Temperature 
		{ 
			Day = day * temperature, 
			Night = night * temperature 
		};
		
		return new TidalLockData 
		{ 
			Atmosphere = newAtmo, 
			Hydrology = newHydrology, 
			Temperature = newTemperature 
		};
	}
}
