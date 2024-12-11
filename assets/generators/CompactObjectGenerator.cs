using Godot;
using System;
using System.Collections.Generic;
using Generator;
using StellarLibraries;

public class CompactObjectGenerator
{
	private static Random random = new Random();

	public Dictionary<string, object> GenerateWhiteDwarf(float mass)
	{
		var properties = CalculateWhiteDwarfProperties(mass);
		return new Dictionary<string, object>
		{
			{ "type", "White Dwarf" },
			{ "mass", mass },
			{ "temperature", properties["temperature"] },
			{ "luminosity", properties["luminosity"] },
			{ "radius", CalculateWhiteDwarfRadius(mass) }
		};
	}

	public Dictionary<string, object> GenerateNeutronStar(float mass)
	{
		var properties = CalculateNeutronStarProperties(mass);
		return new Dictionary<string, object>
		{
			{ "type", "Neutron Star" },
			{ "mass", mass },
			{ "temperature", properties["temperature"] },
			{ "luminosity", properties["luminosity"] },
			{ "radius", properties["radius"] },
			{ "magnetic_field", properties["magnetic_field"] },
			{ "rotation_period", properties["rotation_period"] }
		};
	}

	private Dictionary<string, float> CalculateWhiteDwarfProperties(float mass)
	{
		return new Dictionary<string, float>
		{
			{ "temperature", RandfRange(4000, 40000) },
			{ "luminosity", 0.001f * (float)Math.Pow(mass, -1.0 / 3.0) }
		};
	}

	private Dictionary<string, float> CalculateNeutronStarProperties(float mass)
	{
		return new Dictionary<string, float>
		{
			{ "temperature", RandfRange(1000000, 2000000) },
			{ "luminosity", 10.0f * mass },
			{ "radius", RandfRange(10, 15) },
			{ "magnetic_field", RandfRange(1e8f, 1e12f) },
			{ "rotation_period", RandfRange(0.001f, 1.0f) }
		};
	}

	private float CalculateWhiteDwarfRadius(float mass)
	{
		return (float)(0.01 / Math.Pow(mass, 1.0 / 3.0));
	}

	// Helper function to generate a random float within a range
	private float RandfRange(float min, float max)
	{
		return (float)(random.NextDouble() * (max - min) + min);
	}
}
