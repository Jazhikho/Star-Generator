using Godot;
using System;
using System.Collections.Generic;
using System.Linq;
using Generator;
using StellarLibraries;

public class PlanetBasics
{
	private static readonly Dictionary<string, int> PLANET_SIZE_CATEGORY = new Dictionary<string, int>
	{
		{"Tiny", 4}, {"Small", 8}, {"Standard", 12}, 
		{"Large", 16}, {"Giant", 21}, {"Super-Giant", 26}
	};

	public PlanetBasicsData GenerateBasics(Dictionary<string, object> typeData, string zone)
	{
		int size = CalculatePlanetSize(typeData);
		string sizeCategory = Roll.Seek(PLANET_SIZE_CATEGORY, size);
		float density = CalculatePlanetDensity(sizeCategory, zone);
		float diameter = CalculatePlanetDiameter(size);
		float mass = CalculatePlanetMass(diameter, density);
		float gravity = CalculateGravity(density, diameter);
		
		return new PlanetBasicsData
		{
			Size = size,
			SizeCategory = sizeCategory,
			Density = density,
			Diameter = diameter,
			Mass = mass,
			Gravity = gravity
		};
	}

	private int CalculatePlanetSize(Dictionary<string, object> typeData)
	{
		int dice = typeData.GetValueOrDefault("Size_Dice", 1) is int d ? d : 1;
		int sides = typeData.GetValueOrDefault("Size_Sides", 8) is int s ? s : 8;
		int mod = typeData.GetValueOrDefault("Size_Mod", -1) is int m ? m : -1;
		return Roll.Dice(dice, sides, mod);
	}

	private float CalculatePlanetDensity(string sizeCategory, string zone)
	{
		var coreTypeData = (Dictionary<string, string>)PlanetsData.CORETYPE[sizeCategory];
		string coreType = coreTypeData[zone].ToString();
		
		var coreDensityData = (Dictionary<string, int>)PlanetsData.CORE_DENSITY[coreType];
		float initDensity = float.Parse(Roll.Seek(coreDensityData));
		return Roll.Vary(initDensity);
	}

	private float CalculatePlanetDiameter(int size)
	{
		float initDiameter = 0.1f * Mathf.Pow(1.24f, size);
		return Roll.Vary(initDiameter);
	}

	private float CalculatePlanetMass(float diameter, float density)
	{
		return density * Mathf.Pow(diameter, 3);
	}

	private float CalculateGravity(float density, float diameter)
	{
		return density * diameter;
	}
}
