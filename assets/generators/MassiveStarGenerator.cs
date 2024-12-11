using Godot;
using System;
using System.Collections.Generic;
using System.Linq;
using Generator;
using StellarLibraries;

public class MassiveStarGenerator
{
	private const float OB_A = -0.000524f;
	private const float OB_B = 0.14257f;
	private const float OB_C = 5.33689f;
	private string massStr;

	public MassiveStarData GenerateMassiveStar(float mass, string _massStr)
	{
		massStr = _massStr;
		var age = CalculateMassiveStarAge();
		var luminosity = CalculateMassiveStarLuminosity(mass);
		var temperature = CalculateMassiveStarTemperature(mass);
		var radius = CalculateMassiveStarRadius(mass);
		
		return new MassiveStarData
		{
			Age = age,
			Luminosity = luminosity,
			Temperature = temperature,
			Radius = radius,
			SpectralType = DetermineSpectralType(mass)
		};
	}

	private float CalculateMassiveStarAge()
	{
		var massiveStars = (Dictionary<string, Dictionary<string, object>>)StarsData.MASSIVE_STARS;
		var stellarMass = (Dictionary<string, object>)Roll.Search(massiveStars, massStr);
		var stableSpan = Convert.ToSingle(stellarMass["Stable Span"]);
		return Roll.Vary(Roll.Dice() * stableSpan / 18);
	}

	private float CalculateMassiveStarLuminosity(float mass)
	{
		return Mathf.Pow(mass, 3.5f);
	}

	private float CalculateMassiveStarTemperature(float mass)
	{
		if (mass > 16.0f)
			return 30000 + (mass - 16.0f) * 2000;
		else if (mass > 2.1f)
			return 10000 + (mass - 2.1f) * 2000;
		else
			return 7500 + (mass - 1.4f) * 2000;
	}

	private float CalculateMassiveStarRadius(float mass)
	{
		return Mathf.Pow(OB_A * mass, 2) + OB_B * mass + OB_C;
	}

	private string DetermineSpectralType(float mass)
	{
		if (mass > 16.0f)
			return "O";
		else if (mass > 2.1f)
			return "B";
		else
			return "A";
	}
}
