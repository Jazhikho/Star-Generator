using Godot;
using System;
using System.Collections.Generic;
using System.Linq;
using Generator;
using StellarLibraries;

public class BiochemistryGenerator
{
	private static readonly string[] BIO_CHEM = new string[] 
	{
		"Arean", "Arid", "Jovian", "Tectonic", "Oceanic", "Promethean", "Snowball",
		"Panthalassic", "Vesperian"
	};

	public BiochemistryData GenerateBiochemistry(Dictionary<string, object> typeData, int size, 
		string zone, string spectralType, int luminosity, int atmosphere, float age)
	{
		var chemistry = typeData["Chemistry"];
		if (chemistry is int[] chemArray && chemArray.Length > 1 && chemArray[1] == 0)
		{
			return new BiochemistryData { Biosphere = "0", Chemistry = "None" };
		}

		// Generate chemistry
		int chemNum = Utils.GetAttr(typeData, "Chemistry");
		if (BIO_CHEM.Contains((string)typeData["Planet_class"]))
		{
			chemNum += GetChemMod(typeData, zone, spectralType, luminosity);
		}

		string chem;
		if (typeData.TryGetValue("Chemistry_results", out var chemistryResultsObj))
		{
			var chemistryResults = chemistryResultsObj as Dictionary<string, int>;
			if (chemistryResults != null)
			{
				chem = Roll.Seek(chemistryResults, chemNum);
			}
			else
			{
				// Handle case where Chemistry_results is not a Dictionary<string, int>
				chem = "Unknown";
			}
		}
		else
		{
			// Handle case where Chemistry_results is not present
			chem = "Default";
		}

		// Generate biosphere
		int bio = Utils.GetAttr(typeData, "Biosphere");
		if ((string)typeData["Planet_class"] == "Jovian")
		{
			bio += zone == "Inner" ? 2 : 0;
		}

		bio = BioResults(chem, bio, typeData, atmosphere, age);
		bio = Utils.AdjustedResults(bio, "Biosphere", typeData);
		
		if ((string)typeData["Planet_class"] == "Snowball")
		{
			bio += size;
		}

		return new BiochemistryData 
		{ 
			Biosphere = Math.Max(bio, 0).ToString(), 
			Chemistry = chem 
		};
	}

	private int GetChemMod(Dictionary<string, object> typeData, string zone, 
		string spectralType, int luminosity)
	{
		int mod = 0;
		string[] modClasses1 = new string[] 
			{ "Arid", "Oceanic", "Panthalassic", "Tectonic" };
		string[] modClasses2 = new string[] 
			{ "Jovian", "Promethean" };
		string[] modClasses3 = new string[] 
			{ "Arean", "Snowball" };

		if (modClasses1.Contains((string)typeData["Planet_class"]))
		{
			mod += zone == "Outer" ? 2 : 0;
			mod += (spectralType == "K" && luminosity == 5) ? 2 : 0;
			mod += (spectralType == "M" && luminosity == 5) ? 4 : 0;
			mod += luminosity == 7 ? 5 : 0;
		}
		if (modClasses2.Contains((string)typeData["Planet_class"]))
		{
			mod += zone == "Outer" ? 2 : (zone == "Epistellar" ? -2 : 0);
			mod += luminosity == 7 ? 2 : 0;
		}
		if (modClasses3.Contains((string)typeData["Planet_class"]))
		{
			mod += luminosity == 7 ? 2 : 0;
			mod += zone == "Outer" ? 2 : 0;
		}
		return mod;
	}

	private int BioResults(string chem, int bio, Dictionary<string, object> typeData, 
		int atmosphere, float age)
	{
		int finalCase = 4;
		int chemMod = PlanetsData.CHEM_MOD[chem];
		
		if ((string)typeData["Planet_class"] == "Arean")
		{
			if (atmosphere != 1 && atmosphere !=10)
			{
				return 0;
			}
			if (atmosphere == 1 && age >= bio + chemMod)
			{
				return 3;
			}
			else if (atmosphere == 1)
			{
				return 0;
			}
		}

		if ((string)typeData["Planet_class"] == "Snowball")
		{
			finalCase += 2;
		}

		if (age >= chemMod + bio)
		{
			return 1;
		}
		else if (age >= finalCase + chemMod)
		{
			return 2;
		}
		else
		{
			return 0;
		}
	}
}
