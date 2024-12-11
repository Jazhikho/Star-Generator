using Godot;
using System;
using System.Collections.Generic;
using System.Linq;
using Generator;
using StellarLibraries;

public class HydrosphereGenerator
{
	private static readonly string[] HYDRO_MOD = new string[] 
	{ 
		"Arean", "Hebean", "Rockball" 
	};

	public float GenerateHydrosphere(Dictionary<string, object> typeData, int size, 
		string zone, string spectralType, int atmosphere)
	{
		int hydroMod = 0;
		
		// Apply modifiers based on planet class
		if ((string)typeData["Planet_class"] == "Rockball")
		{
			hydroMod += spectralType == "L" ? 1 : 0;
			hydroMod += zone == "Outer" ? 2 : (zone == "Epistellar" ? -2 : 0);
		}

		if ((string)typeData["Planet_class"] == "Arean")
		{
			hydroMod -= atmosphere == 1 ? 4 : 0;
		}

		// Calculate base hydrosphere
		int hydro = Utils.GetAttr(typeData, "Hydrosphere");
		
		// Apply size modifier if applicable
		if (HYDRO_MOD.Contains((string)typeData["Planet_class"]))
		{
			hydro += size;
		}

		hydro += hydroMod;
		
		// Adjust results based on planet type
		hydro = Utils.AdjustedResults(hydro, "Hydrosphere", typeData);
		
		return Math.Max(hydro, 0.0f);
	}
}
