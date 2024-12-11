using Godot;
using System;
using System.Collections.Generic;
using System.Linq;
using Generator;
using StellarLibraries;

public class ClimateCalculator
{
	private const float BLACKBODY = 278f;

	public ClimateData CalculateClimate(Dictionary<string, object> typeData, float orbit, 
		int luminosity, float atmoMass, Dictionary<string, object> parent)
	{
		var absorption = CalculateAbsorption(typeData);
		var greenhouse = CalculateGreenhouse(typeData);
		
		var blackbody = CalculateBlackbody(luminosity, orbit);
		var temp = blackbody * (absorption * (1 + (atmoMass * greenhouse)));
		
		if (parent != null && parent.Count > 0)
		{
			temp = AdjustTempForParent(temp, parent, orbit);
		}
		
		var climate = Roll.Seek(PlanetsData.CLIMATE, (int)temp);
		
		return new ClimateData
		{
			Blackbody = blackbody,
			Temperature = temp,
			Climate = climate,
			Absorption = absorption
		};
	}

	private float CalculateAbsorption(Dictionary<string, object> typeData)
	{
		var absorp = typeData["Absorption"];
		if (absorp is Dictionary<string, int> absorpDict)
		{
			absorp = Roll.Seek(absorpDict, Roll.Dice(2));
		}
		var absorpFloat = Convert.ToSingle(absorp);
		return Math.Max(Roll.Vary(absorpFloat), 1.0f);
	}

	private float CalculateGreenhouse(Dictionary<string, object> typeData)
	{
		var greenhouse = Convert.ToSingle(typeData["Greenhouse"]);
		if (greenhouse > 0)
		{
			greenhouse = Roll.Vary(greenhouse);
		}
		return greenhouse;
	}

	private float CalculateBlackbody(int luminosity, float orbit)
	{
		return BLACKBODY * (float)Math.Pow(luminosity, 0.25f) / (float)Math.Sqrt(orbit);
	}

	private float AdjustTempForParent(float temp, Dictionary<string, object> parent, float orbit)
	{
		const float TO_SUN = 0.000003003f;
		
		var parentBlackbody = Convert.ToSingle(parent.GetValueOrDefault("blackbody", 0f));
		var parentDiameter = Convert.ToSingle(parent.GetValueOrDefault("diameter", 0f));
		var parentMass = Convert.ToSingle(parent.GetValueOrDefault("mass", 0f));
		var parentAbsorption = Convert.ToSingle(parent.GetValueOrDefault("absorption", 0f));
		var parentEccentricity = Convert.ToSingle(parent.GetValueOrDefault("eccentricity", 0f));
		
		var tempFromPlanet = (float)Math.Pow(parentBlackbody * 
			((float)Math.Pow(parentDiameter * 0.5f, 2) / (float)Math.Pow(orbit, 2) * (1 - parentAbsorption)), 0.25f);
		var tempFromTidal = (float)Math.Pow(63.0f / 16.0f * (float)Math.PI * 
			((float)Math.Pow(parentMass, 3) * (float)Math.Pow(parentEccentricity, 2)) / 
			((float)Math.Pow(orbit, 7) * TO_SUN), 0.25f);
		
		return temp + tempFromPlanet + tempFromTidal;
	}
}
