using Godot;
using System;
using System.Collections.Generic;
using System.Linq;
using Generator;
using StellarLibraries;

public class BrownDwarfGenerator
{
	public BrownDwarfData GenerateBrownDwarf(float mass, float age)
	{
		var luminosity = CalculateBrownDwarfLuminosity(mass, age);
		var temperature = CalculateBrownDwarfTemperature(mass);
		var radius = CalculateBrownDwarfRadius(mass, age);
		
		return new BrownDwarfData
		{
			Luminosity = luminosity,
			Temperature = temperature,
			Radius = radius,
			SpectralType = DetermineSpectralType(temperature)
		};
	}

	private float CalculateBrownDwarfLuminosity(float mass, float age)
	{
		var brownDwarfData = (Dictionary<string, object>)StarsData.BROWN_DWARF;
		var parameters = (Dictionary<string, object>)brownDwarfData["PARAMETERS"];
		var multipliers = (Dictionary<string, object>)brownDwarfData["MULTIPLIERS"];
		var luminosityMultipliers = (Dictionary<string, object>)multipliers["LUMINOSITY"];

		var massKey = Math.Min(Mathf.Snapped(mass, 0.01f), 0.07f).ToString("0.00");
		var massParameters = (Dictionary<string, object>)parameters[massKey];
		var baseLuminosity = Convert.ToSingle(massParameters["Luminosity"]);
		var luminosityMult = float.Parse(Roll.Seek(luminosityMultipliers.ToDictionary(kvp => kvp.Key, kvp => Convert.ToInt32(kvp.Value)), (int)age));
		return baseLuminosity * luminosityMult;
	}

	private float CalculateBrownDwarfTemperature(float mass)
	{
		var brownDwarfData = (Dictionary<string, object>)StarsData.BROWN_DWARF;
		var temps = (Dictionary<string, int>)brownDwarfData["TEMPS"];
		return float.Parse(Roll.Seek(temps));
	}

	private float CalculateBrownDwarfRadius(float mass, float age)
	{
		var brownDwarfData = (Dictionary<string, object>)StarsData.BROWN_DWARF;
		var parameters = (Dictionary<string, Dictionary<string, float>>)brownDwarfData["PARAMETERS"];
		var multipliers = (Dictionary<string, Dictionary<string, int>>)brownDwarfData["MULTIPLIERS"];
		var radiusMultipliers = (Dictionary<string, int>)multipliers["RADIUS"];
		
		var massKey = Math.Min(Mathf.Snapped(mass, 0.01f), 0.07f).ToString("0.00");
		var baseRadius = parameters[massKey]["Radius"];
		var radiusMult = float.Parse(Roll.Seek(radiusMultipliers, (int)age));
		return Roll.Vary(baseRadius * radiusMult);
	}

	private string DetermineSpectralType(float temperature)
	{
		var brownDwarfData = (Dictionary<string, object>)StarsData.BROWN_DWARF;
		var spectralTypes = (Dictionary<string, int>)brownDwarfData["CLASS"];
		return Roll.Seek(spectralTypes, (int)temperature);
	}
}
