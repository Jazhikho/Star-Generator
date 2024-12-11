using Godot;
using System;
using System.Collections.Generic;
using StellarLibraries;

public class SystemBody
{
	private static readonly Dictionary<string, int> InnerOrbitTypes = new()
	{
		{ "Empty", 1 },
		{ "Asteroid Belt", 3 },
		{ "Dwarf", 5 },
		{ "Terrestrial", 9 },
		{ "Helian", 11 },
		{ "Jovian", 12 }
	};

	private static readonly Dictionary<string, int> OuterOrbitTypes = new()
	{
		{ "Empty", 1 },
		{ "Asteroid Belt", 2 },
		{ "Dwarf", 4 },
		{ "Terrestrial", 6 },
		{ "Helian", 9 },
		{ "Jovian", 12 }
	};

	public string DetermineBodyType(string zone)
	{
		var orbitType = zone == "inner" ? InnerOrbitTypes : OuterOrbitTypes;
		return Roll.Seek(orbitType, Roll.Dice(1, 12));
	}

	public Vector3 GenerateBodyPosition(float orbit)
	{
		float randomAngle = (float)(GD.Randf() * 2 * Math.PI);
		float randomInclination = (float)(GD.Randf() * Math.PI / 32);

		float x = orbit * (float)Math.Cos(randomAngle) * (float)Math.Cos(randomInclination);
		float y = orbit * (float)Math.Sin(randomAngle) * (float)Math.Cos(randomInclination);
		float z = orbit * (float)Math.Sin(randomInclination);

		return new Vector3(x, y, z);
	}
}
